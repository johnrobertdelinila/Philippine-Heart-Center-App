import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'login_screen.dart';
import 'content/medical_records_content.dart';
import 'content/add_record_content.dart';
import 'content/view_medical_record_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content/symptoms_checker_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  Widget _currentContent = const HomeContent();
  final DateTime _currentDate = DateTime.now();
  late DateTime _selectedDate;
  List<DateTime> _visibleDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDate;
    _generateVisibleDates();
  }

  void _generateVisibleDates() {
    // Generate 7 days starting from current date
    _visibleDates = List.generate(7, (index) {
      return _currentDate.add(Duration(days: index));
    });
  }

  String _getMonthName(int month) {
    return [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ][month - 1];
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFDC1B22)),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await _auth.signOut();
                    // Also sign out from Google if it was used
                    final googleSignIn = GoogleSignIn();
                    if (await googleSignIn.isSignedIn()) {
                      await googleSignIn.signOut();
                    }
                    // Sign out from Facebook if it was used
                    await FacebookAuth.instance.logOut();
                    
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFDC1B22)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentContent,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFDC1B22), size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDC1B22),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(DateTime date) {
    final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
    final dayName = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? const Color(0xFFDC1B22) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? const Color(0xFFDC1B22) : Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(String date, String time, String doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              doctor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialtyItem(BuildContext context, String label, IconData icon) {
    return InkWell(
      onTap: () async {
        switch (label) {
          case 'Medical\nRecords':
            // Show loading indicator immediately
            setState(() {
              _currentContent = const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFDC1B22),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Medical Records...',
                      style: TextStyle(
                        color: Color(0xFFDC1B22),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            });

            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                final docSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('medical_records')
                    .doc('basic_info')
                    .get();

                if (mounted) {
                  setState(() {
                    if (docSnapshot.exists) {
                      _currentContent = ViewMedicalRecordContent(
                        onBack: () {
                          setState(() {
                            _currentContent = const HomeContent();
                          });
                        },
                      );
                    } else {
                      _currentContent = MedicalRecordsContent(
                        onBack: () {
                          setState(() {
                            _currentContent = const HomeContent();
                          });
                        },
                        onAddRecord: () {
                          setState(() {
                            _currentContent = AddRecordContent(
                              onBack: () {
                                setState(() {
                                  _currentContent = ViewMedicalRecordContent(
                                    onBack: () {
                                      setState(() {
                                        _currentContent = const HomeContent();
                                      });
                                    },
                                  );
                                });
                              },
                            );
                          });
                        },
                      );
                    }
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _currentContent = const HomeContent();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
            break;
          case 'Heart\nMeter':
            // Navigate to Heart Meter screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Heart Meter - Coming Soon')),
            );
            break;
          case 'Refer Me!':
            setState(() {
              _currentContent = SymptomsCheckerContent(
                onBack: () {
                  setState(() {
                    _currentContent = const HomeContent();
                  });
                },
              );
            });
            break;
          case 'Educational\nResources':
            // Navigate to Educational Resources screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Educational Resources - Coming Soon')),
            );
            break;
          case 'Online\nConsultation':
            // Navigate to Online Consultation screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Online Consultation - Coming Soon')),
            );
            break;
          case 'Emergency\nContact':
            // Navigate to Emergency Contact screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Emergency Contact - Coming Soon')),
            );
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDC1B22)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFDC1B22), size: 30),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDC1B22),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Reset to home content when bottom nav is used
            _currentContent = const HomeContent();
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFDC1B22),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDC1B22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _visibleDates.map((date) => _buildDateItem(date)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See all',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                _buildAppointmentItem(
                  '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} - ${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_selectedDate.weekday - 1]}${_selectedDate.day == _currentDate.day ? ' - Today' : ''}',
                  '10:00 am',
                  'Dr. Olivia Turner',
                ),
                const SizedBox(height: 10),
                _buildAppointmentItem(
                  '${_currentDate.add(const Duration(days: 5)).day} ${_getMonthName(_currentDate.add(const Duration(days: 5)).month)} - ${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_currentDate.add(const Duration(days: 5)).weekday - 1]}',
                  '08:00 am',
                  'Dr. Alexander Bennett',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Fixed Top Bar
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildCircularButton(Icons.notifications_outlined),
                  const SizedBox(width: 10),
                  _buildCircularButton(Icons.settings),
                  const SizedBox(width: 10),
                  _buildCircularButton(Icons.search),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hi, WelcomeBack',
                        style: TextStyle(
                          color: Colors.red.shade200,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Jane Doe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  _buildProfileAvatar(context),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Color(0xFFDC1B22),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryItem(Icons.favorite_outline, 'Favorite'),
                      _buildCategoryItem(Icons.medical_services_outlined, 'Doctors'),
                      _buildCategoryItem(Icons.local_pharmacy_outlined, 'Pharmacy'),
                      _buildCategoryItem(Icons.local_hospital_outlined, 'Hospitals'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Calendar Section
                  _buildCalendarSection(),

                  const SizedBox(height: 30),

                  // Specialties Section
                  const Text(
                    'Specialties',
                    style: TextStyle(
                      color: Color(0xFFDC1B22),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: [
                      _buildSpecialtyItem(context, 'Medical\nRecords', Icons.folder_outlined),
                      _buildSpecialtyItem(context, 'Heart\nMeter', Icons.favorite_outline),
                      _buildSpecialtyItem(context, 'Refer Me!', Icons.person_outline),
                      _buildSpecialtyItem(context, 'Educational\nResources', Icons.school_outlined),
                      _buildSpecialtyItem(context, 'Online\nConsultation', Icons.video_call_outlined),
                      _buildSpecialtyItem(context, 'Emergency\nContact', Icons.emergency_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the parent HomeScreen state
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreenState == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Fixed Top Bar
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  homeScreenState._buildCircularButton(Icons.notifications_outlined),
                  const SizedBox(width: 10),
                  homeScreenState._buildCircularButton(Icons.settings),
                  const SizedBox(width: 10),
                  homeScreenState._buildCircularButton(Icons.search),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hi, WelcomeBack',
                        style: TextStyle(
                          color: Colors.red.shade200,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Jane Doe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  homeScreenState._buildProfileAvatar(context),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Color(0xFFDC1B22),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      homeScreenState._buildCategoryItem(Icons.favorite_outline, 'Favorite'),
                      homeScreenState._buildCategoryItem(Icons.medical_services_outlined, 'Doctors'),
                      homeScreenState._buildCategoryItem(Icons.local_pharmacy_outlined, 'Pharmacy'),
                      homeScreenState._buildCategoryItem(Icons.local_hospital_outlined, 'Hospitals'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Calendar Section
                  homeScreenState._buildCalendarSection(),

                  const SizedBox(height: 30),

                  // Specialties Section
                  const Text(
                    'Specialties',
                    style: TextStyle(
                      color: Color(0xFFDC1B22),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: [
                      homeScreenState._buildSpecialtyItem(context, 'Medical\nRecords', Icons.folder_outlined),
                      homeScreenState._buildSpecialtyItem(context, 'Heart\nMeter', Icons.favorite_outline),
                      homeScreenState._buildSpecialtyItem(context, 'Refer Me!', Icons.person_outline),
                      homeScreenState._buildSpecialtyItem(context, 'Educational\nResources', Icons.school_outlined),
                      homeScreenState._buildSpecialtyItem(context, 'Online\nConsultation', Icons.video_call_outlined),
                      homeScreenState._buildSpecialtyItem(context, 'Emergency\nContact', Icons.emergency_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
