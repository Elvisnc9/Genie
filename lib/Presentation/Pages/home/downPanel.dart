import 'package:flutter/material.dart';
import 'package:genie/Constant/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class Downpanel extends StatefulWidget {
  final VoidCallback onClose;

  const Downpanel({super.key, required this.onClose});

  @override
  State<Downpanel> createState() => DownpanelState();
}

class DownpanelState extends State<Downpanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  final List<Map<String, String>> _collections = [
    {'title': 'LIVING ROOM', 'asset': 'assets/images/Category_images/livingRoom.png'},
    {'title': 'OFFICES', 'asset': 'assets/images/Category_images/offices.png'},
    {'title': 'OUTDOORS', 'asset': 'assets/images/Category_images/outdoor.png'},
    {'title': 'SCHOOLS', 'asset': 'assets/images/Category_images/classRoom.png'},
  ];

  final List<Map<String, String>> _products = [
    {
      'title': 'Backrest Chair',
      'tag': 'Office,Coperate',
      'asset': 'assets/images/model_Images/3dd.png',
    },
    {
      'title': 'Wooden Craft',
      'tag': 'General',
      'asset': 'assets/images/model_Images/chair(1).png',
    },
    {
      'title': 'Green Sofa',
      'tag': 'Home',
      'asset': 'assets/images/model_Images/sofa.png',
    },
    {
      'title': 'Desk Table',
      'tag': 'School,Office',
      'asset': 'assets/images/model_Images/officeTable1.png',
    },
       {
      'title': 'Backrest Chair',
      'tag': 'Office,Coperate',
      'asset': 'assets/images/model_Images/3dd.png',
    },
    {
      'title': 'Wooden Craft',
      'tag': 'General',
      'asset': 'assets/images/model_Images/chair(1).png',
    },
    {
      'title': 'Green Sofa',
      'tag': 'Home',
      'asset': 'assets/images/model_Images/sofa.png',
    },
    {
      'title': 'Desk Table',
      'tag': 'School,Office',
      'asset': 'assets/images/model_Images/officeTable1.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _categoryIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black),
        ),
      ],
    );
  }

  Widget _productCard(String asset, String title, String tag, bool showNew) {
    return Container(
    
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image + badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: SizedBox(
                  height: 150,
                  
                  width: double.infinity,
                  child: Image.asset(asset, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/ProductView');
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.crop_free_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              if (showNew)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding:  EdgeInsets.fromLTRB(10, 10, 10, 2),
            child: Text(
              title,
              style:  GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Size: 3ft / 2ft',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightFactor = 0.82;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // absorb taps outside the actual panel
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // top row: X, title, search (matches your reference)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _controller.reverse().then(
                                (_) => widget.onClose(),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                         Expanded(
                            child: Text(
                              'Best Collection',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // horizontal collections
                      SizedBox(
                        height: 20.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _collections.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = _collections[index];
                            return Container(
                              width: 300,
                          
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: AssetImage(item['asset']!),
                                  fit: BoxFit.cover,
                                  
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    item['title']!,
                                    style:  GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // product for you + categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Product for you',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              _categoryIcon(Icons.desktop_windows, 'Desk'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.chair, 'Chair'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.tv, 'TV Stand'),
                              const SizedBox(width: 8),
                              _categoryIcon(Icons.weekend, 'Sofa'),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // products grid
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return _productCard(
                              p['asset']!,
                              p['title']!,
                              p['tag']!,
                              index.isEven,
                            );
                          },
                        ),
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

  Widget _categoryIIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
