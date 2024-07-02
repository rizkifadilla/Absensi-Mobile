import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FormIjinScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  FormIjinScreen({required this.userData});

  @override
  _FormIjinScreenState createState() => _FormIjinScreenState();
}

class _FormIjinScreenState extends State<FormIjinScreen> {
  String? _selectedReason;
  TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Ijin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedReason,
              onChanged: (newValue) {
                setState(() {
                  _selectedReason = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Status Izin',
              ),
              items: ['Sakit', 'Izin'].map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Deskripsi Ijin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (result != null) {
                  setState(() {
                    _selectedFile = result.files.first;
                  });
                } else {
                  // Jika pengguna membatalkan pemilihan
                }
              },
              child: Text('Pilih Dokumen Pendukung (PDF)'),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _submitForm();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_selectedReason == null || _descriptionController.text.isEmpty || _selectedFile == null) {
      // Handle form validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select a PDF file.')),
      );
      return;
    }

    final uri = Uri.parse('http://192.168.45.148/absensi-online/absen/izin');
    var request = http.MultipartRequest('POST', uri);

    request.fields['id_orang_tua'] = widget.userData['username'];
    request.fields['desc_izin'] = _descriptionController.text;
    request.fields['izin_cuser'] = widget.userData['username'];
    request.fields['status_izin'] = _selectedReason!;

    request.files.add(await http.MultipartFile.fromPath(
      'dokumen_izin',
      _selectedFile!.path!,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully.')),
      );
    } else {
      // Handle failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit form.')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
