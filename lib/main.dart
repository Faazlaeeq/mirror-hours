import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';
import 'models/mirror_hour.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  await Permission.notification.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirror Hours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MirrorHoursPage(),
    );
  }
}

class MirrorHoursPage extends StatefulWidget {
  const MirrorHoursPage({super.key});

  @override
  State<MirrorHoursPage> createState() => _MirrorHoursPageState();
}

class _MirrorHoursPageState extends State<MirrorHoursPage> {
  final NotificationService _notificationService = NotificationService();
  final List<MirrorHour> mirrorHours = [
    MirrorHour(time: "19h08", message: "Renouveau, un nouveau départ"),
    MirrorHour(time: "01h01", message: "Quelqu'un t'aime"),
    MirrorHour(time: "01h10", message: "Écoute tes intuitions"),
    MirrorHour(time: "02h02", message: "Travaillez sur vous-même"),
    MirrorHour(time: "02h20", message: "Équilibre et harmonie"),
    MirrorHour(time: "03h03", message: "Tout est possible"),
    MirrorHour(time: "03h30", message: "Confiance en soi"),
    MirrorHour(time: "04h04", message: "Transformation et changement"),
    MirrorHour(time: "04h40", message: "Protection et encouragement"),
    MirrorHour(time: "05h05", message: "Le moment idéal pour agir"),
    MirrorHour(time: "05h50", message: "Préparation à de nouvelles opportunités"),
    MirrorHour(time: "06h06", message: "Énergie positive et renouvellement"),
    MirrorHour(time: "07h07", message: "Union et connexion"),
    MirrorHour(time: "08h08", message: "Réussite et abondance"),
    MirrorHour(time: "09h09", message: "Compassion et empathie"),
    MirrorHour(time: "10h10", message: "Illumination et inspiration"),
    MirrorHour(time: "11h11", message: "Manifestation de vos désirs"),
    MirrorHour(time: "12h12", message: "Harmonie et équilibre intérieur"),
    MirrorHour(time: "12h21", message: "Prenez soin de vous"),
    MirrorHour(time: "13h13", message: "Créativité et développement personnel"),
    MirrorHour(time: "13h31", message: "Nouveaux débuts et changements"),
    MirrorHour(time: "14h14", message: "Amour inconditionnel"),
    MirrorHour(time: "14h41", message: "Intuition forte"),
    MirrorHour(time: "15h15", message: "Diligence et résilience"),
    MirrorHour(time: "15h51", message: "Confiance dans le futur"),
    MirrorHour(time: "16h16", message: "Équilibre émotionnel"),
    MirrorHour(time: "17h17", message: "Protection divine"),
    MirrorHour(time: "18h18", message: "Amour et relations sincères"),
    MirrorHour(time: "19h19", message: "Alignement avec votre véritable chemin"),
    MirrorHour(time: "20h02", message: "Nouvelle aventure à l'horizon"),
    MirrorHour(time: "20h20", message: "Prendre des décisions sage"),
    MirrorHour(time: "21h12", message: "Réflexion et introspection"),
    MirrorHour(time: "21h21", message: "Communication claire"),
    MirrorHour(time: "22h22", message: "Équilibre entre le corps et l'esprit"),
    MirrorHour(time: "23h23", message: "Fin de cycle et préparation"),
    MirrorHour(time: "23h32", message: "Sérénité et paix intérieure")
  ];

  void _toggleNotification(int index) async {
    setState(() {
      mirrorHours[index].isEnabled = !mirrorHours[index].isEnabled;
    });
    if (mirrorHours[index].isEnabled) {
      try {
        var status = await Permission.notification.request();
        print(status);
        await _notificationService.scheduleNotification(
          index,
          mirrorHours[index].time,
          mirrorHours[index].message,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification activée')),
        );
        // await _notificationService.printAllScheduledNotifications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'activation de la notification')),
        );
      }
    } else {
      _notificationService.cancelNotification(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('Mirror Hours'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: mirrorHours.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mirrorHours[index].time),
            subtitle: Text(mirrorHours[index].message),
            trailing: Switch(
              value: mirrorHours[index].isEnabled,
              onChanged: (_) => _toggleNotification(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          final now = DateTime.now();
          final oneMinuteLater = now.add(const Duration(minutes: 1));
          final String hour = oneMinuteLater.hour.toString().padLeft(2, '0');
          final String minute = oneMinuteLater.minute.toString().padLeft(2, '0');
          final String time = '${hour}h$minute';
          final String message = 'Notification set for $time';

          setState(() {
            mirrorHours.add(MirrorHour(time: time, message: message, isEnabled: true));
          });

          await _notificationService.scheduleNotification(
            mirrorHours.length - 1,
            time,
            message,
          );
          // try {
          //   await _notificationService.scheduleNotificationDirect();
          // } catch (e) {
          //   print(e);
          // }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification set for $time')),
          );
        },
        child: const Text("Add Test Notification in 1 minute"),
      ),
    );
  }
}
