import re

with open('../infrastructure/web/camp_handler.go', 'r') as f:
    text = f.read()

text = re.sub(r'patch\.Name\s*=\s*(.+)', r'patch.SetName(\1)', text)
text = re.sub(r'patch\.StartAt\s*=\s*(.+)', r'patch.SetStartAt(\1)', text)
text = re.sub(r'patch\.EndAt\s*=\s*(.+)', r'patch.SetEndAt(\1)', text)
text = re.sub(r'patch\.BottleneckMinSamples\s*=\s*(.+)', r'patch.SetBottleneckMinSamples(\1)', text)
text = re.sub(r'patch\.BottleneckRatioPct\s*=\s*(.+)', r'patch.SetBottleneckRatioPct(\1)', text)

with open('../infrastructure/web/camp_handler.go', 'w') as f:
    f.write(text)
