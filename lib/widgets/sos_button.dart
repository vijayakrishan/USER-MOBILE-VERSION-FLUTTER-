import 'package:flutter/material.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String status;

  const SosButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.status = 'IDLE',
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    switch (widget.status.toUpperCase()) {
      case 'PENDING':
        return Colors.orangeAccent;
      case 'ACCEPTED':
        return Colors.blueAccent;
      case 'IN_PROGRESS':
        return Colors.cyanAccent;
      case 'COMPLETED':
        return Colors.greenAccent;
      default:
        return const Color(0xFFFF2E63);
    }
  }

  String _getButtonLabel() {
    if (widget.isLoading) return 'SENDING...';
    switch (widget.status.toUpperCase()) {
      case 'PENDING':
        return 'PENDING';
      case 'ACCEPTED':
        return 'ACCEPTED';
      case 'IN_PROGRESS':
        return 'RESCUING';
      case 'COMPLETED':
        return 'COMPLETED';
      default:
        return 'SOS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final bool isActionable = widget.status == 'IDLE' ||
        widget.status == 'COMPLETED' ||
        widget.status == 'CANCELLED';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isActionable ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.75),
                  ],
                  center: Alignment.topLeft,
                  radius: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(
                      alpha: isActionable ? 0.5 : 0.25,
                    ),
                    blurRadius: isActionable ? _glowAnimation.value : 12.0,
                    spreadRadius: isActionable ? 4.0 : 1.0,
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3.5,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isActionable
                                ? Icons.warning_rounded
                                : Icons.radio_button_checked,
                            color: Colors.white,
                            size: 38,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getButtonLabel(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          if (isActionable)
                            const Text(
                              'PRESS FOR HELP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
