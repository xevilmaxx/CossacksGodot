import os, glob
for p in glob.glob('app/assets/models/anim*/*.png.import'):
    t=open(p, encoding='utf-8', errors='ignore').read()
    if 'compress/mode=0' in t:
        open(p,'w',encoding='utf-8').write(t.replace('compress/mode=0','compress/mode=2'))
        print('vram',p)
print('done')
