import 'package:absensi/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
                email: emailC.text, 
                password: passC.text
            );
            print(credential);

            if (credential.user != null){
              if(credential.user!.emailVerified == true) {
                Get.offAllNamed(Routes.HOME);
              } else {
                Get.defaultDialog(
                  title: "Belum Verifikasi",
                  middleText: "Akun anda belum Terverifikasi. lakukan verifikasi lewat tautan yang kami kirimkan ke email",
                );
              }
            }
            
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          //print('No user found for that email.');
          Get.snackbar("Error", "email tidak terdaftar");
        } else if (e.code == 'wrong-password') {
          //print('Wrong password provided for that user.');
          Get.snackbar("Error", "Password yang anda masukan salah");
        }
      } catch (e) {
        Get.snackbar("Error", "tidak dapat Login");
      }
    } else {
      Get.snackbar("Error", "Email dan Password Harus di isi");
    }
  }
}
