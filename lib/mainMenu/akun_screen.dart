import 'package:flutter/material.dart';
import '../login/login_form.dart'; // Import the LoginForm

class AkunScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  AkunScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(label: 'Nama', value: userData['nama_siswa']),
              _buildInfoRow(label: 'Kelas', value: userData['kelas']),
              _buildInfoRow(label: 'NIS', value: userData['username']),
              _buildInfoRow(label: 'Nama Orangtua', value: userData['nama_orang_tua']),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginForm()),
                    );
                  },
                  child: Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildInfoRow({required String label, required dynamic value}) {
    String displayValue = value ?? ''; // Provide a default value if value is null
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(displayValue.toString()), // Convert value to string and display
        ],
      ),
    );
  }
}
