
class Crime{
  int id;
  String title;
  String location;
  DateTime date = DateTime.now();
  int status;
  String picture;


  Crime({
    this.title,
    this.location,
    this.date,
    this.status,
    this.picture
  });

//  Named constructor
  Crime.withId({
    this.id,
    this.title,
    this.location,
    this.date,
    this.status,
    this.picture
  });

//  function to store the crime as a map into the database
  Map<String, dynamic>toMap(){

    final map = Map <String, dynamic>();
    if(id != null)
    {
      map['id'] = id;
    }

    map['title'] = title;
    map['location'] = location;
    map['date'] = date.toIso8601String();
    map['status'] = status;
    map['picture'] = picture;
    return map;

  }

//  function to read crime from database and convert it to a Crime object

  factory Crime.fromMap(Map<String, dynamic> map){
    return Crime.withId(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      date: DateTime.parse(map['date']),
      status: map['status'],
      picture: map['picture']
    );
  }
}