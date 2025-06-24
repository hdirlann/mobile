import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuDetailScreen extends StatelessWidget {
  static const String routeName = '/menu_detailscreen';

  const MenuDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Detail Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item['isSvg'] == true
                ? SvgPicture.asset(
              item['iconPath'] ?? 'assets/icons/default.svg',
              width: 100,
              height: 100,
            )
                : Image.asset(
              item['iconPath'] ?? 'assets/images/default.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text('Nama: ${item['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Kategori: ${item['category'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            Text('Deskripsi: ${item['description'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            Text('Kalori: ${item['calories'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            Text('Durasi: ${item['duration'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Resep:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...((item['recipe'] as List<dynamic>?)?.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              return Text('${idx + 1}. $step', style: const TextStyle(fontSize: 16));
            }).toList() ?? [const Text('Tidak ada resep')]),
          ],
        ),
      ),
    );
  }
}