import json
from pathlib import Path

BAD_CHARS = set("ÃÂâðåæçèéäï")


def cjk_count(value: str) -> int:
    return sum(1 for ch in value if "\u3400" <= ch <= "\u9fff")


def badness(value: str) -> int:
    score = sum(1 for ch in value if ch in BAD_CHARS)
    score += sum(2 for ch in value if 0x80 <= ord(ch) <= 0x9F)
    score += value.count("�") * 4
    return score


def reconstruct_utf8_bytes(value: str) -> bytes:
    data = bytearray()
    for ch in value:
        code = ord(ch)
        if code <= 0xFF:
            data.append(code)
            continue
        # UTF-8 bytes that were decoded as Windows-1252 often become symbols
        # such as €, ™, œ, Š or Ÿ. Map those glyphs back to their original byte.
        encoded = ch.encode("cp1252")
        if len(encoded) != 1:
            raise UnicodeEncodeError("cp1252", ch, 0, 1, "not a single byte")
        data.extend(encoded)
    return bytes(data)


def repair_string(value: str) -> str:
    current = value
    for _ in range(3):
        try:
            candidate = reconstruct_utf8_bytes(current).decode("utf-8")
        except (UnicodeEncodeError, UnicodeDecodeError):
            break

        improves_cjk = cjk_count(candidate) > cjk_count(current)
        improves_badness = badness(candidate) < badness(current)
        if not (improves_cjk or improves_badness):
            break
        current = candidate
    return current


def repair(value):
    if isinstance(value, str):
        return repair_string(value)
    if isinstance(value, list):
        return [repair(item) for item in value]
    if isinstance(value, dict):
        return {key: repair(item) for key, item in value.items()}
    return value


for path in sorted(Path("assets/translations").glob("*.json")):
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    repaired = repair(data)
    path.write_text(
        json.dumps(repaired, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
