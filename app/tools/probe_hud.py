import socket, json, time, sys
s = socket.create_connection(('127.0.0.1', int(sys.argv[1]) if len(sys.argv) > 1 else 8138), timeout=10)
buf = b''
def rpc(o):
    global buf
    s.settimeout(30)
    s.sendall((json.dumps(o) + chr(10)).encode())
    while b'\n' not in buf:
        buf += s.recv(65536)
    line, buf = buf.split(b'\n', 1)
    return json.loads(line.decode())
def center(bs, nm):
    for b in bs:
        if nm in str(b['text']):
            x, y, w, h = b['rect']
            return (x + w / 2, y + h / 2)
    return None
bs = rpc({'cmd': 'buttons'})['buttons']
c = center(bs, 'Skirmish - random map')
rpc({'cmd': 'click', 'x': c[0], 'y': c[1]})
time.sleep(1)
bs = rpc({'cmd': 'buttons'})['buttons']
c = center(bs, 'Start skirmish')
rpc({'cmd': 'click', 'x': c[0], 'y': c[1]})
t0 = time.time()
while time.time() - t0 < 120:
    if rpc({'cmd': 'state'})['has_game']:
        break
    time.sleep(2)
time.sleep(4)
d = rpc({'cmd': 'tree'})
for b in d['tree']:
    x, y, w, h = [round(v) for v in b['rect']]
    if 550 < y < 720 and b['class'] in ('PanelContainer', 'HBoxContainer', 'HFlowContainer', 'VBoxContainer', 'Label', 'Button'):
        print(b['class'], '|', repr(b['text'][:70]), [x, y, w, h])
print(rpc({'cmd': 'shot', 'path': 'C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/app/shots/hall_detail3.png'}))
print(rpc({'cmd': 'quit'}))
s.close()
