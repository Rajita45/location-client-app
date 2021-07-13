import 'dart:async';

import 'package:client_app_fcm/model/cordinates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:rxdart/subjects.dart';

class GetLocationBloc {
  BehaviorSubject<Cordinates> serviceFetcher =
      BehaviorSubject.seeded(Cordinates(lat: 0.0, lng: 0.0, status: false));
  Stream<Cordinates> get responseData => serviceFetcher.stream;

  final Location location = Location();

  late PermissionStatus _permissionGranted;
  Timer? timer;
  double lat = 0.0, lng = 0.0;

  ///Call this method to get the location updates.
  getLocation() async {
    ///Set status to true immediatly after pressed the START button.
    serviceFetcher.sink.add(Cordinates(lat: lat, lng: lng, status: true));
    LocationData? _locationData;

    ///Check permissions,
    ///Set timer for every 5 sec for testing puropse.
    ///We can change the duration if necessary
    if (await locationPermission())
      timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        ///get the Location cordinates.
        _locationData = await location.getLocation();
        lat = _locationData?.latitude ?? 0;
        lng = _locationData?.longitude ?? 0;

        ///Add data to stream.
        serviceFetcher.sink.add(Cordinates(lat: lat, lng: lng, status: true));

        ///Post data to Firestore.
        addLocation();
      });
  }

  ///This method helps to get the location cordiantes very first time.
  ///It calls only once
  getFirstTimeLocation() async {
    if (await locationPermission()) {
      LocationData? _locationData;
      _locationData = await location.getLocation();
      lat = _locationData.latitude ?? 0;
      lng = _locationData.longitude ?? 0;
    }
  }

  ///Check for the location permissions.
  ///It returns true, if the permission is granted.
  ///else returns false, if the permission is not given.
  Future<bool> locationPermission() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return _serviceEnabled;
  }

  ///Add location cordinates to Firestore.
  ///Used GeoPoint to update the data.
  addLocation() {
    FirebaseFirestore.instance
        .doc('locationRef/1')
        .update({'location': GeoPoint(lat, lng)})
        .then((value) => print("Location Added->$lat $lng"))
        .catchError((error) => print("Failed to add Location: $error"));
  }

  ///Cancel the timer.
  cancelLocationListner() {
    timer?.cancel();
    serviceFetcher.sink.add(Cordinates(lat: lat, lng: lng, status: false));
  }

  void dispose() async {
    serviceFetcher.drain();
    serviceFetcher.close();
    timer?.cancel();
  }
}

final GetLocationBloc getLocationBloc = GetLocationBloc();
