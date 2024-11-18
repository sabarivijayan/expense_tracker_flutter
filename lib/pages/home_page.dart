import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helper_function.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<int, double>>? _monthlyTotalsFuture;

  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshGraphData();
    super.initState();
  }

  void refreshGraphData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
  }

  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Expense Name"),
                  ),
                  TextField(
                    controller: amountController,
                    decoration:
                        const InputDecoration(hintText: "Expense Amount"),
                  ),
                ],
              ),
              actions: [_cancelButton(), _createNewExpenseButton()],
            ));
  }

  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  ),
                ],
              ),
              actions: [_cancelButton(), _editExpenseButton(expense)],
            ));
  }

  void openDeleteBox(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Expense"),
              actions: [_cancelButton(), _deleteExpenseButton(expense.id)],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      int monthCount =
          calculateMonthCount(startYear, startMonth, currentMonth, currentYear);

      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final monthlyTotals = snapshot.data ?? {};
                        List<double> monthlySummary = List.generate(
                            monthCount,
                            (index) =>
                                monthlyTotals[startMonth + index] ?? 0.0);
                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        return const Text("Loading.....");
                      }
                    }),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: value.allExpenses.length,
                  itemBuilder: (context, index) {
                    Expense individualExpense = value.allExpenses[index];

                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  Widget _createNewExpenseButton() {
    return MaterialButton(
        onPressed: () async {
          if (nameController.text.isNotEmpty &&
              amountController.text.isNotEmpty) {
            Navigator.pop(context);

            Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now(),
            );

            await context.read<ExpenseDatabase>().createNewExpense(newExpense);

            refreshGraphData();


            nameController.clear();
            amountController.clear();
          }
        },
        child: Text('Add expense'));
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          int existingId = expense.id;

          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          refreshGraphData();
        }
      },
      child: const Text("Save"),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshGraphData();
      },
      child: const Text("Delete"),
    );
  }
}
