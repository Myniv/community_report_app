import 'dart:convert';
import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/widgets/no_item.dart';
import 'package:community_report_app/widgets/post_section.dart';
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
  final allLocation = const [
    "Binong Permai",
    "Bintaro",
    "Kalibata",
    "Karawaci",
    "Kemanggisan Baru",
  ];
  String? selectLocation;
  String? selectCategory;
  String? selectUrgency;
  String? selectStatus;
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
    selectLocation = profile?.location;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CommunityPostProvider>().fetchPostsList(
        location: selectLocation,
        category: selectCategory,
        status: selectStatus,
        urgency: selectUrgency,
      );
    });

    if (selectLocation != null) {
      Future.microtask(() async {
        await _getLatLonFromAddress(selectLocation!);
      });
    } else {
      Future.microtask(() async {
        await _getLatLonFromAddress("Tangerang");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityPostProvider = context.watch<CommunityPostProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final communityPost = communityPostProvider.postListProfile;

    final allCategory = [
      'All',
      ...CategoryItem.values.map((e) => e.displayName).toList(),
    ];
    final allStatus = [
      'All',
      ...StatusItem.values.map((e) => e.displayName).toList(),
    ];
    final allUrgency = [
      'All',
      ...UrgencyItem.values.map((e) => e.displayName).toList(),
    ];
    final allLocation = [
      'All',
      ...LocationItem.values.map((e) => e.displayName).toList(),
    ];
    return Scaffold(
      floatingActionButton: profileProvider.profile?.role == 'admin'
          ? FloatingActionButton(
              backgroundColor: CustomTheme.green,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.pushNamed(context, '/edit_post');
                if (mounted) {
                  context.read<CommunityPostProvider>().fetchPostsList(
                    location: selectLocation,
                    category: selectCategory,
                    status: selectStatus,
                    urgency: selectUrgency,
                  );
                }
              },
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTheme().customDropdown2(
                    context: context,
                    hint: "Category",
                    value: selectCategory,
                    items: allCategory,
                    onChanged: (value) async {
                      setState(
                        () => selectCategory = value == 'All' ? null : value!,
                      );
                      if (value != null) {
                        await _getLatLonFromAddress(value);
                        _mapController.move(_currentPosition!, 16.0);
                      }
                      context.read<CommunityPostProvider>().fetchPostsList(
                        status: selectStatus,
                        category: selectCategory,
                        location: selectLocation,
                        urgency: selectUrgency,
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTheme().customDropdown2(
                    context: context,
                    hint: "Status",
                    value: selectStatus,
                    items: allStatus,
                    onChanged: (value) async {
                      setState(
                        () => selectStatus = value == 'All' ? null : value!,
                      );
                      if (value != null) {
                        await _getLatLonFromAddress(value);
                        _mapController.move(_currentPosition!, 16.0);
                      }
                      context.read<CommunityPostProvider>().fetchPostsList(
                        status: selectStatus,
                        category: selectCategory,
                        location: selectLocation,
                        urgency: selectUrgency,
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTheme().customDropdown2(
                    context: context,
                    hint: "Urgency",
                    value: selectUrgency,
                    items: allUrgency,
                    onChanged: (value) async {
                      setState(
                        () => selectUrgency = value == 'All' ? null : value!,
                      );
                      if (value != null) {
                        await _getLatLonFromAddress(value);
                        _mapController.move(_currentPosition!, 16.0);
                      }
                      context.read<CommunityPostProvider>().fetchPostsList(
                        status: selectStatus,
                        category: selectCategory,
                        location: selectLocation,
                        urgency: selectUrgency,
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTheme().customDropdown2(
                    context: context,
                    hint: "Location",
                    value: selectLocation,
                    items: allLocation,
                    onChanged: (value) async {
                      setState(
                        () => selectLocation = value == 'All' ? null : value!,
                      );
                      if (value != null) {
                        await _getLatLonFromAddress(value);
                        _mapController.move(_currentPosition!, 16.0);
                      }
                      context.read<CommunityPostProvider>().fetchPostsList(
                        status: selectStatus,
                        category: selectCategory,
                        location: selectLocation,
                        urgency: selectUrgency,
                      );
                    },
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: DropdownSearch<String>(
            //     onChanged: (value) async {
            //       setState(() {
            //         selectLocation = value;
            //       });
            //       // selectedValue = value;
            //       if (value != null) {
            //         await _getLatLonFromAddress(value);
            //         _mapController.move(_currentPosition!, 16.0);
            //       }

            //       context.read<CommunityPostProvider>().fetchPostsList(
            //         location: value,
            //       );

            //       print(selectLocation);
            //     },
            //     items: (f, cs) => allLocation,
            //     selectedItem: selectLocation,
            //     decoratorProps: DropDownDecoratorProps(
            //       decoration: InputDecoration(
            //         // icon: Icon(Icons.location_on, color: Color(0xFF249A00)),
            //         prefixIcon: const Icon(Icons.place, color: Colors.green),
            //         labelText: "Select Location",
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         contentPadding: const EdgeInsets.symmetric(
            //           horizontal: 12,
            //           vertical: 8,
            //         ),
            //       ),
            //     ),
            //     popupProps: PopupProps.bottomSheet(
            //       showSearchBox: true,
            //       searchFieldProps: TextFieldProps(
            //         controller: searchController,
            //         decoration: InputDecoration(
            //           prefixIcon: const Icon(Icons.search),
            //           suffixIcon: IconButton(
            //             icon: const Icon(Icons.clear, color: Colors.red),
            //             onPressed: () {
            //               setState(() {
            //                 searchController.clear();
            //               });
            //               // trigger rebuild pakai setState / state management
            //             },
            //           ),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           contentPadding: const EdgeInsets.symmetric(
            //             horizontal: 12,
            //             vertical: 8,
            //           ),
            //           hintText: 'Search location',
            //         ),
            //       ),
            //       fit: FlexFit.loose,
            //     ),
            //   ),
            // ),
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
            communityPostProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communityPost.isEmpty
                ? const NoItem(
                    title: "No Post",
                    subTitle: "You have no post yet",
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: communityPost.length,
                    itemBuilder: (context, index) {
                      final post = communityPost[index];
                      return PostSection(
                        postId: post.id,
                        profilePostId: post.user_id,
                        profilePhoto: post.user_photo,
                        username: post.username ?? "",
                        title: post.title ?? "",
                        description: post.description ?? "",
                        category: post.category ?? "",
                        urgency: post.urgency ?? "",
                        status: post.status ?? "",
                        location: post.location ?? "",
                        latitude: post.latitude ?? 0.0,
                        longitude: post.longitude ?? 0.0,
                        createdAt: post.created_at ?? DateTime.now(),
                        settingPostScreen: false,
                        postImage: post.photo,
                        onPostDeleted: () {
                          final profileProvider = context
                              .read<ProfileProvider>();
                          context.read<CommunityPostProvider>().fetchPostsList(
                            location: selectLocation,
                            category: selectCategory,
                            status: selectStatus,
                            urgency: selectUrgency,
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
