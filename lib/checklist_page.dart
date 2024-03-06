import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

import 'delete_item_screen.dart';
import 'login_page.dart';

class ChecklistItem {
  String title;
  bool isCompleted;

  ChecklistItem({required this.title, this.isCompleted = false});
}

class Check extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChecklistScreen(),
    );
  }
}

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}
mm
class _ChecklistScreenState extends State<ChecklistScreen> {
  TextEditingController _itemController = TextEditingController();
  List<ChecklistItem> _checklistItems = [];
  List<ChecklistItem> _deletedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeletedItemsScreen(
                    deletedItems: _deletedItems,
                    restoreItem: (item) {
                      setState(() {
                        _deletedItems.remove(item);
                        _checklistItems.add(item);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _shareChecklist(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Do you want to logout?',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            await GoogleSignIn().signOut();
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                        ),
                        TextButton(
                            child: const Text('No'),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      body: _checklistItems.isEmpty
          ? Center(
              child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Add some checklists',
                    style: TextStyle(
                        fontSize: 25, color: Colors.black.withOpacity(.67)),
                  ),
                  SizedBox(height: 50),
                  Image.asset('assets/waiting.png', height: 300)
                ],
              ),
            ))
          : ListView.builder(
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_checklistItems[index].title),
                  leading: Checkbox(
                    value: _checklistItems[index].isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _checklistItems[index].isCompleted = value!;
                      });
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteItem(_checklistItems[index]);
                    },
                  ),
                  onTap: () {
                    _editItem(index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItem(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: TextField(
            controller: _itemController,
            decoration: InputDecoration(
              hintText: 'Enter item',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newItemTitle = _itemController.text.trim();
                if (newItemTitle.isNotEmpty) {
                  setState(() {
                    _checklistItems.add(ChecklistItem(title: newItemTitle));
                  });
                  _itemController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller:
                TextEditingController(text: _checklistItems[index].title),
            onChanged: (value) {
              _checklistItems[index].title = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter item',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(ChecklistItem item) {
    setState(() {
      _deletedItems.add(item);
      _checklistItems.remove(item);
    });
  }

  void _shareChecklist(BuildContext context) {
    String checklistContent = "Checklist:\n";
    for (int i = 0; i < _checklistItems.length; i++) {
      checklistContent += "${i + 1}. ${_checklistItems[i].title}\n";
    }

    Share.share(checklistContent);
  }
}
