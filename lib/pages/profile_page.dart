// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';

class Profile extends StatefulWidget {
  final Akun akun;
  const Profile({super.key, required this.akun});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;

  void keluar(BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.vpn) {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } else if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.signal_cellular_connected_no_internet_0_bar_outlined,
              color: Colors.red,
              size: 24,
            ),
            title: Text(
              "Tidak ada koneksi Internet",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              "Aplikasi Lapor Book memerlukan koneksi internet agar berjalan dengan baik",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: blackColor,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              widget.akun.nama,
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 40),
            ),
            Text(
              widget.akun.role,
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: primaryColor),
                ), // Sudut border
              ),
              child: Text(
                widget.akun.noHP,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: primaryColor),
                ), // Sudut border
              ),
              child: Text(
                widget.akun.email,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: buttonStyle,
                onPressed: () {
                  keluar(context);
                },
                child: const Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
          ],
        ),
      ),
    );
  }
}
