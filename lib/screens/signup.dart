import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:v1/emailauth/auth.dart';
import 'package:v1/emailauth/pages/loginpage.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  late DateTime? selectedDOB = DateTime.now(); // Variable to store selected DOB
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneNumberController =
      TextEditingController(); // Controller for phone number
  final slotsController =
      TextEditingController(); // Controller for slots available
  final landAreaController =
      TextEditingController(); // Controller for land area
  double? _latitude;
  double? _longitude;
  String userEmail = Auth().currentUser!.email!;

  List<String> imageUrls = [];
  List<String> ownershipImageUrls = [];
  bool _isUploadingImages = false;
  bool _isUploadingOwnershipImages = false;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('plotowners');
  bool evCharging = false;
  bool washroomFacilities = false;
  bool security = false;
  bool shadedStructure = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Fill Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              child: Column(
                children: [
                  // First name
                  TextFormField(
                    controller: firstnameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Last name
                  TextFormField(
                    controller: lastnameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone number
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date of Birth
                  TextFormField(
                    readOnly: true,
                    onTap: () {
                      _selectDate(context); // Call method to select DOB
                    },
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedDOB != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDOB!)
                          : '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Number of slots available
                  TextFormField(
                    controller: slotsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Slots Available',
                      prefixIcon: const Icon(Icons.confirmation_num),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Land area
                  TextFormField(
                    controller: landAreaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Land Area (sq. km)',
                      prefixIcon: const Icon(Icons.landscape),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amenities Checkboxes
                  _buildAmenitiesCheckboxes(),
                  const SizedBox(height: 16),
                  // Location input
                  LocationInput(
                    onLocationChanged: (latitude, longitude) {
                      setState(() {
                        _latitude = latitude;
                        _longitude = longitude;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Add Images
                  _buildAddImages(),
                  const SizedBox(height: 16),
                  // Add Images of Land Ownership Proof
                  _buildAddOwnershipImages(),
                  const SizedBox(height: 16),
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isUploadingImages || _isUploadingOwnershipImages
                              ? null
                              : _createAccount,
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to select DOB
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDOB = picked;
      });

      // Format the selected date
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDOB!);
      // Save the formatted date to the database or wherever you need to store it
      print('Formatted Date: $formattedDate');
    }
  }

  // Build widget for adding amenities checkboxes
  Widget _buildAmenitiesCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Amenities',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Row(
            children: [
              Icon(Icons.ev_station),
              SizedBox(width: 8),
              Text('EV Charging'),
            ],
          ),
          value: evCharging,
          onChanged: (value) {
            setState(() {
              evCharging = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Row(
            children: [
              Icon(Icons.wash),
              SizedBox(width: 8),
              Text('Washroom'),
            ],
          ),
          value: washroomFacilities,
          onChanged: (value) {
            setState(() {
              washroomFacilities = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Row(
            children: [
              Icon(Icons.accessibility),
              SizedBox(width: 8),
              Text('Security'),
            ],
          ),
          value: security,
          onChanged: (value) {
            setState(() {
              security = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Row(
            children: [
              Icon(Icons.house),
              SizedBox(width: 8),
              Text('Shade'),
            ],
          ),
          value: shadedStructure,
          onChanged: (value) {
            setState(() {
              shadedStructure = value!;
            });
          },
        ),
      ],
    );
  }

  // Build widget for adding images
  Widget _buildAddImages() {
    return Column(
      children: [
        // Preview images or show no images chosen
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          child: _buildImagePreview(),
        ),
        const SizedBox(height: 8),
        // Button to add images
        TextButton.icon(
          onPressed: _isUploadingImages ? null : _addImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Images'),
        ),
      ],
    );
  }

  // Build image preview widget
  Widget _buildImagePreview() {
    if (imageUrls.isEmpty) {
      return const Text(
        'No Images chosen',
        textAlign: TextAlign.center,
      );
    } else {
      return SizedBox(
        height: 170,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    imageUrls[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteImage(index),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // Method to add images
  Future<void> _addImages() async {
    final picker = ImagePicker();
    setState(() {
      _isUploadingImages = true;
    });
    try {
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 600,
      );
      for (var file in pickedFiles) {
        final imageUrl = await _uploadImageToStorage(file.path);
        setState(() {
          imageUrls.add(imageUrl);
        });
      }
    } catch (error) {
      print('Error picking image: $error');
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  // Method to delete an image
  void _deleteImage(int index) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrls[index]).delete();
      setState(() {
        imageUrls.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image deleted successfully'),
        ),
      );
    } catch (error) {
      print('Error deleting image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting image. Please try again.'),
        ),
      );
    }
  }

  // Method to upload image to Firebase Storage
  Future<String> _uploadImageToStorage(String imagePath) async {
    final fileName =
        imagePath.split('/').last; // Extracting file name from path
    final path = 'images/$fileName'; // Define the path in storage
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(path);

    try {
      final task = storageReference.putFile(File(imagePath));
      final snapshot = await task.whenComplete(() => task.snapshot);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (error) {
      print('Error uploading image: $error');
      // Handle error appropriately
      return ''; // Or throw an error
    }
  }

  // Build widget for adding images of land ownership proof
  Widget _buildAddOwnershipImages() {
    return Column(
      children: [
        // Preview images or show no images chosen
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          child: _buildOwnershipImagePreview(),
        ),
        const SizedBox(height: 8),
        // Button to add images
        TextButton.icon(
          onPressed: _isUploadingOwnershipImages ? null : _addOwnershipImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Ownership Proof'),
        ),
      ],
    );
  }

  // Build image preview widget for land ownership proof
  Widget _buildOwnershipImagePreview() {
    if (ownershipImageUrls.isEmpty) {
      return const Text(
        'No Images chosen',
        textAlign: TextAlign.center,
      );
    } else {
      return SizedBox(
        height: 170,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ownershipImageUrls.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    ownershipImageUrls[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteOwnershipImage(index),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // Method to add images of land ownership proof
  Future<void> _addOwnershipImages() async {
    final picker = ImagePicker();
    setState(() {
      _isUploadingOwnershipImages = true;
    });
    try {
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 600,
      );
      for (var file in pickedFiles) {
        final imageUrl = await _uploadOwnershipImageToStorage(file.path);
        setState(() {
          ownershipImageUrls.add(imageUrl);
        });
      }
    } catch (error) {
      print('Error picking image: $error');
    } finally {
      setState(() {
        _isUploadingOwnershipImages = false;
      });
    }
  }

  // Method to delete an image of land ownership proof
  void _deleteOwnershipImage(int index) async {
    try {
      await FirebaseStorage.instance
          .refFromURL(ownershipImageUrls[index])
          .delete();
      setState(() {
        ownershipImageUrls.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image deleted successfully'),
        ),
      );
    } catch (error) {
      print('Error deleting image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting image. Please try again.'),
        ),
      );
    }
  }

  // Method to upload image of land ownership proof to Firebase Storage
  Future<String> _uploadOwnershipImageToStorage(String imagePath) async {
    final fileName =
        imagePath.split('/').last; // Extracting file name from path
    final path = 'ownership_images/$fileName'; // Define the path in storage
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(path);

    try {
      final task = storageReference.putFile(File(imagePath));
      final snapshot = await task.whenComplete(() => task.snapshot);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (error) {
      print('Error uploading image: $error');
      // Handle error appropriately
      return ''; // Or throw an error
    }
  }

  // Method to create account
// Method to create account
  void _createAccount() async {
    try {
      // Check if all required fields are filled
      if (firstnameController.text.isEmpty ||
          lastnameController.text.isEmpty ||
          selectedDOB == null ||
          slotsController.text.isEmpty ||
          landAreaController.text.isEmpty ||
          phoneNumberController.text.isEmpty ||
          _latitude == null ||
          _longitude == null ||
          imageUrls.isEmpty ||
          ownershipImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the fields'),
          ),
        );
        return;
      }

      String formattedDOB = DateFormat('dd/MM/yyyy').format(selectedDOB!);

      // Add data to Firestore
      await _reference.add({
        'firstname': firstnameController.text,
        'lastname': lastnameController.text,
        'phone': phoneNumberController.text,
        'dob': formattedDOB,
        'slots': int.parse(slotsController.text),
        'land_area': double.parse(landAreaController.text),
        'latitude': _latitude,
        'longitude': _longitude,
        'ev_charging': evCharging,
        'washroom_facilities': washroomFacilities,
        'security': security,
        'shaded_structure': shadedStructure,
        'images': imageUrls,
        'ownership_images': ownershipImageUrls,
        'email': userEmail,
        'verification': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
        ),
      );

      // Clear all fields after successful account creation
      firstnameController.clear();
      lastnameController.clear();
      phoneNumberController.clear();
      selectedDOB = null;
      slotsController.clear();
      landAreaController.clear();
      imageUrls.clear();
      ownershipImageUrls.clear();
      setState(() {
        evCharging = false;
        washroomFacilities = false;
        security = false;
        shadedStructure = false;
      });

      // Navigate to the login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (error) {
      print('Error creating account: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating account. Please try again.'),
        ),
      );
    }
  }
}

class LocationInput extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationChanged;

  const LocationInput({Key? key, required this.onLocationChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  LocationData? _locationData;
  var _isGettingLocation = false;

  void _getCurrentLocation() async {
    Location location = Location();

    setState(() {
      _isGettingLocation = true;
    });

    try {
      _locationData = await location.getLocation();
      setState(() {
        _isGettingLocation = false;
      });
      // Pass current location data to parent widget
      widget.onLocationChanged(
        _locationData!.latitude!,
        _locationData!.longitude!,
      );
    } catch (error) {
      setState(() {
        _isGettingLocation = false;
      });
      print("Error getting current location: $error");
    }
  }

  Widget _buildMapPreview() {
    return Container(
      height: 250, // Increase the height
      decoration: BoxDecoration(
        // Add border decoration
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0), // Add border radius
      ),
      child: _locationData != null
          ? FlutterMap(
              options: MapOptions(
                initialCenter:
                    LatLng(_locationData!.latitude!, _locationData!.longitude!),
                initialZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/parkshare/clvddk2st00zq01oc72t21np8/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicGFya3NoYXJlIiwiYSI6ImNsdmM0NW8zYjBmazcyanBiY3JuOTB5dDYifQ.N7I-hmOHsuG7HPvYixbUkQ',
                  additionalOptions: const {
                    'accesstoken':
                        'pk.eyJ1IjoicGFya3NoYXJlIiwiYSI6ImNsdmM0NW8zYjBmazcyanBiY3JuOTB5dDYifQ.N7I-hmOHsuG7HPvYixbUkQ',
                    'id': 'mapbox.mapbox-streets-v8',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 60,
                      height: 60,
                      point: LatLng(
                          _locationData!.latitude!, _locationData!.longitude!),
                      child: const Icon(
                        Icons.location_pin,
                        size: 30,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Container(
              alignment: Alignment.center,
              child: const Text('No location chosen'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMapPreview(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            // TextButton.icon(
            //   onPressed: () {
            //     // Implement the functionality to select location on map
            //   },
            //   icon: const Icon(Icons.map),
            //   label: const Text('Select on Map'),
            // ),
          ],
        )
      ],
    );
  }
}
