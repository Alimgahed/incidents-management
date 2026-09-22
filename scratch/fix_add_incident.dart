import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/add_incident.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    content = content.replaceFirst(
      '''
      child: Column(
        children: [
          SharedIncidentForm(
''',
      '''
      child: SharedIncidentForm(
'''
    );
    // Need to remove the closing bracket for the Column
    content = content.replaceFirst(
      '''
                      onBranchChanged: (v) {
                        
                        selectedBranchId = v;
                        
                      },
                    ),
        ],
      ),
    );
  }
''',
      '''
                      onBranchChanged: (v) {
                        
                        selectedBranchId = v;
                        
                      },
                    ),
    );
  }
'''
    );
    file.writeAsStringSync(content);
    print('Fixed add_incident.dart column wrap');
  }
}
