import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController num1Controller = TextEditingController();
  TextEditingController num2Controller = TextEditingController();
  String result = "0";

  void calculate(String operator) {
    if (num1Controller.text.isEmpty || num2Controller.text.isEmpty) {
      setState(() {
        result = "Please enter both number";
      });
    }

    try {
      double num1 = double.parse(num1Controller.text);
      double num2 = double.parse(num2Controller.text);
      double answer;

      if (operator == "+") {
        answer = num1 + num2;
      } else if (operator == "-") {
        answer = num1 - num2;
      } else if (operator == "*") {
        answer = num1 * num2;
      } else {
        answer = num1 / num2;
      }

      setState(() {
        result = answer.toString();
      });
    } catch (e) {
      setState(() {
        result = "Invalid input";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Calculator",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter First Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Second Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOperatorButton("+"),
                _buildOperatorButton("-"),
                _buildOperatorButton("*"),
                _buildOperatorButton("/"),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Text(
                "Result : $result",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      result.contains("Cannot") ||
                          result.contains("Invalid") ||
                          result.contains("Please")
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorButton(String operator) {
    String label = operator == "*" ? "×" : (operator == "/" ? "÷" : operator);
    return ElevatedButton(
      onPressed: () => calculate(operator),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        padding: EdgeInsets.all(18),
      ),
      child: Text(label, style: TextStyle(fontSize: 20)),
    );
  }
}
