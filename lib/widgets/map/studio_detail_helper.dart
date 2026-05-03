import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzme/core/blocs/map/map_bloc.dart';
import 'package:uzme/core/blocs/map/map_event.dart';
import 'package:uzme/core/models/discovered_studio.dart';
import 'package:uzme/core/services/pro_profile_service.dart';
import 'package:uzme/widgets/artist/studio_detail_bottom_sheet.dart';
import 'package:uzme/widgets/pro/pro_detail_bottom_sheet.dart';

/// Opens the detail sheet for a discovered studio or pro profile,
/// then deselects the marker so it can be tapped again.
Future<void> openStudioOrProDetail(
  BuildContext ctx,
  DiscoveredStudio studio,
) async {
  if (studio.isPro) {
    final userId = studio.proUserId;
    if (userId == null) return;
    final user = await ProProfileService().getProUser(userId);
    if (user != null && ctx.mounted) {
      await ProDetailBottomSheet.show(ctx, user);
    }
  } else {
    await StudioDetailBottomSheet.show(ctx, studio);
  }
  if (ctx.mounted) {
    ctx.read<MapBloc>().add(const DeselectStudioEvent());
  }
}
