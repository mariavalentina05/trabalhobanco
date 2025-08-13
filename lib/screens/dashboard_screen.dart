import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '/dao/transaction_dao.dart';
import '/dao/goal_dao.dart';
import '/models/goal.dart';
import '/models/transaction.dart';
import 'menu_screen.dart';
import 'goals_screen.dart';
import 'transactions_screen.dart';

final NumberFormat realFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionDao _transactionDao = TransactionDao();
  final GoalDao _goalDao = GoalDao();

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  Map<String, double> expensesByCategory = {};
  List<Goal> goals = [];
  List<Transaction> recentTransactions = [];

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final income = await _transactionDao.getTotalByType('income');
    final expenses = await _transactionDao.getTotalByType('expense');
    final categories = await _transactionDao.getExpensesByCategory();
    final goalsList = await _goalDao.getAllGoals();
    final allTransactions = await _transactionDao.getAllTransactions();

    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    final recent = allTransactions.take(5).toList();

    setState(() {
      totalIncome = income;
      totalExpenses = expenses;
      expensesByCategory = categories;
      goals = goalsList;
      recentTransactions = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(balance),
            const SizedBox(height: 20),
            _buildChartsCarousel(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
            const SizedBox(height: 20),
            _buildExpenseHistory(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Saldo atual', style: TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            realFormat.format(balance),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Recebidos', style: TextStyle(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(realFormat.format(totalIncome), style: const TextStyle(color: Colors.pink, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(realFormat.format(totalExpenses), style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Análises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildExpensesChart(),
              _buildIncomeVsExpensesChart(),
              _buildGoalsChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          Icons.arrow_back,
          _currentPage > 0
              ? () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          Icons.arrow_forward,
          _currentPage < 2
              ? () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.pink : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Transações Recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
              },
              child: const Text('Ver todas', style: TextStyle(color: Colors.pink, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
          ),
          child: recentTransactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma transação encontrada', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 14))),
                          Expanded(flex: 2, child: Text('Valor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 14), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 14), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    ...recentTransactions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final transaction = entry.value;
                      final isLast = index == recentTransactions.length - 1;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                          borderRadius: isLast ? const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)) : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(transaction.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${transaction.type == 'income' ? '+' : '-'} ${realFormat.format(transaction.amount)}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: transaction.type == 'income' ? Colors.green : Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildExpensesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Tabela de gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: expensesByCategory.isEmpty
                ? const Center(child: Text('Nenhum gasto registrado'))
                : Column(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: expensesByCategory.entries.map((entry) {
                              final colors = [
                                Colors.pink.shade300,
                                Colors.pink.shade400,
                                Colors.pink.shade500,
                                Colors.pink.shade200,
                                Colors.pink.shade600,
                              ];
                              final index = expensesByCategory.keys.toList().indexOf(entry.key);
                              return PieChartSectionData(
                                value: entry.value,
                                title: '',
                                color: colors[index % colors.length],
                                radius: 80,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: expensesByCategory.entries.map((entry) {
                          final colors = [
                            Colors.pink.shade300,
                            Colors.pink.shade400,
                            Colors.pink.shade500,
                            Colors.pink.shade200,
                            Colors.pink.shade600,
                          ];
                          final index = expensesByCategory.keys.toList().indexOf(entry.key);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${entry.key} (R\$ ${entry.value.toStringAsFixed(2)})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
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

  Widget _buildIncomeVsExpensesChart() {
    final sections = [
      PieChartSectionData(
        value: totalIncome,
        title: '',
        color: Colors.pink.shade400,
        radius: 80,
      ),
      PieChartSectionData(
        value: totalExpenses,
        title: '',
        color: Colors.pink.shade200,
        radius: 80,
      ),
    ];
    final legends = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.pink.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text('Receitas (R\$ ${totalIncome.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12)),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.pink.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text('Gastos (R\$ ${totalExpenses.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12)),
        ],
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Receitas vs Gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(sections: sections),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: legends,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)]),
      child: Column(
        children: [
          const Text('Progresso das Metas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: goals.isEmpty
                ? const Center(child: Text('Nenhuma meta cadastrada'))
                : ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: goal.progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(goal.isCompleted ? Colors.green : Colors.pink),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(goal.progress * 100).toStringAsFixed(1)}% - ${realFormat.format(goal.currentAmount)} / ${realFormat.format(goal.targetAmount)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Registros'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
            break;
          case 1:
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen()));
            break;
        }
      },
    );
  }

  // Supondo que você tenha uma lista chamada expenses
  Widget buildExpenseHistoryTable(List<Transaction> expenses, {bool darkMode = false}) {
    if (expenses.isEmpty) {
      return const Center(child: Text('Nenhum gasto registrado.'));
    }
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final e = expenses[expenses.length - 1 - i];
        return Card(
          color: darkMode
              ? const Color.fromARGB(255, 31, 31, 31)
              : const Color.fromARGB(247, 246, 244, 255),
          child: ListTile(
            leading: Icon(
              Icons.money,
              color: darkMode ? Colors.white : Colors.black,
            ),
            title: Text(
              currencyFormatter.format(e.amount),
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              '${e.date.day}/${e.date.month}/${e.date.year}',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico de Gastos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        buildExpenseHistoryTable(recentTransactions),
      ],
    );
  }
}
