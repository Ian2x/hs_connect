import 'package:cloud_firestore/cloud_firestore.dart';

class DomainData {
  final String? county;
  final String? state;
  final String? country;
  final String? fullName;
  final String? color;
  final String? image;
  final Timestamp? launchDate;

  DomainData(
      {required this.county,
      required this.state,
      required this.country,
      required this.fullName,
      required this.color,
      required this.image,
      required this.launchDate});
}
