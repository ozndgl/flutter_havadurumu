import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_havadurumu/search_page.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = "istanbul";
  int sicaklik;
  var locationData;
  var woeid;
  String abbr = "c";
  Position position;
  List<int> temps = List(5);
  List abbrs = List(5);
  List<String> dates = List(5);


  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print("gelen hata $error");
    } finally {
      //ne olursa olsun çalışır
    }

    print("position: $position");
  }

  Future<void> getLocationTempature() async {
    var responseh =
        await http.get("https://www.metaweather.com/api/location/$woeid/");
    var temperatureDataPartsed = jsonDecode(responseh.body);
    //sicaklik = temperatureDataPartsed["consolidated_weather"][0]["the_temp"];
    setState(() {
      sicaklik = temperatureDataPartsed["consolidated_weather"][0]["the_temp"].round();
      abbr = temperatureDataPartsed["consolidated_weather"][0]["weather_state_abbr"];
      for(int i = 0 ;i<temps.length ;i++){
        temps[i] = temperatureDataPartsed["consolidated_weather"][i+1]["the_temp"].round();
        abbrs[i] = temperatureDataPartsed["consolidated_weather"][i+1]["weather_state_abbr"];
        dates[i] = temperatureDataPartsed["consolidated_weather"][i+1]["applicable_date"];
      }
    });
  }

  Future<void> getLocationData() async {
    var url = locationData = await http
        .get("https://www.metaweather.com/api/location/search/?query=$sehir");
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]["woeid"];
    print("woeid 0: $woeid");
  }

  Future<void> getLocationDataLAtLong() async {
    var url = locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}");
    //var locationDataParsed = jsonDecode((locationData.body));
    var locationDataParsed = jsonDecode((locationData.body));
    woeid = locationDataParsed[0]["woeid"];
    sehir = locationDataParsed[0]["title"];
    print("woeid 0: $woeid");
  }

  void getDataFromAPI() async {
    await getDevicePosition();
    await getLocationDataLAtLong();
    getLocationTempature();
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTempature();
  }

  @override
  void initState() {
    getDataFromAPI();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/$abbr.jpg"),
        ),
      ),
      child: sicaklik == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          "https://www.metaweather.com/static/img/weather/png/$abbr.png"),
                    ),
                    Text(
                      "$sicaklik° C",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 70,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: Offset(-3, 3))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$sehir",
                          style: TextStyle(fontSize: 30, shadows: <Shadow>[
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: Offset(-3, 3))
                          ]),
                        ),
                        IconButton(
                            onPressed: () async {
                              sehir = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              getDataFromAPIbyCity();
                              setState(() {
                                sehir = sehir;
                              });
                            },
                            icon: Icon(Icons.search))
                      ],
                    ),
                    SizedBox(
                      height: 120,
                    ),
                    buildDailyWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyWeatherCards(BuildContext context) {

    List<Widget> cards=List(5);

    for(int i=0;i<cards.length;i++){
      cards[i]=DailyWeather(image: abbrs[i], temp: temps[i].toString(), date: dates[i]);
    }

    return Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                     children: cards,
                    ),
                  );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key key, @required this.image, @required this.temp, @required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String>weekdays=["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"];
    String weekday=weekdays[DateTime.parse(date).weekday-1];


    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://www.metaweather.com/static/img/weather/png/$image.png",
              height: 50,
              width: 50,
            ),
            Text("$temp °C"),
            Text(weekday),
          ],
        ),
      ),
    );
  }
}
