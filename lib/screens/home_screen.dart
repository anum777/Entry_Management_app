import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/visitor_form.dart';
import '../widgets/visitor_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _EntryPage(),
    VisitorList(showOnlyActive: true),
    VisitorList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Entry Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 28),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {},
            tooltip: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.business,
                        size: 40,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Organization Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Text(
                      'Welcome!',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.add_circle,
                  size: 24,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'New Entry',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.people,
                  size: 24,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'Active Visitors',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  size: 24,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'History',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  size: 24,
                  color: Color(0xFF1976D2),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  // No need to manually navigate to /login, AuthGate will handle it
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'New Entry',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Active'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class _EntryPage extends StatelessWidget {
  const _EntryPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_add, size: 32, color: Colors.blue),
                  SizedBox(width: 12),
                  Text(
                    'New Visitor Entry',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              VisitorForm(
                onVisitorAdded: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visitor entry recorded')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
