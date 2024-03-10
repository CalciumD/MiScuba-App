// Code Developed from Firevase documentation

import 'package:cloud_firestore/cloud_firestore.dart';

class ApneaModel {
  final String? type;
  final String? date;
  final String? time;
  final String? lat;
  final String? lon;
  final String? timeIn;
  final String? timeOut;
  final String? visibility;
  final String? avgDepth;
  final String? maxDepth;

  // final String? diveSite;
  // final DateTime? bottomTime;
  // final DateTime? totalTime;
  // final String? comments;

  ApneaModel({
    this.type,
    this.date,
    this.time,
    this.lat,
    this.lon,
    this.timeIn,
    this.timeOut,
    this.visibility,
    this.maxDepth,
    this.avgDepth,

    // this.diveSite,
    // this.bottomTime,
    // this.totalTime,
    // this.comments,
  });

  factory ApneaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ApneaModel(
      type: data?['type'],
      date: data?['date'],
      time: data?['time'],
      lat: data?['latitude'],
      lon: data?['lonatude'],
      timeIn: data?['timeIn'],
      timeOut: data?['timeOut'],
      visibility: data?['visibility'],
      maxDepth: data?['maxDepth'],
      avgDepth: data?['avgDepth'],
    );
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
      if (maxDepth != null) "maxDepth": maxDepth,
      if (avgDepth != null) "avgDepth": avgDepth,
    };
  }
}
