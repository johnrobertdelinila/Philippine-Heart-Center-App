import 'package:flutter/material.dart';
import 'dart:math';
import 'hospital_details_content.dart';

class HospitalSearchContent extends StatefulWidget {
  final Function onBack;

  const HospitalSearchContent({
    super.key,
    required this.onBack,
  });

  @override
  State<HospitalSearchContent> createState() => _HospitalSearchContentState();
}

class _HospitalSearchContentState extends State<HospitalSearchContent> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _hospitalFound = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate search delay and finding a hospital
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _hospitalFound = true);
        _navigateToHospital();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToHospital() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalDetailsContent(
          onBack: widget.onBack,
        ),
      ),
    );
  }

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
                  onPressed: () => widget.onBack(),
                ),
                const Expanded(
                  child: Text(
                    'Searching for Hospitals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Search Animation
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 200 + 50 * sin(_pulseController.value * 2 * pi),
                      height: 200 + 50 * sin(_pulseController.value * 2 * pi),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDC1B22).withOpacity(
                            0.5 - 0.5 * sin(_pulseController.value * 2 * pi),
                          ),
                          width: 2,
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDC1B22).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      size: 80,
                      color: Color(0xFFDC1B22),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Searching for\nPartnered Hospitals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC1B22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 