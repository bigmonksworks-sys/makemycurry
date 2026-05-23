import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class LoyaltyBadgeWidget extends StatelessWidget {
  const LoyaltyBadgeWidget({super.key});

  // Badge color palette
  static const Map<String, List<Color>> _badgeGradients = {
    'Bronze': [Color(0xFFCD7F32), Color(0xFF8B4513)],
    'Silver': [Color(0xFFBEC7D1), Color(0xFF6C7A89)],
    'Gold':   [Color(0xFFFFD700), Color(0xFFB8860B)],
    'Platinum': [Color(0xFF00CED1), Color(0xFF1E3A5F)],
  };

  static const Map<String, Color> _badgeShadow = {
    'Bronze': Color(0x66CD7F32),
    'Silver': Color(0x66BEC7D1),
    'Gold':   Color(0x99FFD700),
    'Platinum': Color(0x6600CED1),
  };

  static const Map<String, IconData> _badgeIcons = {
    'Bronze':   Icons.workspace_premium_outlined,
    'Silver':   Icons.military_tech_outlined,
    'Gold':     Icons.emoji_events,
    'Platinum': Icons.diamond,
  };

  static const List<String> _tiers = ['Bronze', 'Silver', 'Gold', 'Platinum'];

  String _nextTier(String current) {
    final idx = _tiers.indexOf(current);
    if (idx < 0 || idx >= _tiers.length - 1) return 'Platinum';
    return _tiers[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final user = profileProvider.userInfoModel;
        if (user == null) return const SizedBox.shrink();

        final badge = user.loyaltyBadge ?? 'Bronze';
        final completed = user.completedOrdersCount ?? 0;
        final thresholds = user.badgeThresholds ?? {};
        final silverThreshold = thresholds['silver'] ?? 5;
        final goldThreshold = thresholds['gold'] ?? 15;
        final platinumThreshold = thresholds['platinum'] ?? 30;

        // Calculate progress to next tier
        int currentMin = 0;
        int nextMin = 0;
        final nextTier = _nextTier(badge);
        switch (badge) {
          case 'Bronze':
            currentMin = 0;
            nextMin = silverThreshold;
            break;
          case 'Silver':
            currentMin = silverThreshold;
            nextMin = goldThreshold;
            break;
          case 'Gold':
            currentMin = goldThreshold;
            nextMin = platinumThreshold;
            break;
          case 'Platinum':
            currentMin = platinumThreshold;
            nextMin = platinumThreshold; // max
            break;
        }

        final bool isMaxTier = badge == 'Platinum';
        final double progress = isMaxTier
            ? 1.0
            : (nextMin == currentMin)
                ? 1.0
                : ((completed - currentMin) / (nextMin - currentMin)).clamp(0.0, 1.0);

        final List<Color> gradColors = _badgeGradients[badge] ??
            [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
        final Color shadowColor =
            _badgeShadow[badge] ?? const Color(0x66CD7F32);
        final IconData icon =
            _badgeIcons[badge] ?? Icons.workspace_premium_outlined;

        final List<Color> progressColors = _badgeGradients[nextTier] ??
            _badgeGradients['Gold']!;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradColors[0].withValues(alpha: 0.15),
                  gradColors[1].withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gradColors[0].withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: badge icon + badge name + orders count
                Row(
                  children: [
                    // Glowing badge icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Badge name + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: gradColors,
                            ).createShader(bounds),
                            child: Text(
                              '$badge Member',
                              style: poppinsBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Loyalty Rewards',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .hintColor
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Completed orders counter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradColors,
                          ).createShader(bounds),
                          child: Text(
                            '$completed',
                            style: poppinsBold.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'orders',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Progress bar section
                if (!isMaxTier) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        badge,
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: gradColors[0],
                        ),
                      ),
                      Text(
                        nextTier,
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: progressColors[0],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Background track
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Filled progress
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [...gradColors, ...progressColors],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: progressColors[0]
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completed >= nextMin
                        ? 'You\'ve reached $nextTier! 🎉'
                        : '${nextMin - completed} more order${(nextMin - completed) == 1 ? '' : 's'} to reach $nextTier',
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.7),
                    ),
                  ),
                ] else ...[
                  // Platinum - max tier celebration
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'You\'ve reached the highest tier! 🏆',
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Tier progression dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _tiers.map((tier) {
                    final bool isCurrentOrPast =
                        _tiers.indexOf(tier) <= _tiers.indexOf(badge);
                    final List<Color> tierColors =
                        _badgeGradients[tier] ?? gradColors;
                    return Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: isCurrentOrPast
                                ? LinearGradient(
                                    colors: tierColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isCurrentOrPast
                                ? null
                                : Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            boxShadow: isCurrentOrPast
                                ? [
                                    BoxShadow(
                                      color: tierColors[0]
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                            border: tier == badge
                                ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Icon(
                            _badgeIcons[tier] ??
                                Icons.workspace_premium_outlined,
                            color: isCurrentOrPast
                                ? Colors.white
                                : Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.4),
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tier,
                          style: poppinsRegular.copyWith(
                            fontSize: 9,
                            color: isCurrentOrPast
                                ? tierColors[0]
                                : Theme.of(context)
                                    .hintColor
                                    .withValues(alpha: 0.5),
                            fontWeight: tier == badge
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
