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

  void setCategory(String? value) {
    _currentPost?.category = value;
    notifyListeners();
  }

  void setUrgency(String? value) {
    _currentPost?.urgency = value;
    notifyListeners();
  }

  void setLocation(String? value) {
    _currentPost?.location = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _currentPost?.status = value;
    notifyListeners();
  }

  void setIsReport(bool? value) {
    _currentPost?.is_report = value;
    notifyListeners();
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

  Future<void> uploadPhoto(File file) async {
    if (_currentPost == null) {
      _errorMessage = "No post loaded";
      notifyListeners();
      return;
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

      final updatedProfile = _currentPost!.copyWith(photo: url);
      _currentPost = updatedProfile;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to upload photo: $e";
      _selectedImageFile = null;
      notifyListeners();
      rethrow;
    } finally {
      _setUploadingPhoto(false);
      _isLoading = false;
    }
  }

  Future<void> savePost() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPost?.title = titleController.text;
      _currentPost?.description = descriptionController.text;

      if (_postIndex == null) {
        final newPost = await _communityPostServices.createPost(_currentPost!);
        // _postsList.add(newPost);
      } else {
        _currentPost?.id = _postIndex;
        await _communityPostServices.updatePost(_currentPost!);

        final index = _postsList.indexWhere((post) => post.id == _postIndex);
        if (index != -1) {
          _postsList[index] = _currentPost!;
        }
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to save post: $e";
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      resetPost();
      notifyListeners();
    }
  }

  void resetPost() {
    titleController.clear();
    descriptionController.clear();
    _currentPost = null;
    _postIndex = null;
    _setSelectedImageFile(null);
    notifyListeners();
  }
}
