import 'package:flutter/material.dart';


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

  // List to track placed items in the room
  List<PlacedItem> _placedItems = [];

  // Track if any message is being shown
  String? _currentMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Customizer'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRoom,
            tooltip: 'Save Room',
          ),
          IconButton(
            icon: Icon(Icons.restart_alt),
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
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8.0),
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
                            ? Text('Drag items here to customize your room', style: TextStyle(color: Colors.grey[600]))
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
                  ..._placedItems.map((item) => Positioned(
                    left: item.position.dx,
                    top: item.position.dy,
                    child: GestureDetector(
                      onTap: () => _showItemMessage(item.item),
                      // Make items draggable after placement for repositioning
                      child: Draggable<PlacedItem>(
                        data: item,
                        feedback: Image.asset(
                          item.item.imagePath,
                          width: 80,
                          height: 80,
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
                        child: Image.asset(
                          item.item.imagePath,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                  )).toList(),
                  
                  // Message display
                  if (_currentMessage != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentMessage!,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentMessage = null;
                                  });
                                },
                                child: Text('Close'),
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
          
          // Item selection area
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    'Available Items:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return Draggable<FurnitureItem>(
                        data: _items[index],
                        feedback: Image.asset(
                          _items[index].imagePath,
                          width: 80,
                          height: 80,
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildItemCard(_items[index]),
                        ),
                        child: _buildItemCard(_items[index]),
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
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              item.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 4),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
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
    // For this example, we'll just show a confirmation dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room layout saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // In a real app, you would save the _placedItems list
    // Example code for saving to shared preferences:
    /*
    final List<Map<String, dynamic>> itemsToSave = _placedItems.map((item) => {
      'itemId': item.item.id,
      'positionX': item.position.dx,
      'positionY': item.position.dy,
    }).toList();
    
    final String jsonData = jsonEncode(itemsToSave);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedRoomLayout', jsonData);
    */
  }

  // Reset the room to empty
  void _resetRoom() {
    setState(() {
      _placedItems = [];
      _currentMessage = null;
    });
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