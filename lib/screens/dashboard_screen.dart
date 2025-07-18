import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/dao/transaction_dao.dart';
import '/dao/goal_dao.dart';
import '/models/goal.dart';
import 'menu_screen.dart';
import 'goals_screen.dart';

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

    setState(() {
      totalIncome = income;
      totalExpenses = expenses;
      expensesByCategory = categories;
      goals = goalsList;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.pink),
            onPressed: _loadData,
          ),
        ],
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
        const Text(
          'Saldo atual',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${balance.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Recebidos',
                    style: TextStyle(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.pink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Gastos',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      const Text(
        'Análises',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 300,
        child: PageView(
          controller: PageController(viewportFraction: 0.9),
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


  Widget _buildExpensesChart() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.pink.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        const Text(
          'Tabela de gastos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: expensesByCategory.isEmpty
              ? const Center(child: Text('Nenhum gasto registrado'))
              : PieChart(
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
      ],
    ),
  );
}

  Widget _buildIncomeVsExpensesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Receitas vs Gastos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: totalIncome,
                    title: 'Receitas\nR\$ ${totalIncome.toStringAsFixed(2)}',
                    color: Colors.green,
                    radius: 80,
                  ),
                  PieChartSectionData(
                    value: totalExpenses,
                    title: 'Gastos\nR\$ ${totalExpenses.toStringAsFixed(2)}',
                    color: Colors.red,
                    radius: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Progresso das Metas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                            Text(
                              goal.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: goal.progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                goal.isCompleted ? Colors.green : Colors.pink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(goal.progress * 100).toStringAsFixed(1)}% - R\$ ${goal.currentAmount.toStringAsFixed(2)} / R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
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

  Widget _buildQuickActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.arrow_back,
            () {
            },
          ),
          _buildActionButton(
            Icons.arrow_forward,
            () {
            },
          ),
        ],
      ),
    ],
  );
}

Widget _buildActionButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
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
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Registros',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Metas',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
            );
            break;
          case 1:
            break;
          case 2: 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalsScreen()),
            );
            break;
        }
      },
    );
  }
}
