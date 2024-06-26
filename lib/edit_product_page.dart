import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'product_adm.dart';
import 'theme.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductPage({required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _img;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(text: widget.product['description']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _img = widget.product['img'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child(widget.product['id']);
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _updateProductDetails(BuildContext context) async {
    String? img = _img;
    if (_imageFile != null) {
      img = await _uploadImage(_imageFile!);
    }
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product['id'])
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'img': img,
      });
      Fluttertoast.showToast(
        msg: "Product Updated Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        timeInSecForIosWeb: 2,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TextButton(
            child: Text(
              '✕',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back when close icon is pressed
            },
          ), onPressed: () {  },
        ),
        title: Center(child: Text('Edit Product')),
        backgroundColor: theme.brightness == Brightness.light ? Colors.white : theme.colorScheme.background,
        actions: [
          IconButton(
            icon: TextButton(
              child: Text(
                '✓',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              onPressed: () {
                _updateProductDetails(context); // Call function to update product details
              },
            ), onPressed: () {  },
          ),
        ],
      ),
      backgroundColor: theme.brightness == Brightness.light ? Colors.white : theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: 300,
                    child: ClipRRect(
                      child: _imageFile != null
                          ? Image.file(_imageFile!, height: 300, width: 300)
                          : (_img != null
                          ? Image.network(_img!, height: 300, width: 300)
                          : Container(height: 300, width: 300, color: Colors.transparent)),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 10,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF532DE0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: InputBorder.none,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.deepPurpleAccent), // Adjust label style
                    ),
                    controller: _nameController,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // Allows the description to expand vertically
                    decoration: InputDecoration(
                      labelText: 'Description :',
                      border: InputBorder.none,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.deepPurpleAccent), // Adjust label style
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: InputBorder.none,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.deepPurpleAccent), // Adjust label style
                    ),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
