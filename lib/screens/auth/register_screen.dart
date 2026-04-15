import "package:flutter/material.dart";
import "../../controllers/login_controller.dart";
import "../../models/user_model.dart"; // Đảm bảo đường dẫn này đúng

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

  String? selectedMonth;
  String? selectedDay;
  String? selectedYear;

  final List<String> months = List.generate(12, (i) => "${i + 1}");
  final List<String> days = List.generate(31, (i) => "${i + 1}");
  final List<String> years = List.generate(100, (i) => "${2026 - i}");

  final LoginController _loginController = LoginController();

  // CHỈ GIỮ LẠI MỘT HÀM validateForm DUY NHẤT VÀ LÀ ASYNC
  void _handleSignUp() async {
    setState(() {
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.trim().isEmpty;
      nameError = nameController.text.trim().isEmpty;
      usernameError = usernameController.text.trim().isEmpty;
    });

    if (!emailError && !passwordError && !nameError && !usernameError) {
      User newUser = User(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        // Thêm name/username nếu Model Users của bạn có hỗ trợ
      );

      bool success = await _loginController.register(newUser);

      if (mounted) {
        // Kiểm tra xem widget còn tồn tại không trước khi dùng context
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng ký thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email đã tồn tại hoặc lỗi hệ thống!"),
              backgroundColor: Colors.red,
            ),
          );
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
                        onPressed: _handleSignUp, // Gọi hàm đã sửa
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white),
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

  // --- WIDGET HELPER ---
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
