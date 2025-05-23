import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const AddProductScreen({Key? key, this.productId, this.productData}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(); // Default price
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryInputController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<dynamic> _selectedImages = [];
  List<String> _categories = [];
  List<Map<String, dynamic>> _varietyTypes =
      []; // Each variety type has a name and its values
  bool _isLoading = false;

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
        'price': 0.0, // Initialize as a double
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
    const uploadPreset = 'products'; // Replace with your Cloudinary upload preset

    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      if (image is String) {
        // Remote URL, reuse it
        imageUrls.add(image);
      } else if (image is File) {
        // Local file, upload to Cloudinary
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

    // Check if at least one image is selected
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Upload images
      final imageUrls = await _uploadImagesToCloudinary();

      // Apply default price to varieties with empty price fields
      final defaultPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
      for (var type in _varietyTypes) {
        for (var variety in type['values']) {
          if (variety['price'] == null || variety['price'].toString().trim().isEmpty) {
            variety['price'] = defaultPrice;
          } else if (variety['price'] is String) {
            variety['price'] = double.tryParse(variety['price'].toString()) ?? defaultPrice;
          }
        }
      }

      // Prepare product data
      final productData = {
        'name': _nameController.text.trim(),
        'price': defaultPrice,
        'description': _descriptionController.text.trim(),
        'categories': _categories,
        'images': imageUrls,
        'userId': user.uid,
        'varietyTypes': _varietyTypes.isNotEmpty ? _varietyTypes : null, // Save only if varieties exist
      };

      // Include quantity if no varieties exist
      if (_varietyTypes.isEmpty) {
        productData['quantity'] = int.tryParse(_quantityController.text.trim()) ?? 0;
      }

      if (widget.productId != null) {
        // Update existing product
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        // Add new product
        productData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Initialize controllers and variables
  @override
  void initState() {
    super.initState();

    if (widget.productData != null) {
      _nameController.text = widget.productData!['name'] ?? '';
      _priceController.text = widget.productData!['price']?.toString() ?? '';
      _descriptionController.text = widget.productData!['description'] ?? '';
      _categories = List<String>.from(widget.productData!['categories'] ?? []);
      _varietyTypes = List<Map<String, dynamic>>.from(widget.productData!['varietyTypes'] ?? []);

      // Handle remote URLs for images
      final images = widget.productData!['images'] ?? [];
      for (var image in images) {
        if (image is String && image.startsWith('http')) {
          _selectedImages.add(image); // Add remote URLs directly
        }
      }

      // Prefill quantity if no varieties exist
      if (_varietyTypes.isEmpty) {
        _quantityController.text = widget.productData!['quantity']?.toString() ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
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
                  validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                ),

                // Default Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Default Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter default price' : null,
                ),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
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
                            _categories.add(_categoryInputController.text.trim());
                            _categoryInputController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: _categories
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
                                onChanged: (value) =>
                                    _varietyTypes[typeIndex]['name'] = value,
                                validator:
                                    (value) => value!.isEmpty ? 'Enter variety type' : null,
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
                                    onChanged: (value) => variety['value'] = value,
                                    validator:
                                        (value) => value!.isEmpty ? 'Enter value' : null,
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
                                    onChanged: (value) => variety['quantity'] = value,
                                    validator:
                                        (value) => value!.isEmpty ? 'Enter quantity' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Price Field
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: variety['price'] != null ? variety['price'].toString() : '',
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      // Ensure price is stored as a double
                                      variety['price'] = value.isNotEmpty ? double.tryParse(value) ?? 0.0 : 0.0;
                                    },
                                    validator: (value) {
                                      // Allow empty price if a default price is set
                                      if ((value == null || value.isEmpty) &&
                                          (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null)) {
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

                // Quantity Field (only if no varieties are added)
                if (_varietyTypes.isEmpty)
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),

                // Images Section
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Select Images'),
                ),
                const SizedBox(height: 8),
                _selectedImages.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedImages.map((image) {
                          return Stack(
                            children: [
                              image is String
                                  ? Image.network(
                                      image,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      image,
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
                                      _selectedImages.remove(image);
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
                      )
                    : const Text('No images selected'),

                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text('Save Product'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
