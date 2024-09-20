import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:provider/provider.dart';

import '../../DataClass/Media.dart';
import '../../Theme/ThemeProvider.dart';
import '../../Widgets/Media/MediaReleaseingIndicator.dart';
import '../../Widgets/Media/MediaScoreBadge.dart';

class MediaPageLargeViewHolder extends StatelessWidget {
  final media mediaInfo;

  const MediaPageLargeViewHolder(this.mediaInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Card(
      color: theme.surfaceContainerLow,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: SizedBox(
          height: 190,
          child: Stack(
            children: [
              _buildBackgroundImage(context, theme),
              _buildContent(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context, ColorScheme theme) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final gradientColors = isDarkMode
        ? [Colors.transparent, theme.surfaceContainerLow]
        : [Colors.white.withOpacity(0.2), theme.surfaceContainerLow];

    return SizedBox(
      height: 152,
      child: Stack(
        children: [
          SizedBox(
            height: 151,
            width: double.infinity,
            child: KenBurns(
              maxScale: 5.0,
              minAnimationDuration: const Duration(milliseconds: 6000),
              maxAnimationDuration: const Duration(milliseconds: 20000),
              child: CachedNetworkImage(
                imageUrl: mediaInfo.banner ?? mediaInfo.cover ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 151,
              ),
            ),
          ),
          _buildGradientOverlay(gradientColors),
          _buildBlurEffect(),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay(List<Color> gradientColors) {
    return Container(
      width: double.infinity,
      height: 153,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildBlurEffect() {
    return Blur(
      colorOpacity: 0.0,
      blur: 2,
      blurColor: Colors.transparent,
      child: Container(),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaInfoRow(context, theme),
        ],
      ),
    );
  }

  Widget _buildMediaInfoRow(BuildContext context, ColorScheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            _buildMediaCover(),
            if (mediaInfo.status == 'RELEASING') ReleasingIndicator(),
            ScoreBadge(context, mediaInfo),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 92),
              Text(
                mediaInfo.userPreferredName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 6),
              _buildAdditionalInfo(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCover() {
    return  ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
          imageUrl: mediaInfo.cover ?? '',
          fit: BoxFit.cover,
          width: 108,
          height: 160,
          placeholder: (context, url) => Container(
            color: Colors.white12,
            width: 108,
            height: 160,
          ),
        ),
      );
  }

  Widget _buildAdditionalInfo(ColorScheme theme) {
    final isAnime = mediaInfo.anime != null;
    final mediaType = isAnime ? "Episodes" : "Chapters";
    final mediaCount = isAnime
        ? formatMediaInfo(mediaInfo)
        : "${mediaInfo.manga?.totalChapters ?? "??"}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 108,
          child: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            text: TextSpan(
              children: [
                TextSpan(
                  text: mediaCount,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: theme.onSurface,
                  ),
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text: mediaType,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: theme.onSurface.withOpacity(0.66),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            mediaInfo.genres.join(" • "),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              color: theme.onSurface.withOpacity(0.66),
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

String formatMediaInfo(media media) {
  final nextAiringEpisode = media.anime?.nextAiringEpisode;
  final totalEpisodes = media.anime?.totalEpisodes?.toString() ?? "??";

  return nextAiringEpisode != null && nextAiringEpisode != -1
      ? "$nextAiringEpisode / $totalEpisodes"
      : totalEpisodes;
}