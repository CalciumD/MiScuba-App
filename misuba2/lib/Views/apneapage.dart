import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:misuba2/Models/ApneaModel.dart';

class ApneaPage extends StatefulWidget {
  final String title;
  const ApneaPage({super.key, required this.title});

  @override
  State<ApneaPage> createState() => _ApneaPage();
}

class _ApneaPage extends State<ApneaPage> {
  final db = FirebaseFirestore.instance;
  final LocalStorage storage = LocalStorage("miscuba");
  DateTime? newDate = DateTime.now();
  TimeOfDay? newTime = TimeOfDay.now();
  late bool servicePermission = false;
  late LocationPermission permission;
  Position? _currentLocation;
  String? uuid;

  final TextEditingController _timeInController = TextEditingController();
  final TextEditingController _timeOutController = TextEditingController();
  final TextEditingController _visibilitController = TextEditingController();
  final TextEditingController _avgDepthController = TextEditingController();
  final TextEditingController _maxDepthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff6495ed),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      left: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      right: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      bottom: BorderSide(color: Color(0xff6495ed), width: 1.0),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Date Picker
                      ElevatedButton(
                        child: Text("${newDate?.day}/${newDate?.month}/${newDate?.year}"),
                        onPressed: () async {
                          newDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (newDate == null) return;
                          setState(() {
                            newDate = newDate;
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text("${newTime?.hour}:${newTime?.minute}"),
                        onPressed: () async {
                          newTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (newTime == null) return;
                          setState(() {
                            newTime = newTime;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                //Second Container
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      left: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      right: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      bottom: BorderSide(color: Color(0xff6495ed), width: 1.0),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () async {
                          _currentLocation = await _getCurrentLocation();
                          setState(() {
                            _currentLocation = _currentLocation;
                          });
                        },
                        child: Text(
                            "Latitude: ${_currentLocation?.latitude}   Longitude: ${_currentLocation?.longitude}"),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  height: 380,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      left: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      right: BorderSide(color: Color(0xff6495ed), width: 1.0),
                      bottom: BorderSide(color: Color(0xff6495ed), width: 1.0),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextField(
                          controller: _timeInController,
                          obscureText: false,
                          decoration: const InputDecoration(hintText: 'Time in'),
                        ),
                        TextField(
                          controller: _timeOutController,
                          obscureText: false,
                          decoration: const InputDecoration(hintText: 'Time Out'),
                        ),
                        TextField(
                          controller: _visibilitController,
                          obscureText: false,
                          decoration: const InputDecoration(hintText: 'Visibility'),
                        ),
                        TextField(
                          controller: _avgDepthController,
                          obscureText: false,
                          decoration: const InputDecoration(hintText: 'Avg Depth'),
                        ),
                        TextField(
                          controller: _maxDepthController,
                          obscureText: false,
                          decoration: const InputDecoration(hintText: 'Max Depth'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              fixedSize: const Size(150, 40)),
                          onPressed: () {
                            _addApnea();
                            _showMyDialog();
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            fixedSize: const Size(150, 40),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeInController.dispose();
    _timeOutController.dispose();
    _visibilitController.dispose();
    _avgDepthController.dispose();
    _maxDepthController.dispose();
    super.dispose();
  }

  // on page load
  @override
  void initState() {
    super.initState();
    uuid = storage.getItem("uuid");
    _getCurrentLocation();
  }

  // Methods
  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      permission = await Geolocator.checkPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  // Adding Data on Save
  // COPILOT Helped with the Modeeling of the Data.
  void _addApnea() async {
    final apneadiving = ApneaModel(
      type: "Apnea",
      date: newDate.toString(),
      time: _formatTimeOfDay(newTime!),
      lat: "${_currentLocation?.latitude}",
      lon: "${_currentLocation?.longitude}",
      timeIn: _timeInController.text,
      timeOut: _timeOutController.text,
      visibility: _visibilitController.text,
      maxDepth: _maxDepthController.text,
      avgDepth: _avgDepthController.text,
    );

    final rf = db
        .collection(uuid!)
        .withConverter(
            fromFirestore: ApneaModel.fromFirestore,
            toFirestore: (ApneaModel fd, options) => fd.toFirestore())
        .doc();
    await rf.set(apneadiving);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saved'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apnea Diving Saved Successfully.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formatter = DateFormat('hh:mm');
    return formatter.format(dt);
  }
}
