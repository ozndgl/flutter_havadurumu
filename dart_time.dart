


main (){
  List<String>weekdays=["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"];


  DateTime simdi=DateTime.now();
  print(simdi);

  DateTime cumhuriyet=DateTime.utc(1923,10,29,9,30);
  print("cumhuriyet: $cumhuriyet");

  DateTime localTime = DateTime.parse("2021-06-21");
  print("local Time: ${localTime.weekday}");

  print(weekdays[simdi.weekday - 1]);
  
  DateTime simdidenSonra = simdi.add(Duration(days: 90));
  print("simdidenSonra: $simdidenSonra");
}