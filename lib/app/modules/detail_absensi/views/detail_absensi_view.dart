import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_absensi_controller.dart';

class DetailAbsensiView extends GetView<DetailAbsensiController> {
  const DetailAbsensiView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail PRESENSI'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${DateFormat.yMMMMEEEEd().format(DateTime.now())}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Masuk",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("Jam :  ${DateFormat.jms().format(DateTime.now())}"),
                Text("Posisi : GPS"),
                Text("Status: dalam area"),
                SizedBox(height: 20),
                Text(
                  "Keluar",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("Jam :  ${DateFormat.jms().format(DateTime.now())}"),
                Text("Posisi : GPS"),
                Text("Status: dalam area"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
