import os
import re

def fix_all_tests():
    structs = ['AuditLog', 'DeviceRegistration', 'Group', 'Track', 'CornerProgress']
    
    def process_file(path):
        try:
            with open(path, 'r') as f:
                content = f.read()
        except Exception:
            return
            
        original = content
        
        for struct in structs:
            # Match domain.Struct{ or &domain.Struct{
            # But only if it has fields like ID: or CornerID: or ...
            # Actually, just matching `domain.Struct{` is safe if we don't have empty structs or we don't care.
            
            # Simple replacement using re.sub with balanced brackets logic is hard.
            # Let's replace `domain.AuditLog{` with `domain.NewAuditLogValFromProps(domain.AuditLogProps{`
            # and we just add `})` at the matching closing bracket.
            
            # Find all occurrences of domain.Struct{
            pos = 0
            while True:
                m = re.search(r'(?<!&)\bdomain\.' + struct + r'\{', content[pos:])
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
            
            # Now for &domain.Struct{
            pos = 0
            while True:
                m = re.search(r'&domain\.' + struct + r'\{', content[pos:])
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
                    
        if original != content:
            with open(path, 'w') as f:
                f.write(content)
                
    for root, dirs, files in os.walk('../'):
        for f in files:
            if f.endswith('_test.go'):
                process_file(os.path.join(root, f))

fix_all_tests()
print("Fixed struct literals in tests.")
