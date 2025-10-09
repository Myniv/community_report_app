import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/widgets/image_picker_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String? profileId;
  const UpdateProfileScreen({super.key, this.profileId});

  @override
  State<UpdateProfileScreen> createState() => FormScreenState();
}

class FormScreenState extends State<UpdateProfileScreen> {
  final CustomTheme _customTheme = CustomTheme();

  @override
  void initState() {
    super.initState();

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    if (widget.profileId != null) {
      profileProvider.loadProfileOtherUser(widget.profileId!);
    } else {
      final profileId = profileProvider.profile?.uid;
      if (profileId != null) {
        profileProvider.loadProfile(profileId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final phoneFormatter = MaskTextInputFormatter(
      mask: '+62 ###-####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    final locationItem = LocationItem.values.map((e) => e.displayName).toList();

    final roleItem = RoleItem.values.map((e) => e.displayName).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: CustomTheme.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Edit Profile",
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
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 1000 ? 700 : 500,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: profileProvider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Form
                      Center(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF249A00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Image Picker
                      ImagePickerExample(
                        onImageSelected: (path) async {
                          if (widget.profileId != null) {
                            profileProvider.otherUserProfile?.photo = path;
                          } else {
                            profileProvider.profile?.photo = path;
                          }
                        },
                        initialImage: widget.profileId != null
                            ? profileProvider.otherUserProfile?.photo
                            : profileProvider.profile?.photo,
                      ),
                      const SizedBox(height: 50),
                      // Front Name
                      CustomTheme().customTextField(
                        context: context,
                        controller: profileProvider.frontNameController,
                        label: "Front Name",
                        hint: "Insert front name",
                        icon: Icons.person,
                        iconColor: CustomTheme.green,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please insert front name";
                          }
                          if (value.trim().length < 3) {
                            return "Front name must be at least 3 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Last Name
                      CustomTheme().customTextField(
                        context: context,
                        controller: profileProvider.lastNameController,
                        label: "Last Name",
                        hint: "Insert last name",
                        icon: Icons.person,
                        iconColor: CustomTheme.green,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please insert last name";
                          }
                          if (value.trim().length < 3) {
                            return "Last name must be at least 3 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone
                      CustomTheme().customTextField(
                        context: context,
                        inputFormatters: [phoneFormatter],
                        controller: profileProvider.phoneController,
                        label: "Phone",
                        hint: "Insert phone",
                        icon: Icons.phone,
                        iconColor: CustomTheme.green,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number cannot be empty';
                          }

                          final digitsOnly = value.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          final requiredDigits =
                              phoneFormatter
                                  .getMask()!
                                  .split('')
                                  .where((c) => c == '#')
                                  .length +
                              2;
                          if (digitsOnly.length < requiredDigits) {
                            return 'Phone number must be complete';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // location
                      _customTheme.customDropdown<String>(
                        context: context,
                        icon: Icons.location_on,
                        value: widget.profileId != null && profileProvider.profile?.role == "admin"
                            ? profileProvider.otherUserProfile?.location
                            : profileProvider.profile?.location,
                        items: locationItem,
                        label: "Location",
                        hint: "Select Location",
                        enabled: widget.profileId != null && profileProvider.profile?.role == "admin",
                        onChanged: widget.profileId != null && profileProvider.profile?.role == "admin"
                            ? (value) {
                                profileProvider.setLocation(
                                  value,
                                  widget.profileId,
                                );
                              }
                            : null,
                        validator: (value) {
                          if (value == null) {
                            return "Please select a location";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _customTheme.customDropdown<String>(
                        context: context,
                        icon: Icons.settings_accessibility,
                        value: widget.profileId != null && profileProvider.profile?.role == "admin"
                            ? profileProvider.otherUserProfile?.role
                            : profileProvider.profile?.role,
                        items: roleItem,
                        enabled: widget.profileId != null && profileProvider.profile?.role == "admin",
                        label: "Role",
                        hint: "Change Role",
                        onChanged: widget.profileId != null && profileProvider.profile?.role == "admin"
                            ? (value) {
                                profileProvider.setRole(
                                  value,
                                  widget.profileId,
                                );
                              }
                            : null,
                        validator: (value) {
                          if (value == null) {
                            return "Please select a Role for user";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Submit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final shouldUpdate = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Cancel'),
                                    content: const Text('Discard changes?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('No'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );

                                if (!context.mounted) return;
                                if (shouldUpdate == true) {
                                  Navigator.pop(context, true);
                                }
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomTheme.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  if (profileProvider.validateForm(
                                    widget.profileId,
                                  )) {
                                    widget.profileId != null
                                        ? await profileProvider
                                              .updateOtherProfile()
                                        : await profileProvider.updateProfile();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Profile updated successfully!',
                                        ),
                                      ),
                                    );

                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Input data is still invalid.",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Update profile failed: $e",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: profileProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
