// imports
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const MyRecipes(),
    );
  }
}

// home page of the application
class MyRecipes extends StatefulWidget {
  const MyRecipes({super.key});

  @override
  State<MyRecipes> createState() => _MyRecipesState();
}

class _MyRecipesState extends State<MyRecipes> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // fetch recipes from storage
  List<dynamic> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('recipe');

    if (data != null && data.isNotEmpty) {
      setState(() {
        _recipes = jsonDecode(data);
      });
    }
  }

  // set free controller
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // only show recipes that match the search
    final filtered = _recipes
        .where((r) => r["name"].toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Meine Rezepte',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
        child: Column(
          children: [
            SearchBar(
              controller: _searchController,
              hintText: 'Rezept suchen...',
              elevation: const WidgetStatePropertyAll(0),

              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainer,
              ),

              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),

              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),

              onChanged: (value) => setState(() => _query = value),
              leading: const Icon(Icons.search),
            ),

            // Recipe list
            const SizedBox(height: 32.0),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetail(recipe: filtered[index]),
                          ),
                        );

                        if (!mounted) return;
                        await _loadRecipes();
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),

                        // Recipe title and description
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // title of the recipe
                                  Text(
                                    filtered[index]['name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),

                                  // space between title and description
                                  const SizedBox(height: 4.0),

                                  // description of the recipe
                                  Text(
                                    filtered[index]['ingredients'].join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // right arrow icon
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: 'SOON'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRecipe()),
          );

          await _loadRecipes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// detail page for a recipe
class RecipeDetail extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetail({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          recipe['name'],
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: "Rezept löschen",
            onPressed: () async {
              // current data
              final prefs = await SharedPreferences.getInstance();
              final data = prefs.getString('recipe');
              if (data == null) return;

              // search for right id, then delete
              List recipes = jsonDecode(data);
              recipes.removeWhere((r) => r["id"] == recipe["id"]);
              await prefs.setString('recipe', jsonEncode(recipes));

              // go back to my recipes
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ingredients section
            Text(
              'Zutaten',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8.0),
            ...recipe['ingredients'].asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24.0),
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 16.0),
                    Text(
                      '${recipe['amount'][entry.key]} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              ),
            ),

            // space between ingredients and steps
            const SizedBox(height: 32.0),

            // steps section
            Text(
              'Zubereitung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8.0),
            ...recipe['steps'].asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24.0),
                    SizedBox(
                      width: 24.0,
                      child: Text(
                        '${entry.key + 1}.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: 'SOON'),
        ],
      ),
    );
  }
}

