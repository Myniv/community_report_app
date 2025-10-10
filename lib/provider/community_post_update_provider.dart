import 'dart:io';
import 'package:community_report_app/models/community_post_update.dart';
import 'package:community_report_app/models/discussion.dart';
import 'package:community_report_app/services/community_post_services.dart';
import 'package:community_report_app/services/community_post_update_service.dart';
import 'package:community_report_app/services/discussion_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPostUpdateProvider with ChangeNotifier {
  final postKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final picker = ImagePicker();

  final List<CommunityPostUpdate> _communityPostUpdate = [];
  List<CommunityPostUpdate> get communityPostUpdate => _communityPostUpdate;

  CommunityPostUpdate? _currentCommunityPostUpdate;
  CommunityPostUpdate? get currentCommunityPostUpdate =>
      _currentCommunityPostUpdate;

  int? _comunityPostUpdateIndex;
  int? get communitypostUpdateIndex => _comunityPostUpdateIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isUploadingPhoto = false;
  bool get isUploadingPhoto => _isUploadingPhoto;
  bool _isResolved = false;
  bool get isResolved => _isResolved;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  final CommunityPostUpdateService _communityPostUpdateService =
      CommunityPostUpdateService();

  // Future<void> fetchPostsList({
  //   String? userId,
  //   String? status,
  //   String? category,
  //   String? location,
  //   bool? isReport,
  //   String? urgency,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     _postsListProfile = await _communityPostServices.getPosts(
  //       userId: userId,
  //       status: status,
  //       category: category,
  //       location: location,
  //       isReport: isReport,
  //       urgency: urgency,
  //     );
  //   } catch (e) {
  //     print("Error in provider: $e");
  //     _postsListProfile = [];
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> fetchDiscussion(int? discussionId) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     _currentDiscussion = await _discussionService.getDiscussionbyId(
  //       discussionId!,
  //     );
  //     print("Fetched post: $_currentDiscussion");
  //   } catch (e) {
  //     print("Error in provider: $e");
  //     // _postsListProfile = [];
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void setIsResolved(bool value) {
    _isResolved = value;
  }

  void _setSelectedImageFile(File? file) {
    _selectedImageFile = file;
    notifyListeners();
  }

  void _setUploadingPhoto(bool value) {
    _isUploadingPhoto = value;
    notifyListeners();
  }

  // pick image from gallery
  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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

  Future<String?> uploadPhoto(File file, int postId) async {
    _setUploadingPhoto(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _communityPostUpdateService.uploadPhoto(postId, file);
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

  Future<void> createCommunityPostUpdate(
    String? userId,
    int communityPostId,
    File file,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = await uploadPhoto(file, communityPostId);
      final communityPostUpdate = CommunityPostUpdate(
        title: titleController.text,
        description: descriptionController.text,
        isResolved: _isResolved,
        photo: url,
        userId: userId,
        communityPostId: communityPostId,
      );
      await _communityPostUpdateService.createCommunityPostUpdate(
        communityPostUpdate,
      );
      titleController.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error in provider while creating discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommunityPostUpdate(int? communityPostUpdateId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCommunityPostUpdate = await _communityPostUpdateService
          .getPostById(communityPostUpdateId!);
      titleController.text = _currentCommunityPostUpdate?.title ?? '';
      descriptionController.text =
          _currentCommunityPostUpdate?.description ?? '';
      print("Fetched post: $_currentCommunityPostUpdate");
    } catch (e) {
      print("Error in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCommunityPostUpdate(
    String? userId,
    int communityPostUpdateId,
    File? file,
    String oldPhotoUrl,
    int communityPostId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? url = oldPhotoUrl;
      print('anaxa');
      print(file);
      if (file != null) {
        await _communityPostUpdateService.deleteOldComunityPostUpdatePhoto(
          oldPhotoUrl,
        );
        url = await uploadPhoto(file, communityPostUpdateId);
      }

      final communityPostUpdate = CommunityPostUpdate(
        title: titleController.text,
        description: descriptionController.text,
        isResolved: _isResolved,
        photo: url,
        userId: userId,
        communityPostId: communityPostId,
      );
      await _communityPostUpdateService.updateCommunityPostUpdate(
        communityPostUpdate,
        communityPostUpdateId,
      );
      titleController.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error in provider while creating discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCommunityPostUpdate(int communityPostUpdateId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _communityPostUpdateService.deleteCommunityPostUpdate(
        communityPostUpdateId,
      );
      print("Deleted discussion with ID: $communityPostUpdateId");
    } catch (e) {
      print("Error in provider while deleting discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
