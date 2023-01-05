import 'package:absensi/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async {
    // kondisi pertama
    if(newPassC.text.isNotEmpty) {
      // kondisi kedua mengecek agar tidak sama password, save newpassword, logout, auto sign in dengan newpassword
      if(newPassC.text != "password") {
        try {
          String email = auth.currentUser!.email!;
          await auth.currentUser!.updatePassword(newPassC.text);

          await auth.signOut();

          await auth.signInWithEmailAndPassword(
            email: email, 
            password: newPassC.text
          );

          Get.offAllNamed(Routes.HOME);
          
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
          //print('No user found for that email.');
          Get.snackbar("Error", "Masukan password yang lebih kuat, setidaknya 6 karakter");
          } 
        } catch (e) {
          Get.snackbar("Error", "Tidak dapat membuat password baru. hubungi admin");
        }
        
      } else {
        Get.snackbar("Error", "password harus berbeda dengan sebelumnya");
      }
    }
    // akhir kondisi pertama 
    else {
      Get.snackbar("Error", "Password baru harus di isi");
    }
  }
}
