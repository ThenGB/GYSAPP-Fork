#!/usr/bin/env python3
"""
Build script: Chunk hymne_master.pdf into smaller compressed chunks stored in a
lightweight custom binary container (header + index + concatenated gzip data).

This script:
  1. Reads the existing hymne_master.pdf and hymne_pdf_manifest.json
  2. Splits the master into chunks (~60 pages each), ensuring no song is split
  3. Compresses each chunk with gzip
  4. Writes assets/data/pdf/hymne/hymne_chunks.bin
  5. Updates hymne_pdf_manifest.json with chunk metadata

Run before building the Flutter app:
    python tools/build_pdf_chunks.py

Dependencies:
    pip install pypdf
"""

import gzip
import io
import json
import struct
import sys
from pathlib import Path

try:
    from pypdf import PdfReader, PdfWriter
except ImportError:
    print("ERROR: pypdf is required. Install it with: pip install pypdf")
    sys.exit(1)

REPO = Path(__file__).resolve().parent.parent
MASTER_PDF = REPO / "assets" / "data" / "pdf" / "hymne" / "hymne_master.pdf"
MANIFEST = REPO / "assets" / "data" / "index" / "hymne_pdf_manifest.json"
OUTPUT = REPO / "assets" / "data" / "pdf" / "hymne" / "hymne_chunks.bin"

TARGET_PAGES_PER_CHUNK = 60

# File format (little-endian):
#   Header   (32 bytes)
#   Index    (N * 40 bytes)
#   Data     (concatenated gzip chunks)
HEADER_SIZE = 32
INDEX_ENTRY_SIZE = 40


def main():
    if not MASTER_PDF.exists():
        print(f"ERROR: Master PDF not found: {MASTER_PDF}")
        sys.exit(1)

    print(f"Reading {MASTER_PDF} ...")
    reader = PdfReader(str(MASTER_PDF))
    total_pages = len(reader.pages)
    print(f"Total pages: {total_pages}")

    with open(MANIFEST, encoding="utf-8") as f:
        manifest = json.load(f)

    songs = sorted(manifest["songs"].items(), key=lambda x: x[1]["startPage"])

    # Group songs into chunks, never splitting a multi-page song
    chunks = []
    current_chunk = []
    current_pages = 0
    for song_num, entry in songs:
        page_count = entry.get("pageCount", 1)
        if current_pages + page_count > TARGET_PAGES_PER_CHUNK and current_chunk:
            chunks.append(current_chunk)
            current_chunk = [(song_num, entry)]
            current_pages = page_count
        else:
            current_chunk.append((song_num, entry))
            current_pages += page_count
    if current_chunk:
        chunks.append(current_chunk)

    print(f"Created {len(chunks)} chunks (target ~{TARGET_PAGES_PER_CHUNK} pages each)")

    manifest["chunkFile"] = "assets/data/pdf/hymne/hymne_chunks.bin"
    manifest["chunks"] = []

    # Build chunk data
    chunk_metas = []
    chunk_data_blocks = []
    data_offset = HEADER_SIZE + len(chunks) * INDEX_ENTRY_SIZE

    for chunk_index, chunk_songs in enumerate(chunks):
        first_start = chunk_songs[0][1]["startPage"]
        last = chunk_songs[-1][1]
        last_end = last["startPage"] + last.get("pageCount", 1) - 1

        writer = PdfWriter()
        for page_num in range(first_start - 1, last_end):
            writer.add_page(reader.pages[page_num])

        buffer = io.BytesIO()
        writer.write(buffer)
        pdf_bytes = buffer.getvalue()
        compressed = gzip.compress(pdf_bytes, compresslevel=9)

        chunk_metas.append({
            "index": chunk_index,
            "startPage": first_start,
            "endPage": last_end,
            "compressedSize": len(compressed),
            "uncompressedSize": len(pdf_bytes),
            "dataOffset": data_offset,
        })
        manifest["chunks"].append({
            "index": chunk_index,
            "startPage": first_start,
            "endPage": last_end,
            "compressedSize": len(compressed),
            "uncompressedSize": len(pdf_bytes),
        })
        chunk_data_blocks.append(compressed)
        data_offset += len(compressed)

        # Update each song entry inside the chunk
        for song_num, entry in chunk_songs:
            entry["chunkIndex"] = chunk_index
            entry["chunkRelativeStart"] = entry["startPage"] - first_start + 1

        ratio = len(compressed) / len(pdf_bytes) * 100
        print(
            f"  Chunk {chunk_index}: master pages {first_start}-{last_end} "
            f"({len(pdf_bytes):,} bytes -> {len(compressed):,} bytes, {ratio:.1f}%)"
        )

    # Write binary file
    with open(OUTPUT, "wb") as f:
        # Header
        f.write(b"CHNK")                         # magic
        f.write(struct.pack("<I", 1))             # version
        f.write(struct.pack("<I", len(chunks)))   # chunk_count
        f.write(struct.pack("<I", HEADER_SIZE))  # index_offset
        f.write(b"\x00" * 16)                     # reserved

        # Index
        for meta in chunk_metas:
            f.write(struct.pack("<I", meta["index"]))
            f.write(struct.pack("<I", meta["startPage"]))
            f.write(struct.pack("<I", meta["endPage"]))
            f.write(struct.pack("<I", meta["compressedSize"]))
            f.write(struct.pack("<I", meta["uncompressedSize"]))
            f.write(struct.pack("<I", meta["dataOffset"]))
            f.write(b"\x00" * 16)  # reserved

        # Data
        for block in chunk_data_blocks:
            f.write(block)

    reader.close()

    # Write updated manifest
    with open(MANIFEST, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    total_uncompressed = sum(c["uncompressedSize"] for c in manifest["chunks"])
    total_compressed = sum(c["compressedSize"] for c in manifest["chunks"])
    print("\nTotals:")
    print(f"  Uncompressed: {total_uncompressed:,} bytes")
    print(f"  Compressed:   {total_compressed:,} bytes")
    print(f"  Ratio:        {total_compressed / total_uncompressed * 100:.1f}%")
    print(f"\nUpdated {MANIFEST}")
    print(f"Created {OUTPUT}")


if __name__ == "__main__":
    main()
