import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/network/dio_factory.dart');
  String content = file.readAsStringSync();
  
  if (!content.contains('session_manager.dart')) {
    content = content.replaceFirst(
      "import 'package:incidents_managment/core/security/secure_storage_service.dart';",
      "import 'package:incidents_managment/core/security/secure_storage_service.dart';\nimport 'package:incidents_managment/core/security/session_manager.dart';"
    );
  }
  
  content = content.replaceFirst(
    '''
        onError: (DioException error, handler) async {
          return handler.next(error);
        },
''',
    '''
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final sessionManager = getIt<SessionManager>();
              await sessionManager.logout(sessionExpired: true);
            } catch (_) {}
          }
          return handler.next(error);
        },
'''
  );
  
  file.writeAsStringSync(content);
  print('Done updating dio_factory.dart');
}
