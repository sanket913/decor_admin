import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart'; // Import Fluttertoast package

class UploadProductPage extends StatefulWidget {
  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  String _name = '';
  String _price = '';
  String _description = '';
  String _img = '';
  String _selectedCategory = 'Select Category';
  List<String> _categories = [];
  bool _isLoading = true;
  File? _imageFile;
  bool _isExpanded = false;
  double _uploadProgress = 0.0; // To track upload progress

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Upload New Product'),
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
                          labelText: 'Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _name = value;
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
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          setState(() {
                            _price = value;
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
                          : ExpansionTile(
                        title: Text(
                          _selectedCategory,
                          style: TextStyle(fontSize: 18),
                        ),
                        onExpansionChanged: (isExpanded) {
                          setState(() {
                            _isExpanded = isExpanded;
                          });
                        },
                        children: [
                          if (_isExpanded)
                            Container(
                              height: _categories.length * 50.0,
                              child: Scrollbar(
                                child: ListView(
                                  children: _categories.map((category) {
                                    return ListTile(
                                      title: Text(category),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _isExpanded = false;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadProduct,
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

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

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

      setState(() {
        _img = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _uploadProduct() async {
    if (_name.isEmpty ||
        _price.isEmpty ||
        _selectedCategory == 'Select Category' ||
        _imageFile == null) {
      print('Please fill all the required fields.');
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    await _uploadImage();

    if (_img.isEmpty) {
      print('Image upload failed.');
      setState(() {
        _isLoading = false; // Set loading state to false
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _name,
        'description': _description,
        'price': _price,
        'img': _img,
        'category': _selectedCategory,
      });

      _showSavedSuccessfullySnackbar(context); // Show toast message

      // Delay navigation to Product page
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/product'); // Replace with your Product page route
      });
    } catch (e) {
      print('Error uploading product: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
        _uploadProgress = 0.0; //
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();
      List<String> categories = [];
      querySnapshot.docs.forEach((doc) {
        categories.add(doc['name']);
      });
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _showSavedSuccessfullySnackbar(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Product Uploaded Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}