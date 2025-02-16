class Recipe {
  final String name;
  final int persons;
  final String description;
  final String ingredients;
  String? uid;
  final int time;
  String? image;

  Recipe({
    required this.name,
    required this.persons,
    required this.description,
    required this.ingredients,
    this.uid,
    required this.time,
    this.image,
  });

  Map<String, dynamic> json() {
    return {
      'uid': uid,
      'name': name.toLowerCase(),
      'persons': persons,
      'description' : description,
      'ingredients' : ingredients,
      'time': time,
      'image': image,
    };
  }

  static Recipe fromJson(Map<String, dynamic> json) {
    return Recipe(
      uid: json['uid'],
      name: json['name'],
      persons: json['persons'],
      description: json['description'],
      ingredients: json['ingredients'],
      time: json['time'],
      image: json['image'],
    );
  }
}