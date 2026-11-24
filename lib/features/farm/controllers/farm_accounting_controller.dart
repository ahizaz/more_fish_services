import 'package:get/get.dart';

import '../models/farm_expense.dart';
import '../models/farm_sale.dart';
import '../models/farm_selling_price.dart';

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
  final RxList<FarmSellingPrice> sellingPrices = <FarmSellingPrice>[].obs;
  final RxList<FarmSale> sales = <FarmSale>[].obs;

  List<FarmSale> filterSales({
    required String farmId,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return sales.where((sale) {
      if (sale.farmId != farmId) return false;
      if (normalizedQuery.isEmpty) return true;
      return sale.stockingBatch.toLowerCase().contains(normalizedQuery) ||
          sale.buyerName.toLowerCase().contains(normalizedQuery) ||
          sale.pricePerKg.toStringAsFixed(2).contains(normalizedQuery);
    }).toList();
  }

  List<FarmSellingPrice> filterSellingPrices({
    required String farmId,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return sellingPrices.where((price) {
      if (price.farmId != farmId) return false;
      if (normalizedQuery.isEmpty) return true;
      return price.stockingBatch.toLowerCase().contains(normalizedQuery) ||
          price.pricePerKg.toStringAsFixed(2).contains(normalizedQuery);
    }).toList();
  }

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

  Future<bool> createSellingPriceApi(FarmSellingPrice price) async => true;

  Future<bool> updateSellingPriceApi(FarmSellingPrice price) async => true;

  Future<bool> deleteSellingPriceApi(String priceId) async => true;

  Future<void> addSellingPrice(FarmSellingPrice price) async {
    if (!await createSellingPriceApi(price)) return;
    sellingPrices.insert(0, price);
  }

  Future<void> updateSellingPrice(FarmSellingPrice price) async {
    if (!await updateSellingPriceApi(price)) return;
    final index = sellingPrices.indexWhere((item) => item.id == price.id);
    if (index >= 0) sellingPrices[index] = price;
  }

  Future<void> deleteSellingPrice(String priceId) async {
    if (!await deleteSellingPriceApi(priceId)) return;
    sellingPrices.removeWhere((item) => item.id == priceId);
  }

  Future<bool> createSaleApi(FarmSale sale) async => true;

  Future<bool> updateSaleApi(FarmSale sale) async => true;

  Future<bool> deleteSaleApi(String saleId) async => true;

  Future<void> addSale(FarmSale sale) async {
    if (!await createSaleApi(sale)) return;
    sales.insert(0, sale);
  }

  Future<void> updateSale(FarmSale sale) async {
    if (!await updateSaleApi(sale)) return;
    final index = sales.indexWhere((item) => item.id == sale.id);
    if (index >= 0) sales[index] = sale;
  }

  Future<void> deleteSale(String saleId) async {
    if (!await deleteSaleApi(saleId)) return;
    sales.removeWhere((sale) => sale.id == saleId);
  }
}
