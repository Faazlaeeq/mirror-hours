import 'package:flutter/material.dart';
import 'package:mirror/screens/alarm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/bg-full.jpg',
            fit: BoxFit.fitHeight,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text("Houruoh", style: TextStyle(fontSize: 40, color: Color(0xffffffff), fontFamily: 'Mouldy')),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 100),
                child: Text(
                    "Une Heure Miroir est une heure aux chiffres doubles. Elle se manifeste généralement de manière fortuite lorsque vous regardez votre téléphone, votre montre ou tout autre appareil qui affiche l'heure en format numérique. Cela peut vous donner une sensation étrange, particulièrement lorsque la même heure double vous apparaît régulièrement.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xffffffff),
                        shadows: [Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(5, 5))])),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE9E1EC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MirrorHoursPage()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Gérer les Heures Miroirs",
                        style: TextStyle(
                          color: Color(0xff2C1542),
                          fontSize: 16,
                        )),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
