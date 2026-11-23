import os, struct
root = r"C:\Games\Cossacks 3\data"
odd = []
count = 0
for dp, _, fs in os.walk(root):
    for f in fs:
        if not f.lower().endswith(".dds"):
            continue
        p = os.path.join(dp, f)
        try:
            with open(p, "rb") as fh:
                h = fh.read(128)
            if len(h) < 128 or h[:4] != b"DDS ":
                continue
            height, width = struct.unpack_from("<II", h, 12)
            count += 1
            if width % 4 or height % 4:
                odd.append((p, width, height))
        except OSError:
            pass
print("dds_headers_scanned:", count)
print("non_multiple_of_4:", len(odd))
for p, w, h in odd[:15]:
    print(" ", w, "x", h, p)
