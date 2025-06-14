import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuDetailScreen extends StatefulWidget {
  const MenuDetailScreen({super.key});

  static const routeName = '/menuDetail';

  @override
  _MenuDetailScreenState createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  bool _showRecipe = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Menu'),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No menu item selected'),
        ),
      );
    }

    final menuItem = args;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          menuItem['name'],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                menuItem['iconPath'],
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              menuItem['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              menuItem['description'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff7B6F72),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calories: ${menuItem['calories']}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff7B6F72),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Duration: ${menuItem['duration']}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff7B6F72),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showRecipe = true; // Tampilkan resep saat tombol ditekan
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff92A3FD),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lihat Resep',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_showRecipe)
              Expanded(
                child: ListView.builder(
                  itemCount: (menuItem['recipe'] as List).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              menuItem['recipe'][index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xff7B6F72),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (!_showRecipe)
              const SizedBox(
                height: 20,
                child: Center(
                  child: Text(
                    'Tekan "Lihat Resep" untuk melihat instruksi.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff7B6F72),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}