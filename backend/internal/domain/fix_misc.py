import os
import re

replacements = {
    'infrastructure/postgres/track_repo.go': [
        (r't\.DeletedAt\s*=\s*(.+)', r't.SetDeletedAt(\1)'),
    ],
    'infrastructure/postgres/visit_repo.go': [
        (r'v\.EndedAt\s*=\s*(.+)', r'v.SetEndedAt(\1)'),
    ],
}

for path, rules in replacements.items():
    full_path = os.path.join('../', path)
    with open(full_path, 'r') as f:
        text = f.read()
    for regex, sub in rules:
        text = re.sub(regex, sub, text)
    with open(full_path, 'w') as f:
        f.write(text)

def add_parens(filepath, line_num, target):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    idx = line_num - 1
    lines[idx] = re.sub(r'\b' + target.replace('.', r'\.') + r'\b(?!\()', f'{target}()', lines[idx])
    with open(filepath, 'w') as f:
        f.writelines(lines)

add_parens('../infrastructure/web/badge_handler.go', 46, 'camp.Status')
add_parens('../infrastructure/web/badge_handler.go', 177, 'b.ID')
add_parens('../infrastructure/web/group_handler.go', 43, 'g.Itinerary')
add_parens('../infrastructure/web/group_handler.go', 45, 'g.Itinerary')
add_parens('../infrastructure/web/group_handler.go', 93, 'session.TrackID')
add_parens('../infrastructure/web/message_handler.go', 231, 'msg.TrackID')
add_parens('../infrastructure/web/message_handler.go', 318, 'session.TrackID')
add_parens('../infrastructure/web/message_handler.go', 350, 'msg.TrackID')

print("Fixed web layer parenthesis and repo assignments.")
