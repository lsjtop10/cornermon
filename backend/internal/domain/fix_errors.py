import subprocess
import re
import os

err_pattern = re.compile(r'(.+\.go):(\d+):\d+: (.+)')
unknown_field_pattern = re.compile(r'unknown field ([A-Za-z0-9_]+) in struct literal of type .*, but does have ([A-Za-z0-9_]+)')

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
            
            m_field = unknown_field_pattern.search(msg)
            if m_field:
                orig = m_field.group(1)
                lower = m_field.group(2)
                content_lines[line_num] = original_line.replace(orig + ':', lower + ':')
                with open(filepath, 'w') as f:
                    f.writelines(content_lines)
                fixes += 1
                continue
                
            if 'has no field or method IsSet' in msg:
                m_isset = re.search(r'\.([A-Z]\w*)\.IsSet', original_line)
                if m_isset:
                    field = m_isset.group(1)
                    lower = field[0].lower() + field[1:]
                    content_lines[line_num] = original_line.replace(f'.{field}.', f'.{lower}.')
                    with open(filepath, 'w') as f:
                        f.writelines(content_lines)
                    fixes += 1
                    continue

            if 'mismatched types func()' in msg or 'undefined (type func()' in msg or 'value of type func()' in msg:
                for word in re.findall(r'\.([A-Z]\w*)', original_line):
                    original_line = original_line.replace(f'.{word}', f'.{word}()')
                content_lines[line_num] = original_line
                with open(filepath, 'w') as f:
                    f.writelines(content_lines)
                fixes += 1
                continue
                
            if 'cannot assign to' in msg:
                # manual
                pass

    if fixes == 0:
        print("Could not auto-fix any errors. Exiting.")
        print(err)
        break
    else:
        print(f"Applied {fixes} fixes, rebuilding...")
