import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:asklab/config/secrets.dart'; // Pastikan file secrets.dart ada

class DetailPost extends StatefulWidget {
  final String postId;
  final String title;
  final List<String> images;
  final String description;
  final DateTime timestamp;

  const DetailPost({
    Key? key,
    required this.postId,
    required this.title,
    required this.images,
    required this.description,
    required this.timestamp,
  }) : super(key: key);

  @override
  _DetailPostState createState() => _DetailPostState();
}

class _DetailPostState extends State<DetailPost> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;
  String? _replyToCommentId; // Untuk menyimpan commentId jika sedang reply
  bool _isLoading = false;
  String _title = '';
  String _description = '';

  // Inisialisasi Cloudinary
  final cloudinary = Cloudinary.signedConfig(
    apiKey: Secrets.cloudinaryApiKey,
    apiSecret: Secrets.cloudinaryApiSecret,
    cloudName: Secrets.cloudinaryCloudName,
  );

  // Format Timestamp ke format yang lebih mudah dibaca
  String formatTimestamp(DateTime dateTime) {
    return "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  @override
  void initState(){
    super.initState();
    _title = widget.title;
    _description = widget.description;
  }

  // Upload Gambar ke Cloudinary
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      final response = await cloudinary.upload(
        file: imageFile.path,
        folder: 'comment_images/${user.uid}',
        resourceType: CloudinaryResourceType.image,
      );

      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  // Tambahkan Komentar atau Reply ke Firestore
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty && _selectedImage == null)
      return;

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      String username = userDoc.exists ? userDoc['username'] : "Unknown";
      String profilePic = userDoc.exists ? userDoc['profilePicture'] ?? "" : "";

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      }

      Map<String, dynamic> commentData = {
        'userId': user.uid,
        'username': username,
        'profilePicture': profilePic,
        'comment': _commentController.text.trim(),
        'image': imageUrl ?? "",
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_replyToCommentId == null) {
        // Tambahkan komentar utama
        await _firestore
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add(commentData);
      } else {
        // Tambahkan reply ke komentar
        await _firestore
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(_replyToCommentId)
            .collection('replies')
            .add(commentData);
      }

      // Reset input setelah submit
      _commentController.clear();
      setState(() {
        _selectedImage = null;
        _replyToCommentId = null;
      });
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading setelah selesai
      });
    }
  }

  // Pilih Gambar dari Gallery atau Kamera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildReplies(String commentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        var replies = snapshot.data!.docs;

        return Column(
          children: replies.map((reply) {
            var replyData = reply.data() as Map<String, dynamic>?;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: replyData != null &&
                        replyData['profilePicture'] != null &&
                        replyData['profilePicture'] != ""
                    ? NetworkImage(replyData['profilePicture']) as ImageProvider
                    : const AssetImage("assets/default_avatar.png"),
              ),
              title: Text(replyData?['username'] ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyData?['image'] != null && replyData!['image'] != "")
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Image.network(replyData['image'], height: 150),
                    ),
                  Text(
                    replyData?.containsKey('reply') == true
                        ? replyData!['reply']
                        : replyData?['comment'] ?? "",
                  ),
                  Text(
                    replyData?['timestamp'] != null
                        ? formatTimestamp(replyData!['timestamp'])
                        : "Just now",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _deletePost() async {
  await _firestore.collection('posts').doc(widget.postId).delete();
  Navigator.pop(context); // Kembali ke page sebelumnya setelah delete
}

void _showEditPostDialog() {
  TextEditingController titleController = TextEditingController(text: widget.title);
  TextEditingController descriptionController = TextEditingController(text: widget.description);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('posts').doc(widget.postId).update({
                'title': titleController.text,
                'description': descriptionController.text,
              });
              Navigator.pop(context);
              setState(() {
                // Update tampilan DetailPost setelah edit
              });
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color(0xFF009ADB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit'){
                _showEditPostDialog();
              } else if (value == 'delete'){
                _deletePost();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Edit Post"),
                  ],
                )
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red,),
                    Text("Delete Post"),
                    SizedBox(width: 8)
                  ],
                )
              )
            ]
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.images.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: widget.images.length > 1,
                autoPlay: widget.images.length > 1,
              ),
              items: widget.images.map((imageUrl) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 10),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Text(
              "Posted on: ${formatTimestamp(widget.timestamp)}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _description,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const Divider(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData = comments[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            commentData['profilePicture'] != null &&
                                    commentData['profilePicture'] != ""
                                ? NetworkImage(commentData['profilePicture'])
                                    as ImageProvider
                                : const AssetImage("assets/default_avatar.png"),
                      ),
                      title: Text(commentData['username'] ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                     
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (commentData['image'] != null &&
                              commentData['image'] != "")
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Image.network(commentData['image'],
                                  height: 150),
                            ),
                          Text(commentData['comment']),
                          Text(
                            commentData['timestamp'] != null
                                ? formatTimestamp((commentData['timestamp'] as Timestamp).toDate())
                                : "Just now",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _replyToCommentId = commentData
                                    .id; // Set untuk reply ke komentar ini
                                _commentController.text =
                                    "@${commentData['username']} ";
                              });
                            },
                            child: const Text("Reply",
                                style: TextStyle(color: Colors.blue)),
                          ),
                          _buildReplies(commentData.id),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Text Bar untuk Menulis Komentar atau Reply
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF009ADB)),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF009ADB)),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: _replyToCommentId == null
                          ? "Write a comment..."
                          : "Replying...",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF009ADB)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),

          // Tampilkan gambar yang dipilih sebelum dikirim
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.file(_selectedImage!, height: 150),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child:
                          const Icon(Icons.close, color: Colors.red, size: 24),
                    ),
                  ),
                ],
              ),
            ),

          // Show loading indicator if _isLoading is true
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
