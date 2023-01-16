import 'package:absensi/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../controllers/page_index_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final pageC = Get.find<PageIndexController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snap) {
          if(snap.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snap.hasData) {

            Map<String, dynamic> user = snap.data!.data()!;

            String defaultImage = "https://ui-avatars.com/api/?name=${user['name']}";
            
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.network(
                          user["img_profile"] != null
                          ? user["img_profile"] != ""
                            ? user["img_profile"]
                          : defaultImage
                          : defaultImage,
                        fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  user['name'].toString().toUpperCase(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  user['email'], 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  onTap: () => Get.toNamed(
                    Routes.UPDATE_PROFILE, 
                    arguments: user,
                  ),
                  leading: Icon(Icons.person),
                  title: Text("Update Profile"),
                ),
                ListTile(
                  onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD),
                  leading: Icon(Icons.vpn_key),
                  title: Text("Update Password"),
                ),
                if (user["role"] == "admin")
                ListTile(
                  onTap: () => Get.toNamed(Routes.ADD_PEGAWAI),
                  leading: Icon(Icons.person_add),
                  title: Text("Add Pegawai"),
                ),
                ListTile(
                  onTap: () => controller.logout(),
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ],
            );
          } else {
            return Center (
              child: Text("tidak dapat memuat data user"),
            );
          }
        }
      ),
      bottomNavigationBar: ConvexAppBar(
        //style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
