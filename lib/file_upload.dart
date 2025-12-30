import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'admin_service.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final service = AdminService.instance;
  final picker = ImagePicker();

  List<Map<String, dynamic>> files = [];
  bool loading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  int _cols(double w) {
    if (w < 600) return 2;
    if (w < 900) return 3;
    return 4;
  }

  Future<void> loadFiles() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      files = await service.fetchFiles();
    } catch (e) {
      errorMsg = "Erreur lors du chargement des fichiers";
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> pickFromGallery() async {
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    setState(() {
      loading = true;
      errorMsg = null;
    });

    final file = File(xfile.path);

    try {
      final r = await service.uploadFile(file: file, tag: 'Timetable'); // ApiResult

      if (!mounted) return;

      // Notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}")),
      ); // [web:225]

      if (r.success) {
        await loadFiles();
      } else {
        setState(() {
          loading = false;
          errorMsg = r.message.isEmpty ? "Upload failed" : r.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMsg = "Erreur upload";
      });
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> f) async {
    final id = int.tryParse(f['id'].toString()) ?? 0;
    final name = (f['name'] ?? '').toString();
    if (id <= 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: Text("Supprimer le fichier: $name ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      loading = true;
      errorMsg = null;
    });

    final r = await service.deleteFile(id); // ApiResult

    if (!mounted) return;

    // Notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? "✅ ${r.message}" : "❌ ${r.message}")),
    ); // [web:225]

    if (r.success) {
      await loadFiles();
    } else {
      setState(() {
        loading = false;
        errorMsg = r.message.isEmpty ? "Delete failed" : r.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = _cols(w);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload files')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : pickFromGallery,
                child: Text(loading ? "Uploading..." : 'Choisir une image (gallery)'),
              ),
            ),
            const SizedBox(height: 12),

            if (loading) const LinearProgressIndicator(),

            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: loadFiles, child: const Text("Retry")),
            ],

            const SizedBox(height: 10),

            Expanded(
              child: files.isEmpty
                  ? const Center(child: Text('Aucun fichier uploadé.'))
                  : GridView.builder(
                itemCount: files.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final f = files[index];
                  final name = (f['name'] ?? '').toString();
                  final tag = (f['tag'] ?? '').toString();

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tag.isEmpty ? "No tag" : tag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              tooltip: "Delete",
                              onPressed: loading ? null : () => _deleteFile(f),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.insert_drive_file, color: Colors.black45),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
