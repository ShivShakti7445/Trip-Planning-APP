import 'package:flutter/material.dart';

import 'checklist_page.dart';

class DeletedItemsScreen extends StatelessWidget {
  final List<ChecklistItem> deletedItems;
  final Function(ChecklistItem) restoreItem;

  DeletedItemsScreen({required this.deletedItems, required this.restoreItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deleted Items'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: deletedItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(deletedItems[index].title),
            onTap: () {
              restoreItem(deletedItems[index]);
            },
          );
        },
      ),
    );
  }
}