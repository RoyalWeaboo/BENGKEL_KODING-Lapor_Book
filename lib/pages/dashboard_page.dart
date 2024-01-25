// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/pages/all_laporan_page.dart';
import 'package:lapor_book/pages/my_laporan_page.dart';
import 'package:lapor_book/pages/profile_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardFull();
  }
}

class DashboardFull extends StatefulWidget {
  const DashboardFull({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardFull();
}

class _DashboardFull extends State<DashboardFull> {
  int _selectedIndex = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    getAkun();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Akun akun = Akun(
    uid: '',
    docId: '',
    nama: '',
    noHP: '',
    email: '',
    role: '',
  );

  void getAkun() async {
    setState(() {
      _isLoading = true;
    });

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.vpn) {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('akun')
            .where('uid', isEqualTo: _auth.currentUser!.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();

          setState(() {
            akun = Akun(
              uid: userData['uid'],
              nama: userData['nama'],
              noHP: userData['noHP'],
              email: userData['email'],
              docId: userData['docId'],
              role: userData['role'],
            );
          });
        }
      } catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void keluar(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    pages = <Widget>[
      AllLaporan(akun: akun),
      MyLaporan(akun: akun),
      Profile(akun: akun),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 35),
        onPressed: () {
          Navigator.pushNamed(context, '/add', arguments: {
            'akun': akun,
          });
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text(
          'Lapor Book',
          style: headerStyle(
            level: 2,
            dark: false,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        selectedFontSize: 16,
        unselectedItemColor: Colors.grey[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Semua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Laporan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : pages.elementAt(_selectedIndex),
    );
  }
}
