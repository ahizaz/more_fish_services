import 'package:get/get.dart';

import '../models/farm_expense.dart';

class FarmAccountingController extends GetxController {
  static const categories = [
    'Feed',
    'Capital',
    'Utilities',
    'Handling',
    'Medicine',
    'Labour',
    'Maintenance',
    'Other',
  ];

  final RxList<FarmExpense> expenses = <FarmExpense>[].obs;

  List<FarmExpense> filterExpenses({
    required String farmId,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return expenses.where((expense) {
      if (expense.farmId != farmId) return false;
      if (normalizedQuery.isEmpty) return true;
      return expense.stockingBatch.toLowerCase().contains(normalizedQuery) ||
          expense.category.toLowerCase().contains(normalizedQuery) ||
          expense.description.toLowerCase().contains(normalizedQuery) ||
          expense.amount.toStringAsFixed(2).contains(normalizedQuery);
    }).toList();
  }

  Future<bool> createExpenseApi(FarmExpense expense) async => true;

  Future<bool> updateExpenseApi(FarmExpense expense) async => true;

  Future<bool> deleteExpenseApi(String expenseId) async => true;

  Future<void> addExpense(FarmExpense expense) async {
    if (!await createExpenseApi(expense)) return;
    expenses.insert(0, expense);
  }

  Future<void> updateExpense(FarmExpense expense) async {
    if (!await updateExpenseApi(expense)) return;
    final index = expenses.indexWhere((item) => item.id == expense.id);
    if (index >= 0) expenses[index] = expense;
  }

  Future<void> deleteExpense(String expenseId) async {
    if (!await deleteExpenseApi(expenseId)) return;
    expenses.removeWhere((expense) => expense.id == expenseId);
  }
}
