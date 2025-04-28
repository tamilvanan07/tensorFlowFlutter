class ListOfPerson{
  List<PersonDb> personList = [];
  ListOfPerson({required this.personList});

  factory ListOfPerson.fromJson(List jsonvALUE) {
    return ListOfPerson(
      personList: jsonvALUE.map((e) => PersonDb.fromJson(e)).toList(),
    );
  }
}



class PersonDb {
  int? addTime;
  int? numImages;
  int? personID;
  String? personName;

  PersonDb({this.addTime, this.numImages, this.personID, this.personName});

  PersonDb.fromJson(Map<String, dynamic> json) {
    addTime = json['addTime'];
    numImages = json['numImages'];
    personID = json['personID'];
    personName = json['personName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addTime'] = this.addTime;
    data['numImages'] = this.numImages;
    data['personID'] = this.personID;
    data['personName'] = this.personName;
    return data;
  }
}