import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telit/helpers/database_helper.dart';
import 'package:telit/models/crime_model.dart';
import 'package:telit/screens/add_emergency.dart';

class EmergencyList extends StatefulWidget
{
  @override
  _EmergencyListState createState() => _EmergencyListState();
}

class _EmergencyListState extends State<EmergencyList>
{

  Future<List<Crime>> _crimeList;
  List<String> _result;
  Icon searchIcon = Icon(Icons.search, color: Colors.white);
  Widget titleBar = Text('My Emergencies',  style: TextStyle(
    color: Colors.white70,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  ),);

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  @override
  initState(){
    super.initState();
    _updateList();
    DatabaseHelper.instance.insert();

  }

  _testing() async{
    _result = await DatabaseHelper.instance.getStateList();

  }

  _updateList(){
    setState(() {
      _crimeList = DatabaseHelper.instance.getCrimeList();

    });

  }

  Widget _buildTask(Crime crime)
  {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(crime.title, style: TextStyle(
              fontSize: 18.0,
              decoration: crime.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
            ),
            subtitle: Text('${_dateFormatter.format(crime.date)} *  ${crime.location}', style: TextStyle(
              fontSize: 15.0,
              decoration: crime.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
            ),
            trailing: Checkbox(
              onChanged: (value){
                crime.status = value ? 1 : 0;
                DatabaseHelper.instance.updateCrime(crime);
                _updateList();
              },
              activeColor: Theme.of(context).primaryColor,
              value: crime.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_)=>AddEmergency(
                    updateList: _updateList,
                    crime: crime,
                  ),
                )
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor
        ),
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: titleBar,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              setState(() {
                if(this.searchIcon.icon == Icons.search){
                   this.searchIcon = Icon(Icons.cancel, color: Colors.white);
                   this.titleBar = TextField(
                     onChanged: (value)
                     {
                       if(value != null && value.trim().isNotEmpty){

                       }

                     },
                      textInputAction: TextInputAction.go,
                     decoration: InputDecoration(
                       border: InputBorder.none,
                       hintText: "search emergency",
                     ),

                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 16.0,

                     ),
                   );
                }
                else{
                  this.searchIcon = Icon(Icons.search, color: Colors.white);
                  this.titleBar = Text('My Emergencies',  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),);

                }
              });
            },
            icon: searchIcon,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: (){
           Navigator.push(context, MaterialPageRoute(
              builder: (_)=>AddEmergency(
                updateList: _updateList,
              )
          ));
           _testing();
        }

      ),
      body: FutureBuilder(
          future: _crimeList,
          builder: (context, snapshot)
          {

            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

//          loop through the list of crime and returns the count of the once with status == 1
            final completedCrimeCount = snapshot.data
                .where((Crime crime) => crime.status == 1)
                .toList()
                .length;

            return  ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                itemCount: 1 + snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 100.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
//                          Text('My Emergencies', style: TextStyle(
//                            color: Colors.black,  SizedBox(height: 10.0),
//                            fontSize: 30.0,
//                            fontWeight: FontWeight.bold,
//                          ),
//                          ),


                          Text('$completedCrimeCount of  ${snapshot.data.length} solved',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 20.0,
                            ),)
                        ],
                      ),
                    );
                  }
                  return _buildTask(snapshot.data[index -1]);
                }
            );

          }
      ),
    );
  }
}
