// UI login

import 'package:flutter/material.dart';
import '../../controllers/Login_controller.dart';
import "../auth/register_screen.dart";

import "../../models/user_model.dart";
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool _obscureText = true;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isRegisterMode) {
      final created = await _loginController.register(
        User(email: email, password: password),
      );
      if (!created) {
        _showMessage('Email đã tồn tại.', backgroundColor: Colors.red);
        return;
      }
      _showMessage('Đăng ký thành công. Vui lòng đăng nhập.');
      setState(() {
        _isRegisterMode = false;
      });
      _passwordController.clear();
    } else {
      final user = await _loginController.login(email, password);
      if (user == null) {
        _showMessage(
          'Email hoặc mật khẩu không đúng.',
          backgroundColor: Colors.red,
        );
        return;
      }
      _showMessage('Đăng nhập thành công.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    }
  }

  void _toggleMode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic bây giờ chỉ tập trung vào Login
    const titleText = 'Welcome back';
    const actionText = 'Log in';
    const switchText = 'Don\'t have an account? Register';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png',
                    height: 80,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Vui lòng nhập email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty)
                        return 'Vui lòng nhập mật khẩu';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút Đăng nhập
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _submit, // Hàm này sẽ gọi _loginController.login
                    child: const Text(actionText),
                  ),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {}, // Quên mật khẩu
                    child: const Text('Forgot password?'),
                  ),

                  const SizedBox(height: 16),
                  // Nút Chuyển sang trang Đăng ký
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed:
                        _toggleMode, // Gọi hàm Navigator.push đã sửa ở trên
                    child: const Text(switchText),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.all_inclusive, size: 16),
                      SizedBox(width: 4),
                      Text('Meta'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
