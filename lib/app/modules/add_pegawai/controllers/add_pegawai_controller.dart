import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    if (nameC.text.isNotEmpty && nipC.text.isNotEmpty && emailC.text.isNotEmpty) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if(credential.user != null ){
          String uid = credential.user!.uid;
          
          await firestore.collection("pegawai").doc(uid).set({
            "nip" : nipC.text,
            "name" : nameC.text,
            "email" : emailC.text,
            "uid" : uid,
            "createdAt" : DateTime.now().toIso8601String(),
          });

          await credential.user!.sendEmailVerification();
        }

        print(credential);

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Error", "Mohon gunakan password yang lebih kuat");
          //print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Error", "Email sudah terdaftar, kamu tidak dapat menambahkan dengan email ini");
          //print('The account already exists for that email.');
        }
      } catch (e) {
        //print(e);
        Get.snackbar("Error", "Tidak dapat menambahkan pegawai");
      }
    } else {
      Get.snackbar("Error", "NIP, Nama, dan Email harus diisi");
    }
  }
}
