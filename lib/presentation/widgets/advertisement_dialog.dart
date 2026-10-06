import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showRandomAdvertisement(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AdvertisementDialog(),
  );
}

class _Advertisement {
  const _Advertisement({
    required this.mobileAsset,
    required this.desktopAsset,
    required this.url,
  });

  final String mobileAsset;
  final String desktopAsset;
  final String url;
}

const _advertisements = [
  _Advertisement(
    mobileAsset: 'assets/advertisements/tiktok/mobile.jpg',
    desktopAsset: 'assets/advertisements/tiktok/desktop.jpg',
    url: 'https://www.tiktok.com/download',
  ),
  _Advertisement(
    mobileAsset: 'assets/advertisements/pinterest/mobile.png',
    desktopAsset: 'assets/advertisements/pinterest/desktop.png',
    url: 'https://www.pinterest.com/download/',
  ),
];

final _advertisementRandom = math.Random();

class _AdvertisementDialog extends StatefulWidget {
  const _AdvertisementDialog();

  @override
  State<_AdvertisementDialog> createState() => _AdvertisementDialogState();
}

class _AdvertisementDialogState extends State<_AdvertisementDialog> {
  late final _Advertisement _advertisement;
  Timer? _closeTimer;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _advertisement = _advertisements[_advertisementRandom.nextInt(
      _advertisements.length,
    )];
    _closeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _canClose = true);
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  Future<void> _openAdvertisedApp() async {
    try {
      final opened = await launchUrl(
        Uri.parse(_advertisement.url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isMobileLayout = screenSize.shortestSide < 600;
    final asset = isMobileLayout
        ? _advertisement.mobileAsset
        : _advertisement.desktopAsset;
    final width = math
        .min(screenSize.width * 0.92, isMobileLayout ? 480.0 : 1100.0)
        .toDouble();
    final height = math.min(screenSize.height * 0.84, 820.0).toDouble();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.black,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openAdvertisedApp,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'No se pudo cargar la publicidad.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (_canClose)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    tooltip: 'Cerrar publicidad',
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
