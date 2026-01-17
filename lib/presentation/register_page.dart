import 'package:flutter/material.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';
import 'package:uas_3012310037/data/usecase/request/register_request.dart';
import '../data/repository/auth_repository.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  final _confirmPassCtr = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(httpService: HttpService());
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _emailCtr.dispose();
    _passCtr.dispose();
    _confirmPassCtr.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = RegisterRequest(
      name: _nameCtr.text,
      email: _emailCtr.text,
      password: _passCtr.text,
    );

    try {
      await _authRepository.register(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  headerSection(),
                  const SizedBox(height: 40),
                  formSection(),
                  const SizedBox(height: 40),
                  actionButton(),
                  const SizedBox(height: 30),
                  footerSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerSection() {
    return Column(
      children: const [
        Center(
          child: Text(
            "Create Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            "Sign up to get started",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget formSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputGroup(
          label: "Full Name",
          controller: _nameCtr,
          hint: "Enter your name",
          icon: Icons.person_outline,
          validator: (val) => val!.isEmpty ? "Name is required" : null,
        ),
        const SizedBox(height: 20),
        _buildInputGroup(
          label: "Email",
          controller: _emailCtr,
          hint: "Enter your email",
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          validator: (val) {
            if (val!.isEmpty) return "Email is required";
            if (!val.contains("@")) return "Invalid email format";
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInputGroup(
          label: "Password",
          controller: _passCtr,
          hint: "Create a password",
          icon: Icons.lock_outline,
          isObscure: _obscurePass,
          hasSuffix: true,
          onSuffixPressed: () => setState(() => _obscurePass = !_obscurePass),
          validator: (val) {
            if (val!.isEmpty) return "Password is required";
            if (val.length < 6) return "Min 6 characters";
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInputGroup(
          label: "Confirm Password",
          controller: _confirmPassCtr,
          hint: "Confirm your password",
          icon: Icons.lock_outline,
          isObscure: _obscureConfirm,
          hasSuffix: true,
          onSuffixPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          validator: (val) {
            if (val!.isEmpty) return "Please confirm password";
            if (val != _passCtr.text) return "Passwords do not match";
            return null;
          },
        ),
      ],
    );
  }

  Widget actionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget footerSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputGroup({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isObscure = false,
    bool hasSuffix = false,
    VoidCallback? onSuffixPressed,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: inputType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: hasSuffix
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: onSuffixPressed,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}