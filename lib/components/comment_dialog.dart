// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapor_book/components/input_widget.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/validators.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class CommentDialog extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;

  const CommentDialog({
    super.key,
    required this.laporan,
    required this.akun,
  });

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  late String status;
  String? comment;
  final _dialogFormKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void commentPost(Akun akun, Laporan laporan) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference laporanCollection =
          _firestore.collection('laporanbaru');

      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      await laporanCollection.doc(laporan.docId).set(
          {
            'komentar': FieldValue.arrayUnion([
              {'nama': akun.nama, 'isi': comment, 'timestamp': timestamp},
            ])
          },
          SetOptions(
            merge: true,
          )).catchError((e) {
        throw e;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Komentar ditambahkan"),
        ),
      );
      setState(() {
        _isLoading = false;
      });

      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    status = widget.laporan.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.laporan.judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Form(
                key: _dialogFormKey,
                child: TextFormField(
                  maxLines: 7,
                  onChanged: (String value) => setState(() {
                    comment = value;
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
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  commentPost(
                    widget.akun,
                    widget.laporan,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
