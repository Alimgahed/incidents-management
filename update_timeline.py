import 'dart:io';

file = 'lib/core/future/home/ui/widgets/dash_board/incident_details.dart'
with open(file, 'r', encoding='utf-8') as f:
    content = f.read()

# Timeline Card uses:
# userId: incident.currentIncidentCreatedBy
# userId: incident.currentIncidentStatusUpdatedBy
# userId: incident.currentIncidentSeverityUpdateBy

content = content.replace('userId: incident.currentIncidentCreatedBy,', 'userId: incident.currentIncidentCreatedBy,\n          userName: incident.username,')
content = content.replace('userId: incident.currentIncidentStatusUpdatedBy,', 'userId: incident.currentIncidentStatusUpdatedBy,\n          userName: incident.statusUpdatedByUserName,')
content = content.replace('userId: incident.currentIncidentSeverityUpdateBy,', 'userId: incident.currentIncidentSeverityUpdateBy,\n          userName: incident.severityUpdatedByUserName,')

# _TimelineItem signature update
content = content.replace('''    this.userId,
    required this.isFirst,''', '''    this.userId,
    this.userName,
    required this.isFirst,''')

content = content.replace('''  final DateTime time;
  final int? userId;
  final bool isFirst;''', '''  final DateTime time;
  final int? userId;
  final String? userName;
  final bool isFirst;''')

content = content.replace('''                  if (userId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'بواسطة المعرّف: #\',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],''', '''                  if (userName != null || userId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'بواسطة: \',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],''')

# Now for the Status and Severity display
# Search where Status and Severity are displayed.
content = content.replace('value: incident.currentIncidentStatus.toString(),', 'value: incident.statusName ?? incident.currentIncidentStatus.toString(),')
content = content.replace('value: incident.currentIncidentSeverity.toString(),', 'value: incident.severityName ?? incident.currentIncidentSeverity.toString(),')

with open(file, 'w', encoding='utf-8') as f:
    f.write(content)
