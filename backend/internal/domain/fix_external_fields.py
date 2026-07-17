import subprocess
import re
import os

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
            
            # Find the specific field from the error message
            m_cannot_use = re.search(r'cannot use (\w+)\.(\w+) \(value of type func\(\)', msg)
            if m_cannot_use:
                field = m_cannot_use.group(2)
                new_line = re.sub(r'\.' + field + r'\b(?!\()', f'.{field}()', original_line)
                if new_line != original_line:
                    content_lines[line_num] = new_line
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue
                    
            m_invalid_op = re.search(r'invalid operation: (.*) \(mismatched types func\(\)', msg)
            if m_invalid_op:
                for word in re.findall(r'\.([A-Z]\w*)', original_line):
                    new_line = re.sub(r'\.' + word + r'\b(?!\()', f'.{word}()', original_line)
                    original_line = new_line
                if original_line != content_lines[line_num]:
                    content_lines[line_num] = original_line
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue
            
            m_convert = re.search(r'cannot convert (\w+)\.(\w+) \(value of type func\(\).*to type string', msg)
            if m_convert:
                var, field = m_convert.group(1), m_convert.group(2)
                new_line = re.sub(r'\b' + var + r'\.' + field + r'\b(?!\()', f'{var}.{field}()', original_line)
                if new_line != original_line:
                    content_lines[line_num] = new_line
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue
                    
            m_convert_var = re.search(r'cannot convert (\w+) \(variable of type func\(\).*to type string', msg)
            if m_convert_var:
                var = m_convert_var.group(1)
                new_line = re.sub(r'\b' + var + r'\b(?!\()', f'{var}()', original_line)
                if new_line != original_line:
                    content_lines[line_num] = new_line
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue

            m_use_var = re.search(r'cannot use (\w+) \(variable of type func\(\).*as.*value', msg)
            if m_use_var:
                var = m_use_var.group(1)
                new_line = re.sub(r'\b' + var + r'\b(?!\()', f'{var}()', original_line)
                if new_line != original_line:
                    content_lines[line_num] = new_line
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue

            if 'undefined (type *domain.' in msg and 'has no field or method' in msg:
                m_field = re.search(r'has no field or method ([A-Z]\w*)', msg)
                if m_field:
                    field = m_field.group(1)
                    new_line = re.sub(r'\.' + field + r'\b(?!\()', f'.{field}()', original_line)
                    if new_line != original_line:
                        content_lines[line_num] = new_line
                        with open(filepath, 'w') as f:
                            f.writelines(content_lines)
                        fixes += 1
                        continue
                        
            if 'undefined (type domain.' in msg and 'has no field or method' in msg:
                m_field = re.search(r'has no field or method ([A-Z]\w*)', msg)
                if m_field:
                    field = m_field.group(1)
                    new_line = re.sub(r'\.' + field + r'\b(?!\()', f'.{field}()', original_line)
                    if new_line != original_line:
                        content_lines[line_num] = new_line
                        with open(filepath, 'w') as f:
                            f.writelines(content_lines)
                        fixes += 1
                        continue

            if 'cannot assign to' in msg:
                print(f"Manual assignment fix needed: {filepath}:{line_num+1} {msg}")

    if fixes == 0:
        print("Could not auto-fix any more errors. Exiting.")
        print(err)
        break
    else:
        print(f"Applied {fixes} fixes, rebuilding...")
