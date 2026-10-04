import 'dart:io';

file = 'lib/core/future/actions/data/models/current_incident.dart/current_incident_model.dart'
with open(file, 'r', encoding='utf-8') as f:
    content = f.read()

# Add the new fields
new_fields = '''  @JsonKey(name: 'status_name')
  final String? statusName;
  @JsonKey(name: 'severity_name')
  final String? severityName;
  @JsonKey(name: 'status_updated_by_user_name')
  final String? statusUpdatedByUserName;
  @JsonKey(name: 'severity_updated_by_user_name')
  final String? severityUpdatedByUserName;
'''
content = content.replace('  @JsonKey(name: ''photos'')\n  final List<CurrentIncidentPhoto>? photos;', '  @JsonKey(name: ''photos'')\n  final List<CurrentIncidentPhoto>? photos;\n' + new_fields)

# Add to constructor
constructor_additions = '''    this.statusName,
    this.severityName,
    this.statusUpdatedByUserName,
    this.severityUpdatedByUserName,
'''
content = content.replace('    this.photos,\n  });', '    this.photos,\n' + constructor_additions + '  });')

with open(file, 'w', encoding='utf-8') as f:
    f.write(content)
