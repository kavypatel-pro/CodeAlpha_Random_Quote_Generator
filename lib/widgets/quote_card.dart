import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote_model.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final GlobalKey? boundaryKey;
  final bool isCompact;

  const QuoteCard({
    super.key,
    required this.quote,
    this.boundaryKey,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    // Design tokens based on compact status
    final cardPadding = isCompact ? 20.0 : 32.0;
    final quoteFontSize = isCompact ? 18.0 : 22.0;
    final authorFontSize = isCompact ? 13.0 : 15.0;
    
    final mutedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final cardBg = Theme.of(context).cardColor;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.3 : 0.05);

    Widget cardContent = Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Large decorative quote mark in the background
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              '“',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isCompact ? 60 : 90,
                color: primaryColor.withOpacity(0.08),
                height: 0.8,
              ),
            ),
          ),
          
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Quote Text in Serif
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  quote.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: quoteFontSize,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1C1C1E),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Thin Divider
              Divider(
                color: Theme.of(context).dividerColor,
                thickness: 1,
              ),
              const SizedBox(height: 12),
              
              // Author text (italic, muted, right aligned)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '— ${quote.author}',
                  style: GoogleFonts.inter(
                    fontSize: authorFontSize,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // If a boundary key is provided, wrap in a RepaintBoundary for PNG exports
    if (boundaryKey != null) {
      return RepaintBoundary(
        key: boundaryKey,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
