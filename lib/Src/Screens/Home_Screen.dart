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
  final List<String> _history = [];
  String _currentCalculation = '';
  bool _isResultShown = false;

  void _onNumberClick(String value) {
    setState(() {
      if (_input == '0' && value == '0' && !_input.contains('.')) {
        // Prevent adding another 0 at start
        return;
      }
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

  void _onOperatorClick(String operator) {
    setState(() {
      // If we already have an operation and the user clicked another operator,
      // calculate first before chaining
      if (_operation.isNotEmpty && !_isOperationClicked) {
        _onEqualClick();
        _input = _result; // so next number starts from result
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

      // Prevent equal if second number not typed
      if ((_isOperationClicked && _input == '0' && !_input.contains('.'))) {
        return;
      }

      // Prevent meaningless zero ops unless explicitly typed
      if (_num1 == 0 && (_input == '0' || _input.isEmpty)) {
        return;
      }

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
            _history.insert(0, '$fullCalculation = Error');
            _currentCalculation = '';
            _isResultShown = true;
            return;
          }
          break;
      }

      _result = (result % 1 == 0)
          ? result.toInt().toString()
          : result.toString();

      String num1Str = (_num1 % 1 == 0)
          ? _num1.toInt().toString()
          : _num1.toString();
      String num2Str = (_input.contains('.') || num2 % 1 != 0)
          ? num2.toString()
          : num2.toInt().toString();

      if (!(num1Str == "0" && num2Str == "0" && _result == "0")) {
        _history.insert(0, '$num1Str $_operation $num2Str = $_result');
      }

      _input = '0';
      _currentCalculation = '';
      _operation = '';
      _isResultShown = true;
    });
  }

  void _onClearClick() {
    setState(() {
      _input = '0'; // reset display input
      _result = ''; // clear any result
      _currentCalculation = ''; // clear current calc string
      _isResultShown = false; // allow new typing
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
      // Allow decimal only if no decimal exists yet
      if (!_input.contains('.')) {
        // If starting fresh, prefix with "0."
        _input = _input == '0' ? '0.' : '$_input.';
      }
    });
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Text(
                    "History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                            child: Text(
                              "No history yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            reverse: true,
                            itemCount: _history.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final parts = item.split('=');
                              final equation = parts[0].trim();
                              final answer = parts.length > 1
                                  ? parts[1].trim()
                                  : "";

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            equation,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            answer,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF5B86E5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setModalState(() {}); // updates sheet UI instantly
                        setState(() {
                          _history.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_history.isNotEmpty)
                          Text(
                            _history.first, // latest only
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.end,
                          ),
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

                  // 📌 Fixed History Icon at top right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        Icons.history,
                        size: 28,
                        color: Colors.black87,
                      ),
                      onPressed: _showHistorySheet,
                    ),
                  ),
                ],
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
                            "CE",
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
                            () => _onOperatorClick('/'),
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
                            () => _onOperatorClick('x'),
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
                            () => _onOperatorClick('-'),
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
                            () => _onOperatorClick('+'),
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
