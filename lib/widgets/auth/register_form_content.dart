import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

/// Register form content styled for draggable sheet overlay
class RegisterFormContent extends StatefulWidget {
  final BaseUserRole? initialRole;
  final ValueChanged<BaseUserRole>? onRoleChanged;

  const RegisterFormContent({
    super.key,
    this.initialRole,
    this.onRoleChanged,
  });

  @override
  State<RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends State<RegisterFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late BaseUserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? BaseUserRole.client;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateRole(BaseUserRole role) {
    setState(() => _selectedRole = role);
    widget.onRoleChanged?.call(role);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;
        final isGoogleLoading = state is AuthGoogleLoadingState;
        final isAppleLoading = state is AuthAppleLoadingState;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildRoleSelector(),
              const SizedBox(height: 16),
              _buildSocialButtons(isGoogleLoading, isAppleLoading),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildForm(isLoading),
              const SizedBox(height: 20),
              _buildLoginLink(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.userPlus, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Creer un compte',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'Rejoignez la communaute',
          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je suis...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleChip(BaseUserRole.client, 'Artiste', FontAwesomeIcons.music)),
            const SizedBox(width: 10),
            Expanded(child: _buildRoleChip(BaseUserRole.worker, 'Ingenieur', FontAwesomeIcons.headphones)),
            const SizedBox(width: 10),
            Expanded(child: _buildRoleChip(BaseUserRole.admin, 'Studio', FontAwesomeIcons.buildingUser)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(BaseUserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _updateRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButtons(bool isGoogleLoading, bool isAppleLoading) {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            isLoading: isGoogleLoading,
            onPressed: () => _socialSignIn('google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.apple,
            label: 'Apple',
            isLoading: isAppleLoading,
            onPressed: () => _socialSignIn('apple'),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else
                  FaIcon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('ou par email', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            hint: _selectedRole == BaseUserRole.client ? 'Nom de scene ou nom' : 'Nom complet',
            icon: FontAwesomeIcons.user,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Nom requis';
              if (v!.length < 2) return 'Minimum 2 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            hint: 'Email',
            icon: FontAwesomeIcons.envelope,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Email requis';
              if (!v!.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            hint: 'Mot de passe',
            icon: FontAwesomeIcons.lock,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: FaIcon(
                _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Mot de passe requis';
              if (v!.length < 6) return 'Minimum 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _confirmController,
            hint: 'Confirmer le mot de passe',
            icon: FontAwesomeIcons.lock,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _register(),
            suffixIcon: IconButton(
              icon: FaIcon(
                _obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Confirmation requise';
              if (v != _passwordController.text) return 'Mots de passe differents';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildRegisterButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: FaIcon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(color: Colors.orangeAccent),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Creer mon compte', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Deja un compte ?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    final extraData = <String, dynamic>{};
    if (_selectedRole == BaseUserRole.client) {
      extraData['stageName'] = _nameController.text.trim();
    }

    context.read<AuthBloc>().add(SignUpWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
          extraData: extraData.isNotEmpty ? extraData : null,
        ));
  }

  void _socialSignIn(String provider) {
    if (provider == 'google') {
      context.read<AuthBloc>().add(const SignInWithGoogleEvent());
    } else if (provider == 'apple') {
      context.read<AuthBloc>().add(const SignInWithAppleEvent());
    }
  }
}
