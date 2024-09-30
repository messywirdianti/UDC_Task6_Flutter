import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Item {
  final String email;
  final String first_name;
  final String last_name;
  final String Avatar;

  Item({required this.email, required this.first_name, required this.last_name, required this.Avatar});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      Avatar: json['avatar'] ?? 'https://reqres.in/img/faces/7-image.jpg',
    );
  }
}

Future<List<Item>> fetchItems() async {
  final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse['data'];
    return data.map((json) => Item.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}


class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late Future<List<Item>> futureItems;
  TextEditingController search = TextEditingController();
  bool isSearch = true;
  bool isGrid = true;
  List<Item> filterList = [];

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems();

    search.addListener(() {
      setState(() {
        isSearch = search.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data User'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: search,
              decoration: const InputDecoration(hintText: 'Cari'),
            ),
          ),
          isSearch
              ? Expanded(
            child: FutureBuilder<List<Item>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found'));
                } else {
                  return GridView.builder(
                    itemCount: snapshot.data!.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail page if needed
                        },
                        child: GridTile(
                          footer: Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.email),
                              ],
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: item.Avatar,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
              : performSearch(),
        ],
      ),
    );
  }

  Widget performSearch() {
    return FutureBuilder<List<Item>>(
      future: futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        } else {
          filterList = snapshot.data!.where((item) {
            return item.email.toLowerCase().contains(search.text.toLowerCase());
          }).toList();

          return resulPencarian();
        }
      },
    );
  }

  Widget resulPencarian() {
    return Expanded(
      child: GridView.builder(
        itemCount: filterList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        itemBuilder: (context, index) {
          final item = filterList[index];
          return GestureDetector(
            onTap: () {
              // Navigate to detail page if needed
            },
            child: GridTile(
              footer: Container(
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.email),
                  ],
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: item.Avatar,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

