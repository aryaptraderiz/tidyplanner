import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/task.dart';
import '../services/firebase_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'calendar_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showProfileOptions = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuint,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleProfileOptions() {
    setState(() {
      _showProfileOptions = !_showProfileOptions;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) { // Calendar index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete "${task.title}"?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              FirebaseService().deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${task.title}" deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void markAsCompleted(Task task) {
    FirebaseService().updateTask(task.copyWith(completed: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" marked as completed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool matchesFilter(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

    if (_filter == 'Today') return taskDate == today;
    if (_filter == 'Tomorrow') return taskDate == tomorrow;
    if (_filter == 'Work') return task.category == 'Work';
    if (_filter == 'Personal') return task.category == 'Personal';
    return true;
  }

  PreferredSizeWidget _buildAppBar(User user) {
    return AppBar(
      title: AnimatedOpacity(
        opacity: _showProfileOptions ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Text(
          'Hello, ${user.displayName ?? 'User'} 👋',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: _toggleProfileOptions,
          child: Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              backgroundColor: Colors.indigo[100],
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? Text(
                user.displayName?.substring(0,1).toUpperCase() ?? 'U',
                style: GoogleFonts.poppins(
                  color: Colors.indigo[800],
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.indigo[700]),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOverlay(User user) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      top: _showProfileOptions ? 80 : -200,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo[100],
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                      user.displayName?.substring(0,1).toUpperCase() ?? 'U',
                      style: GoogleFonts.poppins(
                        color: Colors.indigo[800],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildProfileOption(Icons.person, 'Profile'),
              _buildProfileOption(Icons.settings, 'Settings'),
              _buildProfileOption(Icons.help, 'Help'),
              const Divider(height: 24),
              _buildProfileOption(Icons.logout, 'Logout', isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text, {bool isLogout = false}) {
    return InkWell(
      onTap: () {
        if (isLogout) {
          logout();
        }
        _toggleProfileOptions();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isLogout ? Colors.red : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => EditTaskScreen(task: task),
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (task.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 14, color: Colors.green.shade800),
                              const SizedBox(width: 4),
                              Text(
                                'Done',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(task.dueDate),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(task.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getCategoryColor(task.category),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildCountdownTimer(task),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!task.completed)
                        _buildActionButton(
                          icon: Icons.check,
                          color: Colors.green,
                          onPressed: () => markAsCompleted(task),
                        ),
                      _buildActionButton(
                        icon: Icons.edit,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => EditTaskScreen(task: task),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onPressed: () => deleteTask(task),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(Task task) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final remaining = task.dueDate.difference(now);
        final isOverdue = remaining.isNegative && !task.completed;

        String timeLeftText;
        Color textColor;

        if (isOverdue) {
          timeLeftText = 'Overdue';
          textColor = Colors.red;
        } else if (remaining.isNegative) {
          timeLeftText = 'Completed';
          textColor = Colors.green;
        } else {
          final days = remaining.inDays;
          final hours = remaining.inHours.remainder(24);
          final minutes = remaining.inMinutes.remainder(60);

          timeLeftText = '${days}d ${hours}h ${minutes}m left';
          textColor = Colors.orange;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOverdue ? Icons.warning_amber_rounded : Icons.access_time,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              timeLeftText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        shape: const CircleBorder(),
        color: color.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first task',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => setState(() => _filter = label),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: selected ? Theme.of(context).primaryColor : Colors.grey.shade700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo[100],
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                    user.displayName?.substring(0,1).toUpperCase() ?? 'U',
                    style: GoogleFonts.poppins(
                      color: Colors.indigo[800],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'User',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.indigo[700]),
            title: Text('Home', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: Colors.indigo[700]),
            title: Text('Calendar', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.indigo[700]),
            title: Text('Settings', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              // Add settings navigation here
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Logout', style: GoogleFonts.poppins(color: Colors.red.shade400)),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue.shade700;
      case 'Personal':
        return Colors.green.shade700;
      case 'Study':
        return Colors.purple.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(user),
          drawer: _buildDrawer(user),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('All', _filter == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Today', _filter == 'Today'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tomorrow', _filter == 'Tomorrow'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Work', _filter == 'Work'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Personal', _filter == 'Personal'),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: FirebaseService().getUserTasks(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      );
                    }

                    var tasks = snapshot.data ?? [];
                    final query = _searchController.text.toLowerCase();
                    if (query.isNotEmpty) {
                      tasks = tasks.where((t) => t.title.toLowerCase().contains(query)).toList();
                    }
                    tasks = tasks.where(matchesFilter).toList();

                    if (tasks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        // Refresh logic if needed
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => _buildTaskCard(tasks[index], context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AddTaskScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Icon(Icons.add, size: 28),
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
        if (_showProfileOptions) _buildProfileOverlay(user),
      ],
    );
  }
}