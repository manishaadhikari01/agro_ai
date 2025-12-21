import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/token_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await TokenService.getAccessToken();

    if (token == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final data = await ProfileService.fetchProfile();

    if (!mounted) return;

    if (data == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _profile = data;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await TokenService.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            _item('Name', _profile?['name']),
            _item('Phone', _profile?['phone']),
            _item('Email', _profile?['email']),
            _item('State', _profile?['state']),
            _item('District', _profile?['district']),
            _item('Address', _profile?['address']),
            _item('Farmer Type', _profile?['farmer_type']),
            _item('Crops', _profile?['crops_grown']),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.green),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _editProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value?.toString() ?? '-'),
      ),
    );
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _profile?['name'] ?? '');
    final emailCtrl = TextEditingController(text: _profile?['email'] ?? '');
    final stateCtrl = TextEditingController(text: _profile?['state'] ?? '');
    final districtCtrl = TextEditingController(
      text: _profile?['district'] ?? '',
    );
    final addressCtrl = TextEditingController(text: _profile?['address'] ?? '');

    final cropsCtrl = TextEditingController(
      text: _profile?['crops_grown'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: stateCtrl,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  TextField(
                    controller: districtCtrl,
                    decoration: const InputDecoration(labelText: 'District'),
                  ),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: cropsCtrl,
                    decoration: const InputDecoration(labelText: 'Crops'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await ProfileService.updateProfile(
                    data: {
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'state': stateCtrl.text,
                      'district': districtCtrl.text,
                      'crops': cropsCtrl.text,
                      'address': addressCtrl.text,
                    },
                  );

                  if (!mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    _loadProfile(); // 🔄 refresh profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update failed')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
