import os
import xml.etree.ElementTree as ET
import math
import json
from collections import defaultdict
import traceback

MONSTER_DIR = r"C:\Users\thiag\Projetos\server-tibia\data\monster"
SPELLS_FILE = r"C:\Users\thiag\Projetos\server-tibia\data\spells\spells.xml"
VOCATIONS_FILE = r"C:\Users\thiag\Projetos\server-tibia\data\XML\vocations.xml"
OUTPUT_FILE = r"C:\Users\thiag\Projetos\server-tibia\data\monster_progression_analysis.txt"

# ---------------------------------------------------------------------------
# 1. Player Power Calculator
# ---------------------------------------------------------------------------

LEVEL_RANGES = [
    (1,         0.5,  1.2,  2,    5),
    (30,        0.8,  2.0,  5,   12),
    (50,        1.2,  2.5,  8,   18),
    (100,       1.8,  3.5, 15,   30),
    (200,       2.5,  4.5, 25,   50),
    (300,       3.5,  5.5, 35,   70),
    (400,       4.5,  6.5, 45,   90),
    (500,       5.5,  7.5, 55,  110),
    (600,       6.5,  8.5, 65,  130),
    (700,       7.5,  9.5, 75,  150),
    (800,       8.5, 10.5, 85,  170),
    (900,       9.5, 11.5, 95,  190),
    (1000,     11.0, 13.0, 110, 220),
    (float('inf'), 12.0, 14.5, 120, 250)
]

def get_range(level):
    for maxLvl, mn, mx, a1, a2 in LEVEL_RANGES:
        if level <= maxLvl:
            return mn, mx, a1, a2
    return LEVEL_RANGES[-1][1:]

def calc_player_damage(level, maglevel, str_skill, int_skill, archetype_damage_mult,
                        base_min, base_max, level_div, spell_max_level, extra_magic_damage):
    capped_level = min(level, spell_max_level)
    minMult, maxMult, minAdd, maxAdd = get_range(capped_level)
    skill_mult = 1 + (str_skill + int_skill) / 200
    dmg_mult = archetype_damage_mult * (1 + extra_magic_damage / 100)
    base_min_calc = (capped_level / level_div) + (maglevel * minMult) + minAdd
    base_max_calc = (capped_level / level_div) + (maglevel * maxMult) + maxAdd
    dmg_min = base_min_calc * base_min * skill_mult * dmg_mult
    dmg_max = base_max_calc * base_max * skill_mult * dmg_mult
    return dmg_min, dmg_max

ARCHETYPES = {
    "DPS":    {"hp":250,"mp":250,"mm":1.1,"dmg":2.5},
    "Bruiser": {"hp":250,"mp":250,"mm":1.1,"dmg":2.0},
    "Tank":   {"hp":450,"mp":150,"mm":1.1,"dmg":1.0},
    "Support":{"hp":150,"mp":450,"mm":1.05,"dmg":1.0},
}

BRACKETS = list(range(50, 1001, 50))

def calc_player_stats(level, archetype):
    cfg = ARCHETYPES[archetype]
    hp = level * cfg["hp"]
    mana = int(level * cfg["mp"] * cfg["mm"])
    if level <= 200:
        ml = level / 3
    elif level <= 500:
        ml = 200/3 + (level-200)/4
    else:
        ml = 200/3 + 300/4 + (level-500)/5
    ml = int(ml)
    str_sk = int(level / 2)
    int_sk = int(level / 2)
    extra_md = int(level / 5)
    return hp, mana, ml, str_sk, int_sk, extra_md

