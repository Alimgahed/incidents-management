text = 'طھظ… ط­ظپط¸ ط§ظ„ط¨ظٹط§ظ†ط§طھ ط¨ظ†ط¬ط§ط­'
print("Original:", text)
try:
    print("cp1252:", text.encode('cp1252').decode('utf-8'))
except Exception as e:
    print("cp1252 failed:", e)

try:
    print("cp1256:", text.encode('cp1256').decode('utf-8'))
except Exception as e:
    print("cp1256 failed:", e)

