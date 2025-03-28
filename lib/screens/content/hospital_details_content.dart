import 'package:flutter/material.dart';

class HospitalDetailsContent extends StatelessWidget {
  final Function onBack;
  // Sample coordinates for Baguio Medical Centre
  final double latitude = 16.4020;
  final double longitude = 120.5976;
  final String address = 'Baguio Medical Centre, Kennon Rd, Baguio, Benguet';
  // You should store this in a secure place, not in the code
  final String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  const HospitalDetailsContent({
    super.key,
    required this.onBack,
  });

  String _getStaticMapUrl() {
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude'
        '&zoom=15'
        '&size=600x300'
        '&maptype=roadmap'
        '&markers=color:red%7C$latitude,$longitude'
        '&key=$googleMapsApiKey';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Baguio Medical Centre',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Baguio Medical Centre',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC1B22),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A leading healthcare facility providing comprehensive medical services with state-of-the-art equipment and experienced healthcare professionals.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow('Address:', address),
                          _buildInfoRow('Phone:', '(074) 442-3831'),
                          const SizedBox(height: 20),
                          _buildScheduleSection(),
                          const SizedBox(height: 30),
                          _buildUserFrequencySection(),
                        ],
                      ),
                    ),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          // Map Image
                          Image.network(
                            _getStaticMapUrl(),
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFDC1B22),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '📍 $latitude° N, $longitude° E',
                                      style: const TextStyle(
                                        color: Color(0xFFDC1B22),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Location Details Overlay
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFFDC1B22)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attention schedule:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '7:15 AM - 6:30 PM\nMonday To Saturday',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildUserFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Frequency',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC1B22),
          ),
        ),
        const SizedBox(height: 16),
        _buildFrequencyBar('7:15 AM - 12:00 PM', 0.2),
        const SizedBox(height: 8),
        _buildFrequencyBar('1:00 PM - 4:00 PM', 0.5),
        const SizedBox(height: 8),
        _buildFrequencyBar('5:00 PM - 6:30 PM', 0.8),
      ],
    );
  }

  Widget _buildFrequencyBar(String time, double percentage) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            time,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC1B22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC1B22),
          ),
        ),
      ],
    );
  }
} 