Entendido — vou criar um README no estilo usado em projetos do GitHub, incluindo **descrições com ícones, blocos de código**, e trechos retirados dos arquivos que você me enviou para ilustrar como funciona.

---

# 📄 README.md (Estilo GitHub)

````markdown
# 💰 Finance Tracker App

Um aplicativo **Flutter** para **gerenciamento de finanças pessoais**, permitindo que o usuário registre transações, defina metas financeiras e acompanhe o progresso através de um **painel intuitivo**.

---

## ✨ Funcionalidades

- 📊 **Dashboard**: visão geral do saldo e progresso das metas.
- ➕ **Adicionar transações**: entradas e saídas salvas no banco local.
- 📜 **Lista de transações**: histórico completo.
- 🎯 **Metas financeiras**: criação e acompanhamento de objetivos.
- 📂 **Banco de dados local SQLite** para persistência offline.
- 📱 Interface responsiva.

---

## 🖼️ Estrutura do Projeto

```plaintext
lib/
│── main.dart                  # Ponto de entrada do app
│── database_service.dart      # Serviço para SQLite
│── transaction.dart           # Modelo de transação
│── goal.dart                  # Modelo de meta
│── screens/
│   ├── welcome_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── transactions_screen.dart
│   ├── goals_screen.dart
│   └── menu_screen.dart
````

---

## 🗄️ Banco de Dados

O `database_service.dart` gerencia as operações no SQLite:

```dart
Future<Database> getDatabase() async {
  final path = join(await getDatabasesPath(), 'finance_tracker.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY, title TEXT, amount REAL, date TEXT)',
      );
      db.execute(
        'CREATE TABLE goals(id INTEGER PRIMARY KEY, title TEXT, targetAmount REAL, currentAmount REAL)',
      );
    },
    version: 1,
  );
}
```

---

## 🚀 Como Executar

### 1️⃣ Pré-requisitos

* Flutter instalado ([Guia oficial](https://flutter.dev/docs/get-started/install))
* Emulador Android/iOS ou dispositivo físico conectado

### 2️⃣ Instalar dependências

```bash
flutter pub get
```

### 3️⃣ Executar o app

```bash
flutter run
```

---

## 🖥️ Exemplo de Uso

Trecho do `add_transaction_screen.dart` mostrando o salvamento no banco:

```dart
void _saveTransaction() async {
  final newTransaction = Transaction(
    title: _titleController.text,
    amount: double.parse(_amountController.text),
    date: DateTime.now(),
  );

  await DatabaseService.instance.insertTransaction(newTransaction);
  Navigator.pop(context, true);
}
```

---

## 📦 Dependências Principais

* **sqflite** — Banco de dados SQLite
* **path** — Manipulação de caminhos
* **flutter/material.dart** — UI

---

## 📸 Fluxo de Telas

1. **Boas-vindas**
2. **Dashboard**
3. **Adicionar Transação** / **Metas** / **Lista**
4. **Menu Lateral**

---

## 👤 Autor

Desenvolvido por Maria Valentina, Maria Marques e Camilla Pecinatto

```

---

Se quiser, já posso **gerar esse README estilizado como PDF** também, com formatação preservada, para você ter a versão offline.  
Quer que eu já gere o PDF dessa versão estilizada?
```
