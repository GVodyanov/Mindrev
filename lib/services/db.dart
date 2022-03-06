import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

//this is the class that we will use for managing local storage
class Local {
  //init method to set up db
  Future<Database> init() async {
    Database db;
    //writing data is obv different on native and web so we have to check
    if (kIsWeb) {
      var factory = databaseFactoryWeb;
      db = await factory.openDatabase('mindrev');
    } else {
      final _dir = await getApplicationSupportDirectory();
      await _dir.create(recursive: true);
      String _dbPath = join(_dir.path, 'mindrev');
      db = await databaseFactoryIo.openDatabase(_dbPath);
    }
    return db;
  }

  //method for saving data to specific store
  write(var data, String recordName, String? storeName) async {
    Database db = await init();
    StoreRef store;
    if (storeName != null) {
      store = stringMapStoreFactory.store(storeName);
    } else {
      store = StoreRef<String, String>.main();
    }
    await store.record(recordName).add(db, data);
  }

  update(var data, String recordName, String? storeName) async {
    Database db = await init();
    StoreRef store;
    if (storeName != null) {
      store = stringMapStoreFactory.store(storeName);
    } else {
      store = StoreRef<String, String>.main();
    }
    await store.record(recordName).update(db, data);
  }

  //read data from record and store
  Future read(String recordName, String? storeName) async {
    Database db = await init();
    StoreRef store;
    if (storeName != null) {
      store = stringMapStoreFactory.store(storeName);
    } else {
      store = StoreRef<String, String>.main();
    }
    var result = await store.record(recordName).get(db);
    return result;
  }

  //find all data in a store
  Future<dynamic> findAll(String? storeName) async {
    Database db = await init();
    StoreRef store;
    if (storeName != null) {
      store = stringMapStoreFactory.store(storeName);
    } else {
      store = StoreRef<String, String>.main();
    }
    var finder = Finder(filter: Filter.not(Filter.lessThan('', '')), sortOrders: [
      SortOrder('')
    ]);
    return await store.find(db, finder: finder);
  }
}

Local local = Local();
