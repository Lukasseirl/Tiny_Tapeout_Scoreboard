#!/usr/bin/env python3
import sys

def transform(value):
    # Common Anode 7-Segment Mapping
    seg7_map = {
        0x81: "0",
        0xCF: "1",
        0x92: "2",
        0x86: "3",
        0xCC: "4",
        0xA4: "5",
        0xA0: "6",
        0x8F: "7",
        0x80: "8",
        0x84: "9",
        0x8C: "P",   # 'P'
        0xFF: "aus",
        0x88: "A",
        0xE0: "B",
        0xB1: "C",
        0xC2: "D",
        0xB0: "E",
        0xB8: "F",
        0xFF: " ",
        0xFD: "-",
        0x7F: "."
    }
    
    try:
        # Hex-String zu Integer konvertieren
        if value.startswith('0x'):
            int_val = int(value, 16)
        else:
            # Falls ohne 0x-Präfix
            int_val = int(value, 16) if all(c in '0123456789ABCDEFabcdef' for c in value) else int(value)
        
        # Übersetzung
        return seg7_map.get(int_val, "?")
        
    except (ValueError, TypeError):
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
