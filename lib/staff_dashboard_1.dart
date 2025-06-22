import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  _StaffDashboardPageState createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  int _selectedIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  File? _staffImage;
  File? _circularFile;

  String? selectedYear;
  String? selectedDepartment;
  String? selectedCGPA;

  Map<String, dynamic>? staffData;

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  Future<void> _fetchStaffDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('staffs')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            staffData = doc.data();
          });
        }
      }
    } catch (e) {
      print('Error fetching staff details: $e');
    }
  }

  Future<void> _pickStaffImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _staffImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCircularFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _circularFile = File(pickedFile.path);
      });
    }
  }

  void _uploadCircular() {
    if (_circularFile != null) {
      print('Uploading circular: ${_circularFile!.path}');
    }
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              _selectPage(6);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
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
        if (index == 7) {
          _logout();
        } else {
          _selectPage(index);
        }
      },
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
                  onTap: _pickStaffImage,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        _staffImage != null ? FileImage(_staffImage!) : null,
                    child: _staffImage == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  staffData?['name'] ?? 'Staff Name',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Dept: ${staffData?['department'] ?? 'AI & DS'}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem('Search Students', Icons.search, 1),
          _buildDrawerItem('Send Messages', Icons.message, 2),
          _buildDrawerItem('Upload Circulars', Icons.upload_file, 3),
          _buildDrawerItem('Upload Subject Details', Icons.subject, 4),
          _buildDrawerItem('Feedback', Icons.feedback, 5),
          _buildDrawerItem('Staff Details', Icons.person, 6),
          _buildDrawerItem('Logout', Icons.logout, 7),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 1:
        return _buildSearchStudentsPage();
      case 2:
        return _buildMessagePage();
      case 3:
        return _buildCircularUploadPage();
      case 4:
        return _buildSubjectDetailsPage();
      case 5:
        return _buildFeedbackForm();
      case 6:
        return _buildStaffDetailsPage();
      default:
        return const Center(child: Text('Select an option from the drawer'));
    }
  }

  // =============== PAGE BUILDERS ================

    List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Widget _buildSearchStudentsPage() => _wrapCard(
        title: 'Search Students',
        children: [
          _buildDropdown('Select Year', ['1st Year', '2nd Year', '3rd Year', '4th Year'], (val) => selectedYear = val),
          _buildDropdown('Select Department', ['CSE', 'IT', 'AI & DS', 'ECE'], (val) => selectedDepartment = val),
          TextField(controller: _regNoController, decoration: InputDecoration(labelText: 'Search by Reg No / Name')),
          const SizedBox(height: 16),
          _buildActionButton('Search', _performStudentSearch),
          const SizedBox(height: 16),
          if (_isSearching) Center(child: CircularProgressIndicator()),
          ..._searchResults.map((student) => Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(student['name'] ?? 'No Name'),
                  subtitle: Text(
                      'Reg No: ${student['registerNo'] ?? 'N/A'}\nDept: ${student['department'] ?? 'N/A'}\nYear: ${student['year'] ?? 'N/A'}'),
                  isThreeLine: true,
                ),
              )),
        ],
      );

  Future<void> _performStudentSearch() async {
    final query = _regNoController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Student')
          .where('keywords', arrayContains: query)
          .get();

      final results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error searching students: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }


  Widget _buildMessagePage() => _wrapCard(
        title: 'Send Messages',
        children: [
          TextField(controller: _messageController, maxLines: 4, decoration: InputDecoration(labelText: 'Type your message')),
          _buildDropdown('Select Year', ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'], (val) => selectedYear = val),
          _buildDropdown('Select Department', ['All', 'CSE', 'IT', 'AI & DS', 'ECE'], (val) => selectedDepartment = val),
          _buildDropdown('Select CGPA Filter', [
            'All',
            'CGPA 8.5+ without arrears',
            'CGPA 8.5+ with arrears',
            'CGPA 8.0+ without arrears',
            'CGPA 8.0+ with arrears'
          ], (val) => selectedCGPA = val),
          _buildActionButton('Send Message', () {}),
        ],
      );

  Widget _buildCircularUploadPage() => _wrapCard(
        title: 'Upload Circulars',
        children: [
          _buildDropdown('Select Year', ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'], (val) => selectedYear = val),
          _buildDropdown('Select Department', ['All', 'CSE', 'IT', 'AI & DS', 'ECE', 'MAE', 'CME'], (val) => selectedDepartment = val),
          _buildDropdown('Select CGPA Filter', [
            'All',
            'CGPA 8.5+ without arrears',
            'CGPA 8.5+ with arrears',
            'CGPA 8.0+ without arrears',
            'CGPA 8.0+ with arrears'
          ], (val) => selectedCGPA = val),
          _buildActionButton('Pick Circular', _pickCircularFile),
          if (_circularFile != null)
            Text('Selected file: ${_circularFile!.path.split('/').last}', style: TextStyle(color: Colors.grey)),
          if (_circularFile != null)
            _buildActionButton('Send Circular', _uploadCircular),
        ],
      );

  Widget _buildSubjectDetailsPage() => _wrapCard(
        title: 'Subjects Details (Google Classroom Style)',
        children: [
          Text('Subject listing UI can be added here.'),
        ],
      );

  Widget _buildFeedbackForm() => _wrapCard(
        title: 'Feedback',
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Your Name')),
          TextField(controller: _regNoController, decoration: InputDecoration(labelText: 'Register No')),
          TextField(controller: _issueController, maxLines: 5, decoration: InputDecoration(labelText: 'Issue')),
          _buildActionButton('Submit', () {}),
        ],
      );

  Widget _buildStaffDetailsPage() => _wrapCard(
        title: 'Staff Details',
        children: [
          Text('Name: ${staffData?['name'] ?? 'N/A'}'),
          Text('Register No: ${staffData?['registerNo'] ?? 'N/A'}'),
          Text('Date of Birth: ${staffData?['dob'] ?? 'N/A'}'),
          Text('Details: ${staffData?['details'] ?? 'Senior Lecturer in AI & DS'}'),
        ],
      );

  // ============== UI HELPERS ==============

  Widget _wrapCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: (val) => setState(() => onChanged(val!)),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: Icon(Icons.account_circle), onPressed: _showProfileOptions),
        ],
      ),
      drawer: _buildDrawer(),
      body: _getPage(_selectedIndex),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StaffDashboardPage(),
    debugShowCheckedModeBanner: false,
  ));
}
