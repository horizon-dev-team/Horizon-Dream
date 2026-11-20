#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

BEGIN_INCLUDE = "// BEGIN_INCLUDE"
END_INCLUDE = "// END_INCLUDE"
INCLUDE_RE = re.compile(r'^\s*#include\s+"([^"]+)"\s*$')


def normalize_path(value: str) -> str:
    return value.replace('\\', '/').lower()


def normalize_include_path(path: str) -> str:
    return path.replace('/', '\\')


def normalize_include_path_line(line: str) -> str:
    stripped = line.rstrip('\r\n')
    match = INCLUDE_RE.match(stripped)
    if not match:
        return line

    original_path = match.group(1)
    normalized_path = normalize_include_path(original_path)
    prefix = stripped[:match.start(1)]
    suffix = stripped[match.end(1):]
    newline = line[len(stripped):]
    return f'{prefix}{normalized_path}{suffix}{newline}'


def sort_include_lines(lines):
    include_lines = []
    non_include_lines = []

    for line in lines:
        stripped = line.rstrip('\r\n')
        match = INCLUDE_RE.match(stripped)
        if match:
            normalized_line = normalize_include_path_line(line)
            include_lines.append((normalize_path(match.group(1)), normalized_line))
        else:
            non_include_lines.append(line)

    def cmp_paths(a, b):
        a0 = normalize_path(a).replace('/', '\\')
        b0 = normalize_path(b).replace('/', '\\')

        a_suffix = ''
        if '.' in a0:
            a_suffix = a0.split('.')[-1]
        b_suffix = ''
        if '.' in b0:
            b_suffix = b0.split('.')[-1]

        a_segments = a0.split('\\')
        b_segments = b0.split('\\')

        for a_seg, b_seg in zip(a_segments, b_segments):
            a_is_file = a_seg.endswith(('dm', 'dmf'))
            b_is_file = b_seg.endswith(('dm', 'dmf'))

            if a_is_file and not b_is_file:
                return -1
            if b_is_file and not a_is_file:
                return 1

            if a_seg != b_seg:
                if a_suffix != b_suffix:
                    return (a_suffix > b_suffix) - (a_suffix < b_suffix)
                return (a_seg > b_seg) - (a_seg < b_seg)

        return 0

    from functools import cmp_to_key
    sorted_includes = [
        line for _, line in sorted(include_lines, key=cmp_to_key(lambda x, y: cmp_paths(x[0], y[0])))
    ]
    return sorted_includes + non_include_lines


def sort_dme_file(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    original_lines = text.splitlines(keepends=True)

    output = []
    in_block = False
    current_block_lines = []

    for line in original_lines:
        stripped = line.strip()

        if stripped == BEGIN_INCLUDE:
            in_block = True
            output.append(line)
            continue

        if stripped == END_INCLUDE:
            in_block = False
            output.extend(sort_include_lines(current_block_lines))
            output.append(line)
            current_block_lines = []
            continue

        if in_block:
            current_block_lines.append(line)
        else:
            output.append(line)

    if not any(line.strip() == BEGIN_INCLUDE for line in original_lines):
        raise ValueError(f"Could not find the block {BEGIN_INCLUDE!r} in file {path}")

    if not any(line.strip() == END_INCLUDE for line in original_lines):
        raise ValueError(f"Could not find the block {END_INCLUDE!r} in file {path}")

    new_text = ''.join(output)
    if new_text != text:
        path.write_text(new_text, encoding='utf-8')
        return True

    return False


def parse_args():
    default_file = Path(__file__).resolve().parents[2] / '_horizon_dream.dme'

    parser = argparse.ArgumentParser(description='Sorts #include blocks in the project DME files.')
    parser.add_argument(
        'file',
        nargs='?',
        default=str(default_file),
        help='Path to the .dme file. Default: _horizon_dream.dme'
    )
    parser.add_argument('--all', action='store_true', help='Sort both: _horizon_dream.dme and _horizon_defines.dme')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    if args.all:
        base = Path(__file__).resolve().parents[2]
        files = [base / '_horizon_dream.dme', base / '_horizon_defines.dme']
        sorted_files = []
        for f in files:
            if not f.exists():
                continue
            changed = sort_dme_file(f)
            if changed:
                sorted_files.append(str(f.relative_to(base)))
        if sorted_files:
            print(f"Sorted: {', '.join(sorted_files)}")
        exit(0)
    else:
        file_path = Path(args.file).resolve()

        if not file_path.exists():
            raise FileNotFoundError(f'File not found: {file_path}')

        changed = sort_dme_file(file_path)
        if changed:
            print(f'Sorted: {file_path.name}')
