import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_stock.dart';

class MarketService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<MarketStock>> getStocks() async {
    final response = await http.get(Uri.parse('$baseUrl/market-stocks'));

    if (response.statusCode == 200) {
      print(response.body);

      final data = jsonDecode(response.body);
      final List stocks = data['data'];

      // Kullanıcının seçili hisselerini al
      final userStocks = await getUserStocks();
      final selectedSymbols = userStocks.map((s) => s.symbol).toSet();

      // Market verilerini map et ve seçili olanları işaretle
      return stocks.map((stock) {
        final marketStock = MarketStock.fromJson(stock);
        marketStock.isSelected = selectedSymbols.contains(marketStock.symbol);
        return marketStock;
      }).toList();
    } else {
      throw Exception('Failed to load stocks');
    }
  }

  static Future<List<MarketStock>> getUserStocks() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user-stocks/${user.id}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List stocks = data['data'];
        return stocks.map((stock) {
          return MarketStock(
            symbol: stock['stock_symbol']?.toString() ?? '',
            companyName: stock['company_name']?.toString() ?? '',
            sector: stock['sector']?.toString() ?? '',
            isSelected: true,
          );
        }).toList();
      }
    }

    return [];
  }

  static Future<void> saveUserStock({
    required String userId,
    required String symbol,
    required String companyName,
    required String sector,
    required bool isSelected,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user-stock"), // user_stocks değil user-stock
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "stock_symbol": symbol,
        "company_name": companyName,
        "sector": sector,
        "is_selected": isSelected,
      }),
    );

    print(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to save user stock');
    }
  }
}
