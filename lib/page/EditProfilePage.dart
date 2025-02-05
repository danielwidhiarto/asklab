import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';

import '../config/secrets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profileImage;
  String? _currentProfileUrl;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: Secrets.cloudinaryApiKey,
    apiSecret: Secrets.cloudinaryApiSecret,
    cloudName: Secrets.cloudinaryCloudName,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc['username'] ?? '';
          _fullNameController.text = userDoc['fullName'] ?? '';
          _bioController.text = userDoc['bio'] ?? '';
          _currentProfileUrl = userDoc['profilePicture'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      final response = await cloudinary.upload(
        file: imageFile.path,
        folder: 'profile_picture/${user.uid}',
        resourceType: CloudinaryResourceType.image,
      );

      return response.isSuccessful ? response.secureUrl : null;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? profilePictureUrl = _currentProfileUrl;

        if (_profileImage != null) {
          profilePictureUrl = await _uploadImageToCloudinary(_profileImage!);
        }

        await _firestore.collection('users').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'fullName': _fullNameController.text.trim(),
          'bio': _bioController.text.trim(),
          'profilePicture': profilePictureUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF009ADB),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : _currentProfileUrl != null
                                  ? NetworkImage(_currentProfileUrl!)
                                      as ImageProvider
                                  : null,
                          child: _profileImage == null &&
                                  _currentProfileUrl == null
                              ? const Icon(Icons.account_circle,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Color(0xFF009ADB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                      _usernameController, "Username", Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _fullNameController, "Full Name", Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(_bioController, "Bio", Icons.info,
                      maxLines: 3),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009ADB),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isLoading ? "Saving..." : "Save Changes"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF009ADB)),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
