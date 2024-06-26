import 'package:decorar_admin/blog.dart';
import 'package:decorar_admin/user_adm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_adm.dart';
import 'home_adm.dart';
import 'profile_admin.dart';
import 'theme.dart'; // If you have custom themes
import 'package:fluttertoast/fluttertoast.dart';
import 'package:decorar_admin/edit_product_page.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Container(
            margin: EdgeInsets.only(right: 36.0),
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Color(0xFF2A2A2A),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: Container(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : Color(0xFF2A2A2A),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No categories found'));
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.map((category) {
                              return CategorySection(categoryName: category['name']);
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UploadProductPage()));
          },
          child: Icon(Icons.add, color: Colors.white, size: 32),
          backgroundColor: Color(0xFF532DE0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    List<Map<String, dynamic>> categories = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    for (var doc in querySnapshot.docs) {
      categories.add({'name': doc['name']});
    }
    return categories;
  }
}

class CategorySection extends StatelessWidget {
  final String categoryName;

  CategorySection({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchProducts(categoryName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // Don't display anything if no products found
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('More'),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurple),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var product = snapshot.data![index];
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0, right: 8.0),
                      child: ProductItem(product: product),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String categoryName) async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .limit(5)
        .get();
    for (var doc in querySnapshot.docs) {
      products.add({
        'id': doc.id,
        'name': doc['name'],
        'price': doc['price'],
        'img': doc['img'],
        'description': doc['description'],
      });
    }
    return products;
  }
}

class ProductItem extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductItem({required this.product});

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool showIcons = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      setState(() {
        showIcons = !showIcons;
      });
    },
    child: Container(
    width: 150,
    decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.white54, width: 1),
    ),
    child: Stack(
    alignment: Alignment.center,
    children: [
    Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Padding(
    padding: const EdgeInsets.all(4.0),
    child: Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    image: DecorationImage(
    image: NetworkImage(widget.product['img']),
    fit: BoxFit.fill,
    ),
    ),
    ),
    ),
    SizedBox(height: 8),
    Text(
    widget.product['name'],
    textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    ],
    ),
      if (showIcons)
        Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  _showProductDetailsDialog(context);
                },
                icon: Icon(Icons.visibility, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductPage(product: widget.product),
                    ),
                  );
                },
                icon: Icon(Icons.edit, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                icon: Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
    ],
    ),
    ),
    );
  }

  void _showProductDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.product['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${widget.product['description']}',
              ),
              SizedBox(height: 10),
              Text(
                'Price:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${widget.product['price']}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductPage(product: widget.product),
                  ),
                );
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product?'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: deleteProduct,
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product['id'])
          .delete();
      _showSavedSuccessfullySnackbar(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  void _showSavedSuccessfullySnackbar(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Product Deleted Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      timeInSecForIosWeb: 2,
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
    });
  }
}

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1C2A9F), Color(0xFF2F2B2B)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarItem(
            icon: Icons.home,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.shopping_bag,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
            },
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.article,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage()));
            },
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.person,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
            },
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;

  NavBarItem({required this.icon, required this.onPressed, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: Colors.white,
          iconSize: iconSize,
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductPage(),
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
  ));
}

