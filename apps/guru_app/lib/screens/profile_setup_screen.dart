import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/theme.dart';
import 'package:shared/utils/validators.dart';
import 'package:uuid/uuid.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'DK');
  final _emailController = TextEditingController();
  String? _trainerId = seedTrainers.first.id;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AuthService().seedTrainersIfNeeded();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainersAsync = ref.watch(trainersProvider);
    final trainers = trainersAsync.value ?? seedTrainers;
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WtfSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: Validators.validateName,
              ),
              const SizedBox(height: WtfSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: WtfSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _trainerId,
                decoration: const InputDecoration(labelText: 'Trainer'),
                items: [
                  for (final trainer in trainers)
                    DropdownMenuItem(
                      value: trainer.id,
                      child: Text(
                        trainer.id == 'trainer-aarav-001'
                            ? '${trainer.name} (Lead Trainer)'
                            : trainer.name,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _trainerId = value),
              ),
              const SizedBox(height: WtfSpacing.lg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _trainerId == null) {
      return;
    }
    setState(() => _saving = true);
    final user = User(
      id: 'member-dk-${const Uuid().v4()}',
      role: UserRole.member,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      assignedTrainerId: _trainerId,
    );
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore());
      await ref.read(currentUserProvider.notifier).setCurrentUser(user);
      await ref.read(authServiceProvider).markOnboarded();
      if (mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
