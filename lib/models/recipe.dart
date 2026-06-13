class Recipe {
  // Fields
  final String id; // UUID
  final String name;
  final List<String> amount;
  final List<String> ingredients;
  final List<String> steps;

  // Constructor
  const Recipe({
    required this.id,
    required this.name,
    required this.amount,
    required this.ingredients,
    required this.steps,
  });

  // build recipe from JSON map (loading)
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: List<String>.from(json['amount']),
    ingredients: List<String>.from(json['ingredients']),
    steps: List<String>.from(json['steps']),
  );

  // Convert recipe to JSON map (saving)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'ingredients': ingredients,
    'steps': steps,
  };
}
