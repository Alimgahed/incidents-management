import os

files = [
    'lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart',
    'lib/core/future/home/ui/screens/home.dart',
    'lib/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart'
]

for file in files:
    if not os.path.exists(file): continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will replace the mojibake manually or try to decode it
    # Since python can do regex replacements with a function:
    import re
    def repl(m):
        try:
            return m.group(0).encode('cp1252').decode('utf-8')
        except:
            return m.group(0)
    
    # Match words that contain these strange characters
    # Usually they are combinations of 'ط', 'ظ', '©', '¦', etc.
    fixed_content = re.sub(r'[طظ][\wط-ظ©¦…]+', repl, content)
    
    # Just to be sure, let's try to decode the whole string if it's completely messed up:
    try:
        fixed_content = content.encode('cp1252').decode('utf-8')
    except:
        # If it fails, it means there are legitimate arabic characters. 
        # So we use the regex approach
        fixed_content = re.sub(r'[\u0600-\u06FF\u00A0-\u00FF]+', repl, content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)
    print(f"Fixed {file}")
