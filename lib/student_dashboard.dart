import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({Key? key}) : super(key: key);

  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  int _selectedIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  File? _studentImage;
  List<String> _messages = [];
  bool _isLoading = true;

  // Student details
  String studentName = "";
  String registerNo = "";
  String department = "";
  String year = "";
  String email = "";
  String cgpa = "";
  String arrears = "";

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user is logged in.");
        return;
      }

      String userId = user.uid;
      print("📌 Fetching student data for UID: $userId");

      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('Student')
          .doc(userId)
          .get();

      if (!studentSnapshot.exists) {
        print("❌ No student document found for UID: $userId");
        return;
      }

      var data = studentSnapshot.data() as Map<String, dynamic>;
      print("✅ Student Data: $data");

      setState(() {
        studentName = data['name'] ?? "Unknown";
        registerNo = data['registerNo'] ?? "Not Available";
        department = data['department'] ?? "Unknown";
        year = data['year'] ?? "Unknown";
        email = data['email'] ?? "Unknown";
        cgpa = data['cgpa'] ?? "N/A";
        arrears = data['arrears'] ?? "N/A";
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching student data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStudentImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _studentImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _showProfileOptions,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _getPage(_selectedIndex),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickStudentImage,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: _studentImage != null
                        ? FileImage(_studentImage!)
                        : null,
                    child: _studentImage == null
                        ? Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                Text(studentName, style: TextStyle(color: Colors.white)),
                Text('Dept: $department', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          _buildDrawerItem('View Profile', Icons.person, 0),
          _buildDrawerItem('CGPA & Arrear Status', Icons.school, 1),
          _buildDrawerItem('Circulars & Announcements', Icons.announcement, 2),
          _buildDrawerItem('Messages from Staff', Icons.message, 3),
          _buildDrawerItem('CGPA Calculator', Icons.calculate, 4),
          _buildDrawerItem('Logout', Icons.logout, 5),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _selectPage(index);
      },
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _selectPage(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _wrapContent(_buildStudentInfo());
      case 1:
        return _wrapContent(_buildCGPASection());
      case 2:
        return _wrapContent(_buildCircularsSection());
      case 3:
        return _wrapContent(_buildMessagesSection());
      case 4:
        return _wrapContent(_buildCGPACalculator());
      default:
        return Center(child: Text('Select an option from the drawer'));
    }
  }

  Widget _wrapContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Name: $studentName'),
            Text('Register No: $registerNo'),
            Text('Department: $department'),
            Text('Year: $year'),
            Text('Email: $email')
          ],
        ),
      ),
    );
  }

  Widget _buildCGPASection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CGPA & Arrear Status',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Current CGPA: $cgpa'),
            Text('Arrears: $arrears'),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Circulars & Announcements',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('No new circulars or announcements.'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messages from Staff',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('No new messages from staff.'),
          ],
        ),
      ),
    );
  }

  Widget _buildCGPACalculator() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CGPA Calculator',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
