import 'dart:ui';
import 'package:btk_byte_benders/models/market_stock.dart';
import 'package:btk_byte_benders/service/market_service.dart';
import 'package:btk_byte_benders/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

final user = Supabase.instance.client.auth.currentUser;

final firstName = user?.userMetadata?['first_name'] ?? 'User';
final lastName = user?.userMetadata?['last_name'] ?? '';

class _UserScreenState extends State<UserScreen> {
  int selectedIndex = 0;
  bool _showDesktopChat = true;
  bool _showMobileChatPanel = false;
  List<MarketStock> marketStocks = [];
  List<MarketStock> userStocks = []; // YENİ

  bool isLoadingStocks = true;
  bool isLoadingUserStocks = false;

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Dashboard", "icon": Icons.dashboard_rounded},
    {"title": "Portfolio", "icon": Icons.pie_chart_rounded},
    {"title": "Market", "icon": Icons.show_chart_rounded},
    {"title": "Alerts", "icon": Icons.notifications_active_rounded},
  ];

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'text':
          'Hello! I\'m your AI financial assistant. How can I help you today?',
      'isUser': false,
      'time': '09:15 AM',
    },
  ];
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      await MarketService.ensureUserRow();
    } catch (e) {
      print("ensureUserRow error: $e");
    }
    await loadUserStocks();
    await loadStocks();
  }

  Future<void> loadStocks() async {
    try {
      final stocks = await MarketService.getStocks();

      setState(() {
        marketStocks = stocks;
        isLoadingStocks = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoadingStocks = false;
      });
    }
  }

  Future<void> loadUserStocks() async {
    setState(() {
      isLoadingUserStocks = true;
    });

    try {
      final stocks = await MarketService.getUserStocks();

      setState(() {
        userStocks = stocks;
        isLoadingUserStocks = false;
      });
    } catch (e) {
      print("User stocks error: $e");

      setState(() {
        isLoadingUserStocks = false;
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _chatMessages.add({
        'text': _chatController.text,
        'isUser': true,
        'time': TimeOfDay.now().format(context),
      });
    });

    _chatController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatMessages.add({
          'text':
              'I\'m analyzing your request and checking live market signals.',
          'isUser': false,
          'time': TimeOfDay.now().format(context),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1200;
    final bool isTablet = size.width >= 700 && size.width < 1200;

    return Scaffold(
      backgroundColor: const Color(0xFF060A14),
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: const Color(0xFF0A1020),
              child: SafeArea(child: _buildSidebar()),
            )
          : null,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMobileChatPanel = !_showMobileChatPanel;
                    });
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: glowCircle(const Color(0xFF8B5CF6).withOpacity(0.25), 320),
          ),
          Positioned(
            bottom: -180,
            right: -180,
            child: glowCircle(Colors.blue.withOpacity(0.18), 420),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(width: 280, child: _buildSidebar()),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _buildSelectedPage(
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                ),
                if (isDesktop && _showDesktopChat)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: SizedBox(width: 380, child: _buildAIChatPanel()),
                  ),
              ],
            ),
          ),
          if (isDesktop && !_showDesktopChat)
            Positioned(
              right: 30,
              bottom: 30,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF8B5CF6),
                onPressed: () {
                  setState(() {
                    _showDesktopChat = true;
                  });
                },
                child: const Icon(Icons.chat_rounded, color: Colors.white),
              ),
            ),
          if (_showMobileChatPanel && !isDesktop)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showMobileChatPanel = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: size.height * 0.78,
                        margin: const EdgeInsets.all(16),
                        child: _buildAIChatPanel(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage({required bool isDesktop, required bool isTablet}) {
    switch (selectedIndex) {
      case 0:
        return _dashboardPage(isDesktop, isTablet);
      case 1:
        return _portfolioPage();
      case 2:
        return _marketPage();
      case 3:
        return _alertsPage();

      default:
        return _dashboardPage(isDesktop, isTablet);
    }
  }

  Widget _dashboardPage(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopbar(),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 1150;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildNewsSection()),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildMarketOverview(),
                          const SizedBox(height: 24),
                          _buildYourPortfolioCard(),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildNewsSection(),
                  const SizedBox(height: 24),
                  _buildMarketOverview(),
                  const SizedBox(height: 24),
                  _buildYourPortfolioCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    final newsItems = [
      {
        "title": "Fed Signals Possible Rate Pause",
        "source": "Bloomberg",
        "time": "12 min ago",
        "description":
            "Markets reacted positively after the Federal Reserve hinted at a possible pause in future interest rate hikes.",
        "color": Colors.blue,
        "icon": Icons.trending_up_rounded,
      },
      {
        "title": "Tesla Surges After Delivery Report",
        "source": "Reuters",
        "time": "25 min ago",
        "description":
            "Tesla shares gained momentum following stronger-than-expected delivery numbers this quarter.",
        "color": const Color(0xFF8B5CF6),
        "icon": Icons.electric_car_rounded,
      },
      {
        "title": "Oil Prices Continue Rising",
        "source": "CNBC",
        "time": "41 min ago",
        "description":
            "Energy sector stocks climbed as crude oil prices extended gains amid supply concerns.",
        "color": Colors.orange,
        "icon": Icons.local_fire_department_rounded,
      },
      {
        "title": "AI Stocks Lead Tech Rally",
        "source": "MarketWatch",
        "time": "1 hour ago",
        "description":
            "Artificial intelligence companies continue outperforming broader technology indexes.",
        "color": Colors.green,
        "icon": Icons.memory_rounded,
      },
    ];

    return glassContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Latest News",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = newsItems[index];

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (item["color"] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        item["icon"] as IconData,
                        color: item["color"] as Color,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 8,
                            children: [
                              Text(
                                item["title"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                item["time"] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item["source"] as String,
                            style: TextStyle(
                              color: item["color"] as Color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            item["description"] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYourPortfolioCard() {
    return glassContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Your Portfolio",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "${userStocks.length} selected assets",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 28),

          if (isLoadingUserStocks)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              ),
            )
          else if (userStocks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 60,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No portfolio assets yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userStocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final stock = userStocks[index];

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          stock.symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.companyName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              stock.sector,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _portfolioPage() {
    final filteredUserStocks = _searchQuery.isEmpty
        ? userStocks
        : userStocks
              .where(
                (s) =>
                    s.symbol.toLowerCase().contains(_searchQuery) ||
                    s.companyName.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopbar(),
          const SizedBox(height: 24),
          glassContainer(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Portfolio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isEmpty
                      ? "You have ${userStocks.length} selected stocks"
                      : "${filteredUserStocks.length} of ${userStocks.length} stocks match \"$_searchQuery\"",
                  style: const TextStyle(color: Colors.white60, fontSize: 15),
                ),
                const SizedBox(height: 28),

                // Loading durumu
                if (isLoadingUserStocks)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  )
                // Hisse yoksa
                else if (filteredUserStocks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.inbox_outlined
                                : Icons.search_off_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? "No stocks selected yet"
                                : "No match for \"$_searchQuery\"",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? "Go to Market tab to add stocks"
                                : "Try a different symbol or company",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Hisseler varsa
                else
                  Column(
                    children: filteredUserStocks.map((stock) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF6D28D9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                stock.symbol,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stock.companyName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    stock.sector,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final currentUser = Supabase
                                    .instance
                                    .client
                                    .auth
                                    .currentUser;
                                if (currentUser == null) return;
                                try {
                                  await MarketService.saveUserStock(
                                    userId: currentUser.id,
                                    symbol: stock.symbol,
                                    companyName: stock.companyName,
                                    sector: stock.sector,
                                    isSelected: false,
                                  );
                                  await loadUserStocks();
                                  await loadStocks();
                                } catch (e) {
                                  print("Error removing stock: $e");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Unfollow",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketPage() {
    final filtered = _searchQuery.isEmpty
        ? marketStocks
        : marketStocks
              .where(
                (s) =>
                    s.symbol.toLowerCase().contains(_searchQuery) ||
                    s.companyName.toLowerCase().contains(_searchQuery),
              )
              .toList();

    final financeStocks = filtered
        .where((s) => s.sector == "Finance")
        .toList();

    final techStocks = filtered
        .where((s) => s.sector.contains("Technology"))
        .toList();

    final energyStocks = filtered
        .where(
          (s) => s.sector.contains("Energy") || s.sector.contains("Utilities"),
        )
        .toList();

    final otherStocks = filtered
        .where(
          (s) =>
              s.sector != "Finance" &&
              !s.sector.contains("Technology") &&
              !s.sector.contains("Energy") &&
              !s.sector.contains("Utilities"),
        )
        .toList();

    Widget buildStockList(List<MarketStock> stocks) {
      if (stocks.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              "No stocks available",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    stock.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.sector,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    final currentUser =
                        Supabase.instance.client.auth.currentUser;

                    if (currentUser == null) return;

                    final newValue = !stock.isSelected;

                    setState(() {
                      stock.isSelected = newValue;
                    });

                    try {
                      await MarketService.saveUserStock(
                        userId: currentUser.id,
                        symbol: stock.symbol,
                        companyName: stock.companyName,
                        sector: stock.sector,
                        isSelected: newValue,
                      );

                      // Portfolio'yu yenile
                      await loadUserStocks();
                    } catch (e) {
                      print("Error saving stock: $e");

                      // Hata olursa eski haline döndür
                      setState(() {
                        stock.isSelected = !newValue;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 64,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: stock.isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            )
                          : null,
                      color: stock.isSelected
                          ? null
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: stock.isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: stock.isSelected
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              stock.isSelected ? Icons.check : Icons.close,
                              size: 16,
                              color: stock.isSelected
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return DefaultTabController(
      length: 4,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopbar(),
            const SizedBox(height: 24),
            glassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Market Stocks",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: "Finance"),
                        Tab(text: "Tech"),
                        Tab(text: "Energy"),
                        Tab(text: "Other"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        buildStockList(financeStocks),
                        buildStockList(techStocks),
                        buildStockList(energyStocks),
                        buildStockList(otherStocks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertsPage() {
    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopbar(),
            const SizedBox(height: 24),
            glassContainer(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Alerts Center",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DefaultTabController(
                    length: 2,
                  child: Column(
                    children: [
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(icon: Icon(Icons.warning_amber_rounded), text: "Risk Alerts"),
                            Tab(icon: Icon(Icons.language_rounded), text: "Tweets & News"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 500,
                        child: TabBarView(
                          children: [
                            // TAB 1: Gerçek Supabase verisi
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _fetchAlerts(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "Hata: ${snapshot.error}",
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
                                  );
                                }
                                final alerts = snapshot.data ?? [];
                                if (alerts.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "Su an riskli bir uyari yok.",
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                  );
                                }
                                return ListView(
                                  children: alerts.map((a) {
                                    final level = (a['level'] ?? '').toString();
                                    final color = level == 'YUKSEK'
                                        ? Colors.red
                                        : level == 'ORTA'
                                        ? Colors.orange
                                        : Colors.green;
                                    return activityItem(
                                      "${a['symbol']} - ${a['risk_score']}/100 ($level)",
                                      (a['reason'] ?? '').toString(),
                                      color,
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            // TAB 2: Tweets & News
                            ListView(
                              children: [
                                _alertCard(
                                  title: "Tesla Mention Spike",
                                  source: "Twitter/X",
                                  description: "Social sentiment increased by 34% after earnings rumors.",
                                  time: "1 min ago",
                                  color: const Color(0xFF8B5CF6),
                                  icon: Icons.trending_up_rounded,
                                ),
                                _alertCard(
                                  title: "Breaking Market News",
                                  source: "Bloomberg",
                                  description: "Oil prices jump after unexpected supply chain disruption.",
                                  time: "7 min ago",
                                  color: Colors.orange,
                                  icon: Icons.newspaper_rounded,
                                ),
                                _alertCard(
                                  title: "Banking Sector Trend",
                                  source: "Reuters",
                                  description: "Large institutions show increased short-term accumulation.",
                                  time: "15 min ago",
                                  color: Colors.cyan,
                                  icon: Icons.insights_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _alertCard({
    required String title,
    required String source,
    required String description,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  source,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return glassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Aizanoi",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return sidebarItem(
                  index,
                  menuItems[index]["title"],
                  menuItems[index]["icon"],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B5CF6),
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$firstName $lastName",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "Log Out",
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopbar() {
    return glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search stocks by symbol or company...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white54,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          iconButton(Icons.notifications_none_rounded),
          const SizedBox(width: 10),
          iconButton(Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return glassContainer(
      padding: const EdgeInsets.all(32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 800;

          return Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: compact ? constraints.maxWidth : 500,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        "Markets Open",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Portfolio Performance",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 32 : 42,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "\$124,567.89",
                          style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontSize: compact ? 28 : 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "+12.5%",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "AI detected strong opportunities in semiconductor and renewable energy sectors.",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        gradientButton(
                          "View Opportunities",
                          Icons.trending_up_rounded,
                        ),
                        outlineButton(
                          "Portfolio Details",
                          Icons.pie_chart_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.white24,
                    size: 120,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid({required bool isMobile, required bool isTablet}) {
    int count = isMobile ? (isTablet ? 2 : 1) : 2;

    final items = [
      {
        "title": "Active Bots",
        "value": "12",
        "icon": Icons.smart_toy_rounded,
        "color": const Color(0xFF8B5CF6),
        "subtitle": "+3 this week",
      },
      {
        "title": "Open Positions",
        "value": "8",
        "icon": Icons.account_balance_wallet_rounded,
        "color": Colors.blue,
        "subtitle": "\$45K total",
      },
      {
        "title": "Win Rate",
        "value": "68%",
        "icon": Icons.percent_rounded,
        "color": Colors.green,
        "subtitle": "Last 30 days",
      },
      {
        "title": "Risk Score",
        "value": "7.2",
        "icon": Icons.warning_amber_rounded,
        "color": Colors.orange,
        "subtitle": "Moderate",
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 20;
        final double availableWidth = constraints.maxWidth;
        final double itemWidth =
            (availableWidth - ((count - 1) * spacing)) / count;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: statCard(
                item["title"] as String,
                item["value"] as String,
                item["icon"] as IconData,
                item["color"] as Color,
                item["subtitle"] as String,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMarketOverview() {
    return glassContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Market Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          marketItem("S&P 500", "4,567.89", "+0.8%", Colors.green, "SPX"),
          marketItem("NASDAQ", "14,234.56", "+1.2%", Colors.green, "IXIC"),
          marketItem("BTC/USD", "67,432.10", "+2.4%", Colors.green, "BTC"),
        ],
      ),
    );
  }

  Widget _buildActivityPanel() {
    return glassContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          activityItem(
            "Trade Executed",
            "Bought 50 shares of NVDA at \$875.20",
            Colors.green,
          ),
          activityItem(
            "Risk Alert",
            "Semiconductor volatility increased by 15%",
            Colors.orange,
          ),
          activityItem(
            "AI Analysis",
            "Portfolio rebalancing recommended",
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatPanel() {
    return glassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.assistant_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your AI Assistant",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDesktopChat = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];

                return _buildChatMessage(
                  message["text"],
                  message["isUser"],
                  message["time"],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Ask anything...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String text, bool isUser, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF8B5CF6).withOpacity(0.18)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(int index, String title, IconData icon) {
    final bool selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });

            if (MediaQuery.of(context).size.width < 1200) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return SizedBox(
      width: double.infinity,
      child: glassContainer(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget marketItem(
    String name,
    String price,
    String change,
    Color color,
    String symbol,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                symbol,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.55)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                change,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAlerts() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    // Once kullanicinin takip ettigi semboller
    final portfolio = await supabase
        .from('user_portfolios')
        .select('symbol')
        .eq('user_id', user.id);

    final symbols = (portfolio as List)
        .map((e) => e['symbol']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    if (symbols.isEmpty) return [];

    // Sadece o sembollerin riskleri
    final data = await supabase
        .from('risk_scores')
        .select('symbol, risk_score, level, reason, created_at')
        .inFilter('symbol', symbols)
        .gte('risk_score', 70)
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(data);
  }

  Widget activityItem(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white60, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white38,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget glassContainer({required Widget child, required EdgeInsets padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }

  Widget gradientButton(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget outlineButton(String title, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget iconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget glowCircle(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
