import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  runApp(CalculatorApp(isDarkMode: isDark));
}

class CalculatorApp extends StatefulWidget {
  final bool isDarkMode;
  const CalculatorApp({super.key, required this.isDarkMode});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  late bool isDarkMode;
  String displayText = '0';
  String equation = '';
  String result = '';
  String operator = '';

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        displayText = '0';
        equation = '';
        result = '';
        operator = '';
      } else if (value == '=') {
        try {
          final exp = equation.replaceAll('×', '*').replaceAll('÷', '/');
          result = _calculate(exp);
          displayText = result;
        } catch (_) {
          displayText = 'Error';
        }
      } else {
        if (displayText == '0' && value != '.') {
          displayText = value;
        } else {
          displayText += value;
        }
        equation = displayText;
      }
    });
  }

  String _calculate(String exp) {
    try {
      final expression = exp;
      final parsed = double.parse(
        _safeEval(expression).toStringAsFixed(10),
      ); // Limit precision
      return parsed.toString().replaceAll(RegExp(r'\.?0+$'), '');
    } catch (_) {
      return 'Error';
    }
  }

  double _safeEval(String expr) {
    // Very basic evaluator: use RegExp parsing (no dart:mirrors or eval)
    try {
      return _evalSimple(expr);
    } catch (_) {
      throw Exception('Invalid');
    }
  }

  double _evalSimple(String expr) {
    // Example: "3+5*2"
    final exp = expr.replaceAll(' ', '');
    final tokens = RegExp(
      r'(\d+\.?\d*|[+\-*/])',
    ).allMatches(exp).map((m) => m.group(0)!).toList();

    // Handle * and /
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final a = double.parse(tokens[i - 1]);
        final b = double.parse(tokens[i + 1]);
        final res = tokens[i] == '*' ? a * b : a / b;
        tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        i -= 1;
      }
    }

    // Handle + and -
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final op = tokens[i];
      final num = double.parse(tokens[i + 1]);
      if (op == '+') total += num;
      if (op == '-') total -= num;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final btnColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final opColor = Colors.orange;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: Text('Calculator', style: TextStyle(color: textColor)),
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: textColor,
              ),
              onPressed: toggleTheme,
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 48,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildButtonRow(['C', '÷', '×', '-'], btnColor, opColor, textColor),
            _buildButtonRow(['7', '8', '9', '+'], btnColor, opColor, textColor),
            _buildButtonRow(['4', '5', '6', '='], btnColor, opColor, textColor),
            _buildButtonRow(['1', '2', '3', '.'], btnColor, opColor, textColor),
            _buildButtonRow(['0'], btnColor, opColor, textColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(
    List<String> labels,
    Color btnColor,
    Color opColor,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) {
        final isOperator = ['÷', '×', '-', '+', '='].contains(label);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 70,
            height: 70,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: isOperator ? opColor : btnColor,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => buttonPressed(label),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  color: isOperator ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
