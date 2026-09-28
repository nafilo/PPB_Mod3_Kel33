import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../screens/profile.dart';
import '../screens/favorite.dart';
import '../screens/history.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // TAMBAHAN TUGAS
  final List<Country> _favorites = [];

  // TAMBAHAN TUGAS
  final List<Country> _history = [];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // TAMBAHAN TUGAS - FAVORIT
  void _toggleFavorite(Country country) {
    setState(() {
      final index = _favorites.indexWhere((item) => item.name == country.name);

      if (index >= 0) {
        _favorites.removeAt(index);
      } else {
        _favorites.add(country);
      }
    });
  }

  // TAMBAHAN TUGAS - RIWAYAT
  void _addHistory(Country country) {
    setState(() {
      // Kalau negara pernah dibuka,
      // hapus posisi lama terlebih dahulu.
      _history.removeWhere((item) => item.name == country.name);

      // Negara terbaru muncul paling atas.
      _history.insert(0, country);
    });
  }

  // TAMBAHAN TUGAS
  // Hard delete satu item.
  void _deleteHistory(Country country) {
    setState(() {
      _history.removeWhere((item) => item.name == country.name);
    });
  }

  // TAMBAHAN TUGAS
  // Hard delete seluruh riwayat.
  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        onOpenCountry: _addHistory,
      ),

      FavoritePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        onOpenCountry: _addHistory,
      ),

      HistoryPage(
        history: _history,
        onDeleteHistory: _deleteHistory,
        onClearHistory: _clearHistory,
      ),

      ProfilePage(onHomeTap: () => _onTabTapped(0)),
    ];

    return Scaffold(
      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,

        // Dibutuhkan karena item > 3
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
