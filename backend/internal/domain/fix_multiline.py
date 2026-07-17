import os
import re

def replace_regex(path, pattern, repl):
    try:
        with open(path, 'r') as f:
            content = f.read()
    except Exception:
        return
    content, count = re.subn(pattern, repl, content, flags=re.DOTALL | re.MULTILINE)
    if count > 0:
        with open(path, 'w') as f:
            f.write(content)

replace_regex('../internal/infrastructure/postgres/report_querier_test.go', 
    r'\{[\s\n]*CornerID:\s*(.+?),[\s\n]*Status:\s*(.+?)[\s\n]*\}', 
    r'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: \1, Status: \2})')

replace_regex('../internal/infrastructure/web/audit_handler_test.go',
    r'\{[\s\n]*ID:\s*(.+?),[\s\n]*Actor:\s*(.+?),[\s\n]*Action:\s*(.+?),[\s\n]*Success:\s*(.+?)[\s\n]*\}',
    r'domain.NewAuditLogValFromProps(domain.AuditLogProps{ID: \1, Actor: \2, Action: \3, Success: \4})')

replace_regex('../internal/infrastructure/web/device_handler_test.go',
    r'\{[\s\n]*ID:\s*(.+?),[\s\n]*Status:\s*(.+?),[\s\n]*CreatedAt:\s*(.+?)[\s\n]*\}',
    r'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: \1, Status: \2, CreatedAt: \3})')

replace_regex('../internal/infrastructure/web/group_handler_test.go',
    r'\{[\s\n]*ID:\s*(.+?),[\s\n]*CampID:\s*(.+?),[\s\n]*Name:\s*(.+?)[\s\n]*\}',
    r'domain.NewGroupValFromProps(domain.GroupProps{ID: \1, CampID: \2, Name: \3})')

replace_regex('../internal/domain/corner_test.go',
    r'domain\.Track\{[\s\n]*ID:\s*(.+?),[\s\n]*CornerID:\s*(.+?),[\s\n]*Status:\s*(.+?),[\s\n]*CurrentVisitID:\s*(.+?)[\s\n]*\}',
    r'domain.NewTrackValFromProps(domain.TrackProps{ID: \1, CornerID: \2, Status: \3, CurrentVisitID: \4})')
    
replace_regex('../internal/domain/corner_test.go',
    r'domain\.Track\{[\s\n]*ID:\s*(.+?),[\s\n]*CornerID:\s*(.+?),[\s\n]*Status:\s*(.+?)[\s\n]*\}',
    r'domain.NewTrackValFromProps(domain.TrackProps{ID: \1, CornerID: \2, Status: \3})')

replace_regex('../internal/domain/camp_test.go',
    r'event\.CampID\s*!=\s*camp\.ID',
    r'event.CampID() != camp.ID()')
    
replace_regex('../internal/domain/camp_test.go',
    r'event\.CampID\(\)\(\)\s*!=\s*camp\.ID\(\)\(\)',
    r'event.CampID() != camp.ID()')

print("Applied multiline replacements.")
