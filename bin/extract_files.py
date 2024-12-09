#!python3

import sys

def extract_files(input_lines):
    files = set()  # To store unique file names
    if len(input_lines) == 0:
        return
    is_file_list = ':' not in input_lines[0]
    if is_file_list:
        input_lines = map(lambda l: l.strip(), input_lines)
        # print(list(input_lines), "---")

        print("\0".join(input_lines), end='')
    else:
        first_line_number = None
        first_file = None
        for line in input_lines:
            # Split each line at the first colon and extract the file name
            parts = line.split(":")
            if len(parts) > 2 and parts[0].strip():
                if first_line_number is None:
                    first_line_number = int(parts[1])
                    first_file = parts[0].strip()
                files.add(parts[0].strip())

        # Print the unique file names as a null-terminated list
        if len(files) > 0:
            # Vim supports only +number for the first file:
            remaining_files = files - {first_file}
            print(first_file + f"\0+{first_line_number}\0" +
                  "\0".join(remaining_files),
                  end='')

if len(sys.argv) == 1:
    lines = sys.stdin.readlines()
else:
    file_name = sys.argv[1]
    try:
        with open(file_name, 'r') as file:
            lines = file.readlines()
    except FileNotFoundError:
        print(f"Error reading '{file_name}'.")
        exit(1)

extract_files(lines)

