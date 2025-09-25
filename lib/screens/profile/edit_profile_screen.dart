import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/widgets/image_picker_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_attendance_tracker/providers/employee_provider.dart';
import 'package:hr_attendance_tracker/widgets/image_picker_form.dart';
import 'package:hr_attendance_tracker/widgets/text_form_field.dart';
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

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Edit Profile',
              style: GoogleFonts.pacifico(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
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
                          "Profile Form",
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004966),
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
                      // Full Name
                      CustomTextFormField(
                        label: 'Full Name',
                        controller: profileProvider.fullNameController,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'full name cannot be empty';
                          }

                          if (value.length < 3) {
                            return 'minimal 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // email
                      CustomTextFormField(
                        label: 'Email',
                        controller: profileProvider.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }

                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        inputFormatters: [phoneFormatter],
                        controller: profileProvider.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(14.0),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // location
                      CustomTextFormField(
                        label: 'Location',
                        controller: profileProvider.locationController,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'location cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      CustomTextFormField(
                        label: 'Bio',
                        controller: profileProvider.bioController,
                        keyboardType: TextInputType.multiline,
                        // maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      // Submit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
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
                                // profileProvider.resetForm();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 25),
                          ElevatedButton(
                            onPressed: () async {
                              if (profileProvider.validateForm(
                                widget.profileId,
                              )) {
                                widget.profileId != null
                                    ? await profileProvider
                                          .updateOtherEmployee()
                                    : await profileProvider.updateEmployee();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile updated successfully!',
                                    ),
                                  ),
                                );
                                if (!profileProvider.previousPositionEntries
                                    .contains(
                                      profileProvider.positionController.text,
                                    )) {
                                  profileProvider.savedEmployeePosition(
                                    profileProvider.positionController.text,
                                  );
                                }
                                // profileProvider.resetForm();
                                if (context.mounted) {
                                  Navigator.of(context).pop(false);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please fill all fields (and select a photo if required).",
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
                                : const Text('Submit'),
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
