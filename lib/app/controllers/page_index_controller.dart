import 'package:absensi/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    //print('click index=$i');

    switch (i) {
      case 1:
        print("ABSENSI");
        //Position position = await determinePosition();
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          // ambil dari update position
          Position position = dataResponse["position"];

          //translate koordinat
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].street} , ${placemarks[0].subAdministrativeArea}";
          /* print(placemarks[0].name);
          print(placemarks[0].street); */
          // update
          await updatePosition(
            position,
            address,
          );

          // cek distance area position
          double distance = Geolocator.distanceBetween(
              -6.3521563, 106.5756235, position.latitude, position.longitude);

          // lemparan presensi
          await presensi(position, address, distance);

          // snackbar koordinat jadi alamat
          //Get.snackbar("${dataResponse['message']}", "${placemarks[0].street} , ${placemarks[0].subAdministrativeArea}");
        } else {
          Get.snackbar("Error", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    // get current user
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> dbAbsensi =
        await firestore.collection("pegawai").doc(uid).collection("absensi");

    QuerySnapshot<Map<String, dynamic>> snapAbsensi = await dbAbsensi.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
    //print(todayDocID);

    String status = "Diluar Area";

    // untuk mengelola distance
    if (distance <= 200) {
      status = "Didalam Area";
    }

    if (snapAbsensi.docs.length == 0) {
      await Get.defaultDialog(
        title: "Validasi Absensi",
        middleText:
            "Apakah anda yakin akan mengisi daftar hadir (MASUK) sekarang ?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              // belum pernah absen dan set absen masuk
              await dbAbsensi.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "address": address,
                  "status": status,
                  "distance": distance,
                }
              });
              Get.back();
              Get.snackbar("Succcess", "anda telah berhasil mengisi daftar hadir (MASUK)");
            },
            child: Text("YES"),
          ),
        ],
      );
      
    } else {
      // sudah absen => cek terlebih dahulu udah masuk/keluar
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await dbAbsensi.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        // absen keluar atau absen masuk untuk hari berkutnya
        Map<String, dynamic>? dataAbsenToday = todayDoc.data();
        if (dataAbsenToday?["keluar"] != null) {
          // sudah absen cekin dan cekout
          Get.snackbar("Peringatan", "anda telah absen masuk & keluar hari ini. Tidak dapat mengubah data kembali");
        } else {
          // absen keluar
          await Get.defaultDialog(
            title: "Validasi Absensi",
            middleText:
                "Apakah anda yakin akan mengisi daftar hadir (KELUAR) sekarang ?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(), 
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await dbAbsensi.doc(todayDocID).update({
                    "keluar": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    }
                  });
                  Get.back();
                  Get.snackbar("Succcess", "anda telah berhasil mengisi daftar hadir (KELUAR)");
                }, 
                child: Text("YES"),
              ),
            ]
          );
          
        }
      } else {
        // absen masuk hari ini dan data tidak kosong 
        await Get.defaultDialog(
          title: "Validasi Absensi",
        middleText:
            "Apakah anda yakin akan mengisi daftar hadir (MASUK) sekarang ?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(), 
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              await dbAbsensi.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "address": address,
                  "status": status,
                  "distance": distance,
                }
              });
              Get.back();
              Get.snackbar("Succcess", "anda telah berhasil mengisi daftar hadir (MASUK)");
            }, 
            child: Text("YES"),
          ),
        ]
        );
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    // get current user
    String uid = await auth.currentUser!.uid;

    // update data gps ke firestore
    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      "address": address,
    });
  }

  // hasil modifikasi dari aslinya
  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      //return Future.error('Location services are disabled.');
      return {
        "message": "Layanan GPS tidak diaktifkan.",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        //return Future.error('Location permissions are denied');
        return {
          "message": "Izin lokasi ditolak.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Izin lokasi ditolak secara permanen, silahkan ubah setting lokasi anda",
        "error": true,
      };
      //return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return {
      "position": position,
      "message": "success mendapatkan posisi device",
      "error": false,
    };
  }
}
