import os
import re

replacements = {
    'infrastructure/postgres/device_registration_repo.go': [
        (r'd\.LockedUntil\s*=\s*(.+)', r'd.SetLockedUntil(\1)'),
        (r'd\.ApprovedAt\s*=\s*(.+)', r'd.SetApprovedAt(\1)'),
    ],
    'infrastructure/postgres/facilitator_session_repo.go': [
        (r's\.RevokedAt\s*=\s*(.+)', r's.SetRevokedAt(\1)'),
    ],
    'infrastructure/postgres/message_repo.go': [
        (r'm\.ReadAt\s*=\s*(.+)', r'm.SetReadAt(\1)'),
    ],
    'infrastructure/postgres/track_repo.go': [
        (r't\.CurrentVisitID\s*=\s*(.+)', r't.SetCurrentVisitID(\1)'),
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
print("Done fixing repo assignments.")
