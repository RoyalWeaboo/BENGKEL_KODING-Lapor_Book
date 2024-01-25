// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/comment_dialog.dart';
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
  bool _isCommented = false;
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

  void commentDialog(Laporan laporan, Akun akun) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommentDialog(
          laporan: laporan,
          akun: akun,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                        leading: const Icon(Icons.person),
                        title: Center(
                            child: Text(
                          'Nama Pelapor',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        subtitle: Center(
                          child: Text(
                            laporan.nama,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: blackColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        trailing: const SizedBox(
                          width: 24,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: Center(
                            child: Text(
                          'Tanggal Laporan',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                        subtitle: Center(
                          child: Text(
                            DateFormat('dd MMMM yyyy').format(laporan.tanggal),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: blackColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: const Icon(Icons.location_on),
                              onTap: () {
                                launch(laporan.maps);
                              },
                            ),
                            Text(
                              "Lokasi",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
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
                        Column(
                          children: [
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
                            const SizedBox(height: 8),
                          ],
                        ),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            commentDialog(laporan, akun);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Tambah Komentar'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      (laporan.komentar ?? []).isNotEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'List Komentar',
                                  style: headerStyle(level: 3),
                                ),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: laporan.komentar?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: primaryColor,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              laporan.komentar![index].nama,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                color: whiteColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              laporan.komentar![index].isi,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: whiteColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const SizedBox(
                                      height: 8,
                                    );
                                  },
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
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
