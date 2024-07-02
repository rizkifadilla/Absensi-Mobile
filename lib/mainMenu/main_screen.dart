import 'package:flutter/material.dart';
import 'data_absensi_screen.dart';
import 'form_ijin_screen.dart';
import 'absen_screen.dart';
import 'akun_screen.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Define userData variable type

  MainScreen({required this.userData}); // Constructor to receive userData

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;
  late double mainLatitude;
  late double mainLongitude;

  @override
  void initState() {
    super.initState();
    // Initialize the main location from userData
    mainLatitude = double.parse(widget.userData['lokasi_lat']);
    mainLongitude = double.parse(widget.userData['lokasi_long']);
    // Initialize the screens and navigation items based on the user's role
    _initializeScreensAndNavItems();
  }

  void _initializeScreensAndNavItems() {
    if (widget.userData['role'] == 'siswa') {
      _screens = [
        DataAbsensiScreen(userData: widget.userData),
        AbsenScreen(userData: widget.userData),
        AkunScreen(userData: widget.userData),
      ];
      _navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Data Absensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'Absen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Akun',
        ),
      ];
    } else if (widget.userData['role'] == 'orangtua') {
      _screens = [
        DataAbsensiScreen(userData: widget.userData),
        FormIjinScreen(userData: widget.userData),
        AkunScreen(userData: widget.userData),
      ];
      _navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Data Absensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note_add),
          label: 'Form Ijin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Akun',
        ),
      ];
    }
  }

  void _onTabTapped(int index) async {
    if (widget.userData['role'] == 'siswa' && index == 1) {
      // Check location validation only when clicking on the "Absen" tab
      bool isLocationValid = await _checkLocationValidation();
      if (!isLocationValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are not in the designated location to absen.'),
          ),
        );
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _checkLocationValidation() async {
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calculate the distance between user's location and the main location
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      mainLatitude,
      mainLongitude,
    );

    // Check if the distance is less than or equal to 1000 meters (1 km)
    return distanceInMeters <= 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMKN 2 Depok'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.teal[200],
        backgroundColor: Colors.teal[50],
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }
}
