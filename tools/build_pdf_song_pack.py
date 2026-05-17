#!/usr/bin/env python3
"""
Build per-song PDF packs (SPK2) for faster random access while keeping compact size.

The script:
  1. Reads `<book>_pdf_manifest.json` to get song page ranges from `masterPath`.
  2. Extracts each song pages into a mini PDF.
  3. Gzip-compresses each song PDF.
  4. Writes one or more pack shard files:
      `assets/data/pdf/<folder>/<folder>_song_pack(_NNN).bin`
  5. Updates manifest with:
      - `packFiles` (shard file list)
      - `packFile` (first shard for backwards compatibility)
      - per-song `packFileIndex`, `packIndex`, and `packFile`
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
    parser.add_argument(
        "--max-pack-bytes",
        type=int,
        default=64 * 1024 * 1024,
        help="Maximum bytes per output pack shard (default: 64 MiB).",
    )
    return parser.parse_args()


def _pack_header(entry_count: int) -> bytes:
    return b"".join(
        [
            b"SPK2",
            struct.pack("<I", 1),
            struct.pack("<I", entry_count),
            struct.pack("<I", HEADER_SIZE),
            b"\x00" * 16,
        ]
    )


def _pack_index_row(row: dict) -> bytes:
    return b"".join(
        [
            struct.pack("<I", row["index"]),
            struct.pack("<I", row["startPage"]),
            struct.pack("<I", row["endPage"]),
            struct.pack("<I", row["compressedSize"]),
            struct.pack("<I", row["uncompressedSize"]),
            struct.pack("<I", row["dataOffset"]),
            b"\x00" * 16,
        ]
    )


def _write_pack_file(path: Path, rows: list[dict], blocks: list[bytes]) -> None:
    with open(path, "wb") as f:
        f.write(_pack_header(len(rows)))
        for row in rows:
            f.write(_pack_index_row(row))
        for block in blocks:
            f.write(block)


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

    output_dir = repo / "assets" / "data" / "pdf" / folder
    output_dir.mkdir(parents=True, exist_ok=True)
    max_pack_bytes = max(args.max_pack_bytes, HEADER_SIZE + INDEX_ENTRY_SIZE + 1)

    shard_index_rows = [[]]
    shard_blocks = [[]]
    shard_data_offset = [HEADER_SIZE]
    shard_total_bytes = [HEADER_SIZE]
    shard_pack_paths = []
    packs_meta = []
    total_uncompressed = 0
    total_compressed = 0

    for song_num, entry in ordered:
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

        compressed_size = len(compressed)
        uncompressed_size = len(pdf_bytes)
        total_compressed += compressed_size
        total_uncompressed += uncompressed_size

        # Ensure each shard stays below max_pack_bytes whenever possible.
        current_shard = len(shard_index_rows) - 1
        projected_entries = len(shard_index_rows[current_shard]) + 1
        projected_size = (
            HEADER_SIZE
            + (projected_entries * INDEX_ENTRY_SIZE)
            + sum(len(block) for block in shard_blocks[current_shard])
            + compressed_size
        )
        if projected_size > max_pack_bytes and shard_index_rows[current_shard]:
            shard_index_rows.append([])
            shard_blocks.append([])
            shard_data_offset.append(HEADER_SIZE)
            shard_total_bytes.append(HEADER_SIZE)
            current_shard += 1

        local_index = len(shard_index_rows[current_shard])
        data_offset = HEADER_SIZE + ((local_index + 1) * INDEX_ENTRY_SIZE)
        if local_index > 0:
            data_offset = shard_data_offset[current_shard]

        row = {
            "index": local_index,
            "startPage": start_page,
            "endPage": end_page,
            "compressedSize": compressed_size,
            "uncompressedSize": uncompressed_size,
            "dataOffset": data_offset,
        }
        shard_index_rows[current_shard].append(row)
        shard_blocks[current_shard].append(compressed)
        shard_data_offset[current_shard] = data_offset + compressed_size
        shard_total_bytes[current_shard] = (
            HEADER_SIZE
            + (len(shard_index_rows[current_shard]) * INDEX_ENTRY_SIZE)
            + sum(len(block) for block in shard_blocks[current_shard])
        )

        packs_meta.append(
            {
                "songNumber": song_num,
                "packFileIndex": current_shard,
                "packIndex": local_index,
                "startPage": start_page,
                "endPage": end_page,
                "pageCount": page_count,
                "compressedSize": compressed_size,
                "uncompressedSize": uncompressed_size,
            }
        )

        entry["packFileIndex"] = current_shard
        entry["packIndex"] = local_index

        ratio = compressed_size / max(1, uncompressed_size) * 100.0
        print(
            f"  {song_num}: shard={current_shard} idx={local_index} pages {start_page}-{end_page} | "
            f"{uncompressed_size:,} -> {compressed_size:,} ({ratio:.1f}%)"
        )

    shard_count = len(shard_index_rows)
    for i in range(shard_count):
        if shard_count == 1:
            rel = f"assets/data/pdf/{folder}/{folder}_song_pack.bin"
        else:
            rel = f"assets/data/pdf/{folder}/{folder}_song_pack_{i:03d}.bin"
        shard_pack_paths.append(rel)
        _write_pack_file(repo / rel, shard_index_rows[i], shard_blocks[i])

    for _, entry in ordered:
        shard_idx = entry.get("packFileIndex")
        if isinstance(shard_idx, int) and 0 <= shard_idx < len(shard_pack_paths):
            entry["packFile"] = shard_pack_paths[shard_idx]

    # Remove old shards that are no longer part of the output set.
    for existing in output_dir.glob(f"{folder}_song_pack*.bin"):
        rel_existing = str(existing.relative_to(repo)).replace("\\", "/")
        if rel_existing not in shard_pack_paths:
            existing.unlink(missing_ok=True)

    manifest["packFile"] = shard_pack_paths[0] if shard_pack_paths else None
    manifest["packFiles"] = shard_pack_paths
    manifest["packs"] = packs_meta

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    overall_ratio = (total_compressed / max(1, total_uncompressed)) * 100.0

    print("\nTotals:")
    print(f"  Entries:       {len(packs_meta)}")
    print(f"  Shards:        {len(shard_pack_paths)}")
    print(f"  Uncompressed:  {total_uncompressed:,} bytes")
    print(f"  Compressed:    {total_compressed:,} bytes")
    print(f"  Ratio:         {overall_ratio:.1f}%")
    print(f"\nUpdated manifest: {manifest_path}")
    for rel in shard_pack_paths:
        print(f"Created pack:     {repo / rel}")


if __name__ == "__main__":
    main()
