import 'package:flutter/material.dart';
import 'package:my_own_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();
  String _selectedCurrency = '₹';

  @override
  void dispose() {
    _usernameController.dispose();
    _budgetController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // Top margin
                const Text(
                  'Setup Your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Let\'s get started by setting up your account details.',
                  style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Currency',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '₹',
                      child: Text('Indian Rupee (₹)'),
                    ),
                    DropdownMenuItem(
                      value: '\$',
                      child: Text('US Dollar (\$)'),
                    ),
                    DropdownMenuItem(value: '€', child: Text('Euro (€)')),
                    DropdownMenuItem(
                      value: '£',
                      child: Text('British Pound (£)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Budget (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _dailyLimitController,
                  decoration: const InputDecoration(
                    labelText: 'Daily Spending Limit (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final enteredBudget = _budgetController.text.trim();

                      if (enteredBudget.isNotEmpty) {
                        final budgetValue = double.tryParse(enteredBudget);
                        if (budgetValue == null || budgetValue <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid budget.'),
                            ),
                          );
                          return;
                        }
                      }

                      final dailyLimitValue = _dailyLimitController.text.trim();
                      if (dailyLimitValue.isNotEmpty) {
                        final dailyLimitParsed = double.tryParse(
                          dailyLimitValue,
                        );
                        if (dailyLimitParsed == null || dailyLimitParsed <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid daily limit.',
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isSetupComplete', true);
                      await prefs.setString('currency', _selectedCurrency);
                      await prefs.setString(
                        'username',
                        _usernameController.text.trim(),
                      );

                      if (enteredBudget.isNotEmpty) {
                        await prefs.setDouble(
                          'budget',
                          double.parse(enteredBudget),
                        );
                      }
                      if (dailyLimitValue.isNotEmpty) {
                        await prefs.setDouble(
                          'dailyLimit',
                          double.parse(dailyLimitValue),
                        );
                      }

                      if (!context.mounted) return;

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text('Complete Setup'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
