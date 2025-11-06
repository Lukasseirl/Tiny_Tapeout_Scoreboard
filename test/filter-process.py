#!/usr/bin/env python3
import sys

def transform(value):
    # Common Cathode 7-Segment Mapping
    seg7_map = {
        0x7E: "0",
        0x30: "1", 
        0x6D: "2",
        0x79: "3",
        0x33: "4",
        0x5B: "5",
        0x5F: "6",
        0x70: "7",
        0x7F: "8",
        0x7B: "9",
        0x73: "P",  # 'P'
        0x00: "aus",  #
        0x77: "A",
        0x1F: "B",
        0x4E: "C",
        0x3D: "D",
        0x4F: "E",
        0x47: "F",
        0x00: " ",
        0x02: "-",
        0x80: "."
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
