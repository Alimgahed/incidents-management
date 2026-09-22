import 'dart:io';

void main() {
  final mobileFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/add_incident_mobile.dart');
  final webFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/add_incident.dart');
  
  void processFile(File file, bool isWeb) {
    if (!file.existsSync()) return;
    String content = file.readAsStringSync();
    
    // In mobile, we replace from '/// ================= TYPE =================' to the end of the Column
    // In web, we replace from 'IncidentTypeDropdown(' to the end of the Column
    
    // Instead of complex regex, let's just find the start and end of the column children and replace them.
    final startMarker = isWeb ? 'IncidentTypeDropdown(' : '/// ================= TYPE =================';
    final endMarker = isWeb ? '];' : '],'; // The end of the children array
    
    final startIndex = content.indexOf(startMarker);
    if (startIndex == -1) return;
    
    final searchEnd = content.indexOf('return CustomButton(', startIndex);
    if (searchEnd == -1) return;
    
    final blockEnd = content.indexOf(';', searchEnd); // The end of the return CustomButton(); statement
    if (blockEnd == -1) return;
    
    final fullEnd = content.indexOf('},', blockEnd);
    if (fullEnd == -1) return;
    
    final endOfBuilder = content.indexOf('),', fullEnd);
    
    final chunkToRemove = content.substring(startIndex, endOfBuilder + 2);
    
    final replacement = '''SharedIncidentForm(
                      descriptionController: descriptionController,
                      notesController: notesController,
                      addressController: addressController,
                      selectedTypeId: selectedTypeId,
                      selectedSeverity: selectedSeverity,
                      selectedBranchId: selectedBranchId,
                      isWeb: \$isWeb,
                      onTypeChanged: (v) {
                        \$setStateOrDirect
                        selectedTypeId = v;
                      \$closeState
                      },
                      onSeverityChanged: (v) {
                        \$setStateOrDirect
                        selectedSeverity = v;
                        \$closeState
                      },
                      onBranchChanged: (v) {
                        \$setStateOrDirect
                        selectedBranchId = v;
                        \$closeState
                      },
                    ),'''.replaceAll('\$isWeb', isWeb.toString())
                         .replaceAll('\$setStateOrDirect', isWeb ? '' : 'setState(() {')
                         .replaceAll('\$closeState', isWeb ? '' : '});');
                         
    content = content.replaceFirst(chunkToRemove, replacement);
    
    if (!content.contains('shared_incident_form.dart')) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_form.dart';"
      );
    }
    
    // For mobile, also need to remove the internal _submit method since it's now in the shared form
    if (!isWeb) {
      final submitRegex = RegExp(r'void _submit.*?\}\n\}\n', dotAll: true);
      content = content.replaceAll(submitRegex, '');
    }
    
    file.writeAsStringSync(content);
  }
  
  processFile(mobileFile, false);
  processFile(webFile, true);
  print('Done');
}
