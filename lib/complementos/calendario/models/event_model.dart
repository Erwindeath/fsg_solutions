// ignore_for_file: unnecessary_null_comparison, avoid_renaming_method_parameters

import 'dart:convert';

class AppEvent {
 
  final DateTime? date;

  AppEvent({
 
    this.date,

  });

  AppEvent copyWith({
  
    DateTime? date,

  }) {
    return AppEvent(
     
      date: date ?? this.date,
 
    );
  }

  Map<String, dynamic> toMap() {
    return {


      'date': date!.millisecondsSinceEpoch,

    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    // ignore: null_check_always_fails
    if (map == null) return null!;

    return AppEvent(

      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
 
    );
  }
  factory AppEvent.fromDS(String id, Map<String, dynamic> data) {
    // ignore: null_check_always_fails
    if (data == null) return null!;

    return AppEvent(

      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
   
    );
  }

  String toJson() => json.encode(toMap());

  factory AppEvent.fromJson(String source) =>
      AppEvent.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppEvent( date: $date)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AppEvent &&
        
        o.date == date;
        
  }

  @override
  int get hashCode {
    return 
        date.hashCode;
  }
}
