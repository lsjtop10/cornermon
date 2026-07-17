import os
import re

def fix_struct_literal(filepath, struct_name):
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except:
        return
        
    pattern = r'domain\.' + struct_name + r'\{'
    replacement = r'domain.New' + struct_name + r'ValFromProps(domain.' + struct_name + r'Props{'
    
    # We only want to replace domain.Model{...}, but we have to make sure we close the bracket properly.
    # It's tricky with nested brackets, so instead, let's just use regex for the opening:
    # domain.Track{ -> domain.NewTrackValFromProps(domain.TrackProps{
    # But wait, where does the closing parenthesis go? It goes after the closing bracket.
    # A simpler way is to replace `domain.Track{...}` using a balanced bracket matcher.
    
    def replace_balanced(text, start_pattern, replacement_prefix):
        result = ""
        pos = 0
        while True:
            m = re.search(start_pattern, text[pos:])
            if not m:
                result += text[pos:]
                break
            
            start_idx = pos + m.start()
            bracket_idx = pos + m.end() - 1
            
            # Find matching closing bracket
            depth = 1
            idx = bracket_idx + 1
            while idx < len(text) and depth > 0:
                if text[idx] == '{':
                    depth += 1
                elif text[idx] == '}':
                    depth -= 1
                idx += 1
                
            if depth == 0:
                result += text[pos:start_idx]
                result += replacement_prefix
                result += text[bracket_idx+1:idx-1]
                result += "})"
                pos = idx
            else:
                result += text[pos:bracket_idx+1]
                pos = bracket_idx + 1
                
        return result

    new_content = replace_balanced(content, r'domain\.' + struct_name + r'\{', f'domain.New{struct_name}ValFromProps(domain.{struct_name}Props{{')
    
    # Sometimes it's &domain.Model{
    new_content = replace_balanced(new_content, r'&domain\.' + struct_name + r'\{', f'domain.New{struct_name}FromProps(domain.{struct_name}Props{{')
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)

files = [
    '../internal/domain/corner_test.go',
    '../internal/infrastructure/postgres/report_querier_test.go',
    '../internal/infrastructure/web/audit_handler_test.go',
    '../internal/infrastructure/web/device_handler_test.go',
    '../internal/infrastructure/web/group_handler_test.go',
]

structs = ['Track', 'CornerProgress', 'AuditLog', 'DeviceRegistration', 'Group']

for f in files:
    for s in structs:
        fix_struct_literal(f, s)

print("Struct literals fixed.")
