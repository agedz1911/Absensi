import 'package:absensi/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller.emailC,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: "email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: controller.passC,
            autocorrect: false,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "password",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse) {
                  await controller.login();
                }
              },
              child: Text(controller.isLoading.isFalse ? "LOGIN" : "LOADING ..."),
              ),
            ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD), 
            child: Text("Lupa Password ?")
          ),
        ],
      ),
    );
  }
}
