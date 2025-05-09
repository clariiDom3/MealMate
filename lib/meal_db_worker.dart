import 'package:mealmate/home/meal_model.dart';
import 'package:sqflite/sqflite.dart';
import 'base_model.dart';
//import 'package:path/path.dart';

class MealDBWorker implements EntryDBWorker<Meal> {
  static final MealDBWorker db = MealDBWorker._();

  static const String DB_NAME = 'meals.db';
  static const String TBL_NAME = 'meals';
  static const String KEY_ID = 'id';
  static const String KEY_CALORIES = 'calories';
  static const String KEY_PROTEIN = 'protein';
  static const String KEY_FATS = 'fats';
  static const String KEY_CARBS = 'carbs';
  static const String KEY_NAME = 'name';
  static const String KEY_IMAGE_URL = 'imageUrl';
  static const String KEY_YOUTUBEURL = 'description';
  static const String KEY_CATEGORY = 'category';
  static const String KEY_INSTRUCTIONS = 'instructions';
  static const String KEY_INGREDIENTS = 'ingredients';
  static const String KEY_MEASURES = 'measures';
  static const String KEY_FAVORITE = 'isFavorite';
  static const String KEY_DATE = 'date';
  static const String KEY_MEALTYPE = 'mealType';

  Database? _db;

  MealDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    //await deleteDatabase(join(await getDatabasesPath(), DB_NAME));
    return await openDatabase(
      DB_NAME,
      version: 1,
      onOpen: (db) {
        print('name of database: ${DB_NAME}');
      },
      onCreate: (Database db, int version) async {
        await db.execute('''
  CREATE TABLE IF NOT EXISTS $TBL_NAME (
    $KEY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    $KEY_CALORIES INTEGER,
    $KEY_PROTEIN INTEGER,
    $KEY_FATS INTEGER,
    $KEY_CARBS INTEGER,
    $KEY_NAME TEXT,
    $KEY_IMAGE_URL TEXT,
    $KEY_YOUTUBEURL TEXT,
    $KEY_CATEGORY TEXT,
    $KEY_INSTRUCTIONS TEXT,
    $KEY_INGREDIENTS TEXT,
    $KEY_MEASURES TEXT,
    $KEY_FAVORITE INTEGER DEFAULT 0,
    $KEY_DATE TEXT,
    $KEY_MEALTYPE TEXT,
    UNIQUE($KEY_DATE, $KEY_MEALTYPE)
  )
''');
      },
    );
  }

  @override
  Future<int> create(Meal meal) async {
    Database db = await database;
    print("saving ${meal.name}");
    return await db.rawInsert(
      'INSERT INTO $TBL_NAME ($KEY_CALORIES, $KEY_PROTEIN, $KEY_FATS, $KEY_CARBS, $KEY_NAME, $KEY_IMAGE_URL, $KEY_YOUTUBEURL, $KEY_CATEGORY, $KEY_INSTRUCTIONS, $KEY_INGREDIENTS, $KEY_MEASURES, $KEY_FAVORITE, $KEY_DATE, $KEY_MEALTYPE)'
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
      [
        meal.calories,
        meal.protein,
        meal.fat,
        meal.carbs,
        meal.name,
        meal.imageUrl,
        meal.youtubeUrl,
        meal.category,
        meal.instructions,
        meal.ingredients?.join(','),
        meal.measures?.join(','),
        meal.isFavorite,
        meal.date?.toIso8601String().split('T')[0],
        meal.mealType,
      ],
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
  }

  @override
  Future<Meal?> get(int id) async {
    Database db = await database;
    var values = await db.query(
      TBL_NAME,
      where: '$KEY_ID = ?',
      whereArgs: [id],
    );
    return values.isEmpty ? null : _mealFromMap(values.first);
  }

  @override
  Future<List<Meal>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _mealFromMap(m)).toList() : [];
  }

  @override
  Future<int> update(Meal meal) async {
    Database db = await database;
    print('updating');
    return await db.update(
      TBL_NAME,
      _mealToMap(meal),
      where: '$KEY_ID = ?',
      whereArgs: [meal.id],
    );
  }

  @override
  Future<Meal?> getMealByDateAndType(DateTime date, String type) async {
    final db = await database;
    final formattedDate = date.toIso8601String().split('T')[0];

    final result = await db.query(
      TBL_NAME,
      where: '$KEY_DATE = ? AND $KEY_MEALTYPE = ?',
      whereArgs: [formattedDate, type],
    );

    return result.isNotEmpty ? _mealFromMap(result.first) : null;
  }

  @override
  Future<List<Meal>> getFavorites() async {
    Database db = await database;
    final results = await db.query(
      TBL_NAME,
      where: '$KEY_FAVORITE = ?',
      whereArgs: [1],
    );
    return results.map((m) => _mealFromMap(m)).toList();
  }

  @override
  Future<List<Meal>> getMealByDate(DateTime date) async {
    Database db = await database;
    final formattedDate = date.toIso8601String().split('T')[0];

    final result = await db.query(
      TBL_NAME,
      where: 'date = ?',
      whereArgs: [formattedDate],
    );
    return result.isNotEmpty ? result.map((m) => _mealFromMap(m)).toList() : [];
  }

  Meal _mealFromMap(Map<String, dynamic> map) => Meal(
    id: map[KEY_ID],
    calories: map[KEY_CALORIES],
    protein: map[KEY_PROTEIN],
    fat: map[KEY_FATS],
    carbs: map[KEY_CARBS],
    name: map[KEY_NAME],
    imageUrl: map[KEY_IMAGE_URL],
    youtubeUrl: map[KEY_YOUTUBEURL],
    category: map[KEY_CATEGORY],
    instructions: map[KEY_INSTRUCTIONS],
    ingredients: map[KEY_INGREDIENTS]?.split(','),
    measures: map[KEY_MEASURES]?.split(','),
    isFavorite: map[KEY_FAVORITE],
    date: map[KEY_DATE] != null ? DateTime.parse(map[KEY_DATE]) : null,
    mealType: map[KEY_MEALTYPE],
  );

  Map<String, dynamic> _mealToMap(Meal meal) => <String, dynamic>{
    KEY_ID: meal.id,
    KEY_CALORIES: meal.calories,
    KEY_PROTEIN: meal.protein,
    KEY_FATS: meal.fat,
    KEY_CARBS: meal.carbs,
    KEY_NAME: meal.name,
    KEY_IMAGE_URL: meal.imageUrl,
    KEY_YOUTUBEURL: meal.youtubeUrl,
    KEY_CATEGORY: meal.category,
    KEY_INSTRUCTIONS: meal.instructions,
    KEY_INGREDIENTS: meal.ingredients?.join(','),
    KEY_MEASURES: meal.measures?.join(','),
    KEY_FAVORITE: meal.isFavorite,
    KEY_DATE: meal.date?.toIso8601String().split('T')[0],
    KEY_MEALTYPE: meal.mealType,
  };
}
