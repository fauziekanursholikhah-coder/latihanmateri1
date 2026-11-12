import 'package:flutter/material.dart';

import 'database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> myData = [];
  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Future<void> _refreshData() async {
    final data =
        await DatabaseHelper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshData();
  }
  void showMyForm(int? id) {
    if (id != null) {
      final existingData =
          myData.firstWhere(
        (element) => element['id'] == id,
      );
      _titleController.text =
          existingData['title'] ?? '';
      _descriptionController.text =
          existingData['description'] ?? '';
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Title',
                    hintText:
                        'Masukkan judul catatan',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller:
                      _descriptionController,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Masukkan isi catatan',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_titleController
                              .text
                              .trim()
                              .isEmpty ||
                          _descriptionController
                              .text
                              .trim()
                              .isEmpty) {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Title dan description harus diisi!',
                            ),
                          ),
                        );

                        return;
                      }
                      if (id == null) {
                        await addItem();
                      }
                      if (id != null) {
                        await updateItem(id);
                      }
                      _titleController.clear();
                      _descriptionController
                          .clear();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pop();
                      }
                    },
                    child: Text(
                      id == null
                          ? 'Create New'
                          : 'Update',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> addItem() async {
    await DatabaseHelper.createItem(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    );

    await _refreshData();

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Catatan berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
      id,
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    );

    await _refreshData();

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Catatan berhasil diperbarui!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  Future<void> deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);

    await _refreshData();

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Catatan berhasil dihapus!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simple Note',
        ),
        backgroundColor:
            Theme.of(context)
                .colorScheme
                .inversePrimary,
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : myData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Belum ada catatan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tekan tombol + untuk membuat catatan',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(10),
                  itemCount: myData.length,
                  itemBuilder:
                      (context, index) {

                    final item =
                        myData[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.deepPurple,
                          child: Text(
                            '${index + 1}',
                            style:
                                const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          item['title']
                                  ?.toString() ??
                              '',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 5,
                          ),
                          child: Text(
                            item['description']
                                    ?.toString() ??
                                '',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            // EDIT
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                showMyForm(
                                  item['id'],
                                );
                              },
                            ),

                            // DELETE
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _showDeleteDialog(
                                  item['id'],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          showMyForm(null);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Catatan',
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus catatan ini?',
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop();
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop();

                await deleteItem(id);
              },
              child: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }
}