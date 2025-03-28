import 'package:flutter/material.dart';
import '../home_screen.dart';
import './add_record_content.dart';

class MedicalRecordsContent extends StatelessWidget {
  final Function onBack;
  final Function onAddRecord;
  
  const MedicalRecordsContent({
    super.key,
    required this.onBack,
    required this.onAddRecord,
  });

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Medical Record',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Empty State Content
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Medical Record Icon
              Icon(
                Icons.assignment_outlined,
                size: 120,
                color: const Color(0xFFDC1B22).withOpacity(0.8),
              ),
              const SizedBox(height: 40),
              
              // Empty State Text
              const Text(
                'You Have Not\nAdded Any Medical\nRecords Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC1B22),
                  height: 1.2,
                ),
              ),
              
              const Spacer(),
              
              // Add Records Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => onAddRecord(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC1B22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Add Records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 