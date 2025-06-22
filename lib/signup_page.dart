import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Student fields
  final TextEditingController registerNoController = TextEditingController();
  final TextEditingController cgpaController = TextEditingController();
  final TextEditingController arrearsController = TextEditingController();
  final TextEditingController tenthPercentageController = TextEditingController();
  final TextEditingController twelfthPercentageController = TextEditingController();
  final TextEditingController casteController = TextEditingController();

  // Staff fields
  final TextEditingController staffIdController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  String? selectedDepartment;
  String? selectedYear;
  String userType = 'Student'; // default selection

  final List<String> departments = [
    'Computer Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Biotechnology',
    'Chemical Engineering',
    'Aerospace Engineering',
    'Information Technology',
    'Electronics and Communication',
    'Architecture',
    'Automobile Engineering',
    'Environmental Engineering',
  ];

  final List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  Future<void> _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          if (userType == 'Student') {
            await _firestore.collection('Student').doc(user.uid).set({
              'uid': user.uid,
              'role': 'Student',
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'registerNo': registerNoController.text.trim(),
              'department': selectedDepartment ?? '',
              'year': selectedYear ?? '',
              'cgpa': cgpaController.text.trim(),
              'arrears': arrearsController.text.trim(),
              'tenthPercentage': tenthPercentageController.text.trim(),
              'twelfthPercentage': twelfthPercentageController.text.trim(),
              'caste': casteController.text.trim(),

              
              'createdAt': FieldValue.serverTimestamp(),
            });

            Navigator.pushNamed(context, '/student_dashboard');
          } else {
            await _firestore.collection('Staff').doc(user.uid).set({
              'uid': user.uid,
              'role': 'Staff',
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'staffId': staffIdController.text.trim(),
              'designation': designationController.text.trim(),
              'department': selectedDepartment ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });

            Navigator.pushNamed(context, '/staff_dashboard');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔘 Role Toggle
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: Text('Student'),
                      value: 'Student',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() => userType = value.toString());
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text('Staff'),
                      value: 'Staff',
                      groupValue: userType,
                      onChanged: (value) {
                        setState(() => userType = value.toString());
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Common Fields
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter your email' : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: InputDecoration(labelText: 'Department'),
                items: departments.map((String dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => selectedDepartment = newValue),
                validator: (value) => value == null ? 'Select department' : null,
              ),
              SizedBox(height: 10),

              // 👩‍🎓 Student Fields
              if (userType == 'Student') ...[
                TextFormField(
                  controller: registerNoController,
                  decoration: InputDecoration(labelText: 'Register Number'),
                  validator: (value) => value!.isEmpty ? 'Enter Register Number' : null,
                ),
                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedYear,
                  decoration: InputDecoration(labelText: 'Year'),
                  items: years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedYear = newValue),
                  validator: (value) => value == null ? 'Select year' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: cgpaController,
                  decoration: InputDecoration(labelText: 'CGPA'),
                  validator: (value) => value!.isEmpty ? 'Enter CGPA' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: arrearsController,
                  decoration: InputDecoration(labelText: 'Arrears'),
                  validator: (value) => value!.isEmpty ? 'Enter arrears' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: tenthPercentageController,
                  decoration: InputDecoration(labelText: '10th Percentage'),
                  validator: (value) => value!.isEmpty ? 'Enter 10th %' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: twelfthPercentageController,
                  decoration: InputDecoration(labelText: '12th Percentage'),
                  validator: (value) => value!.isEmpty ? 'Enter 12th %' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: casteController,
                  decoration: InputDecoration(labelText: 'Caste'),
                  validator: (value) => value!.isEmpty ? 'Enter caste' : null,
                ),
                SizedBox(height: 10),
              ],

              // 👨‍🏫 Staff Fields
              if (userType == 'Staff') ...[
                TextFormField(
                  controller: staffIdController,
                  decoration: InputDecoration(labelText: 'Staff ID'),
                  validator: (value) => value!.isEmpty ? 'Enter Staff ID' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Designation'),
                  validator: (value) => value!.isEmpty ? 'Enter Designation' : null,
                ),
                SizedBox(height: 10),
              ],

              ElevatedButton(
                onPressed: _signUpUser,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
