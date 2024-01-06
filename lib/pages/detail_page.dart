// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;
  bool _isLiked = false;
  String? status;
  final _firestore = FirebaseFirestore.instance;
  late Akun akun;
  late Laporan laporan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    laporan = arguments['laporan'];
    akun = arguments['akun'];

    checkLikeStatus(akun, laporan);
  }

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  void checkLikeStatus(Akun akun, Laporan laporan) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final DocumentSnapshot<Map<String, dynamic>> isLikedAlready =
          await _firestore
              .collection('laporan')
              .doc(laporan.docId)
              .collection('likedBy')
              .doc(akun.docId)
              .get();

      if (isLikedAlready.exists) {
        setState(() {
          _isLiked = true;
          print('is liked ke trigger');
        });
      } else {
        setState(() {
          _isLiked = false;
          _isLoading = false;
          print('not exist');
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
  }

  void likePost(Akun akun, Laporan laporan) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference laporanCollection = _firestore.collection('laporan');

      CollectionReference likeCollection =
          laporanCollection.doc(laporan.docId).collection('likedBy');
      final likeId = likeCollection.doc().id;

      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      await laporanCollection.doc(laporan.docId).update({
        'like': laporan.like + 1,
      }).catchError((e) {
        throw (e);
      });

      await likeCollection.doc(akun.docId).set({
        'uid': akun.docId,
        'docId': likeId,
        'nama': akun.nama,
        'noHp': akun.noHP,
        'email': akun.email,
        'role': akun.role,
        'timestamp': timestamp,
      }).catchError((e) {
        throw e;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda menyukai laporan ini"),
        ),
      );

      setState(() {
        _isLiked = true;
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      const SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/no_image_placeholder.png'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'On Process'
                                  ? textStatus(
                                      'On Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.thumb_up_alt_rounded),
                        title: Center(
                          child: StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('laporan')
                                  .doc(laporan.docId)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Ada Kesalahan');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Text(
                                    "Disukai oleh ${data['like']} orang");
                              }),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                      const SizedBox(height: 20),
                      if (akun.role == 'admin')
                        SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Ubah Status'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: _isLiked
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () {
                  likePost(akun, laporan);
                },
                child: const Icon(
                  Icons.thumb_up_alt_rounded,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor,
      {double? fontSize}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(16)),
      child: fontSize != null
          ? Text(
              text,
              style: TextStyle(
                color: textcolor,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: textcolor,
                fontSize: fontSize,
              ),
            ),
    );
  }
}
