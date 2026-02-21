import 'package:flutter/material.dart';
import 'colors.dart';

/// Custom painter for Home icon in bottom navigation
class HomeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit 32x32 viewBox to canvas size
    final scaleX = size.width / 32;
    final scaleY = size.height / 32;

    // Path 1: Door opening
    final doorPath = Path();
    doorPath.moveTo(21 * scaleX, 31 * scaleY);
    doorPath.lineTo(21 * scaleX, 18.3687 * scaleY);
    doorPath.cubicTo(
      21 * scaleX,
      17.95 * scaleY,
      20.8244 * scaleX,
      17.5484 * scaleY,
      20.5118 * scaleX,
      17.2523 * scaleY,
    );
    doorPath.cubicTo(
      20.1993 * scaleX,
      16.9562 * scaleY,
      19.7754 * scaleX,
      16.7898 * scaleY,
      19.3333 * scaleX,
      16.7898 * scaleY,
    );
    doorPath.lineTo(12.6667 * scaleX, 16.7898 * scaleY);
    doorPath.cubicTo(
      12.2246 * scaleX,
      16.7898 * scaleY,
      11.8007 * scaleX,
      16.9562 * scaleY,
      11.4882 * scaleX,
      17.2523 * scaleY,
    );
    doorPath.cubicTo(
      11.1756 * scaleX,
      17.5484 * scaleY,
      11 * scaleX,
      17.95 * scaleY,
      11 * scaleX,
      18.3687 * scaleY,
    );
    doorPath.lineTo(11 * scaleX, 31 * scaleY);
    canvas.drawPath(doorPath, paint);

    // Path 2: Main house structure (roof + walls)
    final housePath = Path();
    housePath.moveTo(1 * scaleX, 13.632 * scaleY);
    housePath.cubicTo(
      0.999884 * scaleX,
      13.1727 * scaleY,
      1.10556 * scaleX,
      12.7188 * scaleY,
      1.30965 * scaleX,
      12.3021 * scaleY,
    );
    housePath.cubicTo(
      1.51374 * scaleX,
      11.8854 * scaleY,
      1.81133 * scaleX,
      11.516 * scaleY,
      2.18167 * scaleX,
      11.2194 * scaleY,
    );
    housePath.lineTo(13.8483 * scaleX, 1.746 * scaleY);
    housePath.cubicTo(
      14.45 * scaleX,
      1.26429 * scaleY,
      15.2123 * scaleX,
      1 * scaleY,
      16 * scaleX,
      1 * scaleY,
    );
    housePath.cubicTo(
      16.7877 * scaleX,
      1 * scaleY,
      17.55 * scaleX,
      1.26429 * scaleY,
      18.1517 * scaleX,
      1.746 * scaleY,
    );
    housePath.lineTo(29.8183 * scaleX, 11.2194 * scaleY);
    housePath.cubicTo(
      30.1887 * scaleX,
      11.516 * scaleY,
      30.4863 * scaleX,
      11.8854 * scaleY,
      30.6904 * scaleX,
      12.3021 * scaleY,
    );
    housePath.cubicTo(
      30.8944 * scaleX,
      12.7188 * scaleY,
      31.0001 * scaleX,
      13.1727 * scaleY,
      31 * scaleX,
      13.632 * scaleY,
    );
    housePath.lineTo(31 * scaleX, 27.8422 * scaleY);
    housePath.cubicTo(
      31 * scaleX,
      28.6797 * scaleY,
      30.6488 * scaleX,
      29.4829 * scaleY,
      30.0237 * scaleX,
      30.0751 * scaleY,
    );
    housePath.cubicTo(
      29.3986 * scaleX,
      30.6673 * scaleY,
      28.5507 * scaleX,
      31 * scaleY,
      27.6667 * scaleX,
      31 * scaleY,
    );
    housePath.lineTo(4.33333 * scaleX, 31 * scaleY);
    housePath.cubicTo(
      3.44928 * scaleX,
      31 * scaleY,
      2.60143 * scaleX,
      30.6673 * scaleY,
      1.97631 * scaleX,
      30.0751 * scaleY,
    );
    housePath.cubicTo(
      1.35119 * scaleX,
      29.4829 * scaleY,
      1 * scaleX,
      28.6797 * scaleY,
      1 * scaleX,
      27.8422 * scaleY,
    );
    housePath.lineTo(1 * scaleX, 13.632 * scaleY);
    housePath.close();
    canvas.drawPath(housePath, paint);
  }

  @override
  bool shouldRepaint(HomeIconPainter oldDelegate) => false;
}

