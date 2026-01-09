#!/usr/bin/env python3
import sys

def transform(value):
    seg7_map = {
        0b1000000: "0",
        0b1111001: "1",
        0b0100100: "2",
        0b0110000: "3",
        0b0011001: "4",
        0b0010010: "5",
        0b0000010: "6",
        0b1111000: "7",
        0b0000000: "8",
        0b0010000: "9",
        0b1111111: " ",
        0b0001100: "P",
        0b0111111: "-"
    }

    try:
        int_val = int(value, 2) if value.startswith("0b") else int(value, 16)
        int_val &= 0x7F  # 7-bit Common Anode
        return seg7_map.get(int_val, "?")
    except:
        return "?"

def main():
    fh_in = sys.stdin
    fh_out = sys.stdout

    while True:
        # incoming values have newline
        l = fh_in.readline().strip()
        if not l:
            return 0

        # outgoing filtered values must have a newline
        filtered_value = transform(l)
        fh_out.write("%s\n" % filtered_value)
        fh_out.flush()

if __name__ == '__main__':
    sys.exit(main())
