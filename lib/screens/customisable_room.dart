import 'package:flutter/material.dart';
import 'package:innerglow/constants/colors.dart';


class RoomCustomizerScreen extends StatefulWidget {
  @override
  _RoomCustomizerScreenState createState() => _RoomCustomizerScreenState();
}

class _RoomCustomizerScreenState extends State<RoomCustomizerScreen> {
  
  
  // List of furniture items
  final List<FurnitureItem> _items = [
    FurnitureItem(id: 'tv', name: 'TV', imagePath: 'lib/assets/images/tv.png', message: 'Time to relax and watch your favorite show!'),
    FurnitureItem(id: 'table', name: 'Table', imagePath: 'lib/assets/images/table.png', message: 'A great place to work or enjoy a meal with loved ones.'),
    FurnitureItem(id: 'bed', name: 'Bed', imagePath: 'lib/assets/images/bed.png', message: 'Hey, it\'s been a long day. Take some rest and recharge.'),
    FurnitureItem(id: 'plant', name: 'Plant', imagePath: 'lib/assets/images/pot.png', message: 'Plants bring life and fresh air to your space. Remember to stay connected with nature!'),
    FurnitureItem(id: 'cupboard', name: 'Cupboard', imagePath: 'lib/assets/images/cupboard.png', message: 'Keep your space organized and clutter-free for peace of mind.'),
    FurnitureItem(id: 'sofa', name: 'Sofa', imagePath: 'lib/assets/images/sofa.png', message: 'Sit back, relax, and enjoy moments of comfort and peace.'),
  ];

  // Variables for item carousel
  late PageController _pageController;
  int _currentPage = 0;
  final int _itemsPerPage = 3;

  // List to track placed items in the room
  List<PlacedItem> _placedItems = [];

  // Track if any message is being shown
  String? _currentMessage;
  
