import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type;

  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = '';
  final List<Map<String, dynamic>> _transactions = [];

  final List<String> _incomeCategories = ['Salário', 'Freelance', 'Investimentos', 'Outros'];
  final List<String> _expenseCategories = ['Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Educação', 'Lazer', 'Outros'];

  @override
  void initState() {
    super.initState();
    final categories = widget.type == 'income' ? _incomeCategories : _expenseCategories;
    _selectedCategory = categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    final title = isIncome ? 'Registrar Recebimentos' : 'Registrar Gastos';
    final categories = isIncome ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('Nome', _descriptionController),
                  const SizedBox(height: 12),
                  _buildTextField('Valor (R\$)', _amountController, isNumber: true),
                  const SizedBox(height: 12),
                  _buildDropdown(categories),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                      child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text('Nenhum registro ainda'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      return Dismissible(
                        key: Key(t['date'].toString()), 
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _transactions.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transação excluída!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(t['description']),
                          subtitle: Text(t['category']),
                          trailing: Text(
                            '${isIncome ? '' : '-'}R\$ ${t['amount'].toStringAsFixed(2)}',
                            style: TextStyle(color: isIncome ? Colors.green : Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        if (isNumber && double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
        return null;
      },
    );
  }

  Widget _buildDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      decoration: InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      setState(() {
        _transactions.add({
          'description': _descriptionController.text,
          'amount': amount,
          'category': _selectedCategory,
          'date': DateTime.now(),
        });
      });

      _descriptionController.clear();
      _amountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.type == 'income' ? 'Recebimento' : 'Gasto'} adicionado!')),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
