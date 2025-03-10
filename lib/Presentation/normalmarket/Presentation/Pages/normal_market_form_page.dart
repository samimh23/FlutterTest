
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hanouty/Core/network/apiconastant.dart';
import 'package:hanouty/Presentation/normalmarket/Data/models/normalmarket_model.dart';
import 'package:hanouty/Presentation/normalmarket/Domain/entities/normalmarket_entity.dart';
import 'package:hanouty/Presentation/normalmarket/Presentation/Provider/normal_market_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class NormalMarketFormPage extends StatefulWidget {
  final NormalMarket? normalMarket;

  const NormalMarketFormPage({
    Key? key,
    this.normalMarket,
  }) : super(key: key);

  @override
  State<NormalMarketFormPage> createState() => _NormalMarketFormPageState();
}

class _NormalMarketFormPageState extends State<NormalMarketFormPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;

  final _marketNameController = TextEditingController();
  final _marketLocationController = TextEditingController();
  final _marketPhoneController = TextEditingController();
  final _marketEmailController = TextEditingController();

  String? _fractionalNFTAddress;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.normalMarket != null;

    if (_isEditing) {
      _initFormWithMarketData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NormalMarketProvider>().clearError();
      }
    });
  }

  void _initFormWithMarketData() {
    final market = widget.normalMarket!;

    _marketNameController.text = market.marketName;
    _marketLocationController.text = market.marketLocation;
    _marketPhoneController.text = market.marketPhone ?? '';
    _marketEmailController.text = market.marketEmail ?? '';
    _fractionalNFTAddress = market.fractionalNFTAddress;
  }

  @override
  void dispose() {
    _marketNameController.dispose();
    _marketLocationController.dispose();
    _marketPhoneController.dispose();
    _marketEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<NormalMarketProvider>();

      // Check if we have an image selected when creating a new market
      if (!_isEditing && !provider.hasSelectedImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Please select an image for the market',
                style: TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Create market model from form data
      final marketModel = NormalMarketModel(
        id: _isEditing
            ? widget.normalMarket!.id
            : '', // ID will be generated by backend for new markets
        marketName: _marketNameController.text,
        marketLocation: _marketLocationController.text,
        marketPhone: _marketPhoneController.text.isNotEmpty
            ? _marketPhoneController.text
            : null,
        marketEmail: _marketEmailController.text.isNotEmpty
            ? _marketEmailController.text
            : null,
        marketWalletPublicKey: '',
        marketWalletSecretKey: '',
        fractions: 100, // Default value, will be set by backend
        fractionalNFTAddress: _fractionalNFTAddress,
        owner: '',
        products: [],
        marketImage: '',
      );

      try {
        bool success;
        if (_isEditing) {
          success = await provider.updateExistingMarket(
            widget.normalMarket!.id,
            marketModel,
          );
        } else {
          success = await provider.addMarket(marketModel);
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF24C168),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing
                        ? 'Market updated successfully'
                        : 'Market created successfully',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NormalMarketProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 800
        ? 700.0
        : screenWidth > 600
            ? screenWidth * 0.85
            : screenWidth - 40;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _isEditing ? 'Edit Market' : 'Create Market',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        actions: [
          TextButton.icon(
            onPressed: provider.isSubmitting ? null : _submitForm,
            icon: Icon(
              _isEditing ? Icons.update : Icons.save,
              color: const Color(0xFF24C168),
            ),
            label: Text(
              _isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                color: Color(0xFF24C168),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: TextButton.styleFrom(
              disabledForegroundColor: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: provider.isSubmitting
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF24C168)),
                    SizedBox(height: 16),
                    Text('Processing...',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: formWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Page title
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                Icon(
                                  _isEditing
                                      ? Icons.edit_note
                                      : Icons.storefront_outlined,
                                  color: const Color(0xFF24C168),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _isEditing
                                        ? 'Update Market Details'
                                        : 'Create New Market',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Image preview and picker
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildImageSection(provider),
                          ),
                          const SizedBox(height: 24),

                          // Error message display
                          if (provider.errorMessage.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900.withOpacity(0.2),
                                  border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.redAccent, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        provider.errorMessage,
                                        style: const TextStyle(
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Form fields
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Basic Information',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Fields in a card
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildTextField(
                                        controller: _marketNameController,
                                        label: 'Market Name',
                                        icon: Icons.store,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter market name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _marketLocationController,
                                        label: 'Market Location',
                                        icon: Icons.location_on,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter market location';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _marketPhoneController,
                                        label: 'Market Phone (optional)',
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _marketEmailController,
                                        label: 'Market Email (optional)',
                                        icon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Note about automatically managed fields - only show in create mode, not update
                          if (!_isEditing) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF24C168).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFF24C168)
                                          .withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: Color(0xFF24C168), size: 22),
                                        SizedBox(width: 10),
                                        Text(
                                          "Automatic Market Setup",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF24C168),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Wallet keys and ownership percentage are automatically generated and managed by the system.",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Submit button
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ElevatedButton(
                              onPressed:
                                  provider.isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF24C168),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      _isEditing
                                          ? Icons.update
                                          : Icons.check_circle,
                                      size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isEditing
                                        ? 'Update Market'
                                        : 'Create Market',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFF24C168)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF24C168), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildImageSection(NormalMarketProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image, color: Color(0xFF24C168), size: 22),
              SizedBox(width: 10),
              Text(
                'Market Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio:
                16 / 9, // Standard aspect ratio for better image display
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isEditing &&
                        widget.normalMarket?.marketImage != null &&
                        !provider.hasSelectedImage
                    ? _buildExistingImage(widget.normalMarket!.marketImage!)
                    : _buildImagePickerContent(provider),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(provider),
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_isEditing ? 'Change Image' : 'Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24C168),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to pick an image, accounting for web platform
  Future<void> _pickImage(NormalMarketProvider provider) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF24C168),
          content: Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 12),
              Text('Selecting image...', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Pick image using the provider method
      await provider.pickImage();

      // Check result
      if (!provider.hasSelectedImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 12),
                Text('No image selected',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Show success message with file info
        String fileInfo = 'Image selected';
        if (kIsWeb && provider.selectedImageBytes != null) {
          final fileSize =
              (provider.selectedImageBytes!.length / 1024).toStringAsFixed(1);
          fileInfo = 'Image selected (${fileSize} KB)';
        } else if (!kIsWeb && provider.selectedImage != null) {
          final fileSize =
              (provider.selectedImage!.lengthSync() / 1024).toStringAsFixed(1);
          fileInfo = 'Image selected (${fileSize} KB)';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF24C168),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(fileInfo, style: const TextStyle(color: Colors.white)),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error selecting image: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildExistingImage(String imagePath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image or placeholder
        imagePath.isNotEmpty
            ? Image.network(
                ApiConstants.getFullImageUrl(imagePath),
                fit: BoxFit.contain, // Use contain to show full image
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading existing image: $error');
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image,
                            size: 40, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load image',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFF2A2A2A),
                child: const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),

        // Overlay text
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'Current Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerContent(NormalMarketProvider provider) {
    // For web, we use selectedImageBytes
    if (kIsWeb && provider.selectedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Selected image for web
          Image.memory(
            provider.selectedImageBytes!,
            fit: BoxFit.contain, // Use contain to show full image
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying selected image: $error');
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 40, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay text with gradient - FIXED OVERFLOW
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    // Using Wrap instead of Row to prevent overflow
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF24C168), size: 18),
                      Text(
                        provider.selectedImageName != null
                            ? 'New Image Selected'
                            : 'Image Selected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // If we have a filename, show it separately
          if (provider.selectedImageName != null)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    "(${provider.selectedImageName})",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    // For mobile/desktop, we use selectedImage
    else if (!kIsWeb && provider.selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Selected image for mobile/desktop
          Image.file(
            provider.selectedImage!,
            fit: BoxFit.contain, // Use contain to show full image
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying selected image: $error');
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 40, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay text with gradient - FIXED OVERFLOW
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    // Using Wrap instead of Row
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF24C168), size: 18),
                      Text(
                        'New Image Selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    // No image selected
    else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 50,
              color: Color(0xFF24C168),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Image Selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to select an image',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
