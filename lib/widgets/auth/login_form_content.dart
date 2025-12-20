import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/routing/app_routes.dart';

/// Login form content styled for draggable sheet overlay
class LoginFormContent extends StatefulWidget {
  const LoginFormContent({super.key});

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const SizedBox(height: 28),
              _buildForm(isLoading),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildSocialButtons(isGoogleLoading, isAppleLoading),
              const SizedBox(height: 24),
              _buildSignUpLink(),
              const SizedBox(height: 12),
              _buildDemoButton(),
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
        // Logo with glow
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.music, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Use Me',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Reservez votre prochaine session',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.8),
              ),
              child: const Text('Mot de passe oublie ?'),
            ),
          ),
          const SizedBox(height: 16),
          _buildLoginButton(isLoading),
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

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
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
            : const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('ou', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
      ],
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
            onPressed: () => _socialLogin('google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: FontAwesomeIcons.apple,
            label: 'Apple',
            isLoading: isAppleLoading,
            onPressed: () => _socialLogin('apple'),
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

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.signup),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('S\'inscrire', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDemoButton() {
    return TextButton.icon(
      onPressed: _showDemoSelector,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.7),
      ),
      icon: FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 14),
      label: const Text('Acces demo'),
    );
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(SignInWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _socialLogin(String provider) {
    if (provider == 'google') {
      context.read<AuthBloc>().add(const SignInWithGoogleEvent());
    } else if (provider == 'apple') {
      context.read<AuthBloc>().add(const SignInWithAppleEvent());
    }
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez votre email d\'abord')),
      );
      return;
    }
    context.read<AuthBloc>().add(ResetPasswordEvent(email: email));
  }

  void _showDemoSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DemoSelectorSheet(),
    );
  }
}

class _DemoSelectorSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Mode Demo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Naviguer sans connexion', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.buildingUser),
              title: const Text('Studio (Admin)'),
              subtitle: const Text('Gerer sessions, artistes, services'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.headphones),
              title: const Text('Ingenieur son'),
              subtitle: const Text('Voir et tracker les sessions'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.engineerDashboard);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.music),
              title: const Text('Artiste'),
              subtitle: const Text('Reserver des sessions'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.artistPortal);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
