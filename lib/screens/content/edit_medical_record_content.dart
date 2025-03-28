import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/medical_record.dart';

class EditMedicalRecordContent extends StatefulWidget {
  final Function onBack;
  final MedicalRecord initialData;

  const EditMedicalRecordContent({
    super.key,
    required this.onBack,
    required this.initialData,
  });

  @override
  State<EditMedicalRecordContent> createState() => _EditMedicalRecordContentState();
}

class _EditMedicalRecordContentState extends State<EditMedicalRecordContent> {
  late String _selectedGender;
  late double _age;
  late double _weight;
  late double _height;
  late String _bloodType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided data
    _selectedGender = widget.initialData.gender;
    _age = widget.initialData.age.toDouble();
    _weight = widget.initialData.weight;
    _height = widget.initialData.height;
    _bloodType = widget.initialData.bloodType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            color: const Color(0xFFDC1B22),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => widget.onBack(),
                ),
                const Text(
                  'Edit Medical Record',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildGenderButton('Male'),
                      const SizedBox(width: 12),
                      _buildGenderButton('Female'),
                      const SizedBox(width: 12),
                      _buildGenderButton('Other'),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Age',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    value: _age,
                    min: 0,
                    max: 100,
                    onChanged: (value) => setState(() => _age = value),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Weight (kg)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    value: _weight,
                    min: 0,
                    max: 200,
                    onChanged: (value) => setState(() => _weight = value),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Height (cm)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    value: _height,
                    min: 0,
                    max: 250,
                    onChanged: (value) => setState(() => _height = value),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Blood Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButton<String>(
                      value: _bloodType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['A +', 'A -', 'B +', 'B -', 'AB +', 'AB -', 'O +', 'O -']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _bloodType = value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC1B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedGender = gender),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFDC1B22) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFFDC1B22),
          elevation: 0,
          side: BorderSide(
            color: const Color(0xFFDC1B22),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(gender),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFDC1B22),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: const Color(0xFFDC1B22),
            overlayColor: const Color(0xFFDC1B22).withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(0),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: Color(0xFFDC1B22),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              max.toStringAsFixed(0),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateRecord() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final record = MedicalRecord(
        gender: _selectedGender,
        age: _age.toInt(),
        weight: _weight,
        height: _height,
        bloodType: _bloodType,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medical_records')
          .doc('basic_info')
          .update(record.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully!')),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating record: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 