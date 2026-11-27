import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/app_config.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/features/login/widgets/login_form.dart';

/// Title + form, centred and width-limited. Shared by every layout.
class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({super.key, this.padding = Dimensions.spaceLg});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Dimensions.formMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: Dimensions.spaceLg),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop-only branding side.
class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Center(child: Text(AppConfig.appName, style: theme.textTheme.displayMedium)),
    );
  }
}
