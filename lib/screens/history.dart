import 'package:flutter/material.dart';

import 'home.dart';
import 'detail.dart';

class HistoryPage extends StatelessWidget {
  final List<Country> history;
  final Function(Country) onDeleteHistory;
  final VoidCallback onClearHistory;

  const HistoryPage({
    super.key,
    required this.history,
    required this.onDeleteHistory,
    required this.onClearHistory,
  });

  void showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hard Delete Riwayat'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus '
            'seluruh riwayat?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                onClearHistory();

                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Hard Delete Riwayat',
              onPressed: () {
                showDeleteAllDialog(context);
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, i) {
                final country = history[i];

                return Card(
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? Image.network(country.flagsPng!, width: 50)
                        : const SizedBox(width: 50),
                    title: Text(country.name),
                    subtitle: Text(country.region),

                    // Hard delete satu item riwayat
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        onDeleteHistory(country);
                      },
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(country: country),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
