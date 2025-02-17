import 'package:flutter/cupertino.dart';


import 'Directions.dart';
class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropoffLocation;
  int counttotaltrips = 0;
  // List<String> historykeytriplists = [];
  // List<TripHistoryModel> allTrips = [];
  void updatePickLocationAdress(Directions userPickupAdress) async{
    userPickUpLocation=userPickupAdress;
    notifyListeners();


  }
  void updateDropLocation(Directions userDropoffAdress) async{
    userDropoffLocation=userDropoffAdress;

  }
}