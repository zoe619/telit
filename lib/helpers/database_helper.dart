import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:telit/models/crime_model.dart';
import 'package:telit/models/police_contacts.dart';
import 'package:uuid/uuid.dart';

 class DatabaseHelper
 {

   //  make DatabaseHelper a singleton i.e can only have one instance of the class
   static final DatabaseHelper instance = DatabaseHelper._instance();

   static Database _db;

   DatabaseHelper._instance();

   String crimeTable = 'crime_table';
   String colId = 'id';
   String colTitle = 'title';
   String colDate = 'date';
   String colLocation = 'location';
   String colStatus = 'status';
   String colPicture = 'picture';

   String stateTable = 'state_table';
   String stateId = 'id';
   String stateName = 'state';
   String statePhone = 'phone';

   Map<String, dynamic> _statePoliceContacts =
   {
     "Adamawa" : "08037617994",
     "Akwa_Ibom" : "08034961915",
     "Anambra" : "08168960944",
     "Bauchi": "08035481586",
     "Bayelsa" : "08060970639",
     "Benue": "08032789712",
     "Borno": "08152112110",
     "Cross_River" : "08033369958",
     "Delta": "08033797766",
     "Ebonyi": "08037739134",
     "Edo": "08037180188",
     "Ekiti": "08081772868",
     "Enugu": "08038829086",
     "Gombe": "08075388884",
     "Imo": "08063827970",
     "Jigawa": "08065670314",
     "Kaduna": "08033024229",
     "Kano": "08066471341",
     "Katsina": "08064211500",
     "Kebbi": "08065159812",
     "Kogi": "08076508275",
     "Kwara": "08032365122",
     "Lagos": "08036634061",
     "Nasarawa": "08038851066",
     "Niger": "07063116303",
     "Ogun": "08037168147",
     "Ondo": "08033852918",
     "Osun": "08035384448",
     "Oyo": "08036536581",
     "Plateau": "08039648676",
     "Rivers": "08033396538",
     "Sokoto" : "08065510954",
     "Taraba": "08032559513",
     "Yobe": "08125129955",
     "Zamfara": "08036186543",
     "FCT": "08133379980",

   };
   //  getter to return database
   Future<Database> get db async
   {
     if(_db == null)
     {
       return await _initDb();
     }
     return _db;
   }

   //  function to create database in users device
   Future<Database> _initDb() async
   {
     Directory dir = await getApplicationDocumentsDirectory();
     String path = dir.path + '/telit.db';
     final crimeListDb = await openDatabase(path, version: 1, onCreate: _createStateTable);
     return crimeListDb;
   }


   void _createDb(Database db, int version) async
   {
     await db.execute(
         'CREATE TABLE $crimeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, '
             '$colLocation TEXT, $colStatus INTEGER, $colPicture TEXT)'
     );



   }

   void _createStateTable(Database db, int version) async{
     await db.execute(
         'CREATE TABLE $stateTable($stateId INTEGER PRIMARY KEY AUTOINCREMENT, $stateName TEXT, $statePhone TEXT)'
     );
     await db.execute(
         'CREATE TABLE $crimeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, '
             '$colLocation TEXT, $colStatus INTEGER, $colPicture TEXT)'
     );
   }

   //  this returns all the rows in crimeTable as maps
   Future<List<Map<String, dynamic>>> getCrimeMapList() async{
     Database db = await this.db;
     final List<Map<String, dynamic>> result = await db.query(crimeTable);
     return result;
   }

   //  this returns all the rows in stateTable as maps
   Future<List<Map<String, dynamic>>> getStateMapList() async{
     Database db = await this.db;
     final List<Map<String, dynamic>> result = await db.query(stateTable, orderBy: colId);
     return result;
   }

   //  convert the maps to crime object and returns a list of crime

   Future<List<Crime>> getCrimeList() async{
     final List<Map<String, dynamic>> crimeMapList = await getCrimeMapList();
     final List<Crime> crimeList = [];
     crimeMapList.forEach((crimeMap){
       crimeList.add(Crime.fromMap(crimeMap));

     });
     crimeList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
     return crimeList;
   }

   Future<List<String>> getStateList() async{
     final List<Map<String, dynamic>> stateMapList = await getStateMapList();
     final List<String> stateList = [];
     stateMapList.forEach((stateMap){
       stateList.add(stateMap.toString());

     });
     return stateList;
   }


   //  function to store crime as map cos sqflite store data as maps
   Future<int> insertCrime(Crime crime) async{
     Database db = await this.db;
     final int result = await db.insert(crimeTable, crime.toMap());
     return result;

   }

//   function to update crime
   Future<int> updateCrime(Crime crime) async{
     Database db = await this.db;
     final int result = await db.update(crimeTable, crime.toMap(),
       where: '$colId = ?',
       whereArgs: [crime.id],
     );
     return result;
   }

   Future<int> deleteCrime(int id) async{
     Database db =  await this.db;
     final int result = await db.delete(crimeTable,
       where: '$colId = ?',
       whereArgs: [id],
     );
     return result;
   }



    Future<void> insert() async
    {


      Database db = await this.db;
      List<String> states = ["Abia", "Adamawa","Akwa Ibom","Anambra", "Bauchi","Bayelsa",
    "Benue", "Borno", "Cross River", "Delta", "Ebonyi", "Edo", "Ekiti", "Enugu", "Gombe",
    "Imo", "Jigawa", "Kaduna", "Kano",  "Katsina", "Kebbi", "Kogi","Kwara","Lagos", "Nasarawa",
    "Niger","Ogun", "Ondo", "Osun",  "Oyo", "Plateau", "Rivers", "Sokoto","Taraba", "Yobe",
    "Zamfara","FCT"];

     List<String> phones = ["08037617994", "08034961915", "08168960944", "08035481586","08060970639",
    "08032789712", "08152112110", "08033126781","08033369958", "08033797766","08037739134","08037180188","08081772868",
    "08038829086","08075388884","08063827970","08065670314","08033024229","08066471341","08064211500",
    "08065159812","08076508275","08032365122","08036634061","08038851066","07063116303","08037168147",
    "08033852918","08035384448","08036536581","08039648676", "08033396538", "08065510954",
    "08032559513", "08125129955", "08036186543", "08133379980"];

      final List<Map<String, dynamic>> result = await db.query(stateTable);
      if(result.isEmpty){

        Batch batch = db.batch();

        for (int i = 0; i < states.length; i++)
        {
          batch.rawInsert("INSERT INTO $stateTable ($stateName, $statePhone) VALUES (?, ?)", [states[i], phones[i]]);
        }

        await batch.commit(noResult: true);

      }


    }

   Future<PoliceContacts> getPhone(String state) async
   {

     Database db =  await this.db;
     var results = await db.rawQuery('SELECT * FROM state_table WHERE state = $state');

     if (results.length > 0)
     {
       return new PoliceContacts.fromMap(results.first);
     }

     return null;
   }


   Future<PoliceContacts> getPhone2(String state) async
   {
     Database db =  await this.db;
     List<Map> results = await db.query("state_table",
         columns: ["id", "state", "phone"],
         where: 'state = ?',
         whereArgs: [state]);

     if (results.length > 0) {
       return new PoliceContacts.fromMap(results.first);
     }

     return null;
   }

   Future<File> _compressImage(String imageId, File image) async{

     final tempDir = await getTemporaryDirectory();
     final path = tempDir.path;
     File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
       image.absolute.path,
       '$path/img_$imageId.jpg',
       quality: 70,
     );
     return compressedImageFile;
   }

   Future<String> uploadImage(File imageFile) async{
     String imageId = Uuid().v4();
     File image = await _compressImage(imageId, imageFile);



     return image.uri.toString();
   }

 }