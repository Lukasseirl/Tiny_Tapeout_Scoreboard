def seg7_decode(value):
    # 7-Segment Decoding Tabelle
    seg7_map = {
        0x3F: 0,  # 0
        0x06: 1,  # 1
        0x5B: 2,  # 2
        0x4F: 3,  # 3
        0x66: 4,  # 4
        0x6D: 5,  # 5
        0x7D: 6,  # 6
        0x07: 7,  # 7
        0x7F: 8,  # 8
        0x6F: 9,  # 9
    }
    return seg7_map.get(value, "E")
