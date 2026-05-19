class MarketStock {
  final String symbol;
  final String companyName;
  final String sector;

  bool isSelected;

  MarketStock({
    required this.symbol,
    required this.companyName,
    required this.sector,
    this.isSelected = false,
  });

  factory MarketStock.fromJson(Map<String, dynamic> json) {
    return MarketStock(
      symbol: (json['symbol'] ?? json['stock_symbol'])?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
    );
  }
}
