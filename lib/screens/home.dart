import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'detail.dart';

class HomePage extends StatefulWidget {
  // Tambahan tugas: data favorit dan riwayat
  final List<Country> favorites;
  final Function(Country) onToggleFavorite;
  final Function(Country) onOpenCountry;

  const HomePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenCountry,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;

  // Tambahan tugas: search
  String searchQuery = '';

  // Tambahan tugas: sorting/filter berdasarkan benua
  String selectedRegion = 'All';

  final List<String> regions = [
    'All',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
  ];

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');

    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();

      final List jsonData = jsonDecode(respBody);

      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  // Mengecek apakah negara sudah masuk favorit
  bool isFavorite(Country country) {
    return widget.favorites.any((item) => item.name == country.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No countries found'));
          }

          final list = snapshot.data!;

          // Search berdasarkan nama negara
          // dan filter berdasarkan region/benua
          final filteredList = list.where((country) {
            final matchesSearch = country.name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

            final matchesRegion =
                selectedRegion == 'All' || country.region == selectedRegion;

            return matchesSearch && matchesRegion;
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Country',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              // Sorting/filter berdasarkan benua
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Benua',
                    border: OutlineInputBorder(),
                  ),
                  items: regions.map((region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRegion = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text('No countries found'))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final country = filteredList[i];

                          return Card(
                            child: ListTile(
                              leading: country.flagsPng != null
                                  ? Image.network(country.flagsPng!, width: 50)
                                  : const SizedBox(width: 50),

                              title: Text(country.name),

                              subtitle: Text(country.region),

                              // Tombol favorit
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite(country)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite(country)
                                      ? Colors.red
                                      : null,
                                ),
                                onPressed: () {
                                  widget.onToggleFavorite(country);

                                  setState(() {});
                                },
                              ),

                              // Membuka detail sekaligus
                              // menambahkan negara ke riwayat
                              onTap: () {
                                widget.onOpenCountry(country);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(country: country),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<dynamic>? languages;
  final List<dynamic>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<dynamic>? langs;

    if (json['languages'] != null) {
      langs = (json['languages'] as List)
          .map((l) => l['name'].toString())
          .toList();
    }

    List<dynamic>? cur;

    if (json['currencies'] != null) {
      cur = (json['currencies'] as List)
          .map((c) => c['name'].toString())
          .toList();
    }

    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      languages: langs,
      currencies: cur,
    );
  }
}
