// lib/models/passport_spec.dart
class PassportSpec {
  final String country;
  final double widthMm;
  final double heightMm;
  final double targetWidthPx;
  final double targetHeightPx;

  PassportSpec(
    this.country,
    this.widthMm,
    this.heightMm,
    this.targetWidthPx,
    this.targetHeightPx,
  );

  static double mmToPx(double mm, double dpi) => (mm / 25.4) * dpi;
}

final List<PassportSpec> passportSpecs = [
  PassportSpec(
    'USA',
    51,
    51,
    PassportSpec.mmToPx(51, 300),
    PassportSpec.mmToPx(51, 300),
  ),
  PassportSpec(
    'UK/Schengen',
    35,
    45,
    PassportSpec.mmToPx(35, 300),
    PassportSpec.mmToPx(45, 300),
  ),
  PassportSpec(
    'Canada',
    50,
    70,
    PassportSpec.mmToPx(50, 300),
    PassportSpec.mmToPx(70, 300),
  ),
  PassportSpec(
    'India',
    51,
    51,
    PassportSpec.mmToPx(51, 300),
    PassportSpec.mmToPx(51, 300),
  ),
  PassportSpec(
    'Australia',
    35,
    45,
    PassportSpec.mmToPx(35, 300),
    PassportSpec.mmToPx(45, 300),
  ),
  PassportSpec(
    'China',
    33,
    48,
    PassportSpec.mmToPx(33, 300),
    PassportSpec.mmToPx(48, 300),
  ),
];
