import 'package:absensi/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        final credential = await auth.signInWithEmailAndPassword(
                email: emailC.text, 
                password: passC.text
            );
            //print(credential);

            // kondisi pertama
            if (credential.user != null){
              // kondisi kedua mengecek user email terverifikasi dan cek default password
              if(credential.user!.emailVerified == true) {
                isLoading.value = false;
                if(passC.text == "password") {
                  Get.offAllNamed(Routes.NEW_PASSWORD);
                } else {
                  Get.offAllNamed(Routes.HOME);
                }
              // akhir kondisi kedua
              } else {
                Get.defaultDialog(
                  title: "Belum Verifikasi",
                  middleText: "Akun anda belum Terverifikasi. lakukan verifikasi lewat tautan yang kami kirimkan ke email",
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        isLoading.value = false;
                        Get.back();
                      },  // tutup dialog 
                      child: Text("Cancel")
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await credential.user!.sendEmailVerification();
                          Get.back();
                          Get.snackbar("Success", "Berhasil mengirim email verifikasi");
                          isLoading.value = false;
                        } catch (e) {
                          isLoading.value = false;
                          Get.snackbar("Error", "Tidak dapat mengirim email verifikasi. Silahkan hubungi admin atau CS");
                        }
                      },  // kirim ulang email verifikasi 
                      child: Text("Kirim Ulang")
                    ),
                  ],
                );
              }
            }
            // akhir kondisi pertama
            isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          //print('No user found for that email.');
          Get.snackbar("Error", "email tidak terdaftar");
        } else if (e.code == 'wrong-password') {
          //print('Wrong password provided for that user.');
          Get.snackbar("Error", "Password yang anda masukan salah");
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "tidak dapat Login");
      }
    } else {
      Get.snackbar("Error", "Email dan Password Harus di isi");
    }
  }
}
