import 'dart:io';

import 'package:asklab/config/secrets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePostPage extends StatefulWidget{
    final String postId;

    const UpdatePostPage({
      Key? key,
      required this.postId
      }) : super(key: key);

    @override
    _UpdatePostPageState createState() => _UpdatePostPageState();

}
class _UpdatePostPageState extends State<UpdatePostPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List <String> _existingImagesUrl = [];
  final List<File> _newSelectImages = [];
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: Secrets.cloudinaryApiKey, apiSecret: Secrets.cloudinaryApiSecret, cloudName: Secrets.cloudinaryCloudName);

     @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ambil dari firebase data 
  Future<void> _fetchData() async {
    DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(widget.postId).get();

    if (postSnapshot.exists){
      var data = postSnapshot.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _existingImagesUrl = List<String>.from(data['images'] ?? []);
      setState(() {});
    }
  }

  // image picker update 
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _newSelectImages.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        User? user = _auth.currentUser;
        if(user == null) return [];

        final response = await cloudinary.upload(
          file: image.path,
          folder: 'post_images/${user.uid}',
          resourceType: CloudinaryResourceType.image,
        );

        if(response.secureUrl != null) {
          imageUrls.add(response.secureUrl!);
        }

      } catch (e) {
        print("Error uploading to Cloudinary: $e");
      }
    }

    return imageUrls;
  }

  // update post 
  Future<void> _updatePost() async {
    if(!_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Description are required')),
      );
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // upload image 
      List<String> imageUrls = await _uploadImagesToCloudinary(_newSelectImages);

      List<String> allImageUrls = [..._existingImagesUrl, ...imageUrls];

      await _firestore.collection('posts').doc(widget.postId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'images': allImageUrls,
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      Navigator.pop(context);

    } catch (e) {
      print("Error update post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

   void _removeExistingImage(int index) {
    setState(() {
      _existingImagesUrl.removeAt(index);
    });
  }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Update Post'),
                backgroundColor: const Color(0xFF009ADB),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder()
                          ),
                        ),
                        const SizedBox(height: 16.0,)
                      ],
                    ),
                  ),
                )
              ],
            ),
            
        );
    }
}