import os
import re
import subprocess

err_pattern = re.compile(r'(.+\.go):(\d+):\d+: (.+)')

def run_build():
    proc = subprocess.Popen(['go', 'build', './...'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd='../')
    out, err = proc.communicate()
    return proc.returncode, err.decode('utf-8')

while True:
    code, err = run_build()
    if code == 0:
        print("Build passed!")
        break
    
    lines = err.split('\n')
    fixes = 0
    for line in lines:
        m = err_pattern.match(line)
        if m:
            filepath = m.group(1).strip()
            if not filepath.startswith('/'):
                filepath = os.path.join('../', filepath)
            
            line_num = int(m.group(2)) - 1
            msg = m.group(3)
            
            with open(filepath, 'r') as f:
                content_lines = f.readlines()
                
            original_line = content_lines[line_num]
            new_line = original_line
            
            m_convert = re.search(r'cannot convert (.+) \(value of type func\(\)', msg)
            if m_convert:
                expr = m_convert.group(1)
                new_line = re.sub(r'\b' + expr.replace('.', r'\.') + r'\b(?!\()', f'{expr}()', new_line)
                
            m_convert_var = re.search(r'cannot convert (.+) \(variable of type func\(\)', msg)
            if m_convert_var:
                expr = m_convert_var.group(1)
                new_line = re.sub(r'\b' + expr.replace('.', r'\.') + r'\b(?!\()', f'{expr}()', new_line)

            m_use_var = re.search(r'cannot use (.+) \(value of type func\(\)', msg)
            if m_use_var:
                expr = m_use_var.group(1)
                new_line = re.sub(r'\b' + expr.replace('.', r'\.') + r'\b(?!\()', f'{expr}()', new_line)
                
            if 'undefined (type func()' in msg and 'has no field or method' in msg:
                m_field = re.search(r'(.+)\.([A-Z]\w*) undefined \(type func\(\)', msg)
                if m_field:
                    expr = m_field.group(1)
                    field = m_field.group(2)
                    new_line = new_line.replace(f'{expr}.{field}', f'{expr}().{field}')
                    
            if new_line != original_line:
                content_lines[line_num] = new_line
                with open(filepath, 'w') as f:
                    f.writelines(content_lines)
                fixes += 1
                
    if fixes == 0:
        print("Could not auto-fix any more errors.")
        print(err)
        break
    else:
        print(f"Applied {fixes} fixes.")
