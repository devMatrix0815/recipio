// imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Run the app
void main() {
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

// model for a recipe
class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> amount;
  final List<String> steps;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.amount,
    required this.steps,
  });
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

  // later fetch this from a database
  final List<Recipe> _recipes = [
    Recipe(
      name: 'Schokomuffins',
      amount: [
        '125 g',
        '150 g',
        '1 Pck.',
        '2 Eier',
        '200 g',
        '200 g',
        '4 EL',
        '1 Prise',
        '2 TL',
        '175 ml',
      ],
      ingredients: [
        'Weiche Butter',
        'Zucker',
        'Vanillezucker',
        'Eier',
        'Zartbitterschokolade',
        'Mehl',
        'Backkakao',
        'Salz',
        'Backpulver',
        'Milch',
      ],
      steps: [
        'Butter mit Zucker und Vanillezucker verrühren. Eier unterrühren. Zartbitterschokolade grob hacken. Ofen auf 180 Grad (Umluft: 160 Grad) vorheizen. Mehl mit Kakaopulver, Salz und Backpulver vermischen. Mehlmischung mit der Milch zur Butter-Zuckermischung geben und alles gut verrühren. Etwa zwei Drittel der gehackten Schokolade unterheben.',
        'Die Mulden eines Muffinblechs mit Förmchen auslegen. Mit einem Eisportionierer den Teig auf die Förmchen verteilen. Die restlichen gehackten Schokostückchen auf den Muffins verteilen. Im vorgeheizten Ofen ca. 25 Min backen.',
      ],
    ),
  ];

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
        .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetail(recipe: filtered[index]),
                          ),
                        );
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
                                    filtered[index].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),

                                  // space between title and description
                                  const SizedBox(height: 4.0),

                                  // description of the recipe
                                  Text(
                                    filtered[index].ingredients.join(', '),
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
          NavigationDestination(icon: Icon(Icons.search), label: '...'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateRecipe()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// detail page for a recipe
class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

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
          recipe.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
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
            ...recipe.ingredients.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24.0),
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 16.0),
                    Text(
                      '${recipe.amount[entry.key]} ',
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
            ...recipe.steps.asMap().entries.map(
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
          NavigationDestination(icon: Icon(Icons.search), label: '...'),
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
  // controller for name text-field
  final TextEditingController _nameController = TextEditingController();

  // controller and focus node for every text-field (ingredient)
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  final List<FocusNode> _focusNodes = [FocusNode()];

  // attach new empty text-field and focus on it (ingredient)
  void _addIngredientField() {
    // add new controller and focus node to list
    setState(() {
      _ingredientControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.last.requestFocus();
    });
  }

  // remove text-field at index and focus the field before (ingredient)
  void _removeIngredientField(int i) {
    if (_ingredientControllers.length <= 1) {
      return; // not less then 1 ingredient
    }

    // remove controller + focus node
    _ingredientControllers[i].dispose();
    _focusNodes[i].dispose();

    setState(() {
      _ingredientControllers.removeAt(i);
      _focusNodes.removeAt(i);
    });

    // focus previous field
    if (i > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[i - 1].requestFocus();
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
              decoration: const InputDecoration(hintText: 'Rezeptname...'),
            ),

            const SizedBox(height: 32.0),

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
                      _removeIngredientField(i);
                    }
                  },

                  child: TextField(
                    controller: _ingredientControllers[i],
                    focusNode: _focusNodes[i],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'z.B. 150g Zucker',
                      suffixIcon: _ingredientControllers.length > 1
                          // remove text-field
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _removeIngredientField(i),
                            )
                          : null,
                    ),

                    // create new textfield when pressing enter
                    onSubmitted: (_) => _addIngredientField(),
                  ),
                ),
              );
            }),

            // space + add ingredient button
            const SizedBox(height: 4.0),
            TextButton.icon(
              onPressed: _addIngredientField,
              icon: const Icon(Icons.add),
              label: const Text('Zutat hinzufügen'),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: '...'),
        ],
      ),
    );
  }
}
