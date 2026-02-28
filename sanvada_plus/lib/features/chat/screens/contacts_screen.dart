import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select contact'),
            Text('10 contacts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final contactId = 'contact_${index + 1}';
          return ListTile(
            onTap: () {
               // Replace the current screen with the chat screen
               context.pushReplacement('/chat/$contactId');
            },
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text('Contact ${index + 1}'),
            subtitle: const Text('Available'),
          );
        },
      ),
    );
  }
}
