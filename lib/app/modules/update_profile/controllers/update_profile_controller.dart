import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nipC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Future<void> updateProfile(String uid) async {
    if (nipC.text.isNotEmpty &&nameC.text.isNotEmpty && emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameC.text,
          };
        if(image != null ) {
          // proses upload file ke firebase storage
          File file = File(image!.path);
          String ext = image!.name.split(".").last;

          await storage.ref('$uid/img_profile.$ext').putFile(file);
          String urlImage = await storage.ref('$uid/img_profile.$ext').getDownloadURL();

          data.addAll({"img_profile": urlImage});

        }
        await firestore.collection("pegawai").doc(uid).update(data);
        image = null;
          Get.back();
          Get.snackbar("Success", "Berhasil update profile");
      } catch (e) {
        Get.snackbar("Error", "tidak dapat update profile");
      } finally {
        isLoading.value = false;
      }
    }
  }

  final ImagePicker picker = ImagePicker();
  XFile? image;

  void picImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    /* if (image != null) {
      print(image!.name);
      print(image!.name.split(".").last);
      print(image!.path);
    } else {
      print(image);
    } */
    update();
  }

  void deleteProfile(String uid) async {
    try {
    await firestore.collection("pegawai").doc(uid).update({
      "img_profile" : FieldValue.delete(),
    });
    Get.back();
    Get.snackbar("Success", "Berhasil delete profile picture");
    } catch (e) {
      Get.snackbar("Error", "Tidak dapat delete profile picture");
    } finally {
      update();
    }
  }
}
