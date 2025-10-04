import 'package:community_report_app/models/discussion.dart';
import 'package:community_report_app/services/discussion_service.dart';
import 'package:flutter/material.dart';

class DiscussionProvider with ChangeNotifier {
  final postKey = GlobalKey<FormState>();

  final messageController = TextEditingController();
  final editMessageController = TextEditingController();

  final List<Discussion> _discussionsList = [];
  List<Discussion> get discussionListProfile => _discussionsList;

  Discussion? _currentDiscussion;
  Discussion? get currentDiscussion => _currentDiscussion;

  int? _discussionIndex;
  int? get discussionIndex => _discussionIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final DiscussionService _discussionService = DiscussionService();

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

  Future<void> fetchDiscussion(int? discussionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentDiscussion = await _discussionService.getDiscussionbyId(
        discussionId!,
      );
      print("Fetched post: $_currentDiscussion");
    } catch (e) {
      print("Error in provider: $e");
      // _postsListProfile = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDiscussion({
    String? message,
    String? userId,
    int? communityPostId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final discussion = Discussion(
        message: message,
        userId: userId,
        communityPostId: communityPostId,
      );
      final newDiscussion = await _discussionService.createDiscussion(
        discussion,
      );
      _discussionsList.add(newDiscussion);
      messageController.clear();
      print("Created discussion: $newDiscussion");
    } catch (e) {
      print("Error in provider while creating discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDiscussion({
    String? message,
    String? userId,
    int? communityPostId,
    int? discussionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final discussion = Discussion(
        message: message,
        userId: userId,
        communityPostId: communityPostId,
      );
      await _discussionService.updateDiscussion(discussion, discussionId!);
      final index = _discussionsList.indexWhere(
        (d) => d.discussionId == discussionId,
      );
      if (index != -1) {
        _discussionsList[index] = _discussionsList[index].copyWith(
          message: message,
        );
        editMessageController.clear();
        print("Updated discussion: $discussion");
      }
    } catch (e) {
      print("Error in provider while updating discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDiscussion(int discussionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _discussionService.deleteDiscussion(discussionId);
      _discussionsList.removeWhere((d) => d.discussionId == discussionId);
      print("Deleted discussion with ID: $discussionId");
    } catch (e) {
      print("Error in provider while deleting discussion: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    editMessageController.dispose();
    super.dispose();
  }
}
