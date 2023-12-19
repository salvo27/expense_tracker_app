import 'package:expense_tracker/providers/user_expenses.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends ConsumerState<Expenses> {
  List<Expense> _registeredExpenses = [];
  late Future<void> _expensesFuture;

  @override
  initState() {
    super.initState();
    _expensesFuture = ref.read(userExpensesProvider.notifier).loadPlaces();
  }

  _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense) {
    ref.read(userExpensesProvider.notifier).addExpense(
          expense.title,
          expense.amount,
          expense.date,
          expense.category,
        );
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Acquisto eliminato'),
        action: SnackBarAction(
            label: 'Cancella',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, expense);
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    _registeredExpenses = ref.watch(userExpensesProvider);
    _registeredExpenses.sort((a, b) {
      return -a.date.compareTo(b.date);
    });

    Widget mainContent = const Center(
      child: Text('Nessun acquisto trovato. Inizia ad aggiungerli!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('ExpenseTracker'),
          actions: [
            IconButton(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _expensesFuture,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : width < height
                      ? Column(
                          children: [
                            Chart(expenses: _registeredExpenses),
                            Expanded(
                              child: mainContent,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Chart(expenses: _registeredExpenses),
                            ),
                            Expanded(
                              child: mainContent,
                            ),
                          ],
                        ),
        )
        // width < height
        //     ? Column(
        //         children: [
        //           Chart(expenses: _registeredExpenses),
        //           Expanded(
        //             child: mainContent,
        //           ),
        //         ],
        //       )
        //     : Row(
        //         children: [
        //           Expanded(
        //             child: Chart(expenses: _registeredExpenses),
        //           ),
        //           Expanded(
        //             child: mainContent,
        //           ),
        //         ],
        //       ),
        );
  }
}
