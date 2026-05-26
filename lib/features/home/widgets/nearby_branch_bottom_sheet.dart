import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class NearbyBranchBottomSheet extends StatefulWidget {
  const NearbyBranchBottomSheet({super.key});

  @override
  State<NearbyBranchBottomSheet> createState() => _NearbyBranchBottomSheetState();
}

class _NearbyBranchBottomSheetState extends State<NearbyBranchBottomSheet> {
  bool _isLoadingLocation = true;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndBranches();
  }

  Future<void> _fetchLocationAndBranches() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _errorText = 'Location permissions are permanently denied. Please enable them in settings.';
        });
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _errorText = 'Location permission was denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      final splashProvider = Provider.of<SplashProvider>(context, listen: false);
      await splashProvider.getNearbyBranchesList(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _errorText = 'Failed to retrieve location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Select Delivery Branch',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a nearby branch for faster delivery',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoadingLocation)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Detecting your location...',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  )
                else if (_errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_rounded, size: 54, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _errorText, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoadingLocation = true;
                              _errorText = '';
                            });
                            _fetchLocationAndBranches();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Consumer<SplashProvider>(
                    builder: (context, splashProvider, child) {
                      if (splashProvider.isLoadingBranches) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Loading nearby branches...',
                                style: TextStyle(color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        );
                      }

                      final branches = splashProvider.nearbyBranches;
                      if (branches == null || branches.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.storefront_outlined, size: 54, color: Theme.of(context).hintColor),
                              const SizedBox(height: 16),
                              Text(
                                'No active branches found in your area.',
                                style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }

                      return Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: branches.length,
                          itemBuilder: (context, index) {
                            final branch = branches[index];
                            final isSelected = splashProvider.selectedBranchId == branch.id;
                            final isAvailable = branch.isAvailable ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor.withOpacity(0.08),
                                          Theme.of(context).primaryColor.withOpacity(0.02),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected 
                                    ? null 
                                    : Theme.of(context).cardColor.withOpacity(0.5),
                                border: Border.all(
                                  color: isSelected 
                                      ? Theme.of(context).primaryColor 
                                      : Theme.of(context).dividerColor.withOpacity(0.3),
                                  width: isSelected ? 1.8 : 1.2,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: InkWell(
                                onTap: isAvailable ? () {
                                  splashProvider.updateSelectedBranch(branch.id!, branch.name!);
                                  Navigator.pop(context);
                                } : null,
                                borderRadius: BorderRadius.circular(18),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left indicator dot or map pin
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor.withOpacity(0.12)
                                              : (isAvailable ? Colors.green.withOpacity(0.06) : Colors.red.withOpacity(0.06)),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.storefront_rounded,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : (isAvailable ? Colors.green : Colors.red),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Middle Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    branch.name ?? '',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: isAvailable
                                                          ? Theme.of(context).textTheme.bodyLarge?.color
                                                          : Theme.of(context).disabledColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isAvailable
                                                        ? Colors.green.withOpacity(0.1)
                                                        : Colors.red.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    isAvailable ? 'Available' : 'Outside Range',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: isAvailable ? Colors.green : Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).hintColor),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    branch.address ?? '',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isAvailable
                                                          ? Theme.of(context).hintColor
                                                          : Theme.of(context).disabledColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Right info (Distance / Time / Checkmark)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${branch.distanceKm?.toStringAsFixed(1) ?? '0.0'} km',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: isAvailable
                                                      ? Theme.of(context).textTheme.bodyLarge?.color
                                                      : Theme.of(context).disabledColor,
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 6),
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 16,
                                                ),
                                              ]
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time, size: 12, color: Theme.of(context).hintColor),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${branch.estimatedDeliveryTime ?? 30}m',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context).hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