  // Selected item for zooming
  PlacedItem? _selectedItem;
  double _zoomLevel = 1.0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dream Room Designer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveRoom,
            tooltip: 'Save Room',
          ),
          IconButton(
            icon: Icon(Icons.restart_alt, color: Colors.white),
            onPressed: _resetRoom,
            tooltip: 'Reset Room',
          ),
        ],
      ),
      body: Column(
        children: [
          // Room area (where items will be placed)
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background - empty room
                  DragTarget<FurnitureItem>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: _placedItems.isEmpty 
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: bg.withOpacity(0.5),
                                    size: 40,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Drag items here to customize your room',
                                    style: TextStyle(
                                      color: bg.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        ),
                      );
                    },
                    onAcceptWithDetails: (details) {
                      // Calculate the position within the room container
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final localPosition = renderBox.globalToLocal(details.offset);
                      
                      // Adjust for item size (centering)
                      final adjustedPosition = Offset(
                        localPosition.dx - 40, // Adjust based on half the item width
                        localPosition.dy - 40, // Adjust based on half the item height
                      );
                      
                      _placeItem(details.data, adjustedPosition);
                    },
                  ),
                  
                  // Placed items
                  ..._placedItems.map((item) {
                    bool isSelected = _selectedItem == item;
                    double itemScale = isSelected && _isZooming ? _zoomLevel : 1.0;
                    
                    return Positioned(
                      left: item.position.dx,
                      top: item.position.dy,
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedItem == item) {
                            _showItemMessage(item.item);
                          } else {
                            setState(() {
                              _selectedItem = item;
                              _isZooming = false;
                              _zoomLevel = 1.0;
                            });
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _selectedItem = item;
                            _isZooming = true;
                            _zoomLevel = 1.5; // Initial zoom level
                          });
                        },
                        onScaleStart: (_) {
                          if (_selectedItem == item) {
                            setState(() {
                              _isZooming = true;
                            });
                          }
                        },
                        onScaleUpdate: (details) {
                          if (_selectedItem == item && _isZooming) {
                            setState(() {
                              // Limit zoom between 1.0 and 2.5
                              _zoomLevel = (details.scale * _zoomLevel).clamp(1.0, 2.5);
                            });
                          }
                        },
                        onScaleEnd: (_) {
                          if (_zoomLevel < 1.2) {
                            setState(() {
                              _isZooming = false;
                              _zoomLevel = 1.0;
                            });
                          }
                        },
                        child: Stack(
                          children: [
                            // Draggable item
                            Draggable<PlacedItem>(
                              data: item,
                              feedback: Transform.scale(
                                scale: itemScale,
                                child: Image.asset(
                                  item.item.imagePath,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.2,
                                child: Image.asset(
                                  item.item.imagePath,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              onDragEnd: (details) {
                                if (details.wasAccepted) return;
                                
                                // If dragged within the room
                                if (details.offset.dx > 0 && details.offset.dy > 0) {
                                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                  final Offset localPosition = renderBox.globalToLocal(details.offset);
                                  
                                  // Check if still within room bounds
                                  if (localPosition.dx > 0 && 
                                      localPosition.dx < renderBox.size.width &&
                                      localPosition.dy > 0 && 
                                      localPosition.dy < renderBox.size.height) {
                                    
                                    // Update position
                                    setState(() {
                                      _placedItems[_placedItems.indexOf(item)] = PlacedItem(
                                        item: item.item,
                                        position: Offset(
                                          localPosition.dx - 40,
                                          localPosition.dy - 40,
                                        ),
                                      );
                                    });
                                  }
                                }
                              },
                              child: Container(
                                decoration: isSelected 
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: bg,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                                child: Transform.scale(
                                  scale: itemScale,
                                  child: Image.asset(
                                    item.item.imagePath,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Zoom controls when selected
                            if (isSelected)
                              Positioned(
                                right: -5,
                                bottom: -5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isZooming ? Icons.zoom_out : Icons.zoom_in,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        if (_isZooming) {
                                          _isZooming = false;
                                          _zoomLevel = 1.0;
                                        } else {
                                          _isZooming = true;
                                          _zoomLevel = 1.5;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Message display
                  if (_currentMessage != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: bg.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentMessage = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bg,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Item selection area with improved UI
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Furniture Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: bg,
                      ),
                    ),
                    Row(
                      children: [
                        // Left arrow for navigation
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: bg),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                        // Right arrow for navigation
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: bg),
                          onPressed: () {
                            if (_currentPage < (_items.length / _itemsPerPage).ceil() - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    (_items.length / _itemsPerPage).ceil(),
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? bg : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // PageView for items
                SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: (_items.length / _itemsPerPage).ceil(),
                    itemBuilder: (context, pageIndex) {
                      int startIndex = pageIndex * _itemsPerPage;
                      int endIndex = startIndex + _itemsPerPage;
                      if (endIndex > _items.length) endIndex = _items.length;
                      
                      List<FurnitureItem> pageItems = _items.sublist(startIndex, endIndex);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: pageItems.map((item) {
                          return Draggable<FurnitureItem>(
                            data: item,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Image.asset(
                                item.imagePath,
                                width: 100,
                                height: 100,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildItemCard(item),
                            ),
                            child: _buildItemCard(item),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(FurnitureItem item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: bg.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              item.imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 6),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Place items in the room
  void _placeItem(FurnitureItem item, Offset position) {
    setState(() {
      _placedItems.add(PlacedItem(
        item: item,
        position: position,
      ));
      
      // Select the newly placed item
      _selectedItem = _placedItems.last;
      _isZooming = false;
    });
  }

  // Display message when item is tapped
  void _showItemMessage(FurnitureItem item) {
    setState(() {
      _currentMessage = item.message;
    });
  }

  // Save the current room layout
  void _saveRoom() {
    // Here you would typically save to a database or local storage
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Your room design has been saved!'),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Reset the room to empty
  void _resetRoom() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Room', style: TextStyle(color: bg)),
        content: Text('Are you sure you want to clear all items from your room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _placedItems = [];
                _currentMessage = null;
                _selectedItem = null;
                _isZooming = false;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: bg),
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Models
class FurnitureItem {
  final String id;
  final String name;
  final String imagePath;
  final String message;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.message,
  });
}

class PlacedItem {
  final FurnitureItem item;
  final Offset position;

  PlacedItem({
    required this.item,
    required this.position,
  });
}