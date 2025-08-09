import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true; // default to dark
  runApp(MyApp(initialDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.initialDarkMode;
  }

  Future<void> _toggleTheme() async {
    setState(() => isDark = !isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      home: DualCalculatorScreen(isDark: isDark, onToggleTheme: _toggleTheme),
    );
  }
}

class DualCalculatorScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DualCalculatorScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? const Color(0xFF0B0D0F)
        : const Color(0xFFECECF1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onToggleTheme,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1F25) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white10 : Colors.white70,
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    size: 22,
                    color: isDark ? Colors.amber[400] : Colors.grey[800],
                  ),
                ),
              ),
            ),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(420.0, constraints.maxWidth * 0.92);
                  return SizedBox(
                    width: width,
                    child: CalculatorPanel(isDark: isDark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorPanel extends StatefulWidget {
  final bool isDark;
  const CalculatorPanel({super.key, required this.isDark});

  @override
  State<CalculatorPanel> createState() => _CalculatorPanelState();
}

class _CalculatorPanelState extends State<CalculatorPanel> {
  String _input = '0';
  String _result = '';
  String _operation = '';
  double _num1 = 0;
  bool _isOperationClicked = false;
  bool _isResultShown = false;

  void _onNumberClick(String value) {
    setState(() {
      if (_input == '0' && value == '0' && !_input.contains('.')) return;
      if (_input == '0' || _isOperationClicked || _isResultShown) {
        _input = value;
        _isOperationClicked = false;
        if (_isResultShown) {
          _result = '';
          _operation = '';
          _num1 = 0;
        }
        _isResultShown = false;
      } else {
        _input += value;
      }
    });
  }

  void _onOperatorClick(String operator) {
    setState(() {
      if (_operation.isNotEmpty && !_isOperationClicked) {
        _onEqualClick();
        _input = _result;
        _num1 = double.tryParse(_result) ?? 0;
        _result = '';
      } else {
        _num1 = double.tryParse(_input) ?? 0;
      }
      _operation = operator;
      _isOperationClicked = true;
      _isResultShown = false;
    });
  }

  void _onEqualClick() {
    setState(() {
      if (_operation.isEmpty) return;
      double num2 = double.tryParse(_input) ?? 0;
      double result = 0;

      switch (_operation) {
        case '+':
          result = _num1 + num2;
          break;
        case '-':
          result = _num1 - num2;
          break;
        case 'x':
          result = _num1 * num2;
          break;
        case '/':
          if (num2 != 0) {
            result = _num1 / num2;
          } else {
            _result = 'Error';
            _input = '0';
            _operation = '';
            _isResultShown = true;
            return;
          }
          break;
      }

      _result = (result % 1 == 0)
          ? result.toInt().toString()
          : result.toString();
      _input = _result;
      _isResultShown = true;
      _operation = '';
      _num1 = 0;
    });
  }

  void _onClearEntry() {
    setState(() {
      _input = '0';
      _result = '';
      _operation = '';
      _num1 = 0;
      _isOperationClicked = false;
      _isResultShown = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_isResultShown) {
        _input = '0';
        _isResultShown = false;
        return;
      }
      if (_input.length > 1) {
        _input = _input.substring(0, _input.length - 1);
      } else {
        _input = '0';
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (!_input.contains('.')) {
        _input = _input == '0' ? '0.' : '$_input.';
      }
    });
  }

  void _onPercent() {
    setState(() {
      final v = double.tryParse(_input) ?? 0;
      _input = (v / 100).toString();
    });
  }

  String _formatWithCommas(String value) {
    if (value == 'Error') return value;
    double? number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return value;
    return number
        .toStringAsFixed(number.truncateToDouble() == number ? 0 : 2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Color get panelBg => widget.isDark ? const Color(0xFF1B1F25) : Colors.white;
  Color get displayBg => widget.isDark ? const Color(0xFF14171B) : Colors.white;
  Color get primaryAccent => const Color(0xFFFF8A00);
  Color get softShadow =>
      widget.isDark ? Colors.black.withOpacity(0.6) : Colors.black12;

  @override
  Widget build(BuildContext context) {
    final cardPadding = 20.0;
    final borderRadius = BorderRadius.circular(28);

    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 420),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black87 : Colors.black12,
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: widget.isDark ? Colors.white10 : Colors.white70,
            blurRadius: 8,
            offset: const Offset(0, -6),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: softShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.history,
                size: 18,
                color: widget.isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ===== NEW DISPLAY =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _operation.isNotEmpty
                    ? '${_formatWithCommas(_num1.toString())} $_operation ${(!_isOperationClicked && !_isResultShown) ? _formatWithCommas(_input) : ''}'
                    : '',
                style: TextStyle(
                  color: widget.isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                _isResultShown && _result.isNotEmpty
                    ? _formatWithCommas(_result)
                    : _formatWithCommas(_input),
                style: TextStyle(
                  color: primaryAccent,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildKeyRow(['CE', '⌫', '%', '/']),
                _buildKeyRow(['7', '8', '9', 'x']),
                _buildKeyRow(['4', '5', '6', '-']),
                _buildKeyRow(['1', '2', '3', '+']),
                _buildBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: labels.map((t) {
          final isOperator = (t == '/' || t == 'x' || t == '+' || t == '-');
          final isFunction = (t == 'CE' || t == '⌫' || t == '%');
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _calcButton(
                label: t,
                isOperator: isOperator,
                isFunction: isFunction,
                onTap: () {
                  if (t == 'CE') {
                    _onClearEntry();
                  } else if (t == '⌫') {
                    _onBackspace();
                  } else if (t == '%') {
                    _onPercent();
                  } else if (isOperator) {
                    _onOperatorClick(t);
                  } else {
                    _onNumberClick(t);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _calcButton(
                label: '0',
                isOperator: false,
                isFunction: false,
                isWide: true,
                onTap: () => _onNumberClick('0'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _calcButton(
                label: '.',
                isOperator: false,
                isFunction: false,
                onTap: _onDecimal,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _calcButton(
                label: '=',
                isOperator: true,
                isFunction: false,
                onTap: _onEqualClick,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcButton({
    required String label,
    required VoidCallback onTap,
    bool isOperator = false,
    bool isFunction = false,
    bool isWide = false,
  }) {
    final Color bgColor = isOperator
        ? primaryAccent
        : isFunction
        ? (widget.isDark ? const Color(0xFF2A2E33) : const Color(0xFFF0F0F3))
        : (widget.isDark ? const Color(0xFF15181B) : Colors.white);

    final Color txtColor = isOperator
        ? Colors.white
        : (widget.isDark ? Colors.white70 : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 72,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: widget.isDark ? Colors.black87 : Colors.black12,
              offset: const Offset(6, 8),
              blurRadius: 18,
              spreadRadius: -8,
            ),
            BoxShadow(
              color: widget.isDark ? Colors.white10 : Colors.white70,
              offset: const Offset(-8, -8),
              blurRadius: 18,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: txtColor,
              fontSize: label.length > 1 ? 20 : 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
