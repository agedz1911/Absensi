import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    isLoadingAddPegawai.value = true;
    if (passAdminC.text.isNotEmpty) {
      try {
        // auth dan simpan email admin
        String emailAdmin = auth.currentUser!.email!;

        final credentialAdmin = await auth.signInWithEmailAndPassword(
            email: emailAdmin, password: passAdminC.text);

        // create email user
        final pegawaicredential = await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (pegawaicredential.user != null) {
          String uid = pegawaicredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });

          await pegawaicredential.user!.sendEmailVerification();
          //logout email yang di daftarkan
          await auth.signOut();

          // login ulang yang mendaftarkan
          final credentialAdmin = await auth.signInWithEmailAndPassword(
              email: emailAdmin, password: passAdminC.text);

          Get.back(); // tutup dialog
          Get.back(); // Back to home
          Get.snackbar("Sukses", "Berhasil menambahkan data pegawai");
          
        }
        isLoadingAddPegawai.value = false;

        print(credentialAdmin);
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar("Error", "Mohon gunakan password yang lebih kuat");
          //print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Error",
              "Email sudah terdaftar, kamu tidak dapat menambahkan dengan email ini");
          //print('The account already exists for that email.');
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Error", "password yang anda masukan salah");
        } else {
          Get.snackbar("Error", "${e.code}");
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;
        //print(e);
        Get.snackbar("Error", "Tidak dapat menambahkan pegawai");
      }
    } else {
      isLoading.value = false;
      Get.snackbar("ERROR", "Password harus di isi untuk validasi");
    }
  }

  Future<void> addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("masukan password untuk validasi !"),
            SizedBox(height: 10),
            TextField(
              controller: passAdminC,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "password",
                border: OutlineInputBorder(),
              ),
            )
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              isLoading.value = false;
              Get.back();
            },
            child: Text("Cancel"),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoadingAddPegawai.isFalse) {
                  await prosesAddPegawai();
                }
                isLoading.value = false;
              },
              child: Text(
                  isLoadingAddPegawai.isFalse ? "ADD Pegawai" : "LOADING ..."),
            ),
          ),
        ],
      );
    } else {
      Get.snackbar("Error", "NIP, Nama, dan Email harus diisi");
    }
  }
}
