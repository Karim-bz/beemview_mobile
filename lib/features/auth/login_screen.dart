import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/config.dart';
import '../../shared/widgets/beemview_wordmark.dart';
import '../../shared/widgets/comment_composer_sheet.dart' show GradientButton;
import 'auth_provider.dart';
import '../../l10n/app_strings.dart';

enum LoginState { empty, filled, loading, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isPasswordObscured = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  void _onFieldChanged() {
    if (_submitting) return;
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // -------- Validation --------

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return context.l10n.emailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return context.l10n.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return context.l10n.passwordRequired;
    if (value.length < 6) return context.l10n.passwordTooShort;
    return null;
  }

  // -------- Submit --------

  Future<void> _handleSignIn() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final ok = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      subdomain: AppConfig.tenantSubdomain,
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
      if (!ok) {
        _errorMessage =
            context.read<AuthProvider>().error ??
            context.l10n.loginFailed;
      }
    });
  }

  // -------- Build --------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: context.palette.skyGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _submitting ? _buildLoadingState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  // -------- Loading state --------

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _logoHeader(),
          const SizedBox(height: 44),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.signingIn,
            style: TextStyle(
              fontSize: 13.5,
              color: context.palette.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoHeader() {
    return Column(
      children: [
        Image.asset(AppAssets.beemviewLogo, width: 72, height: 72),
        const SizedBox(height: 10),
        const BeemViewWordmark(fontSize: 30),
        const SizedBox(height: 6),
        Text(
          context.l10n.loginTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: context.palette.muted,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // -------- Form state (empty / filled / error) --------

  Widget _field({
    required TextEditingController controller,
    required FocusNode focus,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? action,
    Iterable<String>? autofill,
    bool obscure = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    final focused = focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: focused ? AppColors.teal : Colors.transparent,
          width: 2,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focus,
        keyboardType: keyboardType,
        textInputAction: action,
        autofillHints: autofill,
        obscureText: obscure,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: focused ? AppColors.teal : context.palette.muted,
            size: 20,
          ),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(color: context.palette.muted, fontSize: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _logoHeader(),
            const SizedBox(height: 28),

            // Error banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.palette.dangerTint,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _field(
              controller: _emailController,
              focus: _emailFocus,
              hint: context.l10n.emailHint,
              icon: Icons.mail_outline_rounded,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              autofill: const [AutofillHints.email],
            ),
            const SizedBox(height: 14),
            _field(
              controller: _passwordController,
              focus: _passwordFocus,
              hint: context.l10n.passwordHint,
              icon: Icons.lock_outline_rounded,
              validator: _validatePassword,
              action: TextInputAction.done,
              autofill: const [AutofillHints.password],
              obscure: _isPasswordObscured,
              onSubmitted: (_) => _handleSignIn(),
              suffix: IconButton(
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: context.palette.muted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.comingSoon(context.l10n.passwordReset),
                        ),
                      ),
                    );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  context.l10n.forgotPassword,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GradientButton(
              label: context.l10n.signIn,
              height: 56,
              onPressed: _submitting ? null : _handleSignIn,
            ),
            const SizedBox(height: 28),
            Center(
              child: Image.asset(
                AppAssets.laptop,
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
