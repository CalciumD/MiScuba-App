import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:misuba2/Views/apneapage.dart';
import 'package:misuba2/Views/freedivpage.dart';
import 'package:misuba2/loginpage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:misuba2/Views/scubapage.dart';
import 'package:weather/weather.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageStates();
}

class _MainPageStates extends State<MainPage> {
  // Methods GO Here
  final LocalStorage storage = LocalStorage("miscuba");
  final db = FirebaseFirestore.instance;
  Weather? _currentWeather;
  final player = AudioPlayer();
  Location location = Location();
  late bool servicePermission = false;
  late LocationPermission permission;
  late PermissionStatus _permissionGranted;
  String? uuid;

  @override
  void initState() {
    super.initState();
    _getPermission();
    _getLocation();
    _getWeather();
    _getUserId();
  }

  // Pub.dev documentaiton
  Future<PermissionStatus> _getPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return PermissionStatus.granted;
      }
    }
    return PermissionStatus.denied;
  }

  // Pub.dev documentation
  Future<void> _getWeather() async {
    WeatherFactory wf = WeatherFactory("8b8983249c5c386881c3690b181ec2f9");
    Position p = await _getCurrentLocation();
    Weather w = await wf.currentWeatherByLocation(p.latitude, p.longitude);
    setState(() {
      _currentWeather = w;
    });
  }

  Future<Position> _getLocation() async {
    Position p = await _getCurrentLocation();
    return p;
  }

  // Pub.dev documentation
  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      permission = await Geolocator.checkPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getUserId() async {
    uuid = storage.getItem("uuid");
    setState(() {
      uuid = uuid;
    });
  }

  // Page STUFF
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Log Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xff6495ed),
      ),
      // APP PAGE
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xff6495ed),
              // border: Border(
              //   top: BorderSide(color: Color(0xff6495ed), width: 1.0),
              //   left: BorderSide(color: Color(0xff6495ed), width: 1.0),
              //   right: BorderSide(color: Color(0xff6495ed), width: 1.0),
              //   bottom: BorderSide(color: Color(0xff6495ed), width: 1.0),
              // ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            height: 140,
            child: Column(
              children: <Widget>[
                // IMAGE AND TEMP
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentWeather?.weatherDescription}',
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      Text(
                        '${_currentWeather?.temperature?.celsius?.toStringAsFixed(2)}°C',
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      )
                    ],
                  ),
                ),

                // Could add mote to the lower part
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentWeather?.areaName}, ${_currentWeather?.country}',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        'Humidity: ${_currentWeather?.humidity}',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                // border: Border(
                //   top: BorderSide(color: Color(0xff6495ed), width: 2.0),
                //   left: BorderSide(color: Color(0xff6495ed), width: 2.0),
                //   right: BorderSide(color: Color(0xff6495ed), width: 2.0),
                //   bottom: BorderSide(color: Color(0xff6495ed), width: 2.0),
                // ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              alignment: Alignment.center,
              //height: 500,
              child: StreamBuilder(
                // THIS PART WAS HELPED BY COPILOT
                // FirebaseFirestore.instance.collection("Test").snapshots(),
                stream: FirebaseFirestore.instance.collection(uuid!).orderBy('date').snapshots(),
                // THIS PART WAS HELPED BY COPILOT
                builder: (context, snapshot) {
                  // Get Data
                  if (snapshot.hasError) {
                    return const Text("Connection Error");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading...");
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(docs[index].id), // Use unique key for each item
                        onDismissed: (direction) {
                          // Remove the item from the Firestore collection
                          FirebaseFirestore.instance.collection(uuid!).doc(docs[index].id).delete();
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          height: 60,
                          color: const Color(0xff6495ed),
                          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          alignment: Alignment.center,
                          child: Text(
                            '${docs[index]['type']}: ${docs[index]['date']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xff6495ed),
              radius: 30.0,
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 30.0,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showMyDialog();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // POPUP FOR BUTTONS
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SimpleDialog(
                contentPadding: const EdgeInsets.all(10.0),
                children: [
                  // Scuba APp Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        //_playerSound();
                        // Pop Dialog
                        Navigator.of(context).pop();
                        // Then Push New Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScubaPage(
                              title: 'Scuba',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Scuba',
                        style: TextStyle(
                          color: Color(0xff6495ed),
                        ),
                      ),
                    ),
                  ),
                  // APnea Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApneaPage(
                              title: 'Apnea',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Apnea',
                        style: TextStyle(
                          color: Color(0xff6495ed),
                        ),
                      ),
                    ),
                  ),
                  // Free Diving Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FreeDivePage(
                              title: 'Free Diving',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Free',
                        style: TextStyle(
                          color: Color(0xff6495ed),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