/// Custom painter for Activity icon (Rounded Square with Checkmark)
class ActivityIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit SVG viewBox (0-32, 0-32) to canvas size
    final scaleX = size.width / 32;
    final scaleY = size.height / 32;

    // Path 1: Rounded square outline
    final roundedSquarePath = Path();
    roundedSquarePath.moveTo(3.19667 * scaleX, 28.8033 * scaleY);
    roundedSquarePath.cubicTo(
      1 * scaleX,
      26.6067 * scaleY,
      1 * scaleX,
      23.07 * scaleY,
      1 * scaleX,
      16 * scaleY,
    );
    roundedSquarePath.cubicTo(
      1 * scaleX,
      8.93 * scaleY,
      1 * scaleX,
      5.39333 * scaleY,
      3.19667 * scaleX,
      3.19667 * scaleY,
    );
    roundedSquarePath.cubicTo(
      5.39333 * scaleX,
      1 * scaleY,
      8.93 * scaleX,
      1 * scaleY,
      16 * scaleX,
      1 * scaleY,
    );
    roundedSquarePath.cubicTo(
      23.07 * scaleX,
      1 * scaleY,
      26.6067 * scaleX,
      1 * scaleY,
      28.8033 * scaleX,
      3.19667 * scaleY,
    );
    roundedSquarePath.cubicTo(
      31 * scaleX,
      5.39333 * scaleY,
      31 * scaleX,
      8.93 * scaleY,
      31 * scaleX,
      16 * scaleY,
    );
    roundedSquarePath.cubicTo(
      31 * scaleX,
      23.07 * scaleY,
      31 * scaleX,
      26.6067 * scaleY,
      28.8033 * scaleX,
      28.8033 * scaleY,
    );
    roundedSquarePath.cubicTo(
      26.6067 * scaleX,
      31 * scaleY,
      23.07 * scaleX,
      31 * scaleY,
      16 * scaleX,
      31 * scaleY,
    );
    roundedSquarePath.cubicTo(
      8.93 * scaleX,
      31 * scaleY,
      5.39333 * scaleX,
      31 * scaleY,
      3.19667 * scaleX,
      28.8033 * scaleY,
    );
    roundedSquarePath.close();
    canvas.drawPath(roundedSquarePath, paint);

    // Path 2: Checkmark pattern
    final checkmarkPath = Path();
    checkmarkPath.moveTo(7.66626 * scaleX, 19.3333 * scaleY);
    checkmarkPath.lineTo(12.3213 * scaleX, 14.6783 * scaleY);
    checkmarkPath.cubicTo(
      12.6338 * scaleX,
      14.3658 * scaleY,
      13.0577 * scaleX,
      14.1903 * scaleY,
      13.4996 * scaleX,
      14.1903 * scaleY,
    );
    checkmarkPath.cubicTo(
      13.9415 * scaleX,
      14.1903 * scaleY,
      14.3654 * scaleX,
      14.3658 * scaleY,
      14.6779 * scaleX,
      14.6783 * scaleY,
    );
    checkmarkPath.lineTo(17.3213 * scaleX, 17.3216 * scaleY);
    checkmarkPath.cubicTo(
      17.6338 * scaleX,
      17.6341 * scaleY,
      18.0577 * scaleX,
      17.8096 * scaleY,
      18.4996 * scaleX,
      17.8096 * scaleY,
    );
    checkmarkPath.cubicTo(
      18.9415 * scaleX,
      17.8096 * scaleY,
      19.3654 * scaleX,
      17.6341 * scaleY,
      19.6779 * scaleX,
      17.3216 * scaleY,
    );
    checkmarkPath.lineTo(24.3329 * scaleX, 12.6666 * scaleY);
    canvas.drawPath(checkmarkPath, paint);
  }

  @override
  bool shouldRepaint(ActivityIconPainter oldDelegate) => false;
}

