import re

with open('../infrastructure/postgres/camp_repo.go', 'r') as f:
    text = f.read()

text = re.sub(r'camp\.ActivatedAt\s*=\s*(.+)', r'camp.SetActivatedAt(\1)', text)
text = re.sub(r'camp\.EndedAt\s*=\s*(.+)', r'camp.SetEndedAt(\1)', text)

with open('../infrastructure/postgres/camp_repo.go', 'w') as f:
    f.write(text)
