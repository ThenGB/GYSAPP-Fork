#!/usr/bin/env python3
"""
General optimization script: Chunk all master PDFs into smaller compressed chunks 
and update manifests.
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
TARGET_PAGES_PER_CHUNK = 60

# File format (little-endian):
#   Header   (32 bytes)
#   Index    (N * 40 bytes)
#   Data     (concatenated gzip chunks)
HEADER_SIZE = 32
INDEX_ENTRY_SIZE = 40

BOOKS = [
    {
        "name": "kr",
        "master": "assets/data/pdf/kr/KR.pdf",
        "manifest": "assets/data/index/kr_pdf_manifest.json",
        "output": "assets/data/pdf/kr/kr_chunks.bin"
    },
    {
        "name": "mdr",
        "master": "assets/data/pdf/mdr/MDR.pdf",
        "manifest": "assets/data/index/mdr_pdf_manifest.json",
        "output": "assets/data/pdf/mdr/mdr_chunks.bin"
    },
    {
        "name": "asm_i",
        "master": "assets/data/pdf/asm_i/ASM-I.pdf",
        "manifest": "assets/data/index/asm_i_pdf_manifest.json",
        "output": "assets/data/pdf/asm_i/asm_i_chunks.bin"
    },
    {
        "name": "asm_m",
        "master": "assets/data/pdf/asm_m/ASM-M.pdf",
        "manifest": "assets/data/index/asm_m_pdf_manifest.json",
        "output": "assets/data/pdf/asm_m/asm_m_chunks.bin"
    },
    {
        "name": "asm_p",
        "master": "assets/data/pdf/asm_p/ASM-P.pdf",
        "manifest": "assets/data/index/asm_p_pdf_manifest.json",
        "output": "assets/data/pdf/asm_p/asm_p_chunks.bin"
    }
]

def process_book(book):
    master_path = REPO / book["master"]
    manifest_path = REPO / book["manifest"]
    output_path = REPO / book["output"]

    if not master_path.exists():
        print(f"Skipping {book['name']}: Master PDF not found at {master_path}")
        return

    print(f"\nProcessing {book['name']} ({master_path}) ...")
    reader = PdfReader(str(master_path))
    total_pages = len(reader.pages)
    print(f"  Total pages: {total_pages}")

    with open(manifest_path, encoding="utf-8") as f:
        manifest = json.load(f)

    songs = sorted(manifest["songs"].items(), key=lambda x: x[1]["startPage"])

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

    print(f"  Created {len(chunks)} chunks")

    manifest["chunkFile"] = book["output"]
    manifest["chunks"] = []

    chunk_metas = []
    chunk_data_blocks = []
    data_offset = HEADER_SIZE + len(chunks) * INDEX_ENTRY_SIZE

    for chunk_index, chunk_songs in enumerate(chunks):
        first_start = chunk_songs[0][1]["startPage"]
        last = chunk_songs[-1][1]
        last_end = last["startPage"] + last.get("pageCount", 1) - 1

        writer = PdfWriter()
        for page_num in range(first_start - 1, last_end):
            # Clamp to total pages
            if page_num < 0 or page_num >= total_pages:
                continue
            writer.add_page(reader.pages[page_num])

        if len(writer.pages) == 0:
            continue

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

        for song_num, entry in chunk_songs:
            entry["chunkIndex"] = chunk_index
            entry["chunkRelativeStart"] = entry["startPage"] - first_start + 1

    # Write binary file
    with open(output_path, "wb") as f:
        f.write(b"CHNK")
        f.write(struct.pack("<I", 1))
        f.write(struct.pack("<I", len(chunk_metas)))
        f.write(struct.pack("<I", HEADER_SIZE))
        f.write(b"\x00" * 16)

        for meta in chunk_metas:
            f.write(struct.pack("<I", meta["index"]))
            f.write(struct.pack("<I", meta["startPage"]))
            f.write(struct.pack("<I", meta["endPage"]))
            f.write(struct.pack("<I", meta["compressedSize"]))
            f.write(struct.pack("<I", meta["uncompressedSize"]))
            f.write(struct.pack("<I", meta["dataOffset"]))
            f.write(b"\x00" * 16)

        for block in chunk_data_blocks:
            f.write(block)

    reader.close()

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    print(f"  Done! Updated {manifest_path} and created {output_path}")

def main():
    for book in BOOKS:
        try:
            process_book(book)
        except Exception as e:
            print(f"Error processing {book['name']}: {e}")

if __name__ == "__main__":
    main()