# Spell definitions: (name_key, lvl_req, baseMin, baseMax, levelDiv, magMultMin, magMultMax, spellMaxLevel, is_cannon, c_min, c_max)
SPELL_TIERS = [
    ("Basic_Ki_Blast",     1,   1, 2, 10, 1, 1, 50,   False, 0, 0),
    ("Super_Ki_Blast",     20,  1, 2, 10, 1, 1, 50,   False, 0, 0),
    ("Signature",          50,  1, 2, 10, 1, 1, 50,   False, 0, 0),
    ("Explosion",          75,  1, 2, 10, 1, 1, 75,   False, 0, 0),
    ("Cannon_lv90",        90,  1, 2, 10, 1, 1, 90,   True,  50, 90),
    ("Elite",              100, 1, 2, 10, 1, 1, 100,  False, 0, 0),
    ("Advanced",           150, 1, 2, 10, 1, 1, 150,  False, 0, 0),
    ("Master",             200, 1, 2, 10, 1, 1, 200,  False, 0, 0),
    ("Super_Cannon_lv250", 250, 1, 2, 10, 1, 1, 250,  True,  100, 150),
    ("Ultimate",           250, 1, 2, 10, 1, 1, 250,  False, 0, 0),
    ("Hyper_Cannon_lv600", 600, 1, 2, 10, 1, 1, 600,  True,  200, 300),
]

def calc_spell(level, ml, str_sk, int_sk, arch_dmg, extra_md, spell):
    name, lvl_req, bmin, bmax, ldiv, _, _, sml, is_cannon, cmin, cmax = spell
    if level < lvl_req:
        return None
    if is_cannon:
        dmg_min = level * (cmin / 100)
        dmg_max = level * (cmax / 100)
    else:
        dmg_min, dmg_max = calc_player_damage(level, ml, str_sk, int_sk, arch_dmg,
                                               bmin, bmax, ldiv, sml, extra_md)
    return dmg_min, dmg_max

def best_spell_damage(level, ml, str_sk, int_sk, arch_dmg, extra_md):
    """Return (dmg_min, dmg_max, spell_name) for the best spell available at this level."""
    best = None
    best_name = None
    for sp in reversed(SPELL_TIERS):  # try highest first
        result = calc_spell(level, ml, str_sk, int_sk, arch_dmg, extra_md, sp)
        if result is not None:
            dmin, dmax = result
            avg = (dmin + dmax) / 2
            if best is None or avg > (best[0] + best[1]) / 2:
                best = (dmin, dmax)
                best_name = sp[0]
    return best, best_name

# ---------------------------------------------------------------------------
# 2. Parse monsters
# ---------------------------------------------------------------------------

def find_monster_file(file_rel):
    """Search recursively for monster files."""
    direct = os.path.join(MONSTER_DIR, file_rel)
    if os.path.exists(direct):
        return direct
    for root_dir, dirs, files in os.walk(MONSTER_DIR):
        if root_dir == MONSTER_DIR:
            continue
        for f in files:
            if f.lower() == os.path.basename(file_rel).lower():
                return os.path.join(root_dir, f)
    return None

def parse_monster_xml(filepath):
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
        name = root.get('name', 'Unknown')
        hp = int(root.find('health').get('max', 0)) if root.find('health') is not None else 0
        exp = int(root.get('experience', 0))
        speed = int(root.get('speed', 0))
        manacost = int(root.get('manacost', 0))
        attacks = []
        for atk in root.findall('.//attack'):
            atk_min = abs(int(atk.get('min', 0)))
            atk_max = abs(int(atk.get('max', 0)))
            attacks.append({'min': atk_min, 'max': atk_max})
        defenses_el = root.find('defenses')
        armor = int(defenses_el.get('armor', 0)) if defenses_el is not None else 0
        defense = int(defenses_el.get('defense', 0)) if defenses_el is not None else 0
        max_atk = max((a['max'] for a in attacks), default=0)
        return {'name': name, 'hp': hp, 'exp': exp, 'speed': speed,
                'armor': armor, 'defense': defense, 'max_attack_dmg': max_atk}
    except Exception as e:
        # print(f"  ERRO ao ler {filepath}: {e}")
        return None

IGNORED_MONSTERS = {"training monk", "slime summon", "phantasm summon"}

def get_all_monsters():
    monsters = []
    monsters_xml_path = os.path.join(MONSTER_DIR, 'monsters.xml')
    tree = ET.parse(monsters_xml_path)
    root = tree.getroot()
    for entry in root.findall('monster'):
        name = entry.get('name', '')
        if name.lower() in IGNORED_MONSTERS:
            continue
        file_rel = entry.get('file')
        filepath = find_monster_file(file_rel)
        if filepath:
            m = parse_monster_xml(filepath)
            if m and m['hp'] < 1_000_000_000:  # sanity check: skip absurd HP values
                monsters.append(m)
    return monsters

