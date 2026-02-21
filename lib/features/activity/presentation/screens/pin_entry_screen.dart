import 'package:flutter/material.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import 'vehicle_inspection_screen.dart';
import 'pickup_navigation_screen.dart';

class PinEntryScreen extends StatefulWidget {
  final String depotName;
  final bool isFirstDuty;

  const PinEntryScreen({
    super.key,
    required this.depotName,
    this.isFirstDuty = true,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final List<String> _pinDigits = ['', '', '', ''];
  int _currentIndex = 0;

  void _onNumberPressed(String number) {
    if (_currentIndex < 4) {
      setState(() {
        _pinDigits[_currentIndex] = number;
        _currentIndex++;
      });
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pinDigits[_currentIndex] = '';
      });
    }
  }

  void _verifyPin() {
    // TODO: Implement PIN verification logic
    final enteredPin = _pinDigits.join();
    
    // For demo purposes, accept any 4-digit PIN
    if (enteredPin.length == 4) {
      // Skip inspection for non-first duties
      if (!widget.isFirstDuty) {
        // Go directly to pickup navigation for subsequent duties
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PickupNavigationScreen(),
          ),
        );
      } else {
        // Navigate to vehicle inspection screen for first duty
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleInspectionScreen(
              vehicleNumber: 'MH-17-AK-0001',
              vehicleModel: 'White Maruti Suzuki Ertiga',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: ResponsiveUtils.iconSize(context, 20),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    
                    // Title
                    Text(
                      'Enter the four digit pin',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 16),
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 40)),
                    
                    // PIN Display Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: ResponsiveUtils.symmetricPadding(context, horizontal: 8),
                          width: ResponsiveUtils.scale(context, 60),
                          height: ResponsiveUtils.scale(context, 60),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _pinDigits[index],
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // Numeric Keypad
                    _buildNumericKeypad(),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        _buildKeypadRow(['1', '2', '3']),
        SizedBox(height: ResponsiveUtils.padding(context, 16)),
        
        // Row 2: 4, 5, 6
        _buildKeypadRow(['4', '5', '6']),
        SizedBox(height: ResponsiveUtils.padding(context, 16)),
        
        // Row 3: 7, 8, 9
        _buildKeypadRow(['7', '8', '9']),
        SizedBox(height: ResponsiveUtils.padding(context, 16)),
        
        // Row 4: *, 0, →
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton('*', isSpecial: true),
            SizedBox(width: ResponsiveUtils.padding(context, 16)),
            _buildKeypadButton('0'),
            SizedBox(width: ResponsiveUtils.padding(context, 16)),
            _buildKeypadButton('→', isSpecial: true, isSubmit: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        return Padding(
          padding: ResponsiveUtils.symmetricPadding(context, horizontal: 8),
          child: _buildKeypadButton(number),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String value, {bool isSpecial = false, bool isSubmit = false}) {
    final bool canSubmit = _pinDigits.every((digit) => digit.isNotEmpty);
    
    return GestureDetector(
      onTap: () {
        if (isSubmit) {
          // Check if all 4 digits are filled
          if (canSubmit) {
            _verifyPin();
          }
        } else if (value == '*') {
          _onBackspace();
        } else if (!isSpecial) {
          _onNumberPressed(value);
        }
      },
      child: Container(
        width: ResponsiveUtils.scale(context, 70),
        height: ResponsiveUtils.scale(context, 70),
        decoration: BoxDecoration(
          color: isSubmit 
              ? (canSubmit ? const Color(0xFFFFC200) : Colors.grey[300])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        ),
        alignment: Alignment.center,
        child: isSubmit
            ? Icon(
                Icons.arrow_forward,
                size: ResponsiveUtils.iconSize(context, 28),
                color: canSubmit ? Colors.black : Colors.grey[500],
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 24),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
      ),
    );
  }
}
