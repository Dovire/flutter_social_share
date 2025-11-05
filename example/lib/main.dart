import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_social_share/flutter_social_share.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Social Share Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _appIdController = TextEditingController();
  final TextEditingController _clientTokenController = TextEditingController();

  String _initStatus = 'Not initialized';
  String _shareResult = 'No sharing attempted';
  File? _selectedImage;
  bool _isInitialized = false;
  bool _useEnvironmentCredentials = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEnvironmentCredentials();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _appIdController.dispose();
    _clientTokenController.dispose();
    super.dispose();
  }

  void _checkEnvironmentCredentials() {
    const appId = String.fromEnvironment('FB_APP_ID');
    const clientToken = String.fromEnvironment('FB_CLIENT_TOKEN');

    if (appId.isNotEmpty && clientToken.isNotEmpty) {
      setState(() {
        _initStatus = 'Environment credentials detected (FB_APP_ID and FB_CLIENT_TOKEN)';
      });
    } else {
      setState(() {
        _initStatus = 'No environment credentials found. Use explicit credentials or set --dart-define variables.';
        _useEnvironmentCredentials = false;
      });
    }
  }

  Future<void> _initializeFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_useEnvironmentCredentials) {
        await FlutterSocialShare.facebook.init();
      } else {
        if (_appIdController.text.isEmpty || _clientTokenController.text.isEmpty) {
          throw Exception('Please provide both App ID and Client Token');
        }
        await FlutterSocialShare.facebook.init(
          appId: _appIdController.text.trim(),
          clientToken: _clientTokenController.text.trim(),
        );
      }

      setState(() {
        _initStatus = 'Facebook SDK initialized successfully';
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initStatus = 'Failed to initialize Facebook SDK: $e';
        _isInitialized = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    }
  }

  Future<void> _shareToFacebook() async {
    if (_selectedImage == null) {
      _showErrorDialog('Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FlutterSocialShare.facebook.shareImage(
        _selectedImage!.path,
        caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
      );

      setState(() {
        if (result.status == ShareStatus.success) {
          _shareResult = 'Successfully shared to Facebook!';
        } else if (result.status == ShareStatus.cancelled) {
          _shareResult = 'User cancelled the share';
        } else {
          _shareResult = 'Share failed: ${result.errorMessage ?? 'Unknown error'}';
        }
      });
    } catch (e) {
      setState(() {
        _shareResult = 'Error sharing: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Social Share Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Facebook SDK Initialization', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Environment Variables'),
                            subtitle: const Text('--dart-define'),
                            value: true,
                            groupValue: _useEnvironmentCredentials,
                            onChanged: (value) {
                              setState(() {
                                _useEnvironmentCredentials = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Explicit Credentials'),
                            subtitle: const Text('Manual input'),
                            value: false,
                            groupValue: _useEnvironmentCredentials,
                            onChanged: (value) {
                              setState(() {
                                _useEnvironmentCredentials = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (!_useEnvironmentCredentials) ...[
                      TextField(
                        controller: _appIdController,
                        decoration: const InputDecoration(
                          labelText: 'Facebook App ID',
                          hintText: 'Enter your Facebook App ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _clientTokenController,
                        decoration: const InputDecoration(
                          labelText: 'Facebook Client Token',
                          hintText: 'Enter your Facebook Client Token',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isInitialized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isInitialized ? Colors.green : Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isInitialized ? Icons.check_circle : Icons.info,
                            color: _isInitialized ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_initStatus)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _initializeFacebook,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Initialize Facebook SDK'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Image Selection', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    if (_selectedImage != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selected: ${_selectedImage!.path.split('/').last}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No image selected'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_selectedImage == null ? 'Select Image' : 'Change Image'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caption (Optional)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter a caption for your post...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share to Facebook', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    if (_shareResult != 'No sharing attempted') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _shareResult.contains('Successfully')
                              ? Colors.green.withOpacity(0.1)
                              : _shareResult.contains('cancelled')
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _shareResult.contains('Successfully')
                                ? Colors.green
                                : _shareResult.contains('cancelled')
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _shareResult.contains('Successfully')
                                  ? Icons.check_circle
                                  : _shareResult.contains('cancelled')
                                  ? Icons.info
                                  : Icons.error,
                              color: _shareResult.contains('Successfully')
                                  ? Colors.green
                                  : _shareResult.contains('cancelled')
                                  ? Colors.blue
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_shareResult)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ElevatedButton.icon(
                      onPressed: (_isInitialized && _selectedImage != null && !_isLoading) ? _shareToFacebook : null,
                      icon: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.share),
                      label: const Text('Share to Facebook'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    if (!_isInitialized || _selectedImage == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        !_isInitialized ? 'Please initialize Facebook SDK first' : 'Please select an image first',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Setup Instructions', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const Text(
                      'Method 1: Environment Variables (Recommended)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Run your app with --dart-define parameters:\n'
                      'flutter run --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace', backgroundColor: Color(0xFFF5F5F5)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Method 2: Explicit Credentials', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your Facebook App ID and Client Token directly in the form above.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    const Text('Additional Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      '• Facebook app must be installed on your device\n'
                      '• Your Facebook app must be properly configured\n'
                      '• Camera and photo library permissions may be required',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
