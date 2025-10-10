import 'dart:io';
import 'package:camera/camera.dart';
import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/community_post_update_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:community_report_app/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditCommunityPostUpdateScreen extends StatefulWidget {
  final int postId;
  final int communityPostUpdateId;

  const EditCommunityPostUpdateScreen({
    super.key,
    required this.postId,
    required this.communityPostUpdateId,
  });

  @override
  State<EditCommunityPostUpdateScreen> createState() =>
      _EditCommunityPostUpdateScreenState();
}

class _EditCommunityPostUpdateScreenState
    extends State<EditCommunityPostUpdateScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final CustomTheme _customTheme = CustomTheme();
  final ImagePicker _imagePicker = ImagePicker();
  bool isRetakePhoto = false;

  XFile? _capturedImage;
  bool _cameraStatusPermission = false;
  String _cameraStatusPermissionMessage = "Checking camera permission...";
  bool _isSubmitting = false;
  bool _isInitialized = false;

  bool _isFetched = false;
  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetched) {
      final communityPostUpdateProvider =
          Provider.of<CommunityPostUpdateProvider>(context, listen: false);
      communityPostUpdateProvider.fetchCommunityPostUpdate(
        widget.communityPostUpdateId,
      );
      _isFetched = true;
    }
  }

  Future<void> _initAsync() async {
    await _checkPermission();

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
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    var cameraPermission = await Permission.camera.request();

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
      _cameraStatusPermissionMessage = "Camera permission granted";
      _cameraStatusPermission = true;
    });
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera not initialized');
      return;
    }

    try {
      await _cameraController?.pausePreview();
      final XFile file = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = file;
      });

      if (mounted) {
        await _cameraController?.pausePreview();
      }
      isRetakePhoto = false;
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
        isRetakePhoto = false;
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
    final communityPostUpdateProvider = context
        .read<CommunityPostUpdateProvider>();

    bool hasLocalImage = _capturedImage != null;
    bool hasNetworkImage =
        !hasLocalImage &&
        communityPostUpdateProvider.currentCommunityPostUpdate?.photo != null &&
        communityPostUpdateProvider
            .currentCommunityPostUpdate!
            .photo!
            .isNotEmpty;

    if (!hasLocalImage && !hasNetworkImage) {
      return Container(
        height: 300,
        color: CustomTheme.green.withOpacity(0.3),
        child: Center(
          child: Text(
            "No image available",
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
        child: hasLocalImage
            ? Image.file(
                File(_capturedImage!.path),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.network(
                communityPostUpdateProvider.currentCommunityPostUpdate!.photo!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: CustomTheme.green.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomTheme.lightGreen,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: CustomTheme.green.withOpacity(0.3),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Failed to load image",
                            style: CustomTheme().smallFont(
                              Colors.red,
                              FontWeight.w400,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _submitPost(
    String? userId,
    CommunityPostUpdateProvider communityPostProvider,
  ) async {
    if (!communityPostProvider.postKey.currentState!.validate()) {
      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Please fill all required fields",
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await communityPostProvider.updateCommunityPostUpdate(
        userId,
        widget.communityPostUpdateId,
        _capturedImage != null ? File(_capturedImage!.path) : null,
        communityPostProvider.currentCommunityPostUpdate!.photo!,
        widget.postId,
      );

      await Provider.of<CommunityPostProvider>(
        context,
        listen: false,
      ).fetchPost(widget.postId);

      CustomTheme().customScaffoldMessage(
        context: context,
        message: "Post submitted successfully!",
        backgroundColor: Colors.green,
      );

      Navigator.pop(context);
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
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController?.resumePreview();
      setState(() {
        _capturedImage = null;
        isRetakePhoto = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: CustomTheme.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Edit Post Update",
              style: CustomTheme().smallFont(
                CustomTheme.green,
                FontWeight.bold,
                context,
              ),
            ),
            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: CustomTheme().superSmallFont(
                CustomTheme.green,
                FontWeight.bold,
                context,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: CustomTheme.borderRadius,
            border: Border.all(color: CustomTheme.lightGreen),
          ),
          child: Consumer<CommunityPostUpdateProvider>(
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
                      Center(
                        child: Text(
                          "Edit Post Update",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF249A00),
                          ),
                        ),
                      ),
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     borderRadius: CustomTheme.borderRadius,
                      //     border: Border.all(
                      //       color: CustomTheme.lightGreen,
                      //       width: 2,
                      //     ),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       Center(
                      //         child: Text(
                      //           "Edit Profile",
                      //           style: TextStyle(
                      //             fontSize: 32,
                      //             fontWeight: FontWeight.w700,
                      //             color: const Color(0xFF249A00),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 30),

                      _customTheme.customTextField(
                        context: context,
                        controller: postProvider.titleController,
                        label: "Title",
                        hint: "Enter title",
                        // readOnly: isEdit,
                        // enabled: !isEdit,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a title";
                          }
                          if (value.trim().length < 3) {
                            return "Title must be at least 3 characters";
                          }
                          if (value.trim().length > 100) {
                            return "Title must not exceed 100 characters";
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
                          if (value.trim().length > 500) {
                            return "Description must not exceed 500 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // _customTheme.customDropdown<bool>(
                      //   context: context,
                      //   value: postProvider.isResolved,
                      //   items: const [false, true],
                      //   label: "Is Resolved",
                      //   hint: "Select status",
                      //   // enabled: !isEdit,
                      //   onChanged: (value) {
                      //     postProvider.setIsResolved(value!);
                      //   },
                      //   validator: (value) {
                      //     if (value == null) {
                      //       return "Please select a category";
                      //     }
                      //     return null;
                      //   },
                      // ),
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
                                  : () => _submitPost(
                                      profileProvider.profile!.uid,
                                      postProvider,
                                    ),
                              isLoading: _isSubmitting,
                              context: context,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      if (isRetakePhoto) ...[
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
