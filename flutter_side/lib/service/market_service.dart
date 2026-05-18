import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_stock.dart';

class MarketService {
  static final supabase = Supabase.instance.client;

  // MARKET STOCKS
  static Future<List<MarketStock>> getStocks() async {
    try {
      final response = await supabase
          .from('market_stocks')
          .select();

      // Kullanıcının seçili hisseleri
      final userStocks = await getUserStocks();
      final selectedSymbols = userStocks.map((s) => s.symbol).toSet();

      return (response as List).map((stock) {
        final marketStock = MarketStock.fromJson(stock);

        marketStock.isSelected =
            selectedSymbols.contains(marketStock.symbol);

        return marketStock;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load stocks: $e');
    }
  }

  // USER STOCKS
  static Future<List<MarketStock>> getUserStocks() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return [];
      }

      final response = await supabase
          .from('user_stocks')
          .select()
          .eq('user_id', user.id);

      return (response as List).map((stock) {
        return MarketStock(
          symbol: stock['stock_symbol']?.toString() ?? '',
          companyName: stock['company_name']?.toString() ?? '',
          sector: stock['sector']?.toString() ?? '',
          isSelected: true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load user stocks: $e');
    }
  }

  // SAVE USER STOCK
  static Future<void> saveUserStock({
    required String userId,
    required String symbol,
    required String companyName,
    required String sector,
    required bool isSelected,
  }) async {
    try {
      // EKLE
      if (isSelected) {

        // Aynı hisse var mı kontrol et
        final existing = await supabase
            .from('user_stocks')
            .select()
            .eq('user_id', userId)
            .eq('stock_symbol', symbol);

        if ((existing as List).isEmpty) {
          await supabase.from('user_stocks').insert({
            'user_id': userId,
            'stock_symbol': symbol,
            'company_name': companyName,
            'sector': sector,
          });
        }
      }

      // SİL
      else {
        await supabase
            .from('user_stocks')
            .delete()
            .eq('user_id', userId)
            .eq('stock_symbol', symbol);
      }
    } catch (e) {
      throw Exception('Failed to save stock: $e');
    }
  }
}