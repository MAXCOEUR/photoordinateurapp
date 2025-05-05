class ScannedInfo {
  final String ip;
  final int? port;

  ScannedInfo({
    required this.ip,
    required this.port,
  });

  factory ScannedInfo.fromJson(Map<String, dynamic> json) {
    return ScannedInfo(
      ip: json['ip'],
      port: json['port'],
    );
  }

  @override
  String toString() {
    return 'IP: $ip, Port: $port';
  }
}
