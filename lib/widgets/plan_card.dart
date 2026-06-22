import 'package:flutter/material.dart';

class PlanCard extends StatefulWidget {
  final String title;
  final String price;
  final IconData icon;
  final Color accentColor;
  final List<String> features;
  final List<bool> hasFeatures;
  final String buttonText;
  final bool isCurrent;
  final bool isHighlighted;
  final VoidCallback onPressed;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    required this.accentColor,
    required this.features,
    required this.hasFeatures,
    required this.buttonText,
    required this.onPressed,
    this.isCurrent = false,
    this.isHighlighted = false,
  });

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isCurrent ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: widget.isHighlighted
                ? Border.all(color: widget.accentColor, width: 2.5)
                : Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Highlight Badge
              if (widget.isHighlighted)
                Container(
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    '★ BEST VALUE ★',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(widget.icon, color: widget.accentColor, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                            ),
                          ],
                        ),
                        if (widget.isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Current Plan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Price
                    Text(
                      widget.price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: widget.accentColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Theme.of(context).dividerColor),
                    const SizedBox(height: 12),
                    
                    // Features list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.features.length,
                      itemBuilder: (context, idx) {
                        final hasIt = widget.hasFeatures[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                hasIt ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: hasIt
                                    ? (isDark ? Colors.green.shade400 : Colors.green.shade600)
                                    : (isDark ? Colors.red.shade400 : Colors.red.shade600),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.features[idx],
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: hasIt
                                            ? (isDark ? Colors.white : Colors.black87)
                                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: widget.isCurrent
                          ? OutlinedButton(
                              onPressed: null, // Disabled if current plan
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                                side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                              ),
                              child: const Text('Current Plan'),
                            )
                          : widget.isHighlighted
                              ? ElevatedButton(
                                  onPressed: widget.onPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.accentColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(widget.buttonText),
                                )
                              : OutlinedButton(
                                  onPressed: widget.onPressed,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: widget.accentColor,
                                    side: BorderSide(color: widget.accentColor, width: 1.5),
                                  ),
                                  child: Text(widget.buttonText),
                                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
