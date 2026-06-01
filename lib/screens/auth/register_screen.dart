import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // Đã thêm
import "../../controllers/login_controller.dart";
import "../../models/user_model.dart";
import "../main/main_screen.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode usernameFocus = FocusNode();

  bool emailError = false;
  bool passwordError = false;
  bool nameError = false;
  bool usernameError = false;
  bool isLoading = false;

  String? selectedMonth;
  String? selectedDay;
  String? selectedYear;

  final List<String> months = List.generate(12, (i) => "${i + 1}");
  final List<String> days = List.generate(31, (i) => "${i + 1}");
  final List<String> years = List.generate(100, (i) => "${2026 - i}");

  final LoginController _loginController = LoginController();

  void _handleSignUp() async {
    setState(() {
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.trim().isEmpty;
      nameError = nameController.text.trim().isEmpty;
      usernameError = usernameController.text.trim().isEmpty;
    });

    if (selectedMonth == null || selectedDay == null || selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng chọn đầy đủ ngày sinh!"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (!emailError && !passwordError && !nameError && !usernameError) {
      // Hiển thị Loading Dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Đang đăng ký..."),
                ],
              ),
            ),
          ),
        );
      }

      String birthdayStr = "$selectedDay/$selectedMonth/$selectedYear";

      User newUser = User(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        birthday: birthdayStr,
      );

      bool success = await _loginController.register(newUser);

      if (mounted) {
        // Đóng loading dialog
        Navigator.pop(context);

        if (success) {
          final String? currentFirebaseUid =
              fb_auth.FirebaseAuth.instance.currentUser?.uid;

          if (currentFirebaseUid != null) {
            try {
              // 🔥 KHỞI TẠO HỒ SƠ LÊN FIRESTORE
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentFirebaseUid)
                  .set({
                'uid': currentFirebaseUid,
                'email': emailController.text.trim(),
                'fullName': nameController.text.trim(),
                'username': usernameController.text.trim(),
                'birthday': birthdayStr,
                'bio': 'Chào mừng đến với Instagram clone! 🚀',
                'avatarUrl': '',
                'followersCount': 0,
                'followingCount': 0,
                'currentSong': "Thêm nhạc vào trang cá nhân",
                'musicUrl': "",
                'createdAt': FieldValue.serverTimestamp(),
              });
              print("🚀 Đã khởi tạo hồ sơ người dùng mới lên Firestore!");
            } catch (e) {
              print("❌ Lỗi khởi tạo Firestore: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Lỗi: ${e.toString()}"),
                      backgroundColor: Colors.red),
                );
              }
              return;
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Đăng ký thành công!"),
                  backgroundColor: Colors.green),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(firebaseUid: currentFirebaseUid),
              ),
              (route) => false,
            );
          }
        } else {
          // Hiển thị lỗi đăng ký
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Đăng ký thất bại! Vui lòng thử lại."),
                  backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    nameFocus.dispose();
    usernameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      "assets/icons/ins_logo.png",
                      height: 80,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 80),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Get started on Instagram",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign up to see photos and videos from your friends.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    buildTextField("Mobile number or email", emailController,
                        focusNode: emailFocus, isError: emailError),
                    buildTextField("Password", passwordController,
                        isPassword: true,
                        focusNode: passwordFocus,
                        isError: passwordError),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: buildDropdown(
                                months,
                                selectedMonth,
                                (val) => setState(() => selectedMonth = val),
                                "Month")),
                        const SizedBox(width: 8),
                        Expanded(
                            child: buildDropdown(
                                days,
                                selectedDay,
                                (val) => setState(() => selectedDay = val),
                                "Day")),
                        const SizedBox(width: 8),
                        Expanded(
                            child: buildDropdown(
                                years,
                                selectedYear,
                                (val) => setState(() => selectedYear = val),
                                "Year")),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildTextField("Name", nameController,
                        focusNode: nameFocus, isError: nameError),
                    buildTextField("Username", usernameController,
                        focusNode: usernameFocus, isError: usernameError),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isLoading ? "Đang xử lý..." : "Sign up",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.all_inclusive, size: 16),
                  SizedBox(width: 4),
                  Text("Meta"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false,
      required FocusNode focusNode,
      required bool isError}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: isError ? Colors.red : Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: isError ? Colors.red : Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(List<String> items, String? value,
      Function(String?) onChanged, String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ),
    );
  }
}
