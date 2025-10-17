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

  // SEPARATE LISTS FOR DIFFERENT SCREENS
  List<CommunityPost> _homePosts = [];
  List<CommunityPost> get homePosts => _homePosts;

  List<CommunityPost> _profilePosts = [];
  List<CommunityPost> get profilePosts => _profilePosts;

  // Keep this for backward compatibility if needed
  List<CommunityPost> get postListProfile => _profilePosts;

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

  bool _isDisposed = false;

  final CommunityPostServices _communityPostServices = CommunityPostServices();
  final ProfileProvider profileProvider;
  CommunityPostProvider(this.profileProvider);

  // NEW: Fetch posts for HOME SCREEN (no userId filter)
  Future<void> fetchHomePostsList({
    String? status,
    String? category,
    String? location,
    String? urgency,
  }) async {
    print("=== FETCH HOME POSTS START ===");
    print("Current home posts count: ${_homePosts.length}");

    _isLoading = true;
    _safeNotifyListeners();
    print("Set isLoading = true, notified listeners");

    try {
      _homePosts = await _communityPostServices.getPosts(
        userId: null, // No user filter for home
        status: status,
        category: category,
        location: location,
        isReport: null,
        urgency: urgency,
      );
      print("Fetched home posts: ${_homePosts.length}");
    } catch (e) {
      print("Error in provider: $e");
      _homePosts = [];
    } finally {
      _isLoading = false;
      print("Set isLoading = false");
      _safeNotifyListeners();
      print("=== FETCH HOME POSTS END ===");
      print("Final home posts count: ${_homePosts.length}");
    }
  }

  // NEW: Fetch posts for PROFILE SCREEN (with userId filter)
  Future<void> fetchProfilePostsList({
    String? userId,
    String? status,
    String? category,
    String? location,
    String? urgency,
  }) async {
    print("=== FETCH PROFILE POSTS START ===");
    print("userId: $userId");
    print("Current profile posts count: ${_profilePosts.length}");

    _isLoading = true;
    _safeNotifyListeners();
    print("Set isLoading = true, notified listeners");

    try {
      _profilePosts = await _communityPostServices.getPosts(
        userId: userId,
        status: status,
        category: category,
        location: location,
        isReport: null,
        urgency: urgency,
      );
      print("Fetched profile posts: ${_profilePosts.length}");
    } catch (e) {
      print("Error in provider: $e");
      _profilePosts = [];
    } finally {
      _isLoading = false;
      print("Set isLoading = false");
      _safeNotifyListeners();
      print("=== FETCH PROFILE POSTS END ===");
      print("Final profile posts count: ${_profilePosts.length}");
    }
  }

  // DEPRECATED: Keep for backward compatibility, but redirect to appropriate method
  @Deprecated('Use fetchHomePostsList or fetchProfilePostsList instead')
  Future<void> fetchPostsList({
    String? userId,
    String? status,
    String? category,
    String? location,
    bool? isReport,
    String? urgency,
  }) async {
    if (userId != null) {
      await fetchProfilePostsList(
        userId: userId,
        status: status,
        category: category,
        location: location,
        urgency: urgency,
      );
    } else {
      await fetchHomePostsList(
        status: status,
        category: category,
        location: location,
        urgency: urgency,
      );
    }
  }

  Future<void> fetchPost(int? postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPost = await _communityPostServices.getPostById(postId!);
      print("Fetched post: $_currentPost");
    } catch (e) {
      print("Error in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializeNewPost() {
    _currentPost = CommunityPost(
      user_id: profileProvider.profile?.uid,
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
    // Search in both lists
    var post = _homePosts.firstWhere(
      (post) => post.id == postId,
      orElse: () => _profilePosts.firstWhere(
        (post) => post.id == postId,
        orElse: () => CommunityPost(),
      ),
    );

    if (post.id != null) {
      _postIndex = postId;

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
    print("Existing Photo: ${_currentPost!.photo}");
    print("New Image File: ${imageFile?.path}");

    if (imageFile == null &&
        (_currentPost!.photo == null || _currentPost!.photo!.isEmpty)) {
      _errorMessage = "Photo is required";
      notifyListeners();
      throw Exception("Photo is required");
    }

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
      _currentPost = _currentPost!.copyWith(
        title: title,
        description: description,
        is_report: true,
      );

      if (_postIndex == null) {
        if (imageFile == null) {
          throw Exception("Photo is required for new posts");
        }

        _currentPost!.status = 'Pending';

        print("Step 1: Creating temporary post to get ID...");
        final tempPost = await _communityPostServices.createPost(_currentPost!);
        print("Temporary post created with ID: ${tempPost.id}");

        print("Step 2: Uploading photo for post ${tempPost.id}...");
        final photoUrl = await _communityPostServices.uploadProfilePhoto(
          tempPost.id!,
          imageFile,
          '',
        );
        print("Photo uploaded successfully: $photoUrl");

        print("Step 3: Updating post with photo URL...");
        _currentPost = tempPost.copyWith(photo: photoUrl);
        await _communityPostServices.updatePost(_currentPost!);
        print("Post updated with photo URL");

        // Add to both lists
        _homePosts.add(_currentPost!);
        _profilePosts.add(_currentPost!);
      } else {
        print("Updating post: ${_currentPost!.id}");
        _currentPost = _currentPost!.copyWith(id: _postIndex);

        if (imageFile != null) {
          print("Uploading new photo...");
          final photoUrl = await _communityPostServices.uploadProfilePhoto(
            _currentPost!.id!,
            imageFile,
            _currentPost!.photo ?? '',
          );
          print("New photo uploaded: $photoUrl");
          _currentPost = _currentPost!.copyWith(photo: photoUrl);
        } else {
          print("Keeping existing photo: ${_currentPost!.photo}");
        }

        await _communityPostServices.updatePost(_currentPost!);
        print("Post updated successfully");

        // Update in both lists
        final homeIndex = _homePosts.indexWhere(
          (post) => post.id == _postIndex,
        );
        if (homeIndex != -1) {
          _homePosts[homeIndex] = _currentPost!;
        }

        final profileIndex = _profilePosts.indexWhere(
          (post) => post.id == _postIndex,
        );
        if (profileIndex != -1) {
          _profilePosts[profileIndex] = _currentPost!;
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

  Future<void> deletePost(int? postId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _communityPostServices.deletePost(postId!);

      // Remove from both lists
      _homePosts.removeWhere((post) => post.id == postId);
      _profilePosts.removeWhere((post) => post.id == postId);

      _errorMessage = null;
      notifyListeners();
      print("Post deleted successfully");
    } catch (e) {
      _errorMessage = "Failed to delete post: $e";
      print("Error deleting post: $e");
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

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("=== CommunityPostProvider DISPOSING ===");
    _isDisposed = true;
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
