import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart'; // Import SignUpPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String _selectedAccountType = '';
  bool _showLoginForm = false;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacementNamed(
          context, _selectedAccountType == 'teacher' ? '/staff_dashboard' : '/student_dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/login_background.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/act_title.png'),
                        fit: isMobile ? BoxFit.contain : BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAccountTypeOption('Teacher', 'assets/teacher.png', 'teacher'),
                      _buildAccountTypeOption('Student', 'assets/student.png', 'student'),
                    ],
                  ),
                  SizedBox(height: 30),
                  AnimatedOpacity(
                    opacity: _showLoginForm ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: _showLoginForm ? _buildLoginForm() : Container(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeOption(String label, String imagePath, String accountType) {
    bool isSelected = _selectedAccountType == accountType;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAccountType = accountType;
        _showLoginForm = true;
      }),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, child: Text('Forgot Password?')),
              Row(
                children: [
                  Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value!)),
                  Text('Remember Me'),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Login'),
                ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('New user?'),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage())),
                child: Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}