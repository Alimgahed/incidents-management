// lib/repositories/valve_repository.dart

import 'package:incidents_managment/core/future/valve/data/model/valve.dart';


abstract class ValveRepository {
  Future<List<ValveModel>> fetchValves();
}

/// ── Demo / local data ──────────────────────────────────────────────────────
/// Replace this with a Firestore, REST, or SQLite implementation.
/// The Cubit only depends on the abstract ValveRepository, so swapping is safe.
class LocalValveRepository implements ValveRepository {
  @override
  Future<List<ValveModel>> fetchValves() async {
    // Simulate a network/DB call
    await Future.delayed(const Duration(milliseconds: 300));

    // 👇 Replace these coordinates with your real valve locations in Minya
    return const [
      ValveModel(
        id: 'valve-001',
        name: 'محبس رئيسي - شارع الحرية',
        latitude: 28.0871,
        longitude: 30.7501,
        description: 'محبس مياه رئيسي قطر 300 مم',
      ),
      ValveModel(
        id: 'valve-002',
        name: 'محبس فرعي - شارع النيل',
        latitude: 28.0902,
        longitude: 30.7534,
        description: 'محبس فرعي قطر 150 مم',
      ),
      ValveModel(
        id: 'valve-003',
        name: 'محبس توزيع - منطقة أبو قرقاص',
        latitude: 28.0843,
        longitude: 30.7468,
        description: 'محبس توزيع قطر 100 مم',
      ),
      ValveModel(
        id: 'valve-004',
        name: 'تقاطع الضخ - المحطة الرئيسية',
        latitude: 28.0815,
        longitude: 30.7610,
        description: 'نقطة تقاطع رئيسية',
      ),
    ];
  }
}

/// ── Example: Firestore implementation (add cloud_firestore to pubspec) ─────
// class FirestoreValveRepository implements ValveRepository {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   @override
//   Future<List<ValveModel>> fetchValves() async {
//     final snapshot = await _db.collection('water_valves').get();
//     return snapshot.docs
//         .map((doc) => ValveModel.fromJson({'id': doc.id, ...doc.data()}))
//         .toList();
//   }
// }