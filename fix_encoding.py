import os
import re

def fix_mojibake(text):
    # We only want to fix the Arabic Mojibake.
    # Mojibake for Arabic starts with ط or ظ followed by specific characters.
    # But applying encode-decode to the WHOLE string is risky for characters like ═ (U+2550).
    # However, if we read the file and look for strings inside quotes "..." or '...', we can fix just the strings!
    # Or, we can just find any sequence of characters in the range of Arabic Mojibake.
    
    # Actually, a safer way:
    # Split the text line by line.
    lines = text.split('\n')
    new_lines = []
    for line in lines:
        if 'ط' in line or 'ظ' in line or 'â' in line or 'œ' in line:
            # This line probably has mojibake.
            # Try to fix it.
            # Wait, '═' might be corrupted too. In the user's snippet, it looks like 'â•گâ•گâ•گ'
            # Let's just fix the whole line.
            try:
                # The file is currently UTF-8 string containing Mojibake.
                # E.g., 'ط§ظ„ظ…ظ‡ط§ظ…'
                # Convert back to raw bytes using cp1256
                raw_bytes = line.encode('cp1256')
                # Decode bytes to UTF-8
                fixed_line = raw_bytes.decode('utf-8')
                new_lines.append(fixed_line)
            except Exception as e:
                # If it fails, keep original
                new_lines.append(line)
        else:
            new_lines.append(line)
            
    return '\n'.join(new_lines)

files_to_fix = [
    'lib/core/future/mission_assigen/ui/screens/mission_assign_web.dart',
    'lib/core/future/mission_assigen/ui/screens/mission_assign_mobile.dart',
    'lib/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart', # any other?
]

for filepath in files_to_fix:
    if not os.path.exists(filepath):
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    fixed_content = fix_mojibake(content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(fixed_content)
    
    print(f"Fixed {filepath}")
