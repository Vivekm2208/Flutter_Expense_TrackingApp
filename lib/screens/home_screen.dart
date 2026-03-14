import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_own_app/models/transaction_model.dart';
import 'package:my_own_app/charts/monthly_chart.dart';
import 'package:my_own_app/widgets/new_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_own_app/widgets/summary_card.dart';
import 'package:my_own_app/widgets/transaction_list.dart';
import 'package:my_own_app/charts/weekly_chart.dart';
import 'package:my_own_app/charts/category_pie_chart.dart';

enum FilterType { all, weekly, monthly }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];
  FilterType _selectedFilter = FilterType.all;
  String? _userName;
  String _currency = '₹';
  double? _budget;
  double? _userDailyLimit;
  bool _isLoading = true;
  bool _prefsLoaded = false;
  bool _transactionsLoaded = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadUserPrefs();
    _loadTransactions();
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final tx in _displayedTransactions) {
      totals.update(
        tx.category,
        (existing) => existing + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    return totals;
  }

  List<Transaction> get recentTransactions {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _transactions.where((tx) {
      return tx.date.isAfter(sevenDaysAgo);
    }).toList();
  }

  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) {
      return tx.date.year == now.year && tx.date.month == now.month;
    }).toList();
  }

  List<Transaction> get _displayedTransactions {
    List<Transaction> base;

    switch (_selectedFilter) {
      case FilterType.weekly:
        base = recentTransactions;
        break;
      case FilterType.monthly:
        base = currentMonthTransactions;
        break;
      case FilterType.all:
        base = _transactions;
        break;
    }

    if (_selectedCategory != null) {
      base = base.where((tx) => tx.category == _selectedCategory).toList();
    }
    return base;
  }

  double get totalSpent {
    return _transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double? get effectiveDailyLimit {
    if (_userDailyLimit != null) {
      return _userDailyLimit;
    }

    if (_budget != null) {
      final now = DateTime.now();
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
      return _budget! / daysInMonth;
    }
    return null;
  }

  double? get remainingBudget {
    if (_budget == null) return null;
    return _budget! - totalSpent;
  }

  List<Map<String, Object>> get weeklySpending {
    return List.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: index));
      double totalForDay = 0.0;
      for (final tx in recentTransactions) {
        if (tx.date.day == day.day &&
            tx.date.month == day.month &&
            tx.date.year == day.year) {
          totalForDay += tx.amount;
        }
      }
      return {'day': day, 'amount': totalForDay};
    }).reversed.toList();
  }

  List<DailyTotal> get monthlyTotals {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final totalForDay = _transactions
          .where(
            (tx) =>
                tx.date.year == now.year &&
                tx.date.month == now.month &&
                tx.date.day == day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);

      return DailyTotal(day: day, amount: totalForDay);
    });
  }

  void _addNewTransaction(String title, double amount, String category) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );
    setState(() {
      _transactions.add(newTx);
    });
    _saveTransactions();
  }

  void _deleteTransaction(String id) {
    final removedTx = _transactions.firstWhere((tx) => tx.id == id);
    final removedIndex = _transactions.indexOf(removedTx);
    setState(() {
      _transactions.removeAt(removedIndex);
    });
    _saveTransactions();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _transactions.insert(removedIndex, removedTx);
            });
            _saveTransactions();
          },
        ),
      ),
    );
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txList = prefs.getStringList('transactions') ?? [];
    final loadedTransactions = txList.map((txJson) {
      return Transaction.fromJson(jsonDecode(txJson));
    }).toList();
    setState(() {
      _transactionsLoaded = true;
      _transactions.clear();
      _transactions.addAll(loadedTransactions);
      if (_prefsLoaded) _isLoading = false;
    });
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username');
      _currency = prefs.getString('currency') ?? '₹';
      _budget = prefs.getDouble('budget');
      _userDailyLimit = prefs.getDouble('dailyLimit');
      _prefsLoaded = true;
      if (_transactionsLoaded) _isLoading = false;
    });
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> txList = _transactions
        .map((tx) => jsonEncode(tx.toJson()))
        .toList();
    await prefs.setStringList('transactions', txList);
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => NewTransaction(onAdd: _addNewTransaction),
    );
  }

  // filter button
  Widget _buildFilterButton(String label, FilterType type) {
    final isSelected = _selectedFilter == type;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Colors.blue.shade600
            : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
      ),
      child: Text(label),
    );
  }

  // filter selector
  Widget _buildFilterSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton('All', FilterType.all),
          _buildFilterButton('Weekly', FilterType.weekly),
          _buildFilterButton('Monthly', FilterType.monthly),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          totalSpent: totalSpent,
          currency: _currency,
          remainingBudget: remainingBudget,
        ),
        _buildFilterSelector(),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _selectedCategory == null
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey('chip-$_selectedCategory'),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Center(
                    child: Chip(
                      label: Text('Filtering: $_selectedCategory'),
                      onDeleted: () => setState(() => _selectedCategory = null),
                      backgroundColor: Colors.blue.shade50,
                      deleteIconColor: Colors.redAccent,
                    ),
                  ),
                ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[...previousChildren, ?currentChild],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: _buildSelectedChart(),
        ),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _displayedTransactions.isEmpty
                ? Center(
                    key: const ValueKey('empty-state'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 50,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first expense to start tracking.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : TransactionList(
                    key: ValueKey(
                      '${_selectedFilter.toString()}$_selectedCategory',
                    ),
                    transactions: _displayedTransactions,
                    onDelete: _deleteTransaction,
                    currency: _currency,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedChart() {
    if (_selectedFilter == FilterType.weekly) {
      return WeeklyChart(
        key: const ValueKey('weekly-chart'),
        weeklySpending: weeklySpending,
        dailyLimit: effectiveDailyLimit,
      );
    } else if (_selectedFilter == FilterType.monthly) {
      return MonthlyChart(
        key: const ValueKey('monthly-chart'),
        data: monthlyTotals,
        dailyLimit: effectiveDailyLimit,
      );
    } else {
      return Padding(
        key: const ValueKey('pie-chart'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CategoryPieChart(
          data: categoryTotals,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = _selectedCategory == category
                  ? null
                  : category;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_userName == null || _userName!.isEmpty)
              ? 'PennyWise Home'
              : 'Welcome, $_userName!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 227, 43, 43),
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
