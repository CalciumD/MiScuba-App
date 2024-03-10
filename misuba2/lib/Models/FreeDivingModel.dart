// Code Developed from Firevase documentation

import 'package:cloud_firestore/cloud_firestore.dart';

class FreeDivingModel {
  final String? type;
  final String? date;
  final String? time;
  final String? lat;
  final String? lon;
  final String? timeIn;
  final String? timeOut;
  final String? visibility;

  // final String? diveSite;
  // final DateTime? bottomTime;
  // final DateTime? totalTime;
  // final String? maxDepth;
  // final String? avgDepth;
  // final String? comments;

  FreeDivingModel({
    this.type,
    this.date,
    this.time,
    this.lat,
    this.lon,
    this.timeIn,
    this.timeOut,
    this.visibility,
    // this.diveSite,
    // this.timeIn,
    // this.timeOut,
    // this.bottomTime,
    // this.totalTime,
    // this.visibility,
    // this.maxDepth,
    // this.avgDepth,
    // this.comments,
  });

  factory FreeDivingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return FreeDivingModel(
        type: data?['type'],
        date: data?['date'],
        time: data?['time'],
        lat: data?['latitude'],
        lon: data?['lonatude'],
        timeIn: data?['timeIn'],
        visibility: data?['visibility']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (type != null) "type": type,
      if (date != null) "date": date,
      if (time != null) "time": time,
      if (lat != null) "latitude": lat,
      if (lon != null) "longatude": lon,
      if (timeIn != null) "timeIn": timeIn,
      if (timeOut != null) "timeOut": timeOut,
      if (visibility != null) "visibility": visibility,
    };
  }
}
