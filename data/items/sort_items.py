#!/usr/bin/env python3
"""
sort_items.py — Reordena os blocos <item> do items.xml por ID crescente.
Preserva: cabeçalho XML, comentários soltos, e todos os atributos multilinha.
Autor: Antigravity (gerado automaticamente)
"""

import re
import sys

INPUT_FILE  = "items.xml"
OUTPUT_FILE = "items_sorted.xml"

def get_sort_key(block_text):
    """Extrai o menor ID numérico do bloco para usar como chave de ordenação."""
    # Tenta fromid primeiro, depois id
    m = re.search(r'\bfromid="(\d+)"', block_text)
    if m:
        return int(m.group(1))
    m = re.search(r'\bid="(\d+)"', block_text)
    if m:
        return int(m.group(1))
    return 0  # comentários ou linhas sem id ficam no início

def split_into_blocks(lines):
    """
    Divide as linhas em:
      - header: tudo antes do primeiro <item
      - footer: </items> final
      - blocks: lista de blocos (cada bloco = lista de linhas)
    Um bloco pode ser:
      - <item ... /> (linha única auto-fechada)
      - <item ...>\n  ...\n</item> (multiline)
      - <!-- comentário --> (comentário solto entre itens)
    """
    header = []
    footer = []
    blocks = []

    # Encontra onde começa a primeira tag <item ou <!-- após o header
    in_header = True
    current_block = []
    in_multiline = False

    for line in lines:
        stripped = line.rstrip('\n').rstrip()

        # --- HEADER: até a primeira ocorrência de <item ou <items>
        if in_header:
            # Detecta linha de abertura do root <items>
            if re.match(r'\s*<items[\s>]', stripped):
                header.append(line)
                in_header = False
                continue
            header.append(line)
            continue

        # --- FOOTER: linha de fechamento </items>
        if re.match(r'\s*</items>', stripped):
            footer.append(line)
            continue

        # --- Dentro de bloco multiline
        if in_multiline:
            current_block.append(line)
            if re.match(r'\s*</item>', stripped):
                blocks.append(current_block)
                current_block = []
                in_multiline = False
            continue

        # --- Início de novo bloco
        if re.match(r'\s*<item[\s>]', stripped):
            current_block = [line]
            # Verifica se é auto-fechado na mesma linha
            if re.search(r'/>\s*$', stripped) or re.search(r'</item>', stripped):
                blocks.append(current_block)
                current_block = []
            else:
                in_multiline = True
            continue

        # --- Comentários e linhas em branco entre itens
        if stripped == '' or stripped.startswith('<!--') or stripped.startswith('//'):
            # Agrega ao bloco anterior (comentário pertence ao contexto)
            # Ou cria bloco standalone para o comentário
            blocks.append([line])
            continue

        # Linha sem match (não deveria ocorrer) — adiciona como standalone
        blocks.append([line])

    return header, blocks, footer

def main():
    print(f"Lendo {INPUT_FILE}...")
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    print(f"Total de linhas: {len(lines)}")

    header, blocks, footer = split_into_blocks(lines)
    print(f"Blocos encontrados: {len(blocks)}")

    # Separa blocos que têm ID real dos que não têm (comentários puros)
    item_blocks    = [b for b in blocks if get_sort_key(''.join(b)) > 0]
    non_id_blocks  = [b for b in blocks if get_sort_key(''.join(b)) == 0]

    print(f"  Blocos com ID: {len(item_blocks)}")
    print(f"  Blocos sem ID (comentários/brancos): {len(non_id_blocks)}")

    # Ordena apenas os blocos com ID
    item_blocks_sorted = sorted(item_blocks, key=lambda b: get_sort_key(''.join(b)))

    # Verifica se houve mudança real na ordem
    original_keys = [get_sort_key(''.join(b)) for b in item_blocks]
    sorted_keys   = [get_sort_key(''.join(b)) for b in item_blocks_sorted]

    changes = sum(1 for a, b in zip(original_keys, sorted_keys) if a != b)
    print(f"Blocos que mudaram de posição: {changes}")

    # Detecta e reporta duplicatas de ID após ordenação
    seen = {}
    dups = []
    for b in item_blocks_sorted:
        key = get_sort_key(''.join(b))
        if key in seen:
            dups.append(key)
        seen[key] = True
    if dups:
        print(f"AVISO: IDs ainda duplicados após ordenação: {dups}")
    else:
        print("Nenhum ID duplicado restante.")

    # Reconstrói: header + comentários soltos + itens ordenados + footer
    # Estratégia: comentários soltos ficam no início (antes dos itens)
    output_blocks = non_id_blocks + item_blocks_sorted

    print(f"\nEscrevendo {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        for line in header:
            f.write(line)
        for block in output_blocks:
            for line in block:
                f.write(line)
        for line in footer:
            f.write(line)

    print(f"Concluído! Arquivo gerado: {OUTPUT_FILE}")

    # Verificação final
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        out_lines = f.readlines()
    print(f"Linhas no arquivo original: {len(lines)}")
    print(f"Linhas no arquivo gerado:   {len(out_lines)}")

if __name__ == '__main__':
    main()
