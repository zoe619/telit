
class PoliceContacts{
  int id;
  String state;
  String phone;


  PoliceContacts({this.id, this.state, this.phone});

 factory PoliceContacts.fromMap(Map<String, dynamic> data){
   return PoliceContacts(
     id: data['id'],
     state: data['state'],
     phone: data['phone'],
   );
 }

}