import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  String? _nameError;
  String? _ingredientErrors;
  String? _stepErrors;

  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];
  final List<FocusNode> _focusNodes = [FocusNode()];
  final List<FocusNode> _stepFocusNodes = [FocusNode()];

  void _addField(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    setState(() {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => focusNodes.last.requestFocus(),
    );
  }

  void _removeField(
    int i,
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    if (controllers.length <= 1) return;
    controllers[i].dispose();
    focusNodes[i].dispose();
    setState(() {
      controllers.removeAt(i);
      focusNodes.removeAt(i);
    });
    if (i > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNodes[i - 1].requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _ingredientControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    for (final sc in _stepControllers) sc.dispose();
    for (final sf in _stepFocusNodes) sf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Name',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Text(
              'Zutaten',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            ...List.generate(
              _ingredientControllers.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
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
                    onSubmitted: (_) =>
                        _addField(_ingredientControllers, _focusNodes),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            TextButton.icon(
              onPressed: () => _addField(_ingredientControllers, _focusNodes),
              icon: const Icon(Icons.add),
              label: const Text('Zutat hinzufügen'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Zubereitung',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            ...List.generate(
              _stepControllers.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
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
              ),
            ),
            const SizedBox(height: 4.0),
            TextButton.icon(
              onPressed: () => _addField(_stepControllers, _stepFocusNodes),
              icon: const Icon(Icons.add),
              label: const Text('Schritt hinzufügen'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TextButton(
                  onPressed: () async {
                    final amount = <String>[];
                    final ingredients = <String>[];
                    final id = const Uuid().v4();

                    for (final controller in _ingredientControllers) {
                      final input = controller.text.trim();
                      final forward = RegExp(
                        r'^(\d+[\.,]?\d*\s*(?:g|kg|ml|l|EL|TL|Pck\.|Prise|Stück|St\.|Tasse)?\.?)\s+(.+)$',
                        caseSensitive: false,
                      );
                      final backward = RegExp(
                        r'^(.+?)\s+(\d+[\.,]?\d*\s*(?:g|kg|ml|l|EL|TL|Pck\.|Prise|Stück|St\.|Tasse)?\.?)$',
                        caseSensitive: false,
                      );
                      final m1 = forward.firstMatch(input);
                      final m2 = backward.firstMatch(input);

                      if (m1 != null) {
                        amount.add(m1.group(1)!);
                        ingredients.add(m1.group(2)!);
                      } else if (m2 != null) {
                        ingredients.add(m2.group(1)!);
                        amount.add(m2.group(2)!);
                      } else {
                        ingredients.add(input);
                        amount.add('');
                      }
                    }

                    final filledIngredients = ingredients
                        .where((c) => c.isNotEmpty)
                        .toList();
                    final filledSteps = _stepControllers
                        .where((c) => c.text.trim().isNotEmpty)
                        .toList();

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

                    if (_nameError != null ||
                        _ingredientErrors != null ||
                        _stepErrors != null)
                      return;

                    await RecipeService().save(
                      Recipe(
                        id: id,
                        name: _nameController.text,
                        amount: amount,
                        ingredients: filledIngredients,
                        steps: filledSteps.map((c) => c.text.trim()).toList(),
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    foregroundColor: colorScheme.onPrimary,
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
        destinations: [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: 'SOON'),
        ],
      ),
    );
  }
}
