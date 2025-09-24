import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/services/profile_services.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Profile? _profile;
  Profile? get profile => _profile;

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

  // update profile ke Firestore
  Future<void> updateProfile() async {
    if (_profile == null) return;
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      final updated = Profile(
        uid: _profile!.uid,
        email: _profile!.email,
        username: _profile!.username,
        front_name: frontNameController.text,
        last_name: lastNameController.text,
        phone: phoneController.text,
        location: locationController.text,
        photo: _profile!.photo,
        role: _profile!.role,
      );

      await _profileService.updateUserProfile(updated);
      _profile = updated;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
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
