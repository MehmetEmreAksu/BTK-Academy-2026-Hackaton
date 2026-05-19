import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/market_stock.dart';

class MarketService {
  static final supabase = Supabase.instance.client;

  // Giris yapan kullanicinin users tablosunda satiri olmasini garantiler.
  // W2 gunluk mail workflow'u users.email uzerinden mail attigi icin sart.
  static Future<void> ensureUserRow() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final meta = user.userMetadata ?? {};
    final fullName =
        '${meta['first_name'] ?? ''} ${meta['last_name'] ?? ''}'.trim();

    await supabase.from('users').upsert({
      'user_id': user.id,
      'email': user.email,
      'full_name': fullName.isEmpty ? (user.email ?? 'User') : fullName,
    }, onConflict: 'user_id');
  }

  // Tum market hisseleri + kullanicinin takip ettikleri isaretli
  static Future<List<MarketStock>> getStocks() async {
    final response = await supabase.from('market_stocks').select();

    final userStocks = await getUserStocks();
    final selectedSymbols = userStocks.map((s) => s.symbol).toSet();

    return (response as List).map((stock) {
      final marketStock = MarketStock.fromJson(stock);
      marketStock.isSelected = selectedSymbols.contains(marketStock.symbol);
      return marketStock;
    }).toList();
  }

  // Kullanicinin portfoyu (user_portfolios) + sirket bilgisi market_stocks'tan
  static Future<List<MarketStock>> getUserStocks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final portfolio = await supabase
        .from('user_portfolios')
        .select('symbol')
        .eq('user_id', user.id);

    final symbols = (portfolio as List)
        .map((e) => e['symbol']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    if (symbols.isEmpty) return [];

    final stocks = await supabase
        .from('market_stocks')
        .select()
        .inFilter('symbol', symbols);

    return (stocks as List).map((stock) {
      final ms = MarketStock.fromJson(stock);
      ms.isSelected = true;
      return ms;
    }).toList();
  }

  // Takibe ekle / cikar -> user_portfolios
  static Future<void> saveUserStock({
    required String userId,
    required String symbol,
    required String companyName,
    required String sector,
    required bool isSelected,
  }) async {
    if (isSelected) {
      final existing = await supabase
          .from('user_portfolios')
          .select('id')
          .eq('user_id', userId)
          .eq('symbol', symbol);

      if ((existing as List).isEmpty) {
        await supabase.from('user_portfolios').insert({
          'user_id': userId,
          'symbol': symbol,
        });
      }
    } else {
      await supabase
          .from('user_portfolios')
          .delete()
          .eq('user_id', userId)
          .eq('symbol', symbol);
    }
  }
}
