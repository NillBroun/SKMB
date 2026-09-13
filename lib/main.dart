
import 'package:flutter/material.dart';

void main() {
  runApp(const SKMBFamilyApp());
}

class SKMBFamilyApp extends StatelessWidget {
  const SKMBFamilyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKMB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const FamilyTreeScreen(),
    );
  }
}

// সদস্য মডেল
class Person {
  final String id;
  final String name;
  final String? fatherId;
  final int generation;
  final String? birthYear;

  Person({
    required this.id,
    required this.name,
    this.fatherId,
    required this.generation,
    this.birthYear,
  });
}

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  // প্রাথমিক ডাটা: মূল পূর্বপুরুষ থেকে শুরু
  final List<Person> _familyMembers = [
    Person(
      id: '1',
      name: 'মূল পূর্বপুরুষ (৪০০ বছর পূর্বে)',
      fatherId: null,
      generation: 1,
      birthYear: '১৬২০',
    ),
    Person(
      id: '2',
      name: '১ম উত্তরসূরি (বড় সন্তান)',
      fatherId: '1',
      generation: 2,
      birthYear: '১৬৫০',
    ),
    Person(
      id: '3',
      name: '২য় উত্তরসূরি (ছোট সন্তান)',
      fatherId: '1',
      generation: 2,
      birthYear: '১৬৫৫',
    ),
    Person(
      id: '4',
      name: '৩য় প্রজন্ম (নাতি)',
      fatherId: '2',
      generation: 3,
      birthYear: '১৬৮০',
    ),
  ];

  // নতুন ওয়ারিশ / সন্তান যোগ করার ডায়ালগ
  void _addNewMemberDialog(Person parent) {
    final nameController = TextEditingController();
    final yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${parent.name}-এর ওয়ারিশ যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'নাম',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(
                labelText: 'জন্ম সাল (ঐচ্ছিক)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _familyMembers.add(
                    Person(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      fatherId: parent.id,
                      generation: parent.generation + 1,
                      birthYear: yearController.text.trim().isNotEmpty
                          ? yearController.text.trim()
                          : null,
                    ),
                  );
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }

  // শাখা অনুযায়ী ড্রপডাউন ভিউ
  Widget _buildPersonTile(Person person) {
    final children = _familyMembers.where((m) => m.fatherId == person.id).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            '${person.generation}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
        title: Text(
          person.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'প্রজন্ম: ${person.generation} | জন্ম: ${person.birthYear ?? "অজানা"}',
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.person_add_alt_1, color: Colors.teal),
          tooltip: 'নতুন ওয়ারিশ যোগ করুন',
          onPressed: () => _addNewMemberDialog(person),
        ),
        children: children.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'পরবর্তী কোনো ওয়ারিশ যুক্ত করা হয়নি',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              ]
            : children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: _buildPersonTile(child),
                    ))
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rootAncestors = _familyMembers.where((m) => m.fatherId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SKMB বংশলতিকা',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: rootAncestors.length,
        itemBuilder: (context, index) {
          return _buildPersonTile(rootAncestors[index]);
        },
      ),
    );
  }
}