/// Custom painter for Wallet icon in bottom navigation
class WalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit SVG viewBox (0-35, 0-33) to canvas size
    final scaleX = size.width / 35;
    final scaleY = size.height / 33;

    // First path - envelope flap and card slot
    final path1 = Path();
    path1.moveTo(28.7895 * scaleX, 7.88889 * scaleY);
    path1.lineTo(28.7895 * scaleX, 2.72222 * scaleY);

    // Top left curve of flap
    path1.cubicTo(
      28.7895 * scaleX,
      2.26546 * scaleY,
      28.6065 * scaleX,
      1.82741 * scaleY,
      28.2808 * scaleX,
      1.50443 * scaleY,
    );
    path1.cubicTo(
      27.955 * scaleX,
      1.18145 * scaleY,
      27.5133 * scaleX,
      1 * scaleY,
      27.0526 * scaleX,
      1 * scaleY,
    );

    path1.lineTo(4.47368 * scaleX, 1 * scaleY);
    path1.cubicTo(
      3.55241 * scaleX,
      1 * scaleY,
      2.66886 * scaleX,
      1.3629 * scaleY,
      2.01742 * scaleX,
      2.00885 * scaleY,
    );
    path1.cubicTo(
      1.36598 * scaleX,
      2.65481 * scaleY,
      1 * scaleX,
      3.53092 * scaleY,
      1 * scaleX,
      4.44445 * scaleY,
    );
    path1.cubicTo(
      1 * scaleX,
      5.35797 * scaleY,
      1.36598 * scaleX,
      6.23408 * scaleY,
      2.01742 * scaleX,
      6.88004 * scaleY,
    );
    path1.cubicTo(
      2.66886 * scaleX,
      7.526 * scaleY,
      3.55241 * scaleX,
      7.88889 * scaleY,
      4.47368 * scaleX,
      7.88889 * scaleY,
    );

    path1.lineTo(30.5263 * scaleX, 7.88889 * scaleY);
    path1.cubicTo(
      30.987 * scaleX,
      7.88889 * scaleY,
      31.4287 * scaleX,
      8.07034 * scaleY,
      31.7545 * scaleX,
      8.39332 * scaleY,
    );
    path1.cubicTo(
      32.0802 * scaleX,
      8.7163 * scaleY,
      32.2632 * scaleX,
      9.15435 * scaleY,
      32.2632 * scaleX,
      9.61111 * scaleY,
    );

    path1.lineTo(32.2632 * scaleX, 16.5 * scaleY);

    // Card slot part
    path1.moveTo(32.2632 * scaleX, 16.5 * scaleY);
    path1.lineTo(27.0526 * scaleX, 16.5 * scaleY);
    path1.cubicTo(
      26.1314 * scaleX,
      16.5 * scaleY,
      25.2478 * scaleX,
      16.8629 * scaleY,
      24.5964 * scaleX,
      17.5089 * scaleY,
    );
    path1.cubicTo(
      23.9449 * scaleX,
      18.1548 * scaleY,
      23.5789 * scaleX,
      19.0309 * scaleY,
      23.5789 * scaleX,
      19.9445 * scaleY,
    );
    path1.cubicTo(
      23.5789 * scaleX,
      20.858 * scaleY,
      23.9449 * scaleX,
      21.7341 * scaleY,
      24.5964 * scaleX,
      22.38 * scaleY,
    );
    path1.cubicTo(
      25.2478 * scaleX,
      23.026 * scaleY,
      26.1314 * scaleX,
      23.3889 * scaleY,
      27.0526 * scaleX,
      23.3889 * scaleY,
    );

    path1.lineTo(32.2632 * scaleX, 23.3889 * scaleY);
    path1.cubicTo(
      32.7238 * scaleX,
      23.3889 * scaleY,
      33.1656 * scaleX,
      23.2074 * scaleY,
      33.4913 * scaleX,
      22.8845 * scaleY,
    );
    path1.cubicTo(
      33.817 * scaleX,
      22.5615 * scaleY,
      34 * scaleX,
      22.1234 * scaleY,
      34 * scaleX,
      21.6667 * scaleY,
    );

    path1.lineTo(34 * scaleX, 18.2222 * scaleY);
    path1.cubicTo(
      34 * scaleX,
      17.7655 * scaleY,
      33.817 * scaleX,
      17.3274 * scaleY,
      33.4913 * scaleX,
      17.0044 * scaleY,
    );
    path1.cubicTo(
      33.1656 * scaleX,
      16.6815 * scaleY,
      32.7238 * scaleX,
      16.5 * scaleY,
      32.2632 * scaleX,
      16.5 * scaleY,
    );

    canvas.drawPath(path1, paint);

    // Second path - main wallet body
    final path2 = Path();
    path2.moveTo(1 * scaleX, 4.44446 * scaleY);
    path2.lineTo(1 * scaleX, 28.5556 * scaleY);
    path2.cubicTo(
      1 * scaleX,
      29.4691 * scaleY,
      1.36598 * scaleX,
      30.3452 * scaleY,
      2.01742 * scaleX,
      30.9912 * scaleY,
    );
    path2.cubicTo(
      2.66886 * scaleX,
      31.6371 * scaleY,
      3.55241 * scaleX,
      32 * scaleY,
      4.47368 * scaleX,
      32 * scaleY,
    );

    path2.lineTo(30.5263 * scaleX, 32 * scaleY);
    path2.cubicTo(
      30.987 * scaleX,
      32 * scaleY,
      31.4287 * scaleX,
      31.8186 * scaleY,
      31.7544 * scaleX,
      31.4956 * scaleY,
    );
    path2.cubicTo(
      32.0802 * scaleX,
      31.1726 * scaleY,
      32.2632 * scaleX,
      30.7346 * scaleY,
      32.2632 * scaleX,
      30.2778 * scaleY,
    );

    path2.lineTo(32.2632 * scaleX, 23.3889 * scaleY);

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(WalletIconPainter oldDelegate) => false;
}

