// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/input_widget.dart';
import '../components/styles.dart';
import '../components/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? email;
  String? password;

  void login() async {
    setState(() {
      _isLoading = true;
    });
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet ||
        connectivityResult == ConnectivityResult.vpn) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email!, password: password!);

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
        );
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
                    const SizedBox(height: 80),
                    Text(
                      'Login',
                      style: headerStyle(level: 1),
                    ),
                    const Text(
                      'Login to your account',
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
                                'Email',
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    email = value;
                                  }),
                                  validator: notEmptyValidator,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: blackColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: customInputDecoration(""),
                                ),
                              ),
                              InputLayout(
                                'Password',
                                TextFormField(
                                  onChanged: (String value) => setState(() {
                                    password = value;
                                  }),
                                  validator: notEmptyValidator,
                                  obscureText: true,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: blackColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: customInputDecoration(""),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                width: double.infinity,
                                child: FilledButton(
                                    style: buttonStyle,
                                    child: Text(
                                      'Login',
                                      style: headerStyle(
                                        level: 3,
                                        dark: false,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        login();
                                      }
                                    }),
                              )
                            ],
                          )),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? '),
                        InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Daftar Sekarang',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                    Image(
                      image: const AssetImage(
                        "assets/login_assets.jpg",
                      ),
                      width: MediaQuery.of(context).size.width * 0.75,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
