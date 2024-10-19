import 'package:flutter/material.dart';
import 'package:flutter/services.dart';// show rootBundle, AssetManifest;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uta Sanshin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: LinearBorder(),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Uta Sanshin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  String musicTitle = "";
  String lyrics = "";
  double lyricsSize = 20.0;
  List lyricsTypes = [];
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;
  Set musicList = {};
  dynamic assetsList;

  Future<Set> getMusicList() async{
    // assets/lyrics/music_name must be added in pubspec.yaml
    AssetManifest allAssets = await AssetManifest.loadFromAssetBundle(rootBundle);
    assetsList = allAssets.listAssets();
    setState(() {
      // music names
      musicList = assetsList.where((String element) => element.contains('lyrics'))
        .map((element) => element.replaceAll('lyrics/', ''))
        .map((element) => element.replaceAll(RegExp('/.*'), ''))
        .map((element) => element.replaceAll(('_'), ' '))
        .toSet();
    });
      
    return musicList;
  }

  Future<String> getLyrics(String name, String type) async {
    String response;
    String fileName = name.replaceAll(' ', '_');

    lyricsTypes = assetsList.where((String element) => element.contains(fileName))
      .map((element) => element.replaceAll(RegExp('lyrics/.*_'), ''))
      .map((element) => element.replaceAll('.txt', ''))
      .toList();


    response = await rootBundle.loadString('lyrics/${fileName}/${fileName}_${type}.txt');
    setState(() {
      musicTitle = name;
      lyrics = response;
      _tabController.index = 1;
    });
    return response;
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getMusicList();
  }
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: NestedScrollView(headerSliverBuilder:
        (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: Text('Uta Sanshin'),
                floating: true,
                snap: true,
                actions: [
                  ElevatedButton.icon(
                    onPressed: () =>  setState(() {
                      _scrollController.animateTo( _scrollController.position.maxScrollExtent,
                        curve: Curves.linear,
                        duration: Duration(seconds: 60),
                      );
                    }),
                    label: Icon(Icons.height)),
                  ElevatedButton.icon(
                    onPressed: () =>  setState(() {
                      lyricsSize += 1.0;
                    }),
                    label: Icon(Icons.add)),
                  ElevatedButton.icon(
                    onPressed: () =>  setState(() {
                      lyricsSize -= 1.0;
                    }),
                    label: Icon(Icons.remove)),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: <Widget>[
                      Tab(
                      text: 'Lista de Músicas',
                    ),
                      Tab(
                      text: 'Letra',
                    ),
                  ]
                ),
              )
            )
          ];
        },
        body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              // Lista de Músicas
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: const Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        'Coleção de letras de canções populares tradicionais de Ryuukyuu',
                      ),
                    ),
                    for (var musicName in musicList)
                    TextButton(
                      onPressed: () =>  setState(() {
                        getLyrics(musicName, 'romaji');
                      }),
                      child: Text(musicName)),
                  ],
                ),
              ),
              // Letra
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: lyricsTypes.contains('romaji') ?
                            () => getLyrics(musicTitle, 'romaji') : null,
                          child: Text('romaji'),
                        ),
                        ElevatedButton(
                          onPressed: lyricsTypes.contains('kana') ?
                            () => getLyrics(musicTitle, 'kana') : null,
                          child: Text('kana'),
                        ),
                      ],
                    ),
                    Text(musicTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: lyricsSize + 5.0,
                      )
                    ),
                    Text(lyrics.toUpperCase(),
                      style: TextStyle(
                        fontSize: lyricsSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
