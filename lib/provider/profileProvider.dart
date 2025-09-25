import 'dart:io';

import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/services/profile_services.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Profile? _profile;
  Profile? get profile => _profile;

  Profile? _otherUserProfile;
  Profile? get otherUserProfile => _otherUserProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // form key
  final formKey = GlobalKey<FormState>();

  // controllers
  final frontNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  // load profile from Firestore
  Future<void> loadProfile(String uid) async {
    _setLoading(true);
    try {
      _profile = await _profileService.getUserProfile(uid);

      if (_profile != null) {
        frontNameController.text = _profile!.front_name ?? '';
        lastNameController.text = _profile!.last_name ?? '';
        phoneController.text = _profile!.phone ?? '';
        locationController.text = _profile!.location ?? '';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // load profile from Firestore
  Future<void> loadProfileOtherUser(String uid) async {
    _setLoading(true);
    try {
      _otherUserProfile = await _profileService.getUserProfile(uid);

      if (_otherUserProfile != null) {
        frontNameController.text = _otherUserProfile!.front_name ?? '';
        lastNameController.text = _otherUserProfile!.last_name ?? '';
        phoneController.text = _otherUserProfile!.phone ?? '';
        locationController.text = _otherUserProfile!.location ?? '';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // update profile ke Firestore
  Future<bool> updateProfile() async {
    if (_profile == null) return false;
    if (!formKey.currentState!.validate()) return false;

    _setLoading(true);
    try {
      String? pathPhoto;

      if (_profile!.photo != null && !_profile!.photo!.startsWith('http')) {
        pathPhoto = await uploadProfilePhoto(File(_profile!.photo ?? ''), null);
      } else {
        pathPhoto = _profile!.photo;
      }

      final updated = Profile(
        uid: _otherUserProfile!.uid,
        email: _otherUserProfile!.email,
        username: _otherUserProfile!.username,
        front_name: frontNameController.text,
        last_name: lastNameController.text,
        phone: phoneController.text,
        location: otherUserProfile!.location,
        photo: pathPhoto,
        role: _otherUserProfile!.role,
      );

      await _profileService.updateUserProfile(updated);
      _profile = updated;
      notifyListeners();

      return true;
    } finally {
      _setLoading(false);
    }
  }

  // update profile ke Firestore
  Future<void> updateOtherProfile() async {
    if (_otherUserProfile == null) return;
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      String? pathPhoto;

      if (_otherUserProfile!.photo != null &&
          !_otherUserProfile!.photo!.startsWith('http')) {
        pathPhoto = await uploadProfilePhoto(
          File(_otherUserProfile!.photo ?? ''),
          null,
        );
      } else {
        pathPhoto = _otherUserProfile!.photo;
      }
      final updated = Profile(
        uid: _otherUserProfile!.uid,
        email: _otherUserProfile!.email,
        username: _otherUserProfile!.username,
        front_name: frontNameController.text,
        last_name: lastNameController.text,
        phone: phoneController.text,
        location: otherUserProfile!.location,
        photo: pathPhoto,
        role: _otherUserProfile!.role,
      );

      await _profileService.updateUserProfile(updated);
      _otherUserProfile = updated;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadProfilePhoto(File file, String? profileId) async {
    if (_profile == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final targetId = profileId ?? _profile!.uid;
      final url = await _profileService.uploadProfilePhoto(targetId, file);

      // kasih cacheBuster biar url fresh
      return "$url?v=${DateTime.now().millisecondsSinceEpoch}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLocation(String? value, String? uid) {
    if (uid != null) {
      _otherUserProfile!.location = value;
    } else {
      _profile!.location = value;
    }
    notifyListeners();
  }

  bool validateForm(String? profileId) {
    final isValid = formKey.currentState?.validate() ?? false;

    notifyListeners();

    return isValid;
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    frontNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
