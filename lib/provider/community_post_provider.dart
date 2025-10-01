import 'dart:io';

import 'package:community_report_app/models/community_post.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/services/community_post_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPostProvider with ChangeNotifier {
  final postKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  List<CommunityPost> _postsList = [];
  List<CommunityPost> get postList => _postsList;

  CommunityPost? _currentPost;
  CommunityPost? get currentPost => _currentPost;

  final picker = ImagePicker();

  int? _postIndex;
  int? get postIndex => _postIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isUploadingPhoto = false;
  bool get isUploadingPhoto => _isUploadingPhoto;

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;
  final _picker = ImagePicker();

  final CommunityPostServices _communityPostServices = CommunityPostServices();
  final ProfileProvider profileProvider;
  CommunityPostProvider(this.profileProvider);

  Future<void> fetchPosts({
    String? userId,
    String? status,
    String? category,
    String? location,
    bool? isReport,
    String? urgency,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final role = profileProvider.profile!.role;
      final uid = profileProvider.profile!.uid;

      _postsList = await _communityPostServices.getPosts(
        userId: userId,
        status: status,
        category: category,
        location: location,
        isReport: isReport,
        urgency: urgency,
      );
    } catch (e) {
      print("Error in provider: $e");
      _postsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializeNewPost() {
    _currentPost = CommunityPost(
      user_id: profileProvider.profile?.uid,
      status: 'pending',
      is_report: true,
    );
    _postIndex = null;
    titleController.clear();
    descriptionController.clear();
    _selectedImageFile = null;
    _errorMessage = null;
    print("New post initialized: ${_currentPost!.toMap()}");
    notifyListeners();
  }

  Future<void> getEditPost(int postId) async {
    final index = _postsList.indexWhere((post) => post.id == postId);

    if (index != -1) {
      _postIndex = postId;
      final post = _postsList[index];

      titleController.text = post.title ?? '';
      descriptionController.text = post.description ?? '';

      _currentPost = CommunityPost(
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        description: post.description,
        photo: post.photo,
        longitude: post.longitude,
        latitude: post.latitude,
        location: post.location,
        status: post.status,
        category: post.category,
        is_report: post.is_report,
        urgency: post.urgency,
        created_at: post.created_at,
        updated_at: post.updated_at,
        deleted_at: post.deleted_at,
      );

      print("Edit post loaded: ${_currentPost!.toMap()}");
      notifyListeners();
    }
  }

  void setCategory(String? value) {
    if (_currentPost != null) {
      _currentPost!.category = value;
      print("Category set to: $value");
      print("Current post state: ${_currentPost!.toMap()}");
    }
  }

  void setUrgency(String? value) {
    if (_currentPost != null) {
      _currentPost!.urgency = value;
      print("Urgency set to: $value");
    }
  }

  void setLocation(String? value) {
    if (_currentPost != null) {
      _currentPost!.location = value;
      print("Location set to: $value");
    }
  }

  void setCoordinates(double latitude, double longitude) {
    if (_currentPost != null) {
      _currentPost!.latitude = latitude;
      _currentPost!.longitude = longitude;
      print("Coordinates set to: $latitude, $longitude");
    }
  }

  void setStatus(String? value) {
    if (_currentPost != null) {
      _currentPost!.status = value;
    }
  }

  void setIsReport(bool? value) {
    if (_currentPost != null) {
      _currentPost!.is_report = value;
    }
  }

  void _setSelectedImageFile(File? file) {
    _selectedImageFile = file;
    notifyListeners();
  }

  void _setUploadingPhoto(bool value) {
    _isUploadingPhoto = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        print("Image picked: ${pickedFile.path}");
        _setSelectedImageFile(File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
      _errorMessage = "Failed to pick image: $e";
      _selectedImageFile = null;
      notifyListeners();
    }
  }

  Future<String?> uploadPhoto(File file) async {
    if (_currentPost == null) {
      _errorMessage = "No post loaded";
      notifyListeners();
      return null;
    }

    if (_currentPost!.id == null) {
      _errorMessage = "Post must be created before uploading photo";
      notifyListeners();
      return null;
    }

    _setUploadingPhoto(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _communityPostServices.uploadProfilePhoto(
        _currentPost!.id!,
        file,
        _currentPost!.photo ?? '',
      );

      _currentPost = _currentPost!.copyWith(photo: url);
      _errorMessage = null;
      notifyListeners();
      return url;
    } catch (e) {
      _errorMessage = "Failed to upload photo: $e";
      _selectedImageFile = null;
      notifyListeners();
      rethrow;
    } finally {
      _setUploadingPhoto(false);
    }
  }

  Future<void> savePost({File? imageFile}) async {
    if (_currentPost == null) {
      _errorMessage = "Post not initialized";
      notifyListeners();
      throw Exception("Post not initialized");
    }

    // Get current values
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    print("=== SAVE POST DEBUG ===");
    print("Title: '$title'");
    print("Description: '$description'");
    print("Category: ${_currentPost!.category}");
    print("Urgency: ${_currentPost!.urgency}");
    print("Location: ${_currentPost!.location}");
    print("Latitude: ${_currentPost!.latitude}");
    print("Longitude: ${_currentPost!.longitude}");
    print("User ID: ${_currentPost!.user_id}");
    print("Status: ${_currentPost!.status}");
    print("Is Report: ${_currentPost!.is_report}");

    // Validate required fields
    if (title.isEmpty) {
      _errorMessage = "Title is required";
      notifyListeners();
      throw Exception("Title is required");
    }

    if (description.isEmpty) {
      _errorMessage = "Description is required";
      notifyListeners();
      throw Exception("Description is required");
    }

    if (_currentPost!.category == null || _currentPost!.category!.isEmpty) {
      _errorMessage = "Category is required";
      notifyListeners();
      throw Exception("Category is required");
    }

    if (_currentPost!.urgency == null || _currentPost!.urgency!.isEmpty) {
      _errorMessage = "Urgency is required";
      notifyListeners();
      throw Exception("Urgency is required");
    }

    if (_currentPost!.location == null || _currentPost!.location!.isEmpty) {
      _errorMessage = "Location is required";
      notifyListeners();
      throw Exception("Location is required");
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update current post with all values
      _currentPost = _currentPost!.copyWith(
        title: title,
        description: description,
      );

      print("Post to be saved: ${_currentPost!.toMap()}");

      if (_postIndex == null) {
        // Creating new post
        print("Creating new post...");
        final newPost = await _communityPostServices.createPost(_currentPost!);
        print("New post created with ID: ${newPost.id}");
        print("Returned post: ${newPost.toMap()}");

        _currentPost = newPost;

        // Upload photo after post is created
        if (imageFile != null && newPost.id != null) {
          print("Uploading photo for post ${newPost.id}...");
          final photoUrl = await uploadPhoto(imageFile);

          if (photoUrl != null) {
            _currentPost = _currentPost!.copyWith(photo: photoUrl);
            await _communityPostServices.updatePost(_currentPost!);
            print("Photo uploaded and post updated with photo URL");
          }
        }

        _postsList.add(_currentPost!);
      } else {
        // Updating existing post
        print("Updating post: ${_currentPost!.id}");
        _currentPost = _currentPost!.copyWith(id: _postIndex);

        // Upload new photo if provided
        if (imageFile != null) {
          print("Uploading new photo...");
          final photoUrl = await uploadPhoto(imageFile);
          if (photoUrl != null) {
            _currentPost = _currentPost!.copyWith(photo: photoUrl);
          }
        }

        await _communityPostServices.updatePost(_currentPost!);
        print("Post updated successfully");

        final index = _postsList.indexWhere((post) => post.id == _postIndex);
        if (index != -1) {
          _postsList[index] = _currentPost!;
        }
      }

      _errorMessage = null;
      print("Post saved successfully!");
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to save post: $e";
      print("Error saving post: $e");
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPost() {
    titleController.clear();
    descriptionController.clear();
    _currentPost = null;
    _postIndex = null;
    _selectedImageFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
