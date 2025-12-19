import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../utils/config.dart';
import 'login_screen.dart';
import 'main_app_screen.dart';
import '../utils/app_mode.dart';
import 'otp_request_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String verifiedPhone;

  const RegistrationScreen({super.key, required this.verifiedPhone});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cropsController = TextEditingController();

  final _basicFormKey = GlobalKey<FormState>();
  final _additionalFormKey = GlobalKey<FormState>();

  String? _selectedFarmerType;
  bool _showAdditionalDetails = false;

  final List<String> _farmerTypes = [
    'Small Scale Farmer',
    'Large Scale Farmer',
  ];

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.verifiedPhone;
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    if (!authController.isOtpVerifiedFor(widget.verifiedPhone)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OtpRequestScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A2216), // Dark forest green
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E7C8), // Light cream
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),

              // Basic Information Form
              if (!_showAdditionalDetails)
                Form(
                  key: _basicFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name*',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _mobileController,
                        readOnly: true,
                        validator: (value) {
                          if (!authController.isOtpVerifiedFor(
                            widget.verifiedPhone,
                          )) {
                            return 'Phone must be OTP verified to register';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Verified Mobile Number*',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < Config.passwordMinLength) {
                            return 'Password must be at least ${Config.passwordMinLength} characters';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:
                            authController.isLoading
                                ? null
                                : _validateBasicInfo,
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
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),

              // Additional Details Form
              if (_showAdditionalDetails)
                Form(
                  key: _additionalFormKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Additional Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0E7C8),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _stateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your state';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'State',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _districtController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your district';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'District',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _cropsController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter crops you grow';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Crops Grown',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedFarmerType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a farmer type';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Farmer Type',
                          labelStyle: const TextStyle(color: Color(0xFFE0E7C8)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E7C8),
                            ),
                          ),
                        ),
                        dropdownColor: const Color(0xFF0A2216),
                        style: const TextStyle(color: Colors.white),
                        items:
                            _farmerTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFarmerType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:
                            authController.isLoading ? null : _registerUser,
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
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login here',
                    style: TextStyle(
                      color: Color(0xFFE0E7C8),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateBasicInfo() {
    final authController = Provider.of<AuthController>(context, listen: false);
    if (!authController.isOtpVerifiedFor(widget.verifiedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify OTP before registering.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OtpRequestScreen()),
      );
      return;
    }

    if (_basicFormKey.currentState!.validate()) {
      setState(() {
        _showAdditionalDetails = true;
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_additionalFormKey.currentState!.validate()) {
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),

      phone: widget.verifiedPhone,
      password: _passwordController.text,
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      crops: _cropsController.text.trim(),
      farmerType: _selectedFarmerType,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => const MainAppScreen(mode: AppMode.authenticated),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cropsController.dispose();
    super.dispose();
  }
}
