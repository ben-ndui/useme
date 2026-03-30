import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/card/holo_card.dart';
import 'package:useme/widgets/common/app_loader.dart';

/// Screen displaying the user's holographic digital business card.
class DigitalCardScreen extends StatelessWidget {
  const DigitalCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return const AppLoader.fullScreen();
        }

        final user = state.user as AppUser;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              l10n.myCard,
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.shareNodes, size: 18),
                color: Colors.white,
                onPressed: () => _shareCard(user, l10n),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HoloCard(user: user),
                  const SizedBox(height: 32),
                  Text(
                    l10n.tiltToExplore,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareCard(AppUser user, AppLocalizations l10n) {
    final name = user.stageName ?? user.displayName ?? user.name ?? '';
    final url = 'https://uzme.app/u/${user.uid}';
    SharePlus.instance.share(
      ShareParams(text: '$name on UZME\n$url'),
    );
  }
}
