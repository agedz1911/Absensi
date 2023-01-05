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
          ElevatedButton(
            onPressed: () {
              controller.login();
            },
             child: Text("LOGIN")
            ),
          TextButton(
            onPressed: (){}, 
            child: Text("Lupa Password ?")
          ),
        ],
      ),
    );
  }
}
