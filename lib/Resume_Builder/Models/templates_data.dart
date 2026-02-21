import 'package:flutter/material.dart';

class ResumeTemplate {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double headingSize;
  final double bodySize;
  final LayoutStyle layoutStyle;
  final bool showProfileImage;
  final bool showSidebar;
  final BorderStyle borderStyle;
  final String previewImage;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.headingSize,
    required this.bodySize,
    required this.layoutStyle,
    required this.showProfileImage,
    required this.showSidebar,
    required this.borderStyle,
    required this.previewImage,
  });
}

enum LayoutStyle {
  modern,      // Left sidebar with main content
  executive,   // Top header with two columns
  creative,    // Asymmetric design
  minimal,     // Clean, lots of white space
  professional, // Traditional format
  compact,     // Dense, information-rich
}

enum BorderStyle {
  none,
  line,
  shadow,
  rounded,
}

class TemplatesData {
  static List<ResumeTemplate> getTemplates() {
    return [
      // Template 1: Modern Professional
      const ResumeTemplate(
        id: 'modern_pro',
        name: 'Modern Professional',
        primaryColor: Color(0xFF1E3A5F),
        secondaryColor: Color(0xFFE9ECF5),
        accentColor: Color(0xFF4A90E2),
        backgroundColor: Colors.white,
        textColor: Color(0xFF2C3E50),
        fontFamily: 'Poppins',
        headingSize: 18,
        bodySize: 12,
        layoutStyle: LayoutStyle.modern,
        showProfileImage: true,
        showSidebar: true,
        borderStyle: BorderStyle.line,
        previewImage: 'assets/templates/modern_pro.png',
      ),

      // Template 2: Executive
      const ResumeTemplate(
        id: 'executive',
        name: 'Executive',
        primaryColor: Color(0xFF2C3E50),
        secondaryColor: Color(0xFFBDC3C7),
        accentColor: Color(0xFFE67E22),
        backgroundColor: Colors.white,
        textColor: Color(0xFF34495E),
        fontFamily: 'Montserrat',
        headingSize: 20,
        bodySize: 13,
        layoutStyle: LayoutStyle.executive,
        showProfileImage: true,
        showSidebar: false,
        borderStyle: BorderStyle.shadow,
        previewImage: 'assets/templates/executive.png',
      ),

      // Template 3: Creative
      const ResumeTemplate(
        id: 'creative',
        name: 'Creative',
        primaryColor: Color(0xFF8E44AD),
        secondaryColor: Color(0xFFF39C12),
        accentColor: Color(0xFF27AE60),
        backgroundColor: Colors.white,
        textColor: Color(0xFF2C3E50),
        fontFamily: 'Roboto',
        headingSize: 22,
        bodySize: 12,
        layoutStyle: LayoutStyle.creative,
        showProfileImage: true,
        showSidebar: true,
        borderStyle: BorderStyle.rounded,
        previewImage: 'assets/templates/creative.png',
      ),

      // Template 4: Minimal
      const ResumeTemplate(
        id: 'minimal',
        name: 'Minimal',
        primaryColor: Color(0xFF7F8C8D),
        secondaryColor: Color(0xFFECF0F1),
        accentColor: Color(0xFF3498DB),
        backgroundColor: Colors.white,
        textColor: Color(0xFF2C3E50),
        fontFamily: 'Lato',
        headingSize: 16,
        bodySize: 12,
        layoutStyle: LayoutStyle.minimal,
        showProfileImage: false,
        showSidebar: false,
        borderStyle: BorderStyle.none,
        previewImage: 'assets/templates/minimal.png',
      ),

      // Template 5: Professional
      const ResumeTemplate(
        id: 'professional',
        name: 'Professional',
        primaryColor: Color(0xFF16A085),
        secondaryColor: Color(0xFFD5DBDB),
        accentColor: Color(0xFF2980B9),
        backgroundColor: Colors.white,
        textColor: Color(0xFF1F2D3D),
        fontFamily: 'OpenSans',
        headingSize: 18,
        bodySize: 12,
        layoutStyle: LayoutStyle.professional,
        showProfileImage: true,
        showSidebar: true,
        borderStyle: BorderStyle.line,
        previewImage: 'assets/templates/professional.png',
      ),

      // Template 6: Compact
      const ResumeTemplate(
        id: 'compact',
        name: 'Compact',
        primaryColor: Color(0xFFC0392B),
        secondaryColor: Color(0xFFF2F3F4),
        accentColor: Color(0xFF2874A6),
        backgroundColor: Colors.white,
        textColor: Color(0xFF1B2631),
        fontFamily: 'RobotoCondensed',
        headingSize: 16,
        bodySize: 11,
        layoutStyle: LayoutStyle.compact,
        showProfileImage: false,
        showSidebar: false,
        borderStyle: BorderStyle.line,
        previewImage: 'assets/templates/compact.png',
      ),
    ];
  }
}