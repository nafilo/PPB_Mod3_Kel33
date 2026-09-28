import 'package:flutter/material.dart';

import 'home.dart';
import 'detail.dart';

class FavoritePage extends StatelessWidget {
  final List<Country> favorites;
  final Function(Country) onToggleFavorite;
  final Function(Country) onOpenCountry;

  const FavoritePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenCountry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: favorites.isEmpty
          ? const Center(child: Text('Belum ada negara favorit'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final country = favorites[i];

                return Card(
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? Image.network(country.flagsPng!, width: 50)
                        : const SizedBox(width: 50),
                    title: Text(country.name),
                    subtitle: Text(country.region),

                    // Menghapus dari favorit
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        onToggleFavorite(country);
                      },
                    ),

                    onTap: () {
                      onOpenCountry(country);

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
