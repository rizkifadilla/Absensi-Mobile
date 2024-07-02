import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'main_screen.dart'; // Import the MainScreen

class AbsenScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  AbsenScreen({required this.userData});

  @override
  _AbsenScreenState createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isFaceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await _cameraController!.initialize();
    _cameraController!.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _detectFaces(image);
      }
    });
    setState(() {});
  }

  void _initializeFaceDetector() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() {
          _isFaceDetected = true;
        });
      } else {
        setState(() {
          _isFaceDetected = false;
        });
      }
    } catch (e) {
      print("Error detecting faces: $e");
    } finally {
      _isDetecting = false;
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    final allBytes = image.planes.fold<Uint8List>(
      Uint8List(0),
      (previousValue, element) => Uint8List.fromList(previousValue + element.bytes),
    );

    final inputImageData = InputImageData(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: InputImageRotationMethods.fromRawValue(
              _cameraController!.description.sensorOrientation) ??
          InputImageRotation.Rotation_0deg,
      inputImageFormat:
          InputImageFormatMethods.fromRawValue(image.format.raw) ??
              InputImageFormat.NV21,
      planeData: image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    return InputImage.fromBytes(
      bytes: allBytes,
      inputImageData: inputImageData,
    );
  }

  Future<void> _submitAttendance(String filePath, BuildContext context) async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.45.148/absensi-online/absen/submit'),
    );
    
    request.fields['id_siswa'] = widget.userData['username'];
    request.fields['flag_absen'] = "M";
    request.fields['status_kehadiran'] = "Hadir";
    request.fields['lokasi_lat'] = position.latitude.toString();
    request.fields['lokasi_long'] = position.longitude.toString();
    request.fields['keterangan'] = "Absen Online";
    request.files.add(await http.MultipartFile.fromPath('foto', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      print("Attendance submitted successfully");
      _showSuccessDialog(context); // Pass the context here
    } else {
      print("Failed to submit attendance");
      _showErrorDialog(context); // Pass the context here
    }
  }

  Future<void> _captureAndSubmit(BuildContext context) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final picture = await _cameraController!.takePicture();
      final filePath = picture.path;
      await _submitAttendance(filePath, context); // Pass the context here
    }
  }


  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Attendance submitted successfully."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(
                      userData: widget.userData,
                    ), // Ganti MainScreen dengan nama layar utama Anda
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to submit attendance."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }



  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absen Screen'),
      ),
      body: Stack(
        children: [
          _cameraController == null
              ? Center(child: CircularProgressIndicator())
              : CameraPreview(_cameraController!),
          _isFaceDetected
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _captureAndSubmit(context);
                      },
                      child: Text('Absen'),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
