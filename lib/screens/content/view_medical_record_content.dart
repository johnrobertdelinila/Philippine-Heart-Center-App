import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/medical_record.dart';
import '../../screens/content/edit_medical_record_content.dart';

class ViewMedicalRecordContent extends StatelessWidget {
  final Function onBack;

  const ViewMedicalRecordContent({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Content with StreamBuilder
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('medical_records')
                .doc('basic_info')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final record = MedicalRecord.fromMap(
                snapshot.data!.data() as Map<String, dynamic>
              );

              return Column(
                children: [
                  // App Bar
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    color: const Color(0xFFDC1B22),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => onBack(),
                        ),
                        const Expanded(
                          child: Text(
                            'Medical Record',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditMedicalRecordContent(
                                  initialData: record,
                                  onBack: () => Navigator.of(context).pop(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Basic Information
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem('Gender:', record.gender),
                              _buildInfoItem('Blood Type:', record.bloodType),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoItem('Age:', '${record.age} Years'),
                              _buildInfoItem('Weight:', '${record.weight.toInt()} Kg'),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Medical Categories Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            children: [
                              _buildCategoryCard(
                                icon: Icons.medical_information_outlined,
                                title: 'Allergies',
                                onTap: () {
                                  // TODO: Navigate to Allergies screen
                                },
                              ),
                              _buildCategoryCard(
                                icon: Icons.science_outlined,
                                title: 'Analysis',
                                onTap: () {
                                  // TODO: Navigate to Analysis screen
                                },
                              ),
                              _buildCategoryCard(
                                icon: Icons.vaccines_outlined,
                                title: 'Vaccinations',
                                onTap: () {
                                  // TODO: Navigate to Vaccinations screen
                                },
                              ),
                              _buildCategoryCard(
                                icon: Icons.history_edu_outlined,
                                title: 'Medical History',
                                onTap: () {
                                  // TODO: Navigate to Medical History screen
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC1B22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDC1B22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 