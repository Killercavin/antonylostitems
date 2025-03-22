
import 'package:flutter/material.dart';

import 'edit_account.dart';
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new)),
        title: Text("Account"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: Container(

            child: Column(
              children: [
                Icon(Icons.person_add_alt_1_outlined,size: 60,),
                Text("Geofrey Njenga",style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,color: Colors.black),),
                Text("jeffNjenga@gmail.com",style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,color: Colors.black),),
                SizedBox(
                  width: 450,
                  child: ElevatedButton( onPressed: (){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                          (route) => false,
                    );

                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder()
                    ),
                    child: Text("Edit Profile"),

                  ),
                )
              ],
            ),

          )),
          Expanded(
            flex: 2,
              child: Container(
                child: Column(
                  children: [
                    ListTile(
                      onTap: (){

                      },
                      leading: Icon(Icons.shopping_basket_sharp),
                      title: Text("Your Orders",style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15,color: Colors.black),),
                    ),
                    ListTile(
                      onTap: (){

                      },
                      leading: Icon(Icons.favorite_outlined),
                      title: Text("Favourite",style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15,color: Colors.black),),
                    ),
                    ListTile(
                      onTap: (){

                      },
                      leading: Icon(Icons.info),
                      title: Text("About us",style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15,color: Colors.black),),
                    ),
                    ListTile(
                      onTap: (){

                      },
                      leading: Icon(Icons.support),
                      title: Text("Support",style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15,color: Colors.black),),
                    ),
                    ListTile(
                      onTap: (){

                      },
                      leading: Icon(Icons.exit_to_app),
                      title: Text("Log out",style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 15,color: Colors.black),),
                    ),
                    Text("Version 1.0.0",style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15,color: Colors.black),)
                  ],
                ),


          )),
        ],
      ),
    );
  }
}
