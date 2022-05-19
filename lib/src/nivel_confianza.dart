import 'package:mongo_dart/mongo_dart.dart';

class NivelConfianza {
  final ObjectId id;
  final num nivel;
  final num z;

  const NivelConfianza(
      {required this.id, required this.nivel, required this.z});

      
  @override
  bool operator ==(Object other) => other is NivelConfianza && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory NivelConfianza.fromJson(Map<String, dynamic> json) {
    return NivelConfianza(
      id: ObjectId.parse(json['_id'].toString()),
      nivel: json['nivel'] as num,
      z: json['z'] as num
    );
  }
}
