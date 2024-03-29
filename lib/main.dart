import 'package:flutter/material.dart';
import 'cards.dart';
import 'matches.dart';
import 'profiles.dart';

void main() => runApp(MyApp());

final MatchEngine matchEngine = MatchEngine(
  matches: demoProfiles.map((Profile profile){
    return TinderMatch(profile: profile);
  }).toList(),
);

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColorBrightness: Brightness.light
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

}

class MyHomePage extends StatefulWidget {
  String title = "Tinder";
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Widget _buildAppBar(){
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.grey,
            size: 40.0,
          ), onPressed: (){
            //TODO
            }
          ),
      title: Center(
          child: FlutterLogo(
            size: 30.0,
            colors: Colors.red,
          )
      )
      ,
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.chat_bubble,
              color: Colors.grey,
              size: 40.0,
            ), onPressed: (){
          //TODO
        }),
      ],
    );
  }

  Widget _buildBottomBar(){
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RoundIconButton.small(
              icon: Icons.refresh,
              iconColor: Colors.orange,
              onPressed: (){},
            ),
            RoundIconButton.large(
              icon: Icons.clear,
              iconColor: Colors.red,
              onPressed: (){
                matchEngine.currentMatch.dislike();
              },
            ),
            RoundIconButton.small(
              icon: Icons.star,
              iconColor: Colors.blue,
              onPressed: (){
                matchEngine.currentMatch.superlike();
              },
            ),
            RoundIconButton.large(
              icon: Icons.favorite,
              iconColor: Colors.green,
              onPressed: (){
                matchEngine.currentMatch.like();
              },
            ),
            RoundIconButton.small(
              icon: Icons.lock,
              iconColor: Colors.purple,
              onPressed: (){},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: CardStack(
        matchEngine: matchEngine,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

class RoundIconButton extends StatelessWidget{

  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 60.0;

  RoundIconButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 50.0;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000),
            blurRadius: 10.0
          )
        ]
      ),
      child: RawMaterialButton(
          shape: CircleBorder(),
          elevation: 0.0,
          child: Icon(icon, color: iconColor,),
          onPressed: onPressed
      ),
    );
  }

}
