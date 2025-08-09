import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '0';
  String _result = '';
  String _operation = '';
  double _num1 = 0;
  bool _isOperationClicked = false;
  String _history = '';
  String _currentCalculation = '';
  bool _isResultShown = false;

  void _onNumberClick(String value) {
    setState(() {
      if (_input == '0' || _isOperationClicked || _isResultShown) {
        _input = value;
        _isOperationClicked = false;
        if (_isResultShown) {
          _result = '';
          _currentCalculation = '';
          _operation = '';
          _num1 = 0;
        }
        _isResultShown = false;
      } else {
        _input += value;
      }

      if (_operation.isNotEmpty) {
        _currentCalculation = "${_num1.toString()} $_operation $_input";
      }
    });
  }

  void _onOperationClick(String operation) {
    setState(() {
      if (_isResultShown) {
        _result = '';
        _isResultShown = false;
        _currentCalculation = '';
      }
      _num1 = double.tryParse(_input) ?? 0;
      _operation = operation;
      _isOperationClicked = true;

      _currentCalculation = "${_num1.toString()} $operation";
    });
  }

  void _onEqualClick() {
    setState(() {
      double num2 = double.tryParse(_input) ?? 0;
      double result = 0;
      String fullCalculation = "$_num1 $_operation $num2";
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
            _history = '$fullCalculation = Error';
            _currentCalculation = '';
            _isResultShown = true;

            return;
          }
          break;
      }
      _result = (result == result.toInt())
          ? result.toInt().toString()
          : result.toString();

      _history = '$_history\n$fullCalculation = $_result';
      _input = '0';
      _currentCalculation = '';
      _operation = '';
      _isResultShown = true;
    });
  }

  void _onClearClick() {
    setState(() {
      _input = '0';
      _result = '';
      _operation = '';
      _num1 = 0;
      _currentCalculation = '';
      _isResultShown = false;
    });
  }

  void _onBackspaceClick() {
    setState(() {
      if (_input.length > 1) {
        _input = _input.substring(0, _input.length - 1);
      } else {
        _input = '0';
      }
    });
  }

  void _onDecimalClick() {
    setState(() {
      if (!_input.contains('.')) {
        _input += '.';
      }
    });
  }

  Widget _buildButton(
    String text,
    Color textColor,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    bool isWideButton = text == '0';
    return Expanded(
      flex: isWideButton ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(20),
            elevation: 4,
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFFF5F5F5);
    final displayColor = Colors.white;
    final operatorButtonColor = Color(0xFF5B86E5);
    final numberButtonColor = Colors.white;
    final functionButtonColor = Color(0xFFE0E0E0);

    final numberTextColor = Colors.black87;
    final operatorTextColor = Colors.white;
    final functionTextColor = Colors.black87;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: displayColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_history.isNotEmpty)
                      Text(
                        _history,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.end,
                      ),
                    SizedBox(height: 5),
                    if (_currentCalculation.isNotEmpty)
                      Text(
                        _currentCalculation,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    SizedBox(height: 10),
                    if (_result.isNotEmpty)
                      Text(
                        "= $_result",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: operatorButtonColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    Text(
                      _input,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            "CC",
                            functionTextColor,
                            functionButtonColor,
                            _onClearClick,
                          ),
                          _buildButton(
                            "C",
                            functionTextColor,
                            functionButtonColor,
                            _onBackspaceClick,
                          ),
                          _buildButton(
                            "%",
                            functionTextColor,
                            functionButtonColor,
                            () {
                              setState(() {
                                double temp = double.parse(_input) / 100;
                                _input = temp.toString();
                              });
                            },
                          ),
                          _buildButton(
                            "/",
                            operatorTextColor,
                            operatorButtonColor,
                            () => _onOperationClick('/'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            "7",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('7'),
                          ),
                          _buildButton(
                            "8",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('8'),
                          ),
                          _buildButton(
                            "9",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('9'),
                          ),
                          _buildButton(
                            "x",
                            operatorTextColor,
                            operatorButtonColor,
                            () => _onOperationClick('x'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            "4",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('4'),
                          ),
                          _buildButton(
                            "5",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('5'),
                          ),
                          _buildButton(
                            "6",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('6'),
                          ),
                          _buildButton(
                            "-",
                            operatorTextColor,
                            operatorButtonColor,
                            () => _onOperationClick('-'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            "1",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('1'),
                          ),
                          _buildButton(
                            "2",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('2'),
                          ),
                          _buildButton(
                            "3",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('3'),
                          ),
                          _buildButton(
                            "+",
                            operatorTextColor,
                            operatorButtonColor,
                            () => _onOperationClick('+'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            "0",
                            numberTextColor,
                            numberButtonColor,
                            () => _onNumberClick('0'),
                          ),
                          _buildButton(
                            ".",
                            numberTextColor,
                            numberButtonColor,
                            _onDecimalClick,
                          ),
                          _buildButton(
                            "=",
                            operatorTextColor,
                            operatorButtonColor,
                            _onEqualClick,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
