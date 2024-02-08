// ignore: file_names
// ignore_for_file: avoid_print, file_names, duplicate_ignore

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class CreateMenuPage extends StatefulWidget {
  const CreateMenuPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateMenuPageState createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nomCatController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  final TextEditingController isArchivedController = TextEditingController();
  final TextEditingController maxQuantiteController = TextEditingController();
  final TextEditingController isMenuController = TextEditingController();

  html.File? _image;

  Future<void> _pickImage() async {
    final html.InputElement input =
        html.FileUploadInputElement() as html.InputElement;
    input.click();

    input.onChange.listen((event) {
      if (kDebugMode) {
        print('File input changed');
      } // Add this line
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _image = files[0];
          if (kDebugMode) {
            print('Image picked: ${_image!.name}');
          }
        });
      } else {
        if (kDebugMode) {
          print('No image selected');
        }
      }
    });
  }

  Future<void> _createMenu() async {
    try {
      if (_image == null) {
        // Handle the case where the image is not selected
        if (kDebugMode) {
          print('Image not selected');
        }
        return;
      }
      final String contentType = 'image/${_image!.name.split('.').last}';

      var dio = Dio();
      var formData = FormData.fromMap({
        'nom': nomController.text,
        'type': typeController.text,
        'prix': prixController.text,
        'description': descriptionController.text,
        'nom_cat': nomCatController.text,
        'is_Archived': isArchivedController.text,
        'quantite': quantiteController.text,
        'max_quantite': maxQuantiteController.text,
        'is_Menu': isMenuController.text,
        'image': MultipartFile.fromBytes(
          await _readFileAsBytes(_image!),
          filename: _image!.name,
          contentType: MediaType.parse(contentType),
        ),
      });
      print(_image!.name);
      if (kDebugMode) {
        print(formData.fields);
        print (formData.files[0]);
      } // Add this line before making the request
      var response =
          await dio.post('http://localhost:3000/createMenu', data: formData);

      if (response.statusCode == 201) {
        // Menu created successfully
        if (kDebugMode) {
          print('Menu created successfully');
        }
      } else {
        // Handle error
        if (kDebugMode) {
          print('Error creating menu: ${response.statusMessage}');
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (kDebugMode) {
          print('DioError: ${e.response?.statusCode}');
        }
        if (kDebugMode) {
          print('Response data: ${e.response?.data}');
        }
      } else {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }

  Future<List<int>> _readFileAsBytes(html.File file) async {
    final reader = html.FileReader();
    final completer = Completer<List<int>>();

    reader.onLoadEnd.listen((event) {
      completer.complete(Uint8List.fromList(reader.result as List<int>));
    });

    reader.readAsArrayBuffer(file);

    return await completer.future; // Add 'await' here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextFormField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: prixController,
              decoration: const InputDecoration(labelText: 'Prix'),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: nomCatController,
              decoration: const InputDecoration(labelText: 'Nom Cat'),
            ),
            TextFormField(
              controller: isArchivedController,
              decoration: const InputDecoration(labelText: 'Is Archived'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            _image != null
                ? FutureBuilder<List<int>>(
                    future: _readFileAsBytes(_image!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Image.memory(
                          Uint8List.fromList(snapshot.data!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return const CircularProgressIndicator(); // or any loading indicator
                      }
                    },
                  )
                : const SizedBox.shrink(),
            TextFormField(
              controller: quantiteController,
              decoration: const InputDecoration(labelText: 'Quantite'),
            ),
            TextFormField(
              controller: maxQuantiteController,
              decoration: const InputDecoration(labelText: 'Max Quantite'),
            ),
            TextFormField(
              controller: isMenuController,
              decoration: const InputDecoration(labelText: 'Is Menu'),
            ),
            ElevatedButton(
              onPressed: _createMenu,
              child: const Text('Create Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
