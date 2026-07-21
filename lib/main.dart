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
      double num2 = double.parse(num1Controller.text);
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
      appBar: AppBar(title: Text("Calculator")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter First Number"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Second Number"),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => calculate("+"),
                  child: Text("+"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("-"),
                  child: Text("-"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("*"),
                  child: Text("×"),
                ),
                ElevatedButton(
                  onPressed: () => calculate("/"),
                  child: Text("÷"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Result : $result",
              style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: result.contains("Cannot") || result.contains("Invalid") || result.contains("Please")
                      ? Colors.red
                      : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
