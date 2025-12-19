import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'registration_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;

  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A2216),
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: const Color(0xFF0A2216),
        foregroundColor: const Color(0xFFE0E7C8),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'OTP sent to +91 ${widget.phone}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE0E7C8),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the OTP';
                    }
                    if (value.length < 4 || value.length > 6) {
                      return 'Enter the full OTP code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E7C8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E7C8)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E7C8),
                    foregroundColor: const Color(0xFF0A2216),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child:
                      authController.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                            'Verify',
                            style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    FocusScope.of(context).unfocus();

    final verified = await authController.verifyOtp(
      phone: widget.phone.trim(),
      otp: _otpController.text.trim(),
    );

    debugPrint("VERIFY OTP RESULT => $verified");

    if (verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone verified. Continue to register.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(verifiedPhone: widget.phone),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
