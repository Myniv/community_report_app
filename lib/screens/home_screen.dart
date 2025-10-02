import 'dart:convert';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final locationItem = const [
    "Binong Permai",
    "Bintaro",
    "Kalibata",
    "Karawaci",
    "Kemanggisan Baru",
  ];
  String? selectedValue;
  final TextEditingController searchController = TextEditingController();
  LatLng? _currentPosition;
  // LatLng? _currentPosition = LatLng(
  //   -6.200000,
  //   106.816666,
  // ); // Jakarta coordinates
  final MapController _mapController = MapController();
  Future<void> _getLatLonFromAddress(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1",
    );
    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "flutter_app"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];
          return setState(() {
            _currentPosition = LatLng(double.parse(lat), double.parse(lon));
          });
        } else {
          print("No results found");
        }
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    selectedValue = profile?.location;

    if (selectedValue != null) {
      Future.microtask(() async {
        await _getLatLonFromAddress(selectedValue!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownSearch<String>(
                onChanged: (value) async {
                  setState(() {
                    selectedValue = value;
                  });
                  // selectedValue = value;
                  if (value != null) {
                    await _getLatLonFromAddress(value);
                    _mapController.move(_currentPosition!, 16.0);
                  }

                  print(selectedValue);
                },
                items: (f, cs) => locationItem,
                selectedItem: selectedValue,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    // icon: Icon(Icons.location_on, color: Color(0xFF249A00)),
                    prefixIcon: const Icon(Icons.place, color: Colors.green),
                    labelText: "Select Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                popupProps: PopupProps.bottomSheet(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                          });
                          // trigger rebuild pakai setState / state management
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Search location',
                    ),
                  ),
                  fit: FlexFit.loose,
                ),
              ),
            ),
            _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
                    // borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 300,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition!,
                          initialZoom: 16,
                          onMapReady: () {
                            if (_currentPosition != null) {
                              _mapController.move(_currentPosition!, 16.0);
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName:
                                "com.example.community_report_app",
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentPosition!,
                                width: 60,
                                height: 60,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                              // todo: fetch real markers location from backend
                              Marker(
                                point: LatLng(-6.25722, 106.84639),
                                width: 20,
                                height: 20,
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              Marker(
                                point: LatLng(-6.255446, 106.843134),
                                width: 20,
                                height: 20,
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return buildPostSection(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildPostSection(BuildContext context) {
  // todo: fetch posts from backend
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.07;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          30,
          horizontalPadding,
          0,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              // backgroundImage:
              //     (profile?.photo != null && profile!.photo!.isNotEmpty)
              //     ? NetworkImage(profile.photo!)
              //     : null,
              child: const Icon(Icons.person, size: 20),
              // child: (profile?.photo == null || profile!.photo!.isEmpty)
              //     ? const Icon(Icons.person, size: 20)
              //     : null,
            ),
            const SizedBox(width: 10),

            Text(
              'John Doe',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              '22 hours ago',
              style: const TextStyle(
                color: Color(0xFF249A00),
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            Container(
              width: 57,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFFE0FFDE),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Safety',
                style: TextStyle(
                  color: Color(0xFF249A00),
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding + 50,
          0,
          horizontalPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'The pedestrian signal at the main intersection near Mexico Square is not functioning. Cars don’t stop, and people are forced to cross dangerously. This puts children and elderly at high risk. Please fix urgently.',
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                style: TextStyle(
                  color: Colors.black /* Black */,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.92,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width:
                  MediaQuery.of(context).size.width -
                  (horizontalPadding + 50 + horizontalPadding),
              height:
                  (MediaQuery.of(context).size.width -
                      (horizontalPadding + 50 + horizontalPadding)) *
                  0.6,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://dishub.banjarmasinkota.go.id/wp-content/uploads/2024/11/lampu-lalu-lintas-punya-3-warna_169.jpg",
                  ),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
