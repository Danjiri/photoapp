import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photoapp/photo_view_screen.dart';
import 'package:photoapp/sign_in_screen.dart';

class PhotoListScreen extends StatefulWidget{
  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late int _currentIndex;
  late PageController _controller;
  @override
  void initState(){
    super.initState();
    //PageViewで表示されているwidgetの番号を持っておく
    _currentIndex = 0;
    //PageViewの表示を切り替えるのに使う
    _controller = PageController(initialPage: _currentIndex);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo App'),
        actions: [
          //ログアウト用ボタン
          IconButton(
            onPressed: () => {},
            icon:Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: PageView(
        controller: _controller,
        //表示が切り替わったとき
        onPageChanged: (int index) => _onPageChanged(index),
        children: [
          //「全ての画像」を表示する部分
          PhotoGridView(),
          //「お気に入り登録した画像」を表示する部分
          PhotoGridView(),
          Container(
            child:Center(
              child: Text('ページ：フォト'),
            ),
          ),
          //「お気に入り登録した画像」を表示する部分
          Container(
            child: Center(
              child: Text('ページ：お気に入り'),
            ),
          ),
        ],
      ),
     //画像追加用ボタン
     floatingActionButton: FloatingActionButton(
       // 画像追加用ボタンをタップした時の処理
       onPressed: () => _onAddPhoto(),
       child: Icon(Icons.add),
     ),
      //画面下部のボタン部分
      bottomNavigationBar: BottomNavigationBar(
        //BottomNavigationBarItemがタップされた時の処理
        //  0:フォト
        //  1:お気に入り
        currentIndex: _currentIndex,
        items:[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label:'フォト',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
            label:'お気に入り',
          ),
        ],
      ),
    );
    // return Container();
  }
  void _onPageChanged(int index) {
    //PageViewで表示されているWidgetの番号を更新
    setState(() {
      _currentIndex = index;
    });
  }
  void _onTapBottomNavigationItem(int index) {
    // PageViewで表示するWidgetを切り替える
    _controller.animateToPage(
      //表示するWidgetの番号
      //  0:全ての画像
      //  1:お気に入り登録した画像
      index,
      //表示を切り替える時にかかる時間（300ミリ秒）
        duration: Duration(milliseconds:300),
        //アニメーションの動き方
        //この値を帰ることでアニメーションの動きを変えることができる
        // https://api.flutter.dev/flutter/animation/Curves-class.html
        curve:Curves.easeIn,
    );
    // PageViewで表示されているWidgetの番号を更新
    setState((){
      _currentIndex = index;
    });
  }
  Future<void> _onAddPhoto() async {
    //画像ファイルを選択
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    //画像ファイルが選択された場合
    if (result != null) {
      //ログイン中のユーザー情報を取得
      final User user = FirebaseAuth.instance.currentUser!;

      //フォルダとファイル名を指定し画像ファイルをアップロード
      final int timestamp = DateTime.now().microsecondsSinceEpoch;
      final File file = File(result.files.single.path!);
      final String name = file.path.split('/').last;
      final String path = '${timestamp}_$name';
      final TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/photos') //フォルダ名
          .child(path) //ファイル名
          .putFile(file);//画像ファイル
      //アップロードした画像のURLを取得
      final String imageURL = await task.ref.getDownloadURL();
      //アップロードした画像の保存先を取得
      final String imagePath = task.ref.fullPath;
      // データ
      final data ={
        'imageURL': imageURL,
        'imagePath': imagePath,
        'isFavorite': false, //お気に入り登録
        'createdAt':Timestamp.now(), //現在時刻
      };
      //データをCloud Firestoreに保存
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/photos') //コレクション
          .doc() //ドキュメント（何も指定しない場合は自動的にIDが決まる）
          .set(data);//データ
    }
  }
}

class PhotoGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ダミー画像一覧
    final List<String> imageList = [
      'https://placehold.jp/400x300.png?text=0',
      'https://placehold.jp/400x300.png?text=1',
      'https://placehold.jp/400x300.png?text=2',
      'https://placehold.jp/400x300.png?text=3',
      'https://placehold.jp/400x300.png?text=4',
      'https://placehold.jp/400x300.png?text=5',
    ];
    //GridViewを使いタイル状にWidgetを表示する
    return GridView.count(
      //1行あたりに表示するWidgetの数
      crossAxisCount: 2,
      // Widget間のスペース（上下）
      mainAxisSpacing: 8,
      // Widget間のスペース（左右）
      crossAxisSpacing: 8,
      //全体の余白
      padding: const EdgeInsets.all(8),
      //画像一覧
      children: imageList.map((String imageURL){
        //Stackを使いWidgetを前後に重ねる
        return Stack(
          children:[
            SizedBox(
              width:double.infinity,
              height:double.infinity,
              //Widgetをタップ可能にする
              child:InkWell(
                onTap:() => {},
                // URLを指定して画像を表示
                child: Image.network(
                  imageURL,
                  //画像の表示の仕方を調整できる
                  //比率維持しつつつ余白が出ないようにするので cover を指定
                  //https://api.flutter.dev/flutter/painting/BoxFit-class.html
                  fit: BoxFit.cover,
                ),
              ),
            ),
            //画像の上にお気に入りアイコンを重ねて表示
            // Alignment.toRightを指定し右上部分にアイコンを表示
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => {},
                color: Colors.white,
                icon: Icon(Icons.favorite_border),
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}