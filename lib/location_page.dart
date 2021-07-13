import 'package:client_app_fcm/bloc/get_location_bloc.dart';
import 'package:client_app_fcm/model/cordinates.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
    getLocationBloc.getFirstTimeLocation();
  }

  @override
  void dispose() {
    getLocationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Client App')),
      body: StreamBuilder(
          stream: getLocationBloc.responseData,
          builder: (context, AsyncSnapshot<Cordinates> snapshot) {
            if (snapshot.hasData) {
              bool status = snapshot.data?.status ?? false;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Latitude : ${snapshot.data?.lat}\nLongitude : ${snapshot.data?.lng}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: status
                              ? null
                              : () {
                                  getLocationBloc.getLocation();
                                },
                          child: Text('Start'),
                        ),
                        ElevatedButton(
                          onPressed: !status
                              ? null
                              : () {
                                  getLocationBloc.cancelLocationListner();
                                },
                          child: Text('Stop'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
