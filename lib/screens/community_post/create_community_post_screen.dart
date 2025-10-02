import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:community_report_app/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final CustomTheme _customTheme = CustomTheme();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _capturedImage;
  String _location = "Getting location...";
  bool _locationStatusPermission = false;
  String _locationStatusPermissionMessage = "Checking location permission...";
  bool _cameraStatusPermission = false;
  String _cameraStatusPermissionMessage = "Checking camera permission...";
  String _address = "Fetching address...";
  bool _isSubmitting = false;
  bool _isLocationLoading = true;
  double? _latitude;
  double? _longitude;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _checkPermission();
    if (_locationStatusPermission) {
      await _getLocation();
    }
    if (_cameraStatusPermission) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        print("No cameras available");
        return;
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Failed to initialize camera: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final postIndex = args?['postIndex'] as int?;

    final postProvider = context.read<CommunityPostProvider>();

    if (postIndex != null) {
      postProvider.getEditPost(postIndex);
    } else {
      postProvider.initializeNewPost();
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    bool locationServiceEnabled;
    LocationPermission locationPermission;

    var cameraPermission = await Permission.camera.request();

    locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      setState(() {
        _locationStatusPermission = false;
        _locationStatusPermissionMessage = "Location services are disabled";
      });
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Location services are disabled",
        backgroundColor: Colors.red,
      );
      return;
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        setState(() {
          _locationStatusPermission = false;
          _locationStatusPermissionMessage = "Location permission are disabled";
        });
        CustomTheme().customScaffoldMessage(
          context: context,
          message: "Location permission are disabled",
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatusPermission = false;
        _locationStatusPermissionMessage =
            "Location permission are permanently disabled";
      });
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Location permission are permanently disabled",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (cameraPermission.isDenied) {
      setState(() {
        _cameraStatusPermission = false;
        _cameraStatusPermissionMessage = "Camera permission denied";
      });
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Camera permission denied",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (cameraPermission.isPermanentlyDenied) {
      setState(() {
        _cameraStatusPermission = false;
        _cameraStatusPermissionMessage = "Camera permanently denied";
      });
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Camera permanently denied. Opening settings...",
        backgroundColor: Colors.red,
      );
      await openAppSettings();
      return;
    }

    setState(() {
      _locationStatusPermission = true;
      _cameraStatusPermissionMessage = "Camera permission granted";
      _cameraStatusPermission = true;
      _locationStatusPermissionMessage = "Location permission granted";
    });
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera not initialized');
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = file;
      });

      if (mounted) {
        await _cameraController?.pausePreview();
      }
    } catch (e) {
      print('Error taking photo: $e');
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Failed to take photo",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });

        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          await _cameraController?.pausePreview();
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Failed to pick image from gallery",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _getLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _location =
            "${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}";
      });

      final postProvider = context.read<CommunityPostProvider>();
      postProvider.setCoordinates(pos.latitude, pos.longitude);

      await _getAddressFromLatLng(pos.latitude, pos.longitude);
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _address = "Failed to get location";
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json",
    );

    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "community_report_app"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _address = data['display_name'] ?? "Address not found";
          _isLocationLoading = false;
        });
      } else {
        setState(() {
          _address = "Failed to get address";
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = "Error fetching address";
        _isLocationLoading = false;
      });
    }
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || _initializeControllerFuture == null) {
      return Container(
        height: 300,
        color: CustomTheme.green.withOpacity(0.3),
        child: Center(
          child: Text(
            "Camera not available",
            style: CustomTheme().mediumFont(
              CustomTheme.whiteKindaGreen,
              FontWeight.w400,
              context,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: CustomTheme.borderRadius,
        border: Border.all(color: CustomTheme.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.lightGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: CustomTheme.borderRadius,
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _cameraController!.value.isInitialized) {
              return AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              );
            } else {
              return Container(
                height: 300,
                color: CustomTheme.green.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomTheme.lightGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Initializing Camera...",
                        style: CustomTheme().mediumFont(
                          CustomTheme.whiteKindaGreen,
                          FontWeight.w400,
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCameraTaken() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: CustomTheme.borderRadius,
        border: Border.all(color: CustomTheme.lightGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: CustomTheme.borderRadius,
        child: Image.file(
          File(_capturedImage!.path),
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: CustomTheme.borderRadius,
        border: Border.all(color: CustomTheme.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: CustomTheme.lightGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                "Current Location",
                style: CustomTheme().smallFont(
                  CustomTheme.lightGreen,
                  FontWeight.w600,
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _address,
            style: CustomTheme().superSmallFont(
              Colors.black,
              FontWeight.w400,
              context,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            "Coordinates: $_location",
            style: CustomTheme().superSmallFont2(
              Colors.black87.withOpacity(0.7),
              FontWeight.w400,
              context,
            ),
          ),
          const SizedBox(height: 12),
          _buildLocationMap(_latitude!, _longitude!),
        ],
      ),
    );
  }

  Future<void> _submitPost(CommunityPostProvider postProvider) async {
    // Validate form
    if (!postProvider.postKey.currentState!.validate()) {
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Please fill all required fields",
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Check if image is captured
    if (_capturedImage == null) {
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Please capture or select an image",
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await postProvider.savePost(imageFile: File(_capturedImage!.path));

      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Post submitted successfully!",
        backgroundColor: Colors.green,
      );

      Navigator.pop(context, true);
    } catch (e) {
      print("Error submitting post: $e");
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Failed to submit post: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _retakePhoto() async {
    setState(() {
      _capturedImage = null;
    });

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController?.resumePreview();
    }
  }

  Widget _buildLocationMap(double latitude, double longitude) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: CustomTheme.whiteKindaGreen.withOpacity(0.3),
        borderRadius: CustomTheme.borderRadius,
        border: Border.all(color: CustomTheme.green.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: CustomTheme.borderRadius,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.community_report_app",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final postIndex = args?['postIndex'] as int?;

    final isEdit = postIndex != null;

    final allLocation = LocationItem.values.map((e) => e.displayName).toList();
    final allCategory = CategoryItem.values.map((e) => e.displayName).toList();
    final allUrgency = UrgencyItem.values.map((e) => e.displayName).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: CustomTheme.borderRadius,
            border: Border.all(color: CustomTheme.lightGreen),
          ),
          child: Consumer<CommunityPostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        "Error",
                        style: CustomTheme().largeFont(
                          Colors.red,
                          FontWeight.bold,
                          context,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        postProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: CustomTheme().smallFont(
                          Colors.black87,
                          FontWeight.w400,
                          context,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Go Back"),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: postProvider.postKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [CustomTheme.green, CustomTheme.lightGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: CustomTheme.borderRadius,
                          border: Border.all(
                            color: CustomTheme.lightGreen,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.post_add,
                              color: CustomTheme.whiteKindaGreen,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isEdit ? "Edit Post" : "Create Post",
                              style: CustomTheme().largeFont(
                                CustomTheme.whiteKindaGreen,
                                FontWeight.w700,
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_capturedImage != null) ...[
                        _customTheme.customTextField(
                          context: context,
                          controller: postProvider.titleController,
                          label: "Title",
                          hint: "Enter title",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter a title";
                            }
                            if (value.trim().length < 3) {
                              return "Title must be at least 3 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _customTheme.customTextField(
                          context: context,
                          controller: postProvider.descriptionController,
                          label: "Description",
                          hint: "Enter description",
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter a description";
                            }
                            if (value.trim().length < 3) {
                              return "Description must be at least 3 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _customTheme.customDropdown<String>(
                          context: context,
                          value:
                              postProvider.currentPost?.category?.isNotEmpty ==
                                  true
                              ? postProvider.currentPost?.category
                              : null,
                          items: allCategory,
                          label: "Category",
                          hint: "Select category",
                          onChanged: (value) {
                            postProvider.setCategory(value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please select a category";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _customTheme.customDropdown<String>(
                          context: context,
                          value:
                              postProvider.currentPost?.urgency?.isNotEmpty ==
                                  true
                              ? postProvider.currentPost?.urgency
                              : null,
                          items: allUrgency,
                          label: "Urgency",
                          hint: "Select urgency",
                          onChanged: (value) {
                            postProvider.setUrgency(value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please select an urgency";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _customTheme.customDropdown<String>(
                          context: context,
                          value:
                              postProvider.currentPost?.location?.isNotEmpty ==
                                  true
                              ? postProvider.currentPost?.location
                              : null,
                          items: allLocation,
                          label: "Location",
                          hint: "Select location",
                          onChanged: (value) {
                            postProvider.setLocation(value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please select a location";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        if (_isLocationLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      CustomTheme.lightGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Getting location...",
                                  style: CustomTheme().superSmallFont(
                                    CustomTheme.lightGreen,
                                    FontWeight.w400,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _buildLocationInfo(),

                        SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: CustomTheme.borderRadius,
                            border: Border.all(
                              color: CustomTheme.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    color: CustomTheme.lightGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Photo",
                                    style: CustomTheme().smallFont(
                                      CustomTheme.lightGreen,
                                      FontWeight.w600,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCameraTaken(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTheme().customActionButton(
                                text: "Retake",
                                icon: Icons.camera_alt_outlined,
                                onPressed: _retakePhoto,
                                backgroundColor: CustomTheme.lightGreen,
                                foregroundColor: CustomTheme.whiteKindaGreen,
                                context: context,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: CustomTheme().customActionButton(
                                text: "Submit Post",
                                icon: Icons.check_circle_outline,
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _submitPost(postProvider),
                                isLoading: _isSubmitting,
                                context: context,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        _buildCameraPreview(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTheme().customActionButton(
                                text: "Take Photo",
                                icon: Icons.camera_alt,
                                onPressed: _cameraStatusPermission
                                    ? _takePhoto
                                    : null,
                                context: context,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTheme().customActionButton(
                                text: "Gallery",
                                icon: Icons.photo_library,
                                onPressed: _pickFromGallery,
                                backgroundColor: CustomTheme.lightGreen,
                                foregroundColor: CustomTheme.whiteKindaGreen,
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
