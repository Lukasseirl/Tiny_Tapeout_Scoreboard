#!/usr/bin/env python3

def transform(value):
    # 7-Segment Mapping (common cathode - an Ihre Kodierung anpassen!)
    seg7_map = {
        0x3F: "0",  # 0111111
        0x06: "1",  # 0000110  
        0x5B: "2",  # 1011011
        0x4F: "3",  # 1001111
        0x66: "4",  # 1100110
        0x6D: "5",  # 1101101
        0x7D: "6",  # 1111101
        0x07: "7",  # 0000111
        0x7F: "8",  # 1111111
        0x6F: "9",  # 1101111
        0x77: "A",  # 1110111
        0x7C: "B",  # 1111100
        0x39: "C",  # 0111001
        0x5E: "D",  # 1011110
        0x79: "E",  # 1111001
        0x71: "F",  # 1110001
        0x00: " "   # aus
    }
    
    # Hex-String zu Integer konvertieren
    try:
        if value.startswith('0x'):
            int_val = int(value, 16)
        else:
            int_val = int(value)
        
        return seg7_map.get(int_val, "?")
    except:
        return "?"
