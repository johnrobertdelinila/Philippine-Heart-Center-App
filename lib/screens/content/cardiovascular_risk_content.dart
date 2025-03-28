import 'package:flutter/material.dart';
import 'hospital_search_content.dart';

class CardiovascularRiskContent extends StatelessWidget {
  final Function onBack;
  final List<Map<String, String>> symptoms;

  const CardiovascularRiskContent({
    super.key,
    required this.onBack,
    required this.symptoms,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            color: const Color(0xFFDC1B22),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => onBack(),
                ),
                const Expanded(
                  child: Text(
                    'Cardiovascular Risk\nClassification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Risk Calculation Result',
                      style: TextStyle(
                        color: Color(0xFFDC1B22),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRiskMatrix(),
                    const SizedBox(height: 30),
                    _buildRiskLevel(),
                    const SizedBox(height: 30),
                    _buildRecommendations(),
                    const SizedBox(height: 30),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMatrix() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMatrixLabel('IMPACT', isVertical: true),
              Expanded(
                child: Column(
                  children: [
                    _buildMatrixRow([5, 10, 15, 20, 25], 'Catastrophic (5)'),
                    _buildMatrixRow([4, 8, 12, 16, 20], 'Significant (4)'),
                    _buildMatrixRow([3, 6, 9, 12, 15], 'Moderate (3)'),
                    _buildMatrixRow([2, 4, 6, 8, 10], 'Low (2)'),
                    _buildMatrixRow([1, 2, 3, 4, 5], 'Negligible (1)'),
                    const SizedBox(height: 10),
                    _buildMatrixLabels(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixLabel(String label, {bool isVertical = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: RotatedBox(
        quarterTurns: isVertical ? -1 : 0,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixRow(List<int> values, String label) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        ...values.map((value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: _getRiskColor(value),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: value >= 15 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMatrixLabels() {
    final labels = ['Improbable\n(1)', 'Remote\n(2)', 'Occasional\n(3)', 'Probable\n(4)', 'Frequent\n(5)'];
    return Row(
      children: [
        const SizedBox(width: 80),
        ...labels.map((label) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Color _getRiskColor(int value) {
    if (value >= 15) return const Color(0xFFFF6B6B);
    if (value >= 10) return const Color(0xFFFFB347);
    if (value >= 6) return const Color(0xFFFFD700);
    return const Color(0xFF90EE90);
    if (value >= 15) return Colors.red.shade400;
    if (value >= 10) return Colors.orange;
    if (value >= 6) return Colors.yellow;
    return Colors.green.shade300;
  }

  Widget _buildRiskLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CVD: MODERATE',
          style: TextStyle(
            color: Color(0xFFDC1B22),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Based on your symptoms assessment, you show moderate risk factors for cardiovascular disease. While not immediately severe, these symptoms suggest the need for medical attention and lifestyle modifications.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERSONAL RECOMMENDATIONS',
          style: TextStyle(
            color: Color(0xFFDC1B22),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Schedule a consultation with a cardiologist for a thorough evaluation. Monitor your blood pressure regularly and maintain a heart-healthy lifestyle including regular exercise and a balanced diet.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HospitalSearchContent(
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC1B22),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Consult a Doctor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement health tips
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFDC1B22)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Heart Health Tips',
              style: TextStyle(
                color: Color(0xFFDC1B22),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 