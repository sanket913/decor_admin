import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'blog.dart';// Import Fluttertoast package

class UploadBlogPage extends StatefulWidget {
  @override
  _UploadBlogPageState createState() => _UploadBlogPageState();
}

class _UploadBlogPageState extends State<UploadBlogPage> {
  String _title = '';
  String _description = '';
  File? _imageFile;
  bool _isLoading = false;
  double _uploadProgress = 0.0; // To track upload progress

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Upload New Blog'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          width: double.infinity,
                          height: 170,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : Icon(
                              Icons.upload_file,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _title = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                          : SizedBox(height: 10), // Spacer
                      _isLoading
                          ? Center(
                        child: Text(
                          'Uploading ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _uploadBlog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF532DE0),
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('SUBMIT'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: theme.colorScheme.background,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_imageFile!);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _uploadBlog() async {
    if (_title.isEmpty || _description.isEmpty || _imageFile == null) {
      print('Please fill all the required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final imageUrl = await _uploadImage();

    if (imageUrl == null) {
      print('Image upload failed.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('blogs').add({
        'title': _title,
        'description': _description,
        'image': imageUrl,
        'timestamp': Timestamp.now(),
        // You can add more fields if needed
      });

      _showSavedSuccessfullySnackbar(context);

      // Delay navigation to Blog page
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/blog');
      });
    } catch (e) {
      print('Error uploading blog: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _showSavedSuccessfullySnackbar(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Blog Uploaded Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
