import os
import re

domain_dir = '/home/lsjtop10/projects/cornermon/.claude/worktrees/issue-108-device-registration-code/backend/internal/domain'

struct_re = re.compile(r'type\s+([A-Z][a-zA-Z0-9_]*)\s+struct\s+\{([^}]+)\}')
field_re = re.compile(r'^\s+([A-Z][a-zA-Z0-9_]*)\s+(.+)$')

def to_lower_camel(name):
    if len(name) == 0:
        return name
    if name == 'ID':
        return 'id'
    if name.endswith('ID'):
        return name[0].lower() + name[1:-2] + 'ID'
    if name == 'QRPayload':
        return 'qrPayload'
    return name[0].lower() + name[1:]

all_fields = set()

for filename in os.listdir(domain_dir):
    if not filename.endswith('.go') or filename.endswith('_test.go'):
        continue
    filepath = os.path.join(domain_dir, filename)
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = content
    structs = struct_re.findall(content)
    
    getters = ""
    file_fields = []
    
    for struct_name, struct_body in structs:
        lines = struct_body.split('\n')
        new_body_lines = []
        
        props_fields = []
        mapping = []
        
        for line in lines:
            m = field_re.match(line)
            if m:
                field_name = m.group(1)
                field_type_raw = m.group(2).strip()
                field_type = field_type_raw.split('//')[0].strip()
                
                lower_name = to_lower_camel(field_name)
                file_fields.append((field_name, lower_name))
                
                idx = line.find(field_name)
                new_line = line[:idx] + lower_name + line[idx+len(field_name):]
                new_body_lines.append(new_line)
                
                receiver = struct_name[0].lower()
                if receiver == 't' and struct_name == 'Track':
                    receiver = 'tr'
                if receiver == 'g' and struct_name == 'Group':
                    receiver = 'grp'
                getter = f"\nfunc ({receiver} *{struct_name}) {field_name}() {field_type} {{\n\treturn {receiver}.{lower_name}\n}}\n"
                getters += getter
                
                props_fields.append(f"\t{field_name} {field_type}")
                mapping.append(f"\t\t{lower_name}: p.{field_name},")
            else:
                new_body_lines.append(line)
                
        old_struct_str = f"type {struct_name} struct {{{struct_body}}}"
        new_struct_str = f"type {struct_name} struct {{{os.linesep.join(new_body_lines)}}}"
        new_content = new_content.replace(old_struct_str, new_struct_str)
        
        props_struct = f"\ntype {struct_name}Props struct {{\n" + "\n".join(props_fields) + "\n}\n"
        constructor_ptr = f"func New{struct_name}FromProps(p {struct_name}Props) *{struct_name} {{\n\treturn &{struct_name}{{\n" + "\n".join(mapping) + "\n\t}\n}\n"
        constructor_val = f"func New{struct_name}ValFromProps(p {struct_name}Props) {struct_name} {{\n\treturn {struct_name}{{\n" + "\n".join(mapping) + "\n\t}\n}\n"
        
        getters += props_struct + constructor_ptr + constructor_val

    for orig, lower in file_fields:
        new_content = re.sub(r'\.' + orig + r'\b', '.' + lower, new_content)
        new_content = re.sub(r'\b' + orig + r':', lower + ':', new_content)
        
    if getters:
        new_content += getters
        
    with open(filepath, 'w') as f:
        f.write(new_content)

print("Done")