// page to create recipes
class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  // error variables
  String? _nameError;
  String? _ingredientErrors;
  String? _stepErrors;

  // controller for name text-field
  final TextEditingController _nameController = TextEditingController();

  // controller and focus node for every text-field (ingredient + steps)
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  final List<FocusNode> _focusNodes = [FocusNode()];
  final List<FocusNode> _stepFocusNodes = [FocusNode()];

  // attach new empty text-field and focus on it
  void _addField(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    // add new controller and focus node to list
    setState(() {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes.last.requestFocus();
    });
  }

  // remove text-field at index and focus the field before
  void _removeField(
    int i,
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    if (controllers.length <= 1) {
      return; // not less then 1 ingredient
    }

    // remove controller + focus node
    controllers[i].dispose();
    focusNodes[i].dispose();

    setState(() {
      controllers.removeAt(i);
      focusNodes.removeAt(i);
    });

    // focus previous field
    if (i > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNodes[i - 1].requestFocus();
      });
    }
  }

  // clean page
  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final sc in _stepControllers) {
      sc.dispose();
    }
    for (final sf in _stepFocusNodes) {
      sf.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // implement text / colorsheme faster
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Neues Rezept',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: ListView(
          children: [
            // recipe name section
            Text(
              'Name',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // space + text-field
            const SizedBox(height: 12.0),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Rezeptname...',
                errorText: _nameError,
              ),
            ),

            const SizedBox(height: 48.0),

            // recipe ingredient section
            Text(
              'Zutaten',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // space + List with text-fields
            const SizedBox(height: 12.0),
            ...List.generate(_ingredientControllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),

                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    // delete text-field on deleting in a empty input
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _ingredientControllers[i].text.isEmpty) {
                      _removeField(i, _ingredientControllers, _focusNodes);
                    }
                  },

                  child: TextField(
                    controller: _ingredientControllers[i],
                    focusNode: _focusNodes[i],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'z.B. 150g Zucker',
                      errorText: _ingredientErrors,
                      suffixIcon: _ingredientControllers.length > 1
                          // remove text-field
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeField(
                                i,
                                _ingredientControllers,
                                _focusNodes,
                              ),
                            )
                          : null,
                    ),

                    // create new textfield when pressing enter
                    onSubmitted: (_) =>
                        _addField(_ingredientControllers, _focusNodes),
                  ),
                ),
              );
            }),

            // space + add ingredient button
            const SizedBox(height: 4.0),
            TextButton.icon(
              onPressed: () => _addField(_ingredientControllers, _focusNodes),
              icon: const Icon(Icons.add),
              label: const Text('Zutat hinzufügen'),
            ),

            // recipe ingredient section
            const SizedBox(height: 32.0),
            Text(
              'Zubereitung',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12.0),
            ...List.generate(_stepControllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: KeyboardListener(
                  focusNode: FocusNode(),

                  onKeyEvent: (event) {
                    // delete text-field on deleting in a empty input
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _stepControllers[i].text.isEmpty) {
                      _removeField(i, _stepControllers, _stepFocusNodes);
                    }
                  },

                  child: TextField(
                    controller: _stepControllers[i],
                    focusNode: _stepFocusNodes[i],
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText:
                          'Hier kannst du den ${i + 1}. Schritt beschreiben.',
                      errorText: _stepErrors,
                      suffixIcon: _stepControllers.length > 1
                          // remove text-field
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeField(
                                i,
                                _stepControllers,
                                _stepFocusNodes,
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.contains('\n')) {
                        _stepControllers[i].text = value.replaceAll('\n', '');
                        _stepControllers[i]
                            .selection = TextSelection.fromPosition(
                          TextPosition(offset: _stepControllers[i].text.length),
                        );

                        _addField(_stepControllers, _stepFocusNodes);
                      }
                    },
                  ),
                ),
              );
            }),

            // space + add step button
            const SizedBox(height: 4.0),
            TextButton.icon(
              onPressed: () => _addField(_stepControllers, _stepFocusNodes),
              icon: const Icon(Icons.add),
              label: const Text('Schritt hinzufügen'),
            ),

            // add recipe button
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),

              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),

                child: TextButton(
                  onPressed: () async {
                    // array to save all amount &  ingredients
                    final amount = <String>[];
                    final ingredients = <String>[];
                    final id = const Uuid().v4();

                    // seperate ingriedients input by amount & ingredient
                    for (final controller in _ingredientControllers) {
                      // ingredient input
                      final input = controller.text.trim();

                      // front seperate
                      final forward = RegExp(
                        r'^(\d+[\.,]?\d*\s*(?:g|kg|ml|l|EL|TL|Pck\.|Prise|Stück|St\.|Tasse)?\.?)\s+(.+)$',
                        caseSensitive: false,
                      );

                      // back seperate
                      final backward = RegExp(
                        r'^(.+?)\s+(\d+[\.,]?\d*\s*(?:g|kg|ml|l|EL|TL|Pck\.|Prise|Stück|St\.|Tasse)?\.?)$',
                        caseSensitive: false,
                      );

                      // get front and back
                      final m1 = forward.firstMatch(input);
                      final m2 = backward.firstMatch(input);

                      // if front is amoutnt
                      if (m1 != null) {
                        amount.add(m1.group(1)!);
                        ingredients.add(m1.group(2)!);
                      }
                      // if back is amount
                      else if (m2 != null) {
                        ingredients.add(m2.group(1)!);
                        amount.add(m2.group(2)!);
                      }
                      // if no amount
                      else {
                        // fallback!
                        ingredients.add(input);
                        amount.add('');
                      }
                    }

                    // only load filled inputs
                    final filledIngredients = ingredients
                        .where((c) => c.isNotEmpty)
                        .toList();

                    final filledSteps = _stepControllers
                        .where((c) => c.text.trim().isNotEmpty)
                        .toList();

                    // set errors
                    setState(() {
                      _nameError = _nameController.text.isEmpty
                          ? 'Name ist erforderlich'
                          : null;

                      _ingredientErrors = filledIngredients.isEmpty
                          ? 'Mindestens 1 Zutat erforderlich'
                          : null;

                      _stepErrors = filledSteps.isEmpty
                          ? 'Mindestens 1 Schritt erforderlich'
                          : null;
                    });

                    // return if there is a error
                    if (_nameError != null ||
                        _ingredientErrors != null ||
                        _stepErrors != null) {
                      return;
                    }

                    // ceate object to save recipes
                    final newRecipe = {
                      "id": id,
                      "name": _nameController.text,
                      "amount": amount,
                      "ingredients": filledIngredients,
                      "steps": filledSteps.map((c) => c.text.trim()).toList(),
                    };

                    // shared_preferences service
                    final prefs = await SharedPreferences.getInstance();

                    // get current recipes
                    final existing = prefs.getString('recipe');
                    List recipes = existing != null ? jsonDecode(existing) : [];

                    // add the new recipe
                    recipes.add(newRecipe);

                    // set the new object so prefs
                    await prefs.setString('recipe', jsonEncode(recipes));

                    // navigate back to my recipes
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },

                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),

                  child: const Text(
                    'Rezept hinzufügen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: 'SOON'),
        ],
      ),
    );
  }
}
