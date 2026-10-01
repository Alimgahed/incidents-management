import os
file = 'lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart'
if os.path.exists(file):
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace('ط§ط®طھط±', 'اختر')
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
