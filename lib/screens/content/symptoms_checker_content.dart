import 'package:flutter/material.dart';
import 'cardiovascular_risk_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomsCheckerContent extends StatefulWidget {
  final Function onBack;

  const SymptomsCheckerContent({
    super.key,
    required this.onBack,
  });

  @override
  State<SymptomsCheckerContent> createState() => _SymptomsCheckerContentState();
}

class _SymptomsCheckerContentState extends State<SymptomsCheckerContent> {
  final List<Symptom> _symptoms = [
    Symptom(
      name: 'Headache',
      icon: Icons.sick,
      description: 'Headache is pain in any region of the head. Headaches may occur on one or both sides of the head, be isolated to a certain location, radiate across the head from one point, or have a viselike quality. A headache may appear as a sharp pain, a throbbing sensation or a dull ache.',
    ),
    Symptom(
      name: 'Shortness of Breath',
      icon: Icons.air,
      description: 'Shortness of breath, or dyspnea, is the feeling that you cannot get enough air. It may occur during rest or with activity. You may feel like you need to breathe more or breathe faster. Sometimes you may feel like you have tightness in your chest.',
    ),
    Symptom(
      name: 'Fatigue',
      icon: Icons.battery_alert,
      description: "Fatigue is a term used to describe an overall feeling of tiredness or lack of energy. It isn't the same as simply feeling drowsy or sleepy. When you're fatigued, you have no motivation and no energy. Being sleepy may be a symptom of fatigue, but it's not the same thing.",
    ),
    Symptom(
      name: 'Dizziness',
      icon: Icons.motion_photos_auto,
      description: 'Dizziness is a term used to describe a range of sensations, such as feeling faint, woozy, weak or unsteady. Dizziness that creates the false sense that you or your surroundings are spinning or moving is called vertigo.',
    ),
    Symptom(
      name: 'Palpitations',
      icon: Icons.favorite,
      description: "Heart palpitations are feelings of having a fast-beating, fluttering or pounding heart. Stress, exercise, medication or, rarely, a medical condition can trigger them. Although heart palpitations can be worrisome, they're usually harmless.",
    ),
    Symptom(
      name: 'Chest pain',
      icon: Icons.medical_information,
      description: 'Chest pain appears in many forms, ranging from a sharp stab to a dull ache. Sometimes chest pain feels crushing or burning. In certain cases, the pain travels up the neck, into the jaw, and then radiates to the back or down one or both arms.',
    ),
    Symptom(
      name: 'Wheezing',
      icon: Icons.air_sharp,
      description: "Wheezing is a high-pitched whistling sound made while breathing. It's heard most clearly when you exhale, but in severe cases, it can be heard when you inhale. It's caused by narrowed airways or inflammation.",
    ),
  ];

  bool _canProceed = false;
  bool _isLoading = false;

  void _updateSymptomFrequency(Symptom symptom, String frequency) {
    setState(() {
      symptom.frequency = frequency;
      _canProceed = _symptoms.any((s) => s.frequency != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'Symptoms Checker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Symptoms List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _symptoms.length + 1, // +1 for the proceed button
            itemBuilder: (context, index) {
              if (index == _symptoms.length) {
                return _buildProceedButton();
              }
              final symptom = _symptoms[index];
              return _buildSymptomItem(symptom);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomItem(Symptom symptom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: const Color(0xFFDC1B22),
        collapsedBackgroundColor: const Color(0xFFDC1B22),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Row(
          children: [
            Icon(symptom.icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              symptom.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.description!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFrequencyOption(
                      'Almost Everyday',
                      symptom.frequency == 'Almost Everyday',
                      () => _updateSymptomFrequency(symptom, 'Almost Everyday'),
                    ),
                    const SizedBox(width: 12),
                    _buildFrequencyOption(
                      'Sometimes',
                      symptom.frequency == 'Sometimes',
                      () => _updateSymptomFrequency(symptom, 'Sometimes'),
                    ),
                    const SizedBox(width: 12),
                    _buildFrequencyOption(
                      'Never',
                      symptom.frequency == 'Never',
                      () => _updateSymptomFrequency(symptom, 'Never'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDC1B22) : Colors.white,
            border: Border.all(
              color: const Color(0xFFDC1B22),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFDC1B22),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ElevatedButton(
        onPressed: _canProceed && !_isLoading
            ? _saveAndProceed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC1B22),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 0),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Proceed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _saveAndProceed() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create two different data structures: one for Firestore, one for the UI
      final selectedSymptomsForFirestore = _symptoms
          .where((s) => s.frequency != null)
          .map((s) => {
                'name': s.name,
                'frequency': s.frequency,
                // Remove timestamp from individual symptoms
              })
          .toList();

      final selectedSymptomsForUI = _symptoms
          .where((s) => s.frequency != null)
          .map((s) => {
                'name': s.name,
                'frequency': s.frequency!,
              })
          .toList();

      // Save to Firestore with proper data structure
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('symptom_assessments')
          .add({
            'symptoms': selectedSymptomsForFirestore, // Array of symptoms
            'createdAt': FieldValue.serverTimestamp(), // Single timestamp for the entire assessment
            'status': 'completed',
          });

      if (!mounted) return;

      // Navigate to results screen with UI-specific data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardiovascularRiskContent(
            onBack: () => Navigator.pop(context),
            symptoms: selectedSymptomsForUI,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show more specific error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save assessment: ${e.toString().replaceAll('Exception:', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      print('Error saving assessment: $e'); // For debugging
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class Symptom {
  final String name;
  final IconData icon;
  final String? description;
  String? frequency;

  Symptom({
    required this.name,
    required this.icon,
    this.description,
    this.frequency,
  });
} 