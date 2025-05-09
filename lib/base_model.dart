import 'package:scoped_model/scoped_model.dart';

abstract class Entry {
  int id;

  Entry({this.id = -1});

  bool get isNew => id == -1;
}

abstract interface class EntryDBWorker<T extends Entry> {
  Future<int> create(T note);

  Future<void> update(T note);

  Future<void> delete(int id);

  Future<T?> get(int id);

  Future<List<T>> getAll();

  Future<T?> getMealByDateAndType(DateTime date, String type);

  Future<List<T>> getMealByDate(DateTime date);

  Future<List<T>> getFavorites();
}

abstract class BaseModel<T extends Entry> extends Model {
  int _stackIndex = 0;
  final EntryDBWorker<T> database;
  final List<T> entryList = [];
  T? entryBeingEdited;

  BaseModel(this.database);

  int get stackIndex => _stackIndex;

  set stackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  void startEditingEntry(T entry) {
    entryBeingEdited = entry;
    stackIndex = 1;
  }

  Future<int?> stopEditingEntry({bool save = false}) async {
    int? id;
    if (save) {
      var item = entryBeingEdited!;
      if (item.isNew) {
        id = await database.create(item);
      } else {
        await database.update(item);
        id = item.id;
      }
    }
    loadData(); 
    entryBeingEdited = null;
    stackIndex = 0;
    return id;
  }

  Future<void> deleteEntry(T entry) async {
    await database.delete(entry.id);
    loadData();
  }

  void refreshUI() {
    notifyListeners();
  }

  void loadData() async {
    entryList.clear();
    entryList.addAll(await database.getAll());
    notifyListeners();
  }
}