# ---------------------------------------------------------------------------
# 3. Helpers
# ---------------------------------------------------------------------------

def bracket_label(level):
    return "1-50" if level == 50 else f"{level-49}-{level}"

def exp_for_level(lv):
    if lv <= 0:
        return 0
    return int((50/3)*lv**3 - 100*lv**2 + (8500/3)*lv - 2000)

# ---------------------------------------------------------------------------
# 4. Main
# ---------------------------------------------------------------------------

def main():
    print("Lendo monstros...")
    all_monsters = get_all_monsters()
    print(f"  {len(all_monsters)} monstros carregados")

    lines = []
    L = lambda s: lines.append(s)

    L("=" * 100)
    L("  ANALISE DE PROGRESSAO DE PODER - PLAYER vs MONSTROS")
    L(f"  Total de monstros: {len(all_monsters)}  |  Gerado em 04/06/2026")
    L("=" * 100)
    L("")

    # ---- PART 1: Player Power Table (DPS) ----
    L("=" * 100)
    L("  PARTE 1: PROGRESSAO DE PODER DO PLAYER (DPS) - TODAS AS SPELLS")
    L("  maglevel=nivel/3, STR=INT=nivel/2, skillUpgrades=nivel/5")
    L("=" * 100)
    L("")

    # Headers: pick which spells to show
    SHOW = [0, 2, 4, 7, 9]  # Basic, Signature, Cannon, Master, Ultimate
    SHOW_NAMES = ["Basic Ki", "Signature", "Cannon", "Master", "Ultimate"]
    hdr = f"{'Nivel':>6} {'HP':>8} {'Mana':>8} {'MagLv':>5} {'STR':>4} {'INT':>4}"
    for sn in SHOW_NAMES:
        hdr += f" {sn:>18}"
    L(hdr)
    L("-" * len(hdr))

    for br in BRACKETS:
        hp, mana, ml, s, i, ex = calc_player_stats(br, "DPS")
        row = f"{br:>6} {hp:>8,} {mana:>8,} {ml:>5} {s:>4} {i:>4}"
        for idx in SHOW:
            sp = SPELL_TIERS[idx]
            r = calc_spell(br, ml, s, i, 2.5, ex, sp)
            if r:
                row += f" {int(r[0]):>8}-{int(r[1]):>8}"
            else:
                row += f" {'---':>18}"
        L(row)

    L("")
    L("Legenda: Basic=lv1 spellMax50, Signature=lv50 spellMax50, Cannon=lv90 COMBAT_LEVELMAGIC")
    L("        Master=lv200 spellMax200, Ultimate=lv250 spellMax250")
    L("")

    # ---- PART 2: Best available damage per archetype ----
    L("=" * 100)
    L("  PARTE 2: MELHOR DANO DISPONIVEL POR ARQUETIPO")
    L("=" * 100)
    L("")
    arch_hdr = f"{'Nivel':>6} {'DPS HP':>10} {'DPS Dmg':>16} {'Bruiser HP':>10} {'Bruiser Dmg':>16} {'Tank HP':>10} {'Tank Dmg':>16} {'Sup. HP':>10} {'Sup. Dmg':>16}"
    L(arch_hdr)
    L("-" * len(arch_hdr))
    for br in BRACKETS:
        row = f"{br:>6}"
        for an, ac in [("DPS",2.5),("Bruiser",2.0),("Tank",1.0),("Support",1.0)]:
            hp, mp, ml, s, i, ex = calc_player_stats(br, an)
            best, bname = best_spell_damage(br, ml, s, i, ac, ex)
            if best:
                row += f" {hp:>10,} {int(best[0]):>7}-{int(best[1]):>7}"
            else:
                row += f" {hp:>10,} {'N/A':>16}"
        L(row)
    L("")

    # ---- PART 3: Monster HP Distribution ----
    L("=" * 100)
    L("  PARTE 3: DISTRIBUICAO DE HP DOS MONSTROS EXISTENTES")
    L("=" * 100)
    L("")
    HP_BINS = [
        (0,50), (51,200), (201,500), (501,1000), (1001,2000),
        (2001,5000), (5001,10000), (10001,50000), (50001,100000),
        (100001,500000), (500001,2000000), (2000001,10000000), (10000001,float('inf'))
    ]
    HP_LABELS = ["0-50","51-200","201-500","501-1k","1k-2k","2k-5k","5k-10k",
                 "10k-50k","50k-100k","100k-500k","500k-2M","2M-10M","10M+"]
    hp_dist = defaultdict(list)
    for m in all_monsters:
        for i, (lo, hi) in enumerate(HP_BINS):
            if lo <= m['hp'] <= hi:
                hp_dist[i].append(m)
                break
    for i, (lo, hi) in enumerate(HP_BINS):
        grp = hp_dist[i]
        if grp:
            avg_hp = sum(m['hp'] for m in grp) / len(grp)
            avg_exp = sum(m['exp'] for m in grp) / len(grp)
            avg_spd = sum(m['speed'] for m in grp) / len(grp)
            avg_atk = sum(m['max_attack_dmg'] for m in grp) / len(grp)
            L(f"  HP {HP_LABELS[i]:>12}: {len(grp):>4} monstros | HP med={avg_hp:>12,.0f} | EXP med={avg_exp:>12,.0f} | SPD med={avg_spd:>6.0f} | ATK med={avg_atk:>8.1f}")
    L("")

    # ---- PART 4: Ideal Configuration per Bracket ----
    L("=" * 100)
    L("  PARTE 4: CONFIGURACAO IDEAL DE MONSTROS POR FAIXA DE NIVEL")
    L("  HP ideal ~ 6-10x dano da melhor spell do DPS")
    L("  EXP ~ 0.5-1% do necessario para o proximo nivel")
    L("  Speed ~ 200 + nivel*0.8")
    L("  Ataque monstro ~ 8-12% do HP do Tank")
    L("=" * 100)
    L("")
    rhdr = f"{'Faixa':>12} {'Player HP':>10} {'Best Dmg':>16} {'Monstro HP':>16} {'Monstro EXP':>12} {'Spd':>6} {'Atk':>10}"
    L(rhdr)
    L("-" * len(rhdr))
    for br in BRACKETS:
        hp, mp, ml, s, i, ex = calc_player_stats(br, "DPS")
        best, bname = best_spell_damage(br, ml, s, i, 2.5, ex)
        avg_dmg = (best[0]+best[1])/2 if best else 0
        rec_hp = int(avg_dmg * 8)
        exp_next = exp_for_level(br+1) - exp_for_level(br)
        rec_exp = int(exp_next * 0.005) or max(br*5, 10)
        rec_spd = min(200 + br, 1000)
        tank_hp,_,_,_,_,_ = calc_player_stats(br, "Tank")
        rec_atk = int(tank_hp * 0.10) or 10
        if best:
            L(f"  {bracket_label(br):>12} {hp:>10,} {int(best[0]):>7}-{int(best[1]):>7} {rec_hp:>10,}  {rec_exp:>12,} {rec_spd:>6} {rec_atk:>8,}")
        else:
            L(f"  {bracket_label(br):>12} {hp:>10,} {'N/A':>16} {'N/A':>16}")
    L("")

    # ---- PART 5: Existing Monsters per Bracket ----
    L("=" * 100)
    L("  PARTE 5: MONSTROS EXISTENTES ADEQUADOS POR FAIXA")
    L("  (HP do monstro dentro de 4x-12x o dano da melhor spell DPS)")
    L("=" * 100)
    L("")

    for br in BRACKETS:
        hp, mp, ml, s, i, ex = calc_player_stats(br, "DPS")
        best, bname = best_spell_damage(br, ml, s, i, 2.5, ex)
        if not best:
            L(f"  NIVEL {bracket_label(br)}: (dados indisponiveis)\n")
            continue
        avg_dmg = (best[0]+best[1])/2
        lo = int(avg_dmg * 3)
        hi = int(avg_dmg * 12)
        fitting = [m for m in all_monsters if lo <= m['hp'] <= hi]
        fitting.sort(key=lambda x: x['hp'])
        L(f"  NIVEL {bracket_label(br)} (spell: {bname}) -> Dano={int(best[0]):,}-{int(best[1]):,}  HP ideal: {lo:,} - {hi:,}")
        if fitting:
            for m in fitting[:10]:
                L(f"    {m['name']:40s} HP={m['hp']:>12,} EXP={m['exp']:>10,} SPD={m['speed']:>4} ATK={m['max_attack_dmg']:>6,}")
            if len(fitting) > 10:
                L(f"    ... e mais {len(fitting)-10} monstros")
        else:
            L(f"    (NENHUM monstro adequado encontrado)")
        L("")

    # ---- PART 6: Gaps ----
    L("=" * 100)
    L("  PARTE 6: LACUNAS NA DISTRIBUICAO")
    L("=" * 100)
    L("")
    gaps = []
    for br in BRACKETS:
        hp, mp, ml, s, i, ex = calc_player_stats(br, "DPS")
        best, bname = best_spell_damage(br, ml, s, i, 2.5, ex)
        if not best:
            continue
        avg_dmg = (best[0]+best[1])/2
        lo = int(avg_dmg * 3)
        hi = int(avg_dmg * 12)
        fitting = [m for m in all_monsters if lo <= m['hp'] <= hi]
        if len(fitting) < 3:
            gaps.append((br, len(fitting), lo, hi))
        status = "OK" if len(fitting) >= 3 else "LACUNA" if len(fitting) > 0 else "VAZIO"
        L(f"  {bracket_label(br):>12}: {len(fitting):>3} monstros ({lo:>10,}-{hi:>10,} HP)  Status: {status}")

    L("")
    if gaps:
        L("  LACUNAS CRITICAS (menos de 3 monstros adequados):")
        for br, cnt, lo, hi in gaps:
            L(f"    {bracket_label(br):>12}: {cnt} monstro(s) - HP ideal {lo:,} - {hi:,}")
        L("")
        L("  RECOMENDACAO: Criar monstros nestas faixas de HP.")
    else:
        L("  Todas as faixas possuem monstros adequados.")
    L("")

    # ---- PART 7: Monster Creation Template ----
    L("=" * 100)
    L("  PARTE 7: TEMPLATE DE CRIACAO DE MONSTROS POR FAIXA")
    L("=" * 100)
    L("")
    for br in BRACKETS:
        hp, mp, ml, s, i, ex = calc_player_stats(br, "DPS")
        best, bname = best_spell_damage(br, ml, s, i, 2.5, ex)
        avg_dmg = (best[0]+best[1])/2 if best else 0
        rec_hp = int(avg_dmg * 8)
        exp_next = exp_for_level(br+1) - exp_for_level(br)
        rec_exp = int(exp_next * 0.005) or max(br*5, 10)
        rec_spd = min(200 + br, 1000)
        tank_hp,_,_,_,_,_ = calc_player_stats(br, "Tank")
        rec_atk = int(tank_hp * 0.10) or 10

        # Determine folder
        if br <= 100: folder = "50/"
        elif br <= 200: folder = "100/ ou 150/"
        elif br <= 300: folder = "200/ ou 250/"
        elif br <= 400: folder = "300/"
        elif br <= 500: folder = "350/ ou 500/"
        else: folder = "500+"

        L(f"  --- {bracket_label(br)} (pasta: {folder}) ---")
        L(f"    HP.......: {rec_hp:,}")
        L(f"    EXP......: {rec_exp:,}")
        L(f"    Speed....: {rec_spd}")
        L(f"    Ataque...: melee {int(rec_atk*0.6)}-{rec_atk} | especial {int(rec_atk*0.8)}-{int(rec_atk*1.2)}")
        L(f"    Armor....: {int(br/5)}")
        L(f"    Defense..: {int(br/4)}")
        L(f"    Elems....: 1 forte (50%), 1 fraco (-10%)")
        L(f"    Imunidades: paralyze, invisible")
        L(f"    Loot.....: gold coins + items level {br}")
        L("")

    output = "\n".join(lines)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(output)
    print(f"Analise salva em: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
