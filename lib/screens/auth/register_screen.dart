import "package:flutter/material.dart";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// ✅ LOGO PNG
                    Image.asset(
                      "assets/icons/ins_logo.png",
                      height: 80,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Get started on Instagram",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Sign up to see photos and videos from your friends.",
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    buildTextField(
                      "Mobile number or email",
                      emailController,
                      focusNode: emailFocus,
                      isError: emailError,
                    ),

                    buildTextField(
                      "Password",
                      passwordController,
                      isPassword: true,
                      focusNode: passwordFocus,
                      isError: passwordError,
                    ),

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

                    buildTextField(
                      "Name",
                      nameController,
                      focusNode: nameFocus,
                      isError: nameError,
                    ),

                    buildTextField(
                      "Username",
                      usernameController,
                      focusNode: usernameFocus,
                      isError: usernameError,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: validateForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Sign up"),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// ✅ META (đặt ngoài scroll)
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

  void validateForm() {
    setState(() {
      emailError = emailController.text.isEmpty;
      passwordError = passwordController.text.isEmpty;
      nameError = nameController.text.isEmpty;
      usernameError = usernameController.text.isEmpty;
    });
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

  Widget buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    required FocusNode focusNode,
    required bool isError,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        onChanged: (value) {
          setState(() {
            if (controller == emailController) emailError = value.isEmpty;
            if (controller == passwordController) passwordError = value.isEmpty;
            if (controller == nameController) nameError = value.isEmpty;
            if (controller == usernameController) usernameError = value.isEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isError ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
    List<String> items,
    String? value,
    Function(String?) onChanged,
    String hint,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
