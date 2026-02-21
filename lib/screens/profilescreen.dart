import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final collegeController = TextEditingController();
  final degreeController = TextEditingController();
  final objectiveController = TextEditingController();
  final skillsController = TextEditingController();
  final projectsController = TextEditingController();
  final githubController = TextEditingController();
  final linkedinController = TextEditingController();
  final resumeController = TextEditingController();

  String department = 'Computer Science';
  String year = '3rd Year';
  bool openToWork = true;

  final List<String> allDomains = [
    'Software Development',
    'Data / Business Analytics',
    'Data Science',
    'AI / Machine Learning',
    'Business Intelligence',
    'Product / Consulting',
  ];
  List<String> selectedDomains = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('career')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        collegeController.text = data['college'] ?? '';
        degreeController.text = data['degree'] ?? '';
        objectiveController.text = data['objective'] ?? '';
        skillsController.text = data['skills'] ?? '';
        projectsController.text = data['projects'] ?? '';
        githubController.text = data['github'] ?? '';
        linkedinController.text = data['linkedin'] ?? '';
        resumeController.text = data['resume'] ?? '';
        department = data['department'] ?? department;
        year = data['year'] ?? year;
        openToWork = data['openToWork'] ?? true;
        selectedDomains =
            List<String>.from(data['domains'] ?? <String>[]);
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('career')
        .set({
      'name': nameController.text,
      'college': collegeController.text,
      'degree': degreeController.text,
      'objective': objectiveController.text,
      'skills': skillsController.text,
      'projects': projectsController.text,
      'github': githubController.text,
      'linkedin': linkedinController.text,
      'resume': resumeController.text,
      'department': department,
      'year': year,
      'domains': selectedDomains,
      'openToWork': openToWork,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Career Profile Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Career Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              _card(context, 'Academic Details', [
                _field(context, 'Full Name', nameController),
                _field(context, 'College Name', collegeController),
                _field(context, 'Degree', degreeController),
                _dropdown(
                  context,
                  'Department',
                  department,
                  ['Computer Science', 'IT', 'AI & DS'],
                  (v) => setState(() => department = v!),
                ),
                _dropdown(
                  context,
                  'Year of Study',
                  year,
                  ['1st Year', '2nd Year', '3rd Year', '4th Year'],
                  (v) => setState(() => year = v!),
                ),
              ]),

              _card(context, 'Career Profile', [
                _field(context, 'Career Objective', objectiveController,
                    maxLines: 3),
                _field(context, 'Skills (comma separated)', skillsController),
                _field(context, 'Projects Summary', projectsController,
                    maxLines: 3),
              ]),

              _card(context, 'Portfolio Links', [
                _field(context, 'GitHub Profile URL', githubController),
                _field(context, 'LinkedIn Profile URL', linkedinController),
                _field(context, 'Resume Drive Link', resumeController),
              ]),

              _card(context, 'Professional Preferences', [
                Text(
                  'Interested Domains',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allDomains.map((d) {
                    final selected = selectedDomains.contains(d);
                    return FilterChip(
                      label: Text(d),
                      selected: selected,
                      selectedColor: colors.primaryContainer,
                      labelStyle: TextStyle(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                      ),
                      onSelected: (v) {
                        setState(() {
                          v
                              ? selectedDomains.add(d)
                              : selectedDomains.remove(d);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Open to Opportunities'),
                  value: openToWork,
                  onChanged: (v) => setState(() => openToWork = v),
                ),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'SAVE CAREER PROFILE',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label,
      TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: _inputDecoration(context, label),
      ),
    );
  }

  Widget _dropdown(
    BuildContext context,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(context, label),
        items: items
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}