import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsmobile/pages/edit_profile.dart';
import 'package:utsmobile/pages/favorites.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'sugeng';
  String _email = 'profile@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'sugeng';
      _email = prefs.getString('email') ?? 'profile@gmail.com';
    });
    print('User data loaded: name=$_name, email=$_email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _email,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff7B6F72),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                ).then((_) => _loadUserData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff92A3FD),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xff92A3FD)),
              title: const Text('Favorites'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                print('Navigating to /favorites');
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: Color(0xff92A3FD)),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xff92A3FD)),
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                print('Logged out, SharedPreferences cleared');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}