/// Custom painter for Notification icon in bottom navigation
class NotificationIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit SVG viewBox (0-35, 0-33) to canvas size
    final scaleX = size.width / 35;
    final scaleY = size.height / 33;

    final path = Path();

    // Bell notification icon path
    path.moveTo(23.1393 * scaleX, 26.4737 * scaleY);
    path.cubicTo(
      23.1393 * scaleX,
      27.1994 * scaleY,
      22.9934 * scaleX,
      27.918 * scaleY,
      22.71 * scaleX,
      28.5885 * scaleY,
    );
    path.cubicTo(
      22.4266 * scaleX,
      29.259 * scaleY,
      22.0112 * scaleX,
      29.8682 * scaleY,
      21.4875 * scaleX,
      30.3814 * scaleY,
    );
    path.cubicTo(
      20.9638 * scaleX,
      30.8945 * scaleY,
      20.342 * scaleX,
      31.3016 * scaleY,
      19.6578 * scaleX,
      31.5793 * scaleY,
    );
    path.cubicTo(
      18.9735 * scaleX,
      31.8571 * scaleY,
      18.2402 * scaleX,
      32 * scaleY,
      17.4995 * scaleX,
      32 * scaleY,
    );
    path.cubicTo(
      16.7589 * scaleX,
      32 * scaleY,
      16.0255 * scaleX,
      31.8571 * scaleY,
      15.3413 * scaleX,
      31.5793 * scaleY,
    );
    path.cubicTo(
      14.657 * scaleX,
      31.3016 * scaleY,
      14.0353 * scaleX,
      30.8945 * scaleY,
      13.5116 * scaleX,
      30.3814 * scaleY,
    );
    path.cubicTo(
      12.9879 * scaleX,
      29.8682 * scaleY,
      12.5725 * scaleX,
      29.259 * scaleY,
      12.289 * scaleX,
      28.5885 * scaleY,
    );
    path.cubicTo(
      12.0056 * scaleX,
      27.918 * scaleY,
      11.8597 * scaleX,
      27.1994 * scaleY,
      11.8597 * scaleX,
      26.4737 * scaleY,
    );

    // Move to main bell shape
    path.moveTo(29.1513 * scaleX, 26.4737 * scaleY);
    path.lineTo(5.84932 * scaleX, 26.4737 * scaleY);
    path.cubicTo(
      5.28562 * scaleX,
      26.4735 * scaleY,
      4.73464 * scaleX,
      26.3095 * scaleY,
      4.26605 * scaleX,
      26.0024 * scaleY,
    );
    path.cubicTo(
      3.79745 * scaleX,
      25.6954 * scaleY,
      3.43228 * scaleX,
      25.2591 * scaleY,
      3.2167 * scaleX,
      24.7487 * scaleY,
    );
    path.cubicTo(
      3.00112 * scaleX,
      24.2384 * scaleY,
      2.9448 * scaleX,
      23.6768 * scaleY,
      3.05487 * scaleX,
      23.1351 * scaleY,
    );
    path.cubicTo(
      3.16495 * scaleX,
      22.5934 * scaleY,
      3.43647 * scaleX,
      22.0958 * scaleY,
      3.8351 * scaleX,
      21.7053 * scaleY,
    );

    path.lineTo(4.80515 * scaleX, 20.7532 * scaleY);
    path.cubicTo(
      5.71119 * scaleX,
      19.8648 * scaleY,
      6.22009 * scaleX,
      18.6602 * scaleY,
      6.21993 * scaleX,
      17.4042 * scaleY,
    );

    path.lineTo(6.21993 * scaleX, 13.0526 * scaleY);
    path.cubicTo(
      6.21993 * scaleX,
      10.1213 * scaleY,
      7.40831 * scaleX,
      7.31001 * scaleY,
      9.52365 * scaleX,
      5.23724 * scaleY,
    );
    path.cubicTo(
      11.639 * scaleX,
      3.16447 * scaleY,
      14.508 * scaleX,
      2 * scaleY,
      17.4995 * scaleX,
      2 * scaleY,
    );
    path.cubicTo(
      20.4911 * scaleX,
      2 * scaleY,
      23.3601 * scaleX,
      3.16447 * scaleY,
      25.4754 * scaleX,
      5.23724 * scaleY,
    );
    path.cubicTo(
      27.5907 * scaleX,
      7.31001 * scaleY,
      28.7791 * scaleX,
      10.1213 * scaleY,
      28.7791 * scaleX,
      13.0526 * scaleY,
    );

    path.lineTo(28.7791 * scaleX, 17.4042 * scaleY);
    path.cubicTo(
      28.7794 * scaleX,
      18.6604 * scaleY,
      29.2889 * scaleX,
      19.865 * scaleY,
      30.1955 * scaleX,
      20.7532 * scaleY,
    );

    path.lineTo(31.1672 * scaleX, 21.7053 * scaleY);
    path.cubicTo(
      31.565 * scaleX,
      22.0961 * scaleY,
      31.8358 * scaleX,
      22.5936 * scaleY,
      31.9455 * scaleX,
      23.1351 * scaleY,
    );
    path.cubicTo(
      32.0551 * scaleX,
      23.6766 * scaleY,
      31.9986 * scaleX,
      24.2377 * scaleY,
      31.7832 * scaleX,
      24.7478 * scaleY,
    );
    path.cubicTo(
      31.5677 * scaleX,
      25.2578 * scaleY,
      31.2029 * scaleX,
      25.6939 * scaleY,
      30.7349 * scaleX,
      26.0011 * scaleY,
    );
    path.cubicTo(
      30.2668 * scaleX,
      26.3083 * scaleY,
      29.7147 * scaleX,
      26.4727 * scaleY,
      29.1513 * scaleX,
      26.4737 * scaleY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NotificationIconPainter oldDelegate) => false;
}

/// Custom painter for Profile icon in bottom navigation
class ProfileIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit SVG viewBox (0-33, 0-33) to canvas size
    final scaleX = size.width / 33;
    final scaleY = size.height / 33;

    // Path 1: Body/torso (rounded rectangle at bottom)
    final bodyPath = Path();
    bodyPath.moveTo(1 * scaleX, 27.6667 * scaleY);
    bodyPath.cubicTo(
      1 * scaleX,
      25.3681 * scaleY,
      1.81652 * scaleX,
      23.1637 * scaleY,
      3.26992 * scaleX,
      21.5384 * scaleY,
    );
    bodyPath.cubicTo(
      4.72333 * scaleX,
      19.9131 * scaleY,
      6.69457 * scaleX,
      19 * scaleY,
      8.75 * scaleX,
      19 * scaleY,
    );
    bodyPath.lineTo(24.25 * scaleX, 19 * scaleY);
    bodyPath.cubicTo(
      26.3054 * scaleX,
      19 * scaleY,
      28.2767 * scaleX,
      19.9131 * scaleY,
      29.7301 * scaleX,
      21.5384 * scaleY,
    );
    bodyPath.cubicTo(
      31.1835 * scaleX,
      23.1637 * scaleY,
      32 * scaleX,
      25.3681 * scaleY,
      32 * scaleX,
      27.6667 * scaleY,
    );
    bodyPath.cubicTo(
      32 * scaleX,
      28.8159 * scaleY,
      31.5917 * scaleX,
      29.9181 * scaleY,
      30.865 * scaleX,
      30.7308 * scaleY,
    );
    bodyPath.cubicTo(
      30.1383 * scaleX,
      31.5435 * scaleY,
      29.1527 * scaleX,
      32 * scaleY,
      28.125 * scaleX,
      32 * scaleY,
    );
    bodyPath.lineTo(4.875 * scaleX, 32 * scaleY);
    bodyPath.cubicTo(
      3.84729 * scaleX,
      32 * scaleY,
      2.86166 * scaleX,
      31.5435 * scaleY,
      2.13496 * scaleX,
      30.7308 * scaleY,
    );
    bodyPath.cubicTo(
      1.40826 * scaleX,
      29.9181 * scaleY,
      1 * scaleX,
      28.8159 * scaleY,
      1 * scaleX,
      27.6667 * scaleY,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Path 2: Head (circle at top)
    final headPath = Path();
    headPath.addOval(
      Rect.fromCenter(
        center: Offset(16.5 * scaleX, 7.5 * scaleY),
        width: 13 * scaleX,
        height: 13 * scaleY,
      ),
    );
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(ProfileIconPainter oldDelegate) => false;
}

/// Custom painter for Bookings icon in bottom navigation
class BookingsIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale factors to fit 24x24 viewBox to canvas size
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;

    // Calendar body with rounded corners (simplified rectangle with rounded corners)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(3 * scaleX, 4 * scaleY, 21 * scaleX, 21 * scaleY),
      Radius.circular(2 * scaleX),
    );
    canvas.drawRRect(rect, paint);

    // Left calendar hanger (vertical line)
    canvas.drawLine(
      Offset(7.5 * scaleX, 2 * scaleY),
      Offset(7.5 * scaleX, 6 * scaleY),
      paint,
    );

    // Right calendar hanger (vertical line)
    canvas.drawLine(
      Offset(16.5 * scaleX, 2 * scaleY),
      Offset(16.5 * scaleX, 6 * scaleY),
      paint,
    );

    // Horizontal separator line
    canvas.drawLine(
      Offset(3 * scaleX, 9 * scaleY),
      Offset(21 * scaleX, 9 * scaleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(BookingsIconPainter oldDelegate) => false;
}

/// Custom painter for Scheduled Taxi icon in bottom navigation
class ScheduledTaxiIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill;

    // Scale factors to fit 24x24 viewBox to canvas size
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;

    // Path 1: Bottom curved line
    final path1 = Path();
    path1.moveTo(8 * scaleX, 18.5 * scaleY);
    path1.lineTo(8.24567 * scaleX, 17.8858 * scaleY);
    path1.cubicTo(
      8.61101 * scaleX,
      16.9725 * scaleY,
      8.79368 * scaleX,
      16.5158 * scaleY,
      9.17461 * scaleX,
      16.2579 * scaleY,
    );
    path1.cubicTo(
      9.55553 * scaleX,
      16 * scaleY,
      10.0474 * scaleX,
      16 * scaleY,
      11.0311 * scaleX,
      16 * scaleY,
    );
    path1.lineTo(12.9689 * scaleX, 16 * scaleY);
    path1.cubicTo(
      13.9526 * scaleX,
      16 * scaleY,
      14.4445 * scaleX,
      16 * scaleY,
      14.8254 * scaleX,
      16.2579 * scaleY,
    );
    path1.cubicTo(
      15.2063 * scaleX,
      16.5158 * scaleY,
      15.389 * scaleX,
      16.9725 * scaleY,
      15.7543 * scaleX,
      17.8858 * scaleY,
    );
    path1.lineTo(16 * scaleX, 18.5 * scaleY);
    canvas.drawPath(path1, strokePaint);

    // Path 2: Left side detail
    final path2 = Path();
    path2.moveTo(2 * scaleX, 18 * scaleY);
    path2.lineTo(2 * scaleX, 20.882 * scaleY);
    path2.cubicTo(
      2 * scaleX,
      21.2607 * scaleY,
      2.24075 * scaleX,
      21.607 * scaleY,
      2.62188 * scaleX,
      21.7764 * scaleY,
    );
    path2.cubicTo(
      2.86918 * scaleX,
      21.8863 * scaleY,
      3.10538 * scaleX,
      22 * scaleY,
      3.39058 * scaleX,
      22 * scaleY,
    );
    path2.lineTo(5.10942 * scaleX, 22 * scaleY);
    path2.cubicTo(
      5.39462 * scaleX,
      22 * scaleY,
      5.63082 * scaleX,
      21.8863 * scaleY,
      5.87812 * scaleX,
      21.7764 * scaleY,
    );
    path2.cubicTo(
      6.25925 * scaleX,
      21.607 * scaleY,
      6.5 * scaleX,
      21.2607 * scaleY,
      6.5 * scaleX,
      20.882 * scaleY,
    );
    path2.lineTo(6.5 * scaleX, 19 * scaleY);
    canvas.drawPath(path2, strokePaint);

    // Path 3: Right side detail
    final path3 = Path();
    path3.moveTo(17.5 * scaleX, 19 * scaleY);
    path3.lineTo(17.5 * scaleX, 20.882 * scaleY);
    path3.cubicTo(
      17.5 * scaleX,
      21.2607 * scaleY,
      17.7408 * scaleX,
      21.607 * scaleY,
      18.1219 * scaleX,
      21.7764 * scaleY,
    );
    path3.cubicTo(
      18.3692 * scaleX,
      21.8863 * scaleY,
      18.6054 * scaleX,
      22 * scaleY,
      18.8906 * scaleX,
      22 * scaleY,
    );
    path3.lineTo(20.6094 * scaleX, 22 * scaleY);
    path3.cubicTo(
      20.8946 * scaleX,
      22 * scaleY,
      21.1308 * scaleX,
      21.8863 * scaleY,
      21.3781 * scaleX,
      21.7764 * scaleY,
    );
    path3.cubicTo(
      21.7592 * scaleX,
      21.607 * scaleY,
      22 * scaleX,
      21.2607 * scaleY,
      22 * scaleX,
      20.882 * scaleY,
    );
    path3.lineTo(22 * scaleX, 18 * scaleY);
    canvas.drawPath(path3, strokePaint);

    // Path 4: Top front part
    final path4 = Path();
    path4.moveTo(4.5 * scaleX, 10.5 * scaleY);
    path4.lineTo(5.5883 * scaleX, 7.23509 * scaleY);
    path4.cubicTo(
      6.02832 * scaleX,
      5.91505 * scaleY,
      6.24832 * scaleX,
      5.25503 * scaleY,
      6.7721 * scaleX,
      4.87752 * scaleY,
    );
    path4.cubicTo(
      7.29587 * scaleX,
      4.5 * scaleY,
      7.99159 * scaleX,
      4.5 * scaleY,
      9.38304 * scaleX,
      4.5 * scaleY,
    );
    path4.lineTo(14.617 * scaleX, 4.5 * scaleY);
    path4.cubicTo(
      16.0084 * scaleX,
      4.5 * scaleY,
      16.7041 * scaleX,
      4.5 * scaleY,
      17.2279 * scaleX,
      4.87752 * scaleY,
    );
    path4.cubicTo(
      17.7517 * scaleX,
      5.25503 * scaleY,
      17.9717 * scaleX,
      5.91505 * scaleY,
      18.4117 * scaleX,
      7.23509 * scaleY,
    );
    path4.lineTo(19.5 * scaleX, 10.5 * scaleY);
    canvas.drawPath(path4, strokePaint);

    // Path 5: Main body
    final path5 = Path();
    path5.moveTo(4.5 * scaleX, 10.5 * scaleY);
    path5.lineTo(19.5 * scaleX, 10.5 * scaleY);
    path5.cubicTo(
      20.4572 * scaleX,
      11.4572 * scaleY,
      22 * scaleX,
      12.7902 * scaleY,
      22 * scaleX,
      14.2774 * scaleY,
    );
    path5.lineTo(22 * scaleX, 17.5552 * scaleY);
    path5.cubicTo(
      22 * scaleX,
      18.094 * scaleY,
      21.6205 * scaleX,
      18.5474 * scaleY,
      21.1168 * scaleX,
      18.6104 * scaleY,
    );
    path5.lineTo(18 * scaleX, 19 * scaleY);
    path5.lineTo(6 * scaleX, 19 * scaleY);
    path5.lineTo(2.88316 * scaleX, 18.6104 * scaleY);
    path5.cubicTo(
      2.37955 * scaleX,
      18.5474 * scaleY,
      2 * scaleX,
      18.094 * scaleY,
      2 * scaleX,
      17.5552 * scaleY,
    );
    path5.lineTo(2 * scaleX, 14.2774 * scaleY);
    path5.cubicTo(
      2 * scaleX,
      12.7902 * scaleY,
      3.54279 * scaleX,
      11.4572 * scaleY,
      4.5 * scaleX,
      10.5 * scaleY,
    );
    path5.close();
    canvas.drawPath(path5, strokePaint);

    // Path 6: Right wheel (filled)
    final path6 = Path();
    path6.moveTo(20 * scaleX, 13.5002 * scaleY);
    path6.cubicTo(
      20 * scaleX,
      14.1187 * scaleY,
      18.5523 * scaleX,
      15.1253 * scaleY,
      18 * scaleX,
      15.1253 * scaleY,
    );
    path6.cubicTo(
      17.4477 * scaleX,
      15.1253 * scaleY,
      17 * scaleX,
      14.6775 * scaleY,
      17 * scaleX,
      14.1253 * scaleY,
    );
    path6.cubicTo(
      17 * scaleX,
      13.573 * scaleY,
      17.515 * scaleX,
      13.2468 * scaleY,
      18 * scaleX,
      13.1253 * scaleY,
    );
    path6.cubicTo(
      18.5 * scaleX,
      13 * scaleY,
      20 * scaleX,
      12.5893 * scaleY,
      20 * scaleX,
      13.5002 * scaleY,
    );
    path6.close();
    canvas.drawPath(path6, fillPaint);

    // Path 7: Left wheel (filled)
    final path7 = Path();
    path7.moveTo(4 * scaleX, 13.5235 * scaleY);
    path7.cubicTo(
      4 * scaleX,
      14.0854 * scaleY,
      5.44772 * scaleX,
      15 * scaleY,
      6 * scaleX,
      15 * scaleY,
    );
    path7.cubicTo(
      6.55228 * scaleX,
      15 * scaleY,
      7 * scaleX,
      14.5932 * scaleY,
      7 * scaleX,
      14.0914 * scaleY,
    );
    path7.cubicTo(
      7 * scaleX,
      13.5896 * scaleY,
      6.48501 * scaleX,
      13.2932 * scaleY,
      6 * scaleX,
      13.1828 * scaleY,
    );
    path7.cubicTo(
      5.5 * scaleX,
      13.069 * scaleY,
      4 * scaleX,
      12.6958 * scaleY,
      4 * scaleX,
      13.5235 * scaleY,
    );
    path7.close();
    canvas.drawPath(path7, fillPaint);
  }

  @override
  bool shouldRepaint(ScheduledTaxiIconPainter oldDelegate) => false;
}
