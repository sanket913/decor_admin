import 'package:decorar_admin/user_adm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'home_adm.dart';
import 'product_adm.dart';
import 'profile_admin.dart';
import 'upload_blog.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  bool _isImageZoomed = false;
  int _zoomedImageIndex = 0;
  late List<DocumentSnapshot> _blogs;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  void _toggleImageZoom(int index) {
    setState(() {
      _isImageZoomed = !_isImageZoomed;
      _zoomedImageIndex = index;
    });
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final blogDate = timestamp.toDate();
    final difference = now.difference(blogDate);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat.yMMMd().format(blogDate);
    }
  }

  void _deleteBlog(String blogId) {
    FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    final isLightTheme = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : theme.colorScheme.background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: isLightTheme ? Colors.black : Colors.white, // icon color based on theme
          ),
        ),
        title: Text(
          'Blogs',
          style: theme.textTheme.titleLarge?.copyWith(color: isLightTheme ? Colors.black : Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              size: 30.0,
              color: isLightTheme ? Colors.black : Colors.white, // icon color based on theme
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadBlogPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blogs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                _blogs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: _blogs.length,
                  itemBuilder: (context, index) {
                    var blog = _blogs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
                      child: InkWell(
                        onTap: () {
                          _toggleImageZoom(index);
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Blog?'),
                              content: Text('Are you sure you want to delete this blog?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteBlog(_blogs[index].id);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: BlogCard(
                          timestamp: blog['timestamp'],
                          image: blog['image'],
                          title: blog['title'],
                          description: blog['description'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isImageZoomed)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isImageZoomed = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: (_blogs[_zoomedImageIndex].data() as Map<String, dynamic>)['image'],
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class BlogCard extends StatefulWidget {
  final Timestamp timestamp;
  final String image;
  final String title;
  final String description;

  const BlogCard({
    Key? key,
    required this.timestamp,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool isLiked = false;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context).currentTheme;
    final timeAgo = _formatTimestamp(widget.timestamp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.5)),
        color: theme.colorScheme.background.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.image,
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : theme.iconTheme.color,
                ),
              ),
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final blogDate = timestamp.toDate();
    final difference = now.difference(blogDate);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat.yMMMd().format(blogDate);
    }
  }
}

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.shopping_bag,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage())),
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.article,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage())),
            iconSize: 30,
          ),
          NavBarItem(
            icon: Icons.person,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage())),
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

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(icon, size:
        iconSize, color: Colors.white),
      onPressed: onPressed,
    );
  }
}
