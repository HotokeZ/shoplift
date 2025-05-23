import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    Key? key,
    required this.productId,
    required this.productData,
  }) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryInputController =
      TextEditingController();

  List<File> _selectedImages = [];
  List<String> _existingImages = [];
  List<String> _categories = [];
  List<Map<String, dynamic>> _varietyTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prefill fields with existing product data
    _nameController.text = widget.productData['name'] ?? '';
    _priceController.text = widget.productData['price']?.toString() ?? '';
    _descriptionController.text = widget.productData['description'] ?? '';
    _categories = List<String>.from(widget.productData['categories'] ?? []);
    _varietyTypes = List<Map<String, dynamic>>.from(
      widget.productData['varietyTypes'] ?? [],
    );
    _existingImages = List<String>.from(widget.productData['images'] ?? []);
  }

  void _addVarietyType() {
    if (_varietyTypes.length < 2) {
      setState(() {
        _varietyTypes.add({'name': '', 'values': []});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 2 variety types')),
      );
    }
  }

  void _removeVarietyType(int index) {
    setState(() {
      _varietyTypes.removeAt(index);
    });
  }

  void _addVarietyValue(int typeIndex) {
    setState(() {
      _varietyTypes[typeIndex]['values'].add({
        'value': '',
        'quantity': '',
        'price': '',
      });
    });
  }

  void _removeVarietyValue(int typeIndex, int valueIndex) {
    setState(() {
      _varietyTypes[typeIndex]['values'].removeAt(valueIndex);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImagesToCloudinary() async {
    const cloudName = 'duw2eq9gt'; // Replace with your Cloudinary cloud name
    const uploadPreset =
        'products'; // Replace with your Cloudinary upload preset

    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.fields['upload_preset'] = uploadPreset;

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        imageUrls.add(jsonResponse['secure_url']);
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    }
    return imageUrls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if at least one category is added
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images
      final newImageUrls = await _uploadImagesToCloudinary();

      // Combine existing and new images
      final allImages = [..._existingImages, ...newImageUrls];

      // Save updated product data to Firestore
      final updatedProductData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'categories': _categories,
        'images': allImages,
        'varietyTypes': _varietyTypes.isNotEmpty ? _varietyTypes : null,
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update(updatedProductData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update product: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Enter product name' : null,
                ),

                // Default Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Default Price'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) => value!.isEmpty ? 'Enter default price' : null,
                ),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator:
                      (value) => value!.isEmpty ? 'Enter description' : null,
                ),

                // Categories Section
                const Text('Categories'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryInputController,
                        decoration: const InputDecoration(
                          labelText: 'Add Category',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_categoryInputController.text.trim().isNotEmpty) {
                          setState(() {
                            _categories.add(
                              _categoryInputController.text.trim(),
                            );
                            _categoryInputController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children:
                      _categories
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              label: Text(entry.value),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  _categories.removeAt(entry.key);
                                });
                              },
                            ),
                          )
                          .toList(),
                ),

                // Variety Types Section
                const Text('Variety Types'),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _varietyTypes.length,
                  itemBuilder: (context, typeIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _varietyTypes[typeIndex]['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Variety Type',
                                ),
                                onChanged:
                                    (value) =>
                                        _varietyTypes[typeIndex]['name'] =
                                            value,
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Enter variety type'
                                            : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeVarietyType(typeIndex),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Values'),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _varietyTypes[typeIndex]['values'].length,
                          itemBuilder: (context, valueIndex) {
                            final variety =
                                _varietyTypes[typeIndex]['values'][valueIndex];
                            return Row(
                              children: [
                                // Variety Value
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: variety['value'],
                                    decoration: const InputDecoration(
                                      labelText: 'Value',
                                    ),
                                    onChanged:
                                        (value) => variety['value'] = value,
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? 'Enter value'
                                                : null,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Quantity
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: variety['quantity'],
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged:
                                        (value) => variety['quantity'] = value,
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? 'Enter quantity'
                                                : null,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Price Field
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue:
                                        variety['price'] != null
                                            ? variety['price'].toString()
                                            : '',
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      variety['price'] =
                                          value.isNotEmpty
                                              ? double.tryParse(value)
                                              : null;
                                    },
                                    validator: (value) {
                                      if ((value == null || value.isEmpty) &&
                                          (_priceController.text.isEmpty ||
                                              double.tryParse(
                                                    _priceController.text,
                                                  ) ==
                                                  null)) {
                                        return 'Enter price or set a default price';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Remove Variety Button
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _removeVarietyValue(
                                        typeIndex,
                                        valueIndex,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _addVarietyValue(typeIndex),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Value'),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addVarietyType,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Variety Type'),
                  ),
                ),

                // Existing Images Section
                const SizedBox(height: 16),
                const Text('Existing Images'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _existingImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final imageUrl = entry.value;
                        return Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _existingImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),

                // New Images Section
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Select New Images'),
                ),
                const SizedBox(height: 8),
                _selectedImages.isNotEmpty
                    ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _selectedImages
                              .map(
                                (image) => Image.file(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                              .toList(),
                    )
                    : const Text('No new images selected'),

                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('Save Changes'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
