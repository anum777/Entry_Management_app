import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VisitorList extends StatelessWidget {
  final bool showOnlyActive;
  final FirebaseService _firebaseService = FirebaseService();

  VisitorList({super.key, this.showOnlyActive = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseAuth.instance.currentUser == null
          ? Future.value(null)
          : FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((doc) => doc.data()),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          // Show loading or fallback UI
          return const Center(child: CircularProgressIndicator());
        }
        final role = userSnapshot.data!['role'];
        final username = userSnapshot.data!['username'] ?? '';
        Widget adminBanner = const SizedBox();
        if (role == 'admin') {
          adminBanner = Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Admin: $username',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            adminBanner,
            Expanded(
              child: role == 'admin'
                  // ADMIN INTERFACE: show all entries, show which guard made each entry
                  ? StreamBuilder<List<Visitor>>(
                      stream: showOnlyActive
                          ? _firebaseService.getActiveVisitors()
                          : _firebaseService.getVisitors(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: \\${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final visitors = snapshot.data ?? [];
                        if (visitors.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.blue.shade100,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    showOnlyActive
                                        ? 'No active visitors.'
                                        : 'No visitors found.',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueGrey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 0,
                          ),
                          itemCount: visitors.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final visitor = visitors[index];
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 24,
                                ),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: visitor.status == 'inside'
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  child: Icon(
                                    visitor.status == 'inside'
                                        ? Icons.person
                                        : Icons.exit_to_app,
                                    color: visitor.status == 'inside'
                                        ? Colors.blue
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                ),
                                title: Text(
                                  visitor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Purpose: \\${visitor.purpose}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Phone: \\${visitor.phone}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Entry: \\${_formatDateTime(visitor.entryTime)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      if (visitor.exitTime != null)
                                        Text(
                                          'Exit: \\${_formatDateTime(visitor.exitTime!)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.green,
                                          ),
                                        ),
                                      FutureBuilder<Map<String, dynamic>?>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(visitor.createdBy)
                                            .get()
                                            .then((doc) => doc.data()),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data == null)
                                            return const SizedBox();
                                          final username =
                                              snapshot.data!['username'] ??
                                              'Unknown';
                                          return Text(
                                            'Entry by: \\${username}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.deepPurple,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: visitor.status == 'inside'
                                    ? ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.logout,
                                          size: 18,
                                        ),
                                        label: const Text('Mark Exit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () => _firebaseService
                                            .updateVisitorExit(visitor.id),
                                      )
                                    : const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  // GUARD INTERFACE: show only their own entries, no guard info
                  : StreamBuilder<List<Visitor>>(
                      stream: showOnlyActive
                          ? _firebaseService.getActiveVisitorsForCurrentUser()
                          : _firebaseService.getVisitorsForCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: \\${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final visitors = snapshot.data ?? [];
                        if (visitors.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.blue.shade100,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    showOnlyActive
                                        ? 'No active visitors.'
                                        : 'No visitors found.',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueGrey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 0,
                          ),
                          itemCount: visitors.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final visitor = visitors[index];
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 24,
                                ),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: visitor.status == 'inside'
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  child: Icon(
                                    visitor.status == 'inside'
                                        ? Icons.person
                                        : Icons.exit_to_app,
                                    color: visitor.status == 'inside'
                                        ? Colors.blue
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                ),
                                title: Text(
                                  visitor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Purpose: \\${visitor.purpose}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Phone: \\${visitor.phone}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Entry: \\${_formatDateTime(visitor.entryTime)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      if (visitor.exitTime != null)
                                        Text(
                                          'Exit: \\${_formatDateTime(visitor.exitTime!)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: visitor.status == 'inside'
                                    ? ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.logout,
                                          size: 18,
                                        ),
                                        label: const Text('Mark Exit'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: () => _firebaseService
                                            .updateVisitorExit(visitor.id),
                                      )
                                    : const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
