import 'dart:convert';
import 'dart:developer';
import 'package:auto_route/auto_route.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class AdminUserTablePage extends StatefulWidget {
  const AdminUserTablePage({super.key});

  @override
  State<AdminUserTablePage> createState() => _AdminUserTablePageState();
}

class _AdminUserTablePageState extends State<AdminUserTablePage> {
  bool isLoading = true;
  bool isUploading = false;
  bool isUploadSuccess = false;
  Set<Map<String, dynamic>>? userList;
  Set<Map<String, dynamic>>? sortedUserList;
  Set<Map<String, dynamic>>? importedCsv;
  final _firestore = FirebaseFirestore.instance;
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUserFromBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withReadStream: true,
    );
    if (result != null) {
      final file = result.files.first;

      final fileReadStream = file.readStream;
      if (fileReadStream == null) {
        throw Exception('Cannot read file from null stream');
      }
      final stream = http.ByteStream(fileReadStream);

      final fields = await stream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();
      // final participantData = fields;
      fields.removeAt(0);
      const CsvToListConverter().convert(_textEditingController.text);
      final participantData = <Map<String, dynamic>>{};
      for (final participant in fields) {
        // if (participantData.length > 5) break;
        final data = {
          'orderNumber': participant.elementAt(0),
          'name': participant.elementAt(16),
          'category': participant.elementAt(9),
          'networkCount': 0,
        };
        participantData.add(data);
      }
      log('participantData $participantData');
      setState(() {
        importedCsv = participantData;
      });
    }
  }

  Future<void> _uploadParticipants() async {
    setState(() {
      isUploading = true;
    });
    try {
      if (importedCsv != null) {
        final batch = _firestore.batch();
        for (final participant in importedCsv!) {
          final docRef = _firestore.collection('userList').doc();
          batch.set(docRef, participant, SetOptions(merge: true));
        }
        for (final participant in importedCsv!) {
          final docRef = _firestore.collection('taggedUserInfoList').doc();
          participant
            ..remove('category')
            ..remove('networkCount');
          batch.set(docRef, {
            ...participant,
            'lowercaseName':
                (participant['name'] as String).toLowerCase().split(' '),
          });
        }
        await batch.commit();
        setState(() {
          isUploadSuccess = true;
        });
      }
    } catch (e) {
      log('error: $e');
    }
    setState(() {
      isUploading = false;
    });
  }

  Future<void> _loadUser() async {
    final snapshot = await _firestore.collection('userList').get();
    if (snapshot.size > 0) {
      final userListDocs = <Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final user = doc.data();
        userListDocs.add(user);
      }
      setState(() {
        isLoading = false;
        userList = userListDocs;
      });
    }
  }

  void _sortBy(String type) {
    //
    final sorted = List<Map<String, dynamic>>.from(userList!)
      ..sort((prev, curr) {
        if (type == 'networkCount') {
          return (curr[type] as int? ?? 0).compareTo(prev[type] as int? ?? 0);
        }
        return (prev[type] as String? ?? '')
            .compareTo(curr[type] as String? ?? '');
      });
    setState(() {
      sortedUserList = sorted.toSet();
    });
  }

  // void _clearSort() {
  //   setState(() {
  //     sortedUserList = null;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // if (isUploadSuccess) {
    //   initState();
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _loadUserFromBytes,
                    icon: const Icon(Icons.file_copy),
                  ),
                  const SizedBox(width: 16),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: isUploading
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: IconButton(
                      onPressed:
                          importedCsv != null ? _uploadParticipants : null,
                      icon: const Icon(Icons.upload),
                    ),
                    secondChild: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  if (importedCsv != null) ...[
                    const SizedBox(width: 16),
                    const Text('File is ready to upload'),
                  ]
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      final visibleList =
                          importedCsv ?? sortedUserList ?? userList;
                      return Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: List.generate(
                            visibleList == null ? 1 : visibleList.length + 1,
                            (index) {
                          if (index == 0) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextButton(
                                    child: const Text('Order Number'),
                                    onPressed: () => _sortBy('orderNumber'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextButton(
                                    child: const Text('Name'),
                                    onPressed: () => _sortBy('name'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextButton(
                                    child: const Text('Category'),
                                    onPressed: () => _sortBy('category'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextButton(
                                    child: const Text('Network Count'),
                                    onPressed: () => _sortBy('networkCount'),
                                  ),
                                ),
                              ],
                            );
                          }
                          final user = visibleList!.elementAt(index - 1);
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  user['orderNumber'] as String? ?? 'none',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(user['name'] as String? ?? 'none'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child:
                                    Text(user['category'] as String? ?? 'none'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  (user['networkCount'] as int? ?? 0)
                                      .toString(),
                                ),
                              ),
                            ],
                          );
                        }),
                      );
                    },
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
