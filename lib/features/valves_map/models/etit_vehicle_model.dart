class EtitVehicleModel {
  final String id;
  final String code;
  final String plateNumber;
  final String? codePlateNumber;
  final String? branch;
  final String? allocation; // e.g. فرع المنيا, فرع مطاى
  final String? vehicleType; // e.g. Truck, Trailer, Pickup
  final String? statusName; // e.g. Available
  final String? deviceCode; // Teltonika IMEI
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
  });

  bool get hasValidLocation =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0;

  bool get isMoving => (speed ?? 0) > 0;

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
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      speed: json['speed'] != null ? double.tryParse(json['speed'].toString()) : null,
      statusCode: json['statusCode']?.toString(),
      lastUpdate: json['lastUpdate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}
