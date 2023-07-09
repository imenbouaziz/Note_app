import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
class Note {
  final String noteContent;
  final String dattime;
  const Note(this.noteContent, this.dattime);
}


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TP4',
      home: const MyHomePage(title: 'Notes'),
    );
  }
}
class SplashScreen extends StatelessWidget{

  const SplashScreen({key});

  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(splash: Column(
      children: [
        Image.asset("assets/note.png",height: 100,
          width: 200,
        ),
        const Text('Notes App', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),)
      ],
    ),
      backgroundColor: Colors.black12,
      nextScreen: const MyHomePage(title: '',),
      splashIconSize : 50,
      duration: 4000,
      splashTransition: SplashTransition.slideTransition,
      animationDuration: const Duration(seconds: 3),

    );

  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  final List<Note> notes = [];
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  Future<void> openDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          final TextEditingController _textFieldController = TextEditingController();
          return AlertDialog(
            title: Text('Notes'),
            content: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _textFieldController,
                    validator: (value){
                      return value!.isNotEmpty ? null : "Input is empty, please enter a correct input.";
                    },
                    decoration: InputDecoration(hintText: "Quoi de neuf ?"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Note'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
                ),
                onPressed: () {
                  if(_formkey.currentState!.validate()) {
                    DateTime now = DateTime.now();
                    final Note note = Note(_textFieldController.text, "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}-${now.minute.toString().padLeft(2,'0')}");
                    setState(() {
                      notes.add(note);
                    });
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        }
    );
  }

  Future<void> openSuppDialog(BuildContext context, int index) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text('Suppression'),
            content: new Text("Vous confirmez la suppression ?"),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Oui'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
                ),
                onPressed: () {
                  setState(() {
                    notes.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        backgroundColor: Colors.cyan,
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/Twitter-Logo.png'),
            onPressed: () async {
              await openDialog(context);
            },
          ),
        ],
      ),
      body:OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait)
               return _myListView(context);
            else
             return const Text('portrait!');
          })

    );
  }

  Widget _myListView(BuildContext context) {
    // backing data
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Card(child: ListTile(
          leading: Image.asset("assets/profile-pic.png"),
          title: Text('Imene'),
          subtitle: Text(notes[index].noteContent),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(note: notes[index]),
              ),
            );
          },
          onLongPress: () async {
            await openSuppDialog(context, index);
          },
        ));
        },
    );
  }
}


class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.note}) : super(key: key);

  final Note note;

  @override
  Widget build(BuildContext context) {
    FlutterTts flutterTts = FlutterTts();
    return WillPopScope(
        onWillPop: () async {
          await flutterTts.stop();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Details"),
              backgroundColor: Colors.cyan,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset("assets/profile-pic.png"),
                    Text("Imene"),
                    Text(note.noteContent),
                    Text(note.dattime),
                    GestureDetector(
                      onTap: () async {
                        await flutterTts.speak(note.noteContent);
                      },
                      child: Image.asset("assets/voice.png"),
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}