import os
import re

structs = [
    'AdminSession', 'Badge', 'Admin', 'CornerProgress', 'AuditLog', 
    'DeviceRegistration', 'Group', 'Track', 'FacilitatorSession', 'Message', 'Camp', 'Corner', 'CampSettingsPatch'
]

def process_file(path):
    try:
        with open(path, 'r') as f:
            content = f.read()
    except Exception:
        return
        
    original = content
    
    for struct in structs:
        # Match `&domain.Struct{\s*[A-Z]`
        pattern_ptr = r'&domain\.' + struct + r'\{\s*(?=[A-Z])'
        pos = 0
        while True:
            m = re.search(pattern_ptr, content[pos:])
            if not m:
                break
            
            start_idx = pos + m.start()
            bracket_idx = pos + m.end() - 1
            
            depth = 1
            idx = bracket_idx + 1
            while idx < len(content) and depth > 0:
                if content[idx] == '{':
                    depth += 1
                elif content[idx] == '}':
                    depth -= 1
                idx += 1
                
            if depth == 0:
                new_str = content[:start_idx] + f'domain.New{struct}FromProps(domain.{struct}Props{{' + content[bracket_idx+1:idx-1] + '})' + content[idx:]
                content = new_str
                pos = idx + len(f'domain.New{struct}FromProps(domain.{struct}Props{{') - len(m.group(0)) + 1
            else:
                pos = bracket_idx + 1
                
        # Match `domain.Struct{\s*[A-Z]` not preceded by &
        pattern_val = r'(?<!&)\bdomain\.' + struct + r'\{\s*(?=[A-Z])'
        pos = 0
        while True:
            m = re.search(pattern_val, content[pos:])
            if not m:
                break
            
            start_idx = pos + m.start()
            bracket_idx = pos + m.end() - 1
            
            depth = 1
            idx = bracket_idx + 1
            while idx < len(content) and depth > 0:
                if content[idx] == '{':
                    depth += 1
                elif content[idx] == '}':
                    depth -= 1
                idx += 1
                
            if depth == 0:
                new_str = content[:start_idx] + f'domain.New{struct}ValFromProps(domain.{struct}Props{{' + content[bracket_idx+1:idx-1] + '})' + content[idx:]
                content = new_str
                pos = idx + len(f'domain.New{struct}ValFromProps(domain.{struct}Props{{') - len(m.group(0)) + 1
            else:
                pos = bracket_idx + 1

    if original != content:
        with open(path, 'w') as f:
            f.write(content)

for root, dirs, files in os.walk('../'):
    for f in files:
        if f.endswith('_test.go'):
            process_file(os.path.join(root, f))

print("Fixed structs intelligently in tests.")
