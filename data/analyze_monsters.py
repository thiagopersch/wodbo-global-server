#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Analisador de Monstros - Server Tibia (v2)
Extrai dados, calcula nível recomendado (faixas de 10 em 10 até 1000+),
e gera Tabela: Nome | HP | EXP | Speed | Mana (ordem alfabética por faixa).
"""

import xml.etree.ElementTree as ET
import os
import math
import shutil
from datetime import datetime

MONSTER_DIR = r'C:\Users\thiag\Projetos\server-tibia\data\monster'
OUTPUT_FILE = r'C:\Users\thiag\Projetos\server-tibia\data\monster_recommendation.txt'

def safe_int(val, default=0):
    try:
        return int(val)
    except (ValueError, TypeError):
        return default

def get_level_band(score):
    bands = [
        (0, 1, 50), (600, 51, 100), (3800, 101, 150), (14000, 151, 200),
        (45000, 201, 250), (115000, 251, 300), (265000, 301, 350),
        (570000, 351, 400), (1150000, 401, 450), (2200000, 451, 500),
        (3600000, 501, 550), (5500000, 551, 600), (8000000, 601, 650),
        (11000000, 651, 700), (15000000, 701, 750), (20000000, 751, 800),
        (26000000, 801, 850), (33000000, 851, 900), (42000000, 901, 950),
        (53000000, 951, 1000),
    ]
    lo, hi = 1, 50
    for threshold, band_lo, band_hi in bands:
        if score < threshold:
            break
        lo, hi = band_lo, band_hi
    return lo, hi

def parse_monster(filepath):
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
    except Exception:
        return None

    if root.tag != 'monster':
        return None

    name = root.get('name', 'Unknown')
    exp = safe_int(root.get('experience', '0'))
    speed = safe_int(root.get('speed', '100'))
    manacost = safe_int(root.get('manacost', '0'))

    health_el = root.find('health')
    hp = safe_int(health_el.get('max', '0') if health_el is not None else '0')

    attacks_el = root.find('attacks')
    melee_skill = melee_attack = max_spell_damage = 0
    attack_types = set()
    has_speed_debuff = has_mana_drain = has_life_drain = False

    if attacks_el is not None:
        for attack in attacks_el.findall('attack'):
            atk_name = attack.get('name', '')
            if atk_name == 'melee':
                melee_skill = max(melee_skill, safe_int(attack.get('skill', '0')))
                melee_attack = max(melee_attack, safe_int(attack.get('attack', '0')))
                attack_types.add('physical')
            else:
                attack_types.add(atk_name)
                min_dmg = abs(safe_int(attack.get('min', '0')))
                max_dmg = abs(safe_int(attack.get('max', '0')))
                max_spell_damage = max(max_spell_damage, max(min_dmg, max_dmg))
                if atk_name == 'speed': has_speed_debuff = True
                elif atk_name == 'manadrain': has_mana_drain = True
                elif atk_name == 'lifedrain': has_life_drain = True

    if melee_skill > 0 and melee_attack > 0:
        max_melee_damage = int(melee_attack * (0.5 + melee_skill / 30))
    else:
        max_melee_damage = 0
    max_total_damage = max(max_melee_damage, max_spell_damage)

    defenses_el = root.find('defenses')
    armor = safe_int(defenses_el.get('armor', '0') if defenses_el is not None else '0')
    defense = safe_int(defenses_el.get('defense', '0') if defenses_el is not None else '0')
    max_heal = 0
    if defenses_el is not None:
        for d in defenses_el.findall('defense'):
            if d.get('name') == 'healing':
                max_heal = max(max_heal, abs(safe_int(d.get('max', '0'))))

    elements_el = root.find('elements')
    net_element_score = 0
    if elements_el is not None:
        for elem in elements_el.findall('element'):
            for v in elem.attrib.values():
                net_element_score += safe_int(v, 0)

    immunities_el = root.find('immunities')
    immunity_list = []
    if immunities_el is not None:
        for imm in immunities_el.findall('immunity'):
            for attr, val in imm.attrib.items():
                if val == "1":
                    immunity_list.append(attr)

    loot_el = root.find('loot')
    loot_count = 0
    has_rare_items = False
    if loot_el is not None:
        loot_items = list(loot_el.iter('item'))
        loot_count = len(loot_items)
        has_rare_items = any(
            safe_int(it.get('id', '0')) in {2160, 2168, 2170, 2470, 2472, 2514, 2520, 7382, 7393}
            for it in loot_items
        )

    flags_el = root.find('flags')
    is_hostile = True
    is_summonable = False
    if flags_el is not None:
        for flag in flags_el.findall('flag'):
            fname = list(flag.attrib.keys())[0] if flag.attrib else ''
            fval = flag.get(fname, '0')
            if fname == 'hostile': is_hostile = (fval == '1')
            elif fname == 'summonable': is_summonable = (fval == '1')

    exp_score = math.sqrt(exp) * 10
    hp_score = hp * 0.15
    dmg_score = max_total_damage * 1.5
    speed_score = (speed / 200.0) * 30
    def_score = (armor * 3 + defense * 2)
    imm_score = len(immunity_list) * 25
    elem_score = net_element_score * 0.5
    loot_bonus = 50 if has_rare_items else 0

    if not is_hostile:
        exp_score *= 0.3

    total_score = (
        exp_score * 0.35 + hp_score * 0.20 + dmg_score * 0.20 +
        speed_score * 0.10 + def_score * 0.10 + imm_score * 0.05 +
        elem_score * 0.025 + loot_bonus * 0.025
    )

    level_min, level_max = get_level_band(total_score)
    level_range = f"{level_min} - {level_max}"

    file_dir = os.path.dirname(os.path.normpath(filepath))
    is_boss = os.path.basename(file_dir) == 'bosses'

    return {
        'name': name,
        'exp': exp,
        'hp': hp,
        'speed': speed,
        'manacost': manacost,
        'score': total_score,
        'level_range': level_range,
        'level_min': level_min,
        'is_summonable': is_summonable,
        'is_hostile': is_hostile,
        'filename': os.path.basename(filepath),
        'filepath': filepath,
        'is_boss': is_boss,
    }

def organize_by_level(monsters, sorted_ranges):
    level_folders = {}
    for rk in sorted_ranges:
        parts = rk.split(' - ')
        folder_name = parts[1].strip()
        folder_path = os.path.join(MONSTER_DIR, folder_name)
        level_folders[rk] = folder_path

    folders_created = set()
    for fpath in level_folders.values():
        if fpath not in folders_created:
            os.makedirs(fpath, exist_ok=True)
            folders_created.add(fpath)
            print(f"  Criada pasta: {os.path.basename(fpath)}")

    # Collect existing numeric subfolders that are NOT in the new set
    new_folders_norm = {os.path.normpath(p).lower() for p in level_folders.values()}
    old_numeric = []
    for entry in os.listdir(MONSTER_DIR):
        epath = os.path.join(MONSTER_DIR, entry)
        if os.path.isdir(epath) and entry.isdigit() and os.path.normpath(epath).lower() not in new_folders_norm:
            old_numeric.append(epath)

    moved = 0
    skipped = 0
    for m in monsters:
        if m['is_boss']:
            skipped += 1
            continue

        src = m['filepath']
        dst_dir = level_folders[m['level_range']]
        dst = os.path.join(dst_dir, m['filename'])

        if os.path.normpath(os.path.dirname(src)) == os.path.normpath(dst_dir):
            skipped += 1
            continue

        if os.path.exists(src):
            shutil.move(src, dst)
            moved += 1

    # Remove old numeric subfolders (from previous 10-level organization)
    removed = 0
    for old_dir in old_numeric:
        try:
            remaining = os.listdir(old_dir)
            if not remaining:
                os.rmdir(old_dir)
                print(f"  Removida pasta antiga: {os.path.basename(old_dir)}")
                removed += 1
            else:
                print(f"  Pasta antiga {os.path.basename(old_dir)} ainda tem {len(remaining)} arquivos, mantida")
        except OSError:
            pass

    print(f"\n  Arquivos movidos: {moved}  |  Mantidos em bosses/: {skipped}  |  Pastas antigas removidas: {removed}")
    return level_folders


def main():
    print("=" * 60)
    print("  ANALISADOR DE MONSTROS v2")
    print("  Faixas de 50 em 50 niveis ate 1000+")
    print("=" * 60)

    xml_files = []
    for root_dir, dirs, files in os.walk(MONSTER_DIR):
        for f in files:
            if f.endswith('.xml') and f != 'monsters.xml':
                xml_files.append(os.path.join(root_dir, f))

    total_files = len(xml_files)
    print(f"\n  Processando {total_files} monstros...")

    monsters = []
    summoned_names = set()
    parsed_monsters = []

    for filepath in xml_files:
        data = parse_monster(filepath)
        if data is not None:
            parsed_monsters.append(data)

    for m in parsed_monsters:
        if m['name'] == 'Training Monk' or ' Summon' in m['name']:
            continue
        monsters.append(m)

    level_groups = {}
    for m in monsters:
        key = m['level_range']
        level_groups.setdefault(key, []).append(m)

    def sort_key(r):
        return int(r.split(' - ')[0])

    sorted_ranges = sorted(level_groups.keys(), key=sort_key)

    print(f"  Gerando arquivo: {OUTPUT_FILE}")

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:

        f.write(f"{'=' * 100}\n")
        f.write(f"  RECOMENDACAO DE MONSTROS POR NIVEL (FAIXAS DE 50)\n")
        f.write(f"  Total: {len(monsters)} monstros  |  Gerado: {datetime.now().strftime('%d/%m/%Y %H:%M')}\n")
        f.write(f"{'=' * 100}\n\n")

        f.write(f"{'=' * 100}\n")
        f.write(f"  TABELA COMPLETA POR NIVEL (ordenado por HP crescente)\n")
        f.write(f"{'=' * 100}\n\n")

        for range_key in sorted_ranges:
            group = level_groups[range_key]
            group.sort(key=lambda m: m['hp'])
            f.write(f"{'-' * 100}\n")
            f.write(f"  LEVEL {range_key}  ({len(group)} monstros)\n")
            f.write(f"{'-' * 100}\n")
            f.write(f"  {'MONSTRO':<35s} {'HP':>12s} {'EXP':>14s} {'SPEED':>8s} {'MANA':>8s}\n")
            f.write(f"  {'-'*35:<35s} {'-'*12:>12s} {'-'*14:>14s} {'-'*8:>8s} {'-'*8:>8s}\n")
            for m in group:
                hp_str = f"{m['hp']:,}"
                exp_str = f"{m['exp']:,}"
                f.write(f"  {m['name']:<35s} {hp_str:>12s} {exp_str:>14s} {m['speed']:>8d} {m['manacost']:>8d}\n")
            f.write("\n")

        f.write(f"{'=' * 100}\n")
        f.write(f"  ESTATISTICAS\n")
        f.write(f"{'=' * 100}\n\n")

        f.write(f"  Monstros por faixa:\n\n")
        for rk in sorted_ranges:
            cnt = len(level_groups[rk])
            bar = "█" * min(cnt, 60)
            f.write(f"  LV {rk:<8s}: {bar} {cnt}\n")

        f.write(f"\n  Top 10 Mais Fortes:\n\n")
        top = sorted(monsters, key=lambda m: m['score'], reverse=True)[:10]
        for i, m in enumerate(top, 1):
            f.write(f"  {i:>2}. {m['name']:<30s} | Score: {m['score']:>8.0f} | EXP: {m['exp']:>10,} | HP: {m['hp']:>10,} | LV: {m['level_range']}\n")

        f.write(f"\n  Top 10 Mais Fracos:\n\n")
        bot = sorted(monsters, key=lambda m: m['score'])[:10]
        for i, m in enumerate(bot, 1):
            f.write(f"  {i:>2}. {m['name']:<30s} | Score: {m['score']:>8.0f} | EXP: {m['exp']:>10,} | HP: {m['hp']:>10,} | LV: {m['level_range']}\n")

        f.write(f"\n  Monstros Summonable/Convinceable:\n\n")
        summ = [m for m in monsters if m['is_summonable'] and m['manacost'] > 0]
        summ.sort(key=lambda m: m['manacost'])
        for m in summ:
            f.write(f"  {m['name']:<30s} | Mana: {m['manacost']:>5} | LV: {m['level_range']:<8s} | EXP: {m['exp']:>8,}\n")

        f.write(f"\n{'=' * 100}\n")
        f.write(f"  FIM DO RELATORIO  |  {len(monsters)} monstros em {len(level_groups)} faixas\n")
        f.write(f"{'=' * 100}\n")

    print(f"\n  Concluido! {len(monsters)} monstros em {len(level_groups)} faixas.")
    print(f"  Arquivo: {OUTPUT_FILE}")

    print(f"\n{'=' * 60}")
    print(f"  ORGANIZANDO ARQUIVOS POR NIVEL...")
    print(f"{'=' * 60}")
    organize_by_level(monsters, sorted_ranges)
    print(f"\n  Organizacao concluida!")

if __name__ == '__main__':
    main()
