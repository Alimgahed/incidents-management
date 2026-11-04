class EtitVehicleModel {
  final String id;
  final String code;
  final String plateNumber;
  final String? codePlateNumber;
  final String? branch;
  final String? allocation; // e.g. فرع المنيا, فرع مطاى
  final String? vehicleType; // e.g. Truck, Trailer, Pickup
  final String? statusName; // e.g. Available
  String? deviceCode; // Teltonika / Queclink IMEI
  final String? vendorName; // e.g. Teltonika
  final String? providerName; // e.g. Orange
  final String? chassisNumber;
  final bool isMonitored;

  // Real-time Telematics
  double? latitude;
  double? longitude;
  double? speed;
  String? statusCode;
  String? lastUpdate;

  // Full raw JSON payload from ETIT so no field is ever lost
  final Map<String, dynamic> rawData;

  EtitVehicleModel({
    required this.id,
    required this.code,
    required this.plateNumber,
    this.codePlateNumber,
    this.branch,
    this.allocation,
    this.vehicleType,
    this.statusName,
    this.deviceCode,
    this.vendorName,
    this.providerName,
    this.chassisNumber,
    this.isMonitored = false,
    this.latitude,
    this.longitude,
    this.speed,
    this.statusCode,
    this.lastUpdate,
    this.rawData = const {},
  });

  bool get hasValidLocation =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0;

  bool get isOffline => !hasValidLocation || statusCode == '12';

  bool get isMoving => hasValidLocation && !isOffline && (speed ?? 0) > 0;

  bool get isStopped => hasValidLocation && !isOffline && (speed ?? 0) <= 0;

  String get arabicStatusLabel {
    if (isMoving) return 'متحركة';
    if (isStopped) return 'متوقفة';
    return 'غير متصل';
  }

  String get arabicVehicleType {
    final t = (vehicleType ?? '').toLowerCase();
    if (t.contains('pickup')) return 'بيك أب';
    if (t.contains('trailer')) return 'مقطورة';
    if (t.contains('truck')) return 'شاحنة';
    if (t.contains('car') || t.contains('sedan')) return 'سيارة';
    if (t.contains('van') || t.contains('bus')) return 'ميكروباص';
    if (t.contains('loader') || t.contains('tractor')) return 'معدة ثقيلة';
    return vehicleType ?? 'مركبة';
  }

  EtitVehicleModel copyWith({
    String? id,
    String? code,
    String? plateNumber,
    String? codePlateNumber,
    String? branch,
    String? allocation,
    String? vehicleType,
    String? statusName,
    String? deviceCode,
    String? vendorName,
    String? providerName,
    String? chassisNumber,
    bool? isMonitored,
    double? latitude,
    double? longitude,
    double? speed,
    String? statusCode,
    String? lastUpdate,
    Map<String, dynamic>? rawData,
  }) {
    return EtitVehicleModel(
      id: id ?? this.id,
      code: code ?? this.code,
      plateNumber: plateNumber ?? this.plateNumber,
      codePlateNumber: codePlateNumber ?? this.codePlateNumber,
      branch: branch ?? this.branch,
      allocation: allocation ?? this.allocation,
      vehicleType: vehicleType ?? this.vehicleType,
      statusName: statusName ?? this.statusName,
      deviceCode: deviceCode ?? this.deviceCode,
      vendorName: vendorName ?? this.vendorName,
      providerName: providerName ?? this.providerName,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      isMonitored: isMonitored ?? this.isMonitored,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      statusCode: statusCode ?? this.statusCode,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rawData: rawData ?? this.rawData,
    );
  }

  factory EtitVehicleModel.fromJson(Map<String, dynamic> json) {
    return EtitVehicleModel(
      id: json['ID']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      plateNumber: json['plateNo']?.toString() ?? '',
      codePlateNumber: json['CodePlateNumber']?.toString(),
      branch: json['branch']?.toString(),
      allocation: json['Allocation']?.toString(),
      vehicleType: json['VehicleType']?.toString(),
      statusName: json['StatusName']?.toString(),
      deviceCode: json['deviceCode']?.toString(),
      vendorName: json['Vendor_Name']?.toString(),
      providerName: json['providerName']?.toString(),
      chassisNumber: json['ChassisNumber']?.toString(),
      isMonitored: json['isMonitored'] == true,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      speed: json['speed'] != null
          ? double.tryParse(json['speed'].toString())
          : null,
      statusCode: json['statusCode']?.toString(),
      lastUpdate: json['lastUpdate']?.toString(),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...rawData,
      'ID': id,
      'code': code,
      'plateNo': plateNumber,
      'CodePlateNumber': codePlateNumber,
      'branch': branch,
      'Allocation': allocation,
      'VehicleType': vehicleType,
      'StatusName': statusName,
      'deviceCode': deviceCode,
      'Vendor_Name': vendorName,
      'providerName': providerName,
      'ChassisNumber': chassisNumber,
      'isMonitored': isMonitored,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'statusCode': statusCode,
      'lastUpdate': lastUpdate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EtitVehicleModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          plateNumber == other.plateNumber &&
          allocation == other.allocation &&
          vehicleType == other.vehicleType &&
          deviceCode == other.deviceCode &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          speed == other.speed &&
          statusCode == other.statusCode &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode => Object.hash(
    id,
    code,
    plateNumber,
    allocation,
    vehicleType,
    deviceCode,
    latitude,
    longitude,
    speed,
    statusCode,
    lastUpdate,
  );
}
