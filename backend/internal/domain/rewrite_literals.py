import os
import re

def find_matching_brace(s, start_idx):
    count = 0
    for i in range(start_idx, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i
    return -1

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find all matches first
    matches = []
    for m in re.finditer(r'(&?)domain\.([A-Z][a-zA-Z0-9_]*)\s*\{', content):
        is_ptr = m.group(1) == '&'
        struct_name = m.group(2)
        if struct_name.endswith('Props') or struct_name.startswith('New'):
            continue
            
        start_idx = m.end() - 1
        end_idx = find_matching_brace(content, start_idx)
        if end_idx != -1:
            matches.append((m.start(), m.end(), end_idx, is_ptr, struct_name))
            
    # Process from right to left to avoid offset shifting
    for start, m_end, end_idx, is_ptr, struct_name in reversed(matches):
        if is_ptr:
            replacement_start = f"domain.New{struct_name}FromProps(domain.{struct_name}Props{{"
        else:
            replacement_start = f"domain.New{struct_name}ValFromProps(domain.{struct_name}Props{{"
            
        content = content[:start] + replacement_start + content[m_end:end_idx] + "})" + content[end_idx+1:]
        
    with open(filepath, 'w') as f:
        f.write(content)

for root, dirs, files in os.walk('../'):
    for file in files:
        if file.endswith('.go') and 'internal/domain/' not in root and 'internal/domain' != root:
            process_file(os.path.join(root, file))

print("Done rewriting literals")
