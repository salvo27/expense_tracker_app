import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'expenses.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_expenses(id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category TEXT)');
    },
    version: 1,
  );
  return db;
}

Category _getCategory(String category) {
  if (category == 'cibo') return Category.cibo;
  if (category == 'viaggi') return Category.viaggi;
  if (category == 'shopping') return Category.shopping;
  return Category.lavoro;
}



class UserExpensesNotifier extends StateNotifier<List<Expense>> {
  UserExpensesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_expenses');
    final expenses = data
        .map(
          (row) => Expense(
            id: row['id'] as String,
            title: row['title'] as String,
            amount: row['amount'] as double,
            date: DateFormat('d/M/y').parse(row['date'] as String),
            category: _getCategory(row['category'] as String),
          ),
        )
        .toList();
    state = expenses;
  }

  void addExpense(String title, double amount, DateTime date, Category category) async{
    final appDir = syspaths.getApplicationDocumentsDirectory();
    final newExpense = Expense(title: title, amount: amount, date: date, category: category);

    final db = await _getDatabase();
    db.insert('user_expenses', {
      'id' : newExpense.id,
      'title' : newExpense.title,
      'amount' : newExpense.amount,
      'date' : formatter.format(date),
      'category' : category.name,
    });
    state = [newExpense, ...state];
  }
}

final userExpensesProvider = StateNotifierProvider<UserExpensesNotifier, List<Expense>> (
  (ref) => UserExpensesNotifier(),
);
