import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(datePicked: DateTime.now()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.dark()),
        home: const MyHomePage(title: 'Today'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Food> foodList = [];
  final DateTime datePicked;
  final DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  MyAppState({required this.datePicked});

  (int, int) calculateCalories(List foodList) {
    int totalCalories = 0;
    int totalFood = 0;
    for (Food food in foodList) {
      totalCalories += food.calories * food.count;
      totalFood += food.count;
    }
    return (totalCalories, totalFood);
  }

  bool dateCheck() {
    if (datePicked.compareTo(today) == 0) {
      return true;
    } else {
      return false;
    }
  }

  void addFood(Food food) {
    foodList.add(food);
    notifyListeners();
  }

  void removeFood(Food food) {
    foodList.remove(food);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final myController = TextEditingController();
  Food addFoodTrack = Food(title: "title", count: 1, calories: 1);

  Future _showFoodAdderBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Food"),
          content: _showAmountHad(),
          key: Key("add_food_modal"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context), // passing false
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: (() => Navigator.pop(context)),
              child: Text('Ok', key: Key("add_food_modal_submit")),
            ),
          ],
        );
      },
    );
  }

  Widget _showAmountHad() {
    return Scaffold(body: Column(children: <Widget>[_showAddFoodForm()]));
  }

  Widget _showAddFoodForm() {
    return Form(
      key: GlobalKey<FormState>(),
      child: Column(
        children: [
          TextFormField(
            key: Key('add_food_modal_food_name_field'),
            decoration: const InputDecoration(
              labelText: "Name *",
              hintText: "Please enter food name",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter the food name";
              }
              return null;
            },
            onChanged: (value) {
              addFoodTrack.title = value;
            },
          ),
          TextFormField(
            key: Key('add_food_modal_calorie_field'),
            decoration: const InputDecoration(
              labelText: "Calories *",
              hintText: "Please enter a calorie amount",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a calorie amount";
              }
              return null;
            },
            keyboardType: TextInputType.number,
            onChanged: (value) {
              try {
                addFoodTrack.calories = int.parse(value);
              } catch (e) {
                addFoodTrack.calories = 0;
              }
            },
          ),
          TextFormField(
            key: Key('add_food_modal_amount_field'),
            decoration: const InputDecoration(
              labelText: "Amount *",
              hintText: "Please enter food amount",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter food amount";
              }
              return null;
            },
            onChanged: (value) {
              try {
                addFoodTrack.count = int.parse(value);
              } catch (e) {
                addFoodTrack.count = 0;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(child: Day()),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              addFoodTrack = Food(title: "title", count: 0, calories: 0);
              appState.addFood(addFoodTrack);
              _showFoodAdderBox(context);
            },
            tooltip: 'Add New Food',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}

class Food {
  String title;
  int calories;
  int count;

  Food({required this.title, required this.count, required this.calories});
}

// ignore: must_be_immutable
class Day extends StatelessWidget {
  final DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Day({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: Text("Stats")),
        ListTile(
          leading: Text("Total Calories:"),
          title: Text(
            appState.calculateCalories(appState.foodList).$1.toString(),
          ),
        ),
        ListTile(
          leading: Text("Total Food:"),
          title: Text(
            appState.calculateCalories(appState.foodList).$2.toString(),
          ),
        ),
      ],
    );
  }
}

class DayList {
  List<Day> dayList = [];
  DateTime datePicked;

  DayList({required this.datePicked});
}
