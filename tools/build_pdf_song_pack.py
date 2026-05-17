#!/usr/bin/env python3
"""
Build per-song PDF packs (SPK2) for faster random access while keeping compact size.

The script:
  1. Reads `<book>_pdf_manifest.json` to get song page ranges from `masterPath`.
  2. Extracts each song pages into a mini PDF.
  3. Gzip-compresses each song PDF.
  4. Writes one pack file: `assets/data/pdf/<folder>/<folder>_song_pack.bin`.
  5. Updates manifest with:
      - `packFile`
      - per-song `packIndex`
      - optional `packs` metadata list

Format SPK2 (little-endian):
  Header: 32 bytes
    magic[4] = "SPK2"
    version u32
    entry_count u32
    index_offset u32
    reserved[16]
  Index: entry_count * 40 bytes
    index u32
    start_page u32
    end_page u32
    compressed_size u32
    uncompressed_size u32
    data_offset u32
    reserved[16]
  Data:
    concatenated gzip(song_pdf_bytes)
"""

import argparse
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


HEADER_SIZE = 32
INDEX_ENTRY_SIZE = 40
BOOK_TO_FOLDER = {
    "KR": "kr",
    "HYMNE": "hymne",
    "MDR": "mdr",
    "ASM-I": "asm_i",
    "ASM-M": "asm_m",
    "ASM-P": "asm_p",
}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--book",
        required=True,
        help="Book code: KR, HYMNE, MDR, ASM-I, ASM-M, ASM-P",
    )
    parser.add_argument(
        "--compress-level",
        type=int,
        default=9,
        help="gzip compression level (1-9). Default: 9",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    book_code = args.book.upper()
    folder = BOOK_TO_FOLDER.get(book_code)
    if folder is None:
        print(f"ERROR: Unsupported book code: {book_code}")
        sys.exit(1)

    repo = Path(__file__).resolve().parent.parent
    manifest_path = repo / "assets" / "data" / "index" / f"{folder}_pdf_manifest.json"
    if not manifest_path.exists():
        print(f"ERROR: Manifest not found: {manifest_path}")
        sys.exit(1)

    with open(manifest_path, encoding="utf-8") as f:
        manifest = json.load(f)

    master_path_rel = manifest.get("masterPath")
    if not master_path_rel:
        print(f"ERROR: masterPath missing in manifest: {manifest_path}")
        sys.exit(1)

    master_path = repo / master_path_rel
    if not master_path.exists():
        print(f"ERROR: Master PDF not found: {master_path}")
        sys.exit(1)

    songs = manifest.get("songs")
    if not isinstance(songs, dict) or not songs:
        print(f"ERROR: songs map missing/empty in manifest: {manifest_path}")
        sys.exit(1)

    # Sort by start page for deterministic pack index assignment.
    ordered = sorted(
        songs.items(),
        key=lambda item: (item[1].get("startPage", 0), item[0]),
    )

    print(f"Reading master: {master_path_rel}")
    reader = PdfReader(str(master_path))
    total_pages = len(reader.pages)
    print(f"Total pages: {total_pages}")

    output_rel = f"assets/data/pdf/{folder}/{folder}_song_pack.bin"
    output_path = repo / output_rel
    output_path.parent.mkdir(parents=True, exist_ok=True)

    data_offset = HEADER_SIZE + len(ordered) * INDEX_ENTRY_SIZE
    index_rows = []
    data_blocks = []
    packs_meta = []

    for pack_index, (song_num, entry) in enumerate(ordered):
        start_page = int(entry.get("startPage", 0))
        page_count = int(entry.get("pageCount", 1))
        if start_page <= 0 or page_count <= 0:
            print(f"Skipping invalid entry {song_num}: start={start_page}, count={page_count}")
            continue

        end_page = start_page + page_count - 1
        if end_page > total_pages:
            print(f"Skipping out-of-range entry {song_num}: end={end_page} > {total_pages}")
            continue

        writer = PdfWriter()
        for page_num in range(start_page - 1, end_page):
            writer.add_page(reader.pages[page_num])

        buffer = io.BytesIO()
        writer.write(buffer)
        pdf_bytes = buffer.getvalue()
        compressed = gzip.compress(pdf_bytes, compresslevel=max(1, min(9, args.compress_level)))

        index_rows.append(
            {
                "index": pack_index,
                "startPage": start_page,
                "endPage": end_page,
                "compressedSize": len(compressed),
                "uncompressedSize": len(pdf_bytes),
                "dataOffset": data_offset,
            }
        )
        packs_meta.append(
            {
                "index": pack_index,
                "songNumber": song_num,
                "startPage": start_page,
                "endPage": end_page,
                "pageCount": page_count,
                "compressedSize": len(compressed),
                "uncompressedSize": len(pdf_bytes),
            }
        )
        data_blocks.append(compressed)
        data_offset += len(compressed)

        entry["packIndex"] = pack_index

        ratio = len(compressed) / max(1, len(pdf_bytes)) * 100.0
        print(
            f"  {song_num}: pages {start_page}-{end_page} | "
            f"{len(pdf_bytes):,} -> {len(compressed):,} ({ratio:.1f}%)"
        )

    with open(output_path, "wb") as f:
        f.write(b"SPK2")
        f.write(struct.pack("<I", 1))
        f.write(struct.pack("<I", len(index_rows)))
        f.write(struct.pack("<I", HEADER_SIZE))
        f.write(b"\x00" * 16)

        for row in index_rows:
            f.write(struct.pack("<I", row["index"]))
            f.write(struct.pack("<I", row["startPage"]))
            f.write(struct.pack("<I", row["endPage"]))
            f.write(struct.pack("<I", row["compressedSize"]))
            f.write(struct.pack("<I", row["uncompressedSize"]))
            f.write(struct.pack("<I", row["dataOffset"]))
            f.write(b"\x00" * 16)

        for block in data_blocks:
            f.write(block)

    manifest["packFile"] = output_rel
    manifest["packs"] = packs_meta

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    total_uncompressed = sum(row["uncompressedSize"] for row in index_rows)
    total_compressed = sum(row["compressedSize"] for row in index_rows)
    overall_ratio = (total_compressed / max(1, total_uncompressed)) * 100.0

    print("\nTotals:")
    print(f"  Entries:       {len(index_rows)}")
    print(f"  Uncompressed:  {total_uncompressed:,} bytes")
    print(f"  Compressed:    {total_compressed:,} bytes")
    print(f"  Ratio:         {overall_ratio:.1f}%")
    print(f"\nUpdated manifest: {manifest_path}")
    print(f"Created pack:     {output_path}")


if __name__ == "__main__":
    main()

