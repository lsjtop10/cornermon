import os
import re

constants = ['BadgeUnassigned', 'BadgeAssigned', 'CampEnded', 'CampActive', 'CampReady', 'TrackActive', 'TrackEnded', 'RoleAdmin', 'DeviceApproved', 'DevicePending', 'DeviceRejected']

for root, _, files in os.walk('../'):
    if 'internal/domain' in root:
        continue
    for file in files:
        if file.endswith('.go'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            original = content
            for const in constants:
                content = content.replace(f'domain.{const}()', f'domain.{const}')
            
            if original != content:
                with open(filepath, 'w') as f:
                    f.write(content)
print("Done fixing constants")
