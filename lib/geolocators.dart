

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
class GeolocatorsPage extends StatefulWidget {
  const GeolocatorsPage ({super.key});

  @override
  State<GeolocatorsPage> createState() => _GeolocatorsPageState();
}

class _GeolocatorsPageState extends State<GeolocatorsPage> {
  Position? _currlocation;
  late bool servicePermission=true;
  late LocationPermission permission;
  String _currentAdress="";
  Future<Position> _getCurrentLocation() async{
    servicePermission=await Geolocator.isLocationServiceEnabled();
    if(!servicePermission){
      permission=await Geolocator.checkPermission();
      if(permission ==LocationPermission.denied){
        permission= await Geolocator.requestPermission();
      }

    }
    return await Geolocator.getCurrentPosition();
  }
  _getAdressFromCoordinates() async{
    try{
      List<Placemark> placemarks= await placemarkFromCoordinates(_currlocation!.latitude,
          _currlocation!.longitude);
      Placemark placemark=placemarks[0];
      setState(() {
        _currentAdress="${placemark.locality},${placemark.country}";
      });

    }
    catch(e){
      print(e);

    }

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Geolocator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Get coordinates"),
            Text("lattitude =${_currlocation?.latitude};longitude =${_currlocation?.longitude}"),
            SizedBox(height: 10,),
            Text("${_currentAdress}"),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: () async{
              _currlocation=await  _getCurrentLocation();
              await _getAdressFromCoordinates();
              setState(() {

              });
              print("$_currlocation");

            }, child: Text("Get Location")),


          ],
        ),
      ),
    );
  }
}
