import os

directory_in = 'C:\\Users\\thiag\\Meus Projetos\\server-tibia\\data\\monster'
directory_out = 'C:\\Users\\thiag\\Meus Projetos\\server-tibia\\data\\monster'
xml_tags = '<?xml version="1.0" encoding="UTF-8"?>\n<monsters>\n'

# List to store file information
file_list = []

# Walk through directory and subdirectories
for root, _, files in os.walk(directory_in):
    for filename in files:
        # Skip monsters.xml
        if filename.lower() == 'monsters.xml':
            continue
        # Check for .txt or .xml files
        if filename.endswith(('.txt', '.xml')):
            # Get relative path from directory_in
            relative_path = os.path.relpath(os.path.join(root, filename), directory_in)
            # Replace backslashes with forward slashes for XML
            relative_path = relative_path.replace('\\', '/')
            # Get name without extension and capitalize
            name = os.path.splitext(filename)[0].capitalize()
            file_list.append((name, relative_path))

# Sort files by name
file_list.sort(key=lambda x: x[0])

# Generate XML tags
for name, file_path in file_list:
    xml_tags += f'  <monster name="{name}" file="{file_path}"/>\n'

xml_tags += '</monsters>'

# Write to output file
with open(os.path.join(directory_out, 'monsters.xml'), 'w', encoding='utf-8') as f:
    f.write(xml_tags)

print('Monsters.xml gerado com sucesso em', directory_out)

# import os

# directory_in = 'C:\\Users\\thiag\\Meus Projetos\\server-tibia\\data\\monster'
# directory_out = 'C:\\Users\\thiag\\Meus Projetos\\server-tibia\\data\\monster'
# xml_tags = '<?xml version="1.0" encoding="UTF-8"?>\n<monsters>\n'

# files = [f for f in os.listdir(directory_in) if f.endswith(('.txt', '.xml'))]
# files.sort()

# for filename in files:
#     if filename.endswith('.txt'):
#         name = filename.capitalize().replace('.txt', '')
#     elif filename.endswith('.xml'):
#         name = filename.capitalize().replace('.xml', '')
#         archive = filename.replace('.xml', '')
#     xml_tags += f'  <monster name="{name}" file="{archive}.xml"/>\n'

# xml_tags += '</monsters>'

# with open(os.path.join(directory_out, 'monsters.xml'), 'w') as f:
#     f.write(xml_tags)

# print('Monsters.xml gerado com sucesso em', directory_out)
