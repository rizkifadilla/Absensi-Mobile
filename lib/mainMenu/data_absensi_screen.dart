import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataAbsensiScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  DataAbsensiScreen({required this.userData});

  @override
  _DataAbsensiScreenState createState() => _DataAbsensiScreenState();
}

class _DataAbsensiScreenState extends State<DataAbsensiScreen> {
  late Future<List<Map<String, dynamic>>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://192.168.45.148/absensi-online/absen/list_absen?id_siswa=${widget.userData['id_siswa']}')); // Menggunakan userData untuk mendapatkan id_siswa

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Absensi'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Tanggal Absen')),
                  DataColumn(label: Text('Keterangan Absen')),
                  DataColumn(label: Text('Foto')), // Tambahkan kolom Foto
                ],
                rows: data.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry['id_siswa'])),
                    DataCell(Text(entry['tanggal_absen'])),
                    DataCell(Text(entry['status_kehadiran'])),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          _showImageDialog('http://192.168.45.148/absensi-online/upload/absen/${entry['foto']}');
                        },
                        child: Text('Show'),
                      ),
                    ), // Tambahkan sel tombol Show
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
