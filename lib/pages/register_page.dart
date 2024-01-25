// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapor_book/components/input_widget.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;

  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void register() async {
    setState(() {
      _isLoading = true;
    });
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.vpn) {
      try {
        CollectionReference akunCollection = _db.collection('akun');

        final password = _password.text;
        await _auth.createUserWithEmailAndPassword(
            email: email!, password: password);

        final docId = akunCollection.doc().id;
        await akunCollection.doc(docId).set({
          'uid': _auth.currentUser!.uid,
          'nama': nama,
          'email': email,
          'noHP': noHP,
          'docId': docId,
          'role': 'user',
        });

        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      } catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        print(e);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text('Register', style: headerStyle(level: 1)),
                    const Text(
                      'Create your profile to start your journey',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputLayout(
                              'Nama',
                              TextFormField(
                                onChanged: (String value) => setState(
                                  () {
                                    nama = value;
                                  },
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                validator: notEmptyValidator,
                                decoration: customInputDecoration(""),
                              ),
                            ),
                            InputLayout(
                              'Email',
                              TextFormField(
                                onChanged: (String value) => setState(
                                  () {
                                    email = value;
                                  },
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                validator: notEmptyValidator,
                                decoration: customInputDecoration(""),
                              ),
                            ),
                            InputLayout(
                              'No. Handphone',
                              TextFormField(
                                onChanged: (String value) => setState(
                                  () {
                                    noHP = value;
                                  },
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                validator: notEmptyValidator,
                                decoration: customInputDecoration(""),
                              ),
                            ),
                            InputLayout(
                              'Password',
                              TextFormField(
                                controller: _password,
                                validator: notEmptyValidator,
                                obscureText: true,
                                decoration: customInputDecoration(""),
                              ),
                            ),
                            InputLayout(
                              'Konfirmasi Password',
                              TextFormField(
                                validator: (value) =>
                                    passConfirmationValidator(value, _password),
                                obscureText: true,
                                decoration: customInputDecoration(""),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: FilledButton(
                                style: buttonStyle,
                                child: Text(
                                  'Register',
                                  style: headerStyle(
                                    level: 3,
                                    dark: false,
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    register();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Login Sekarang',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }
}
