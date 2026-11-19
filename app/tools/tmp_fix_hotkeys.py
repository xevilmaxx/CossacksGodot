import json
for p in ['app/config.json','app/shots/boost.json']:
    d=json.load(open(p, encoding='utf-8'))
    hk=d.setdefault('controls',{}).setdefault('hotkeys',{})
    hk['hold_fire']='D'
    hk['feuer_frei']='E'
    hk['engage']='V'
    hk['attack_ground']='R'
    hk['unload']='U'
    hk['select_all_peasants']='Ctrl+`'
    hk['select_idle_mines']='Ctrl+M'
    hk['add_same_type']='Shift+Z'
    hk['minimap_toggle']='Alt+M'
    b=hk.setdefault('build',{})
    b['dip']='D'
    b['bar18']='K'
    if 'rally' in hk:
        del hk['rally']
    json.dump(d,open(p,'w', encoding='utf-8'),indent=1)
    print(p,'updated',sorted(hk.keys()))
