import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController currentC = TextEditingController();
  TextEditingController newPassC = TextEditingController();
  TextEditingController confPassC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void updatePass() async {
    if (currentC.text.isNotEmpty && newPassC.text.isNotEmpty && confPassC.text.isNotEmpty) {
      if(newPassC.text == confPassC.text) {
          isLoading.value = true;
        try {
          String emailUser = auth.currentUser!.email!;

          await auth.signInWithEmailAndPassword(email: emailUser, password: currentC.text);

          await auth.currentUser!.updatePassword(newPassC.text);
          
          Get.back();
          Get.snackbar("Success", "Berhasil update password");

        } on FirebaseAuthException catch (e) {
          if (e.code == "wrong-password") {
            Get.snackbar("Error", "Password yang dimasukan salah. tidak dapat update password");
          } else {
            Get.snackbar("Error", "${e.code.toLowerCase()}");
          }
        } catch (e) {
          Get.snackbar("Error", "Tidak dapat merubah password");
        } finally {
          isLoading.value = false;
        }
      } else {
      Get.snackbar("Error", "Confirm password tidak cocok");
      }
    } else {
      Get.snackbar("Error", "semua field harus di isi");
    }
  }
}
