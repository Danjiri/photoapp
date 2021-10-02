import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoapp/photo_list_screen.dart';

class SignInScreen extends StatefulWidget{
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Formのkeyを指定する場合は<FormState>としてGlobalKeyを定義する
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //メールアドレス用のTextEditingController
  final TextEditingController _emailController = TextEditingController();
  //パスワード用のTextEditingController
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:24),
            //Columnを使い縦に並べる
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //タイトル
                Text(
                  'Photo App',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 16),
                //入力フォーム（メアド）
                TextFormField(
                  //TextEditingControllerを設定
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  //メール用のバリデーション
                  validator: (String? value) {
                    // メールアドレスが入力されていない場合
                    if (value?.isEmpty == true) {
                      // 問題があるときはメッセージを返す
                      return 'メールアドレスを入力して下さい';
                    }
                    // 問題ないときはnullを返す
                    return null;
                  },
                ),
                SizedBox(height: 8),
                //入力フォーム（パスワード）
                TextFormField(
                  //TextEditingControllerを設定
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText:'パスワード'
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  //パスワード用のバリデーション
                  validator: (String? value) {
                    //パスワードが入力されていない場合
                    if (value?.isEmpty == true) {
                      //問題があるときはメッセージを返す
                      return 'パスワードを入力して下さい';
                    }
                    //問題ないときはnullを返す
                    return null;
                  },
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  //ボタン（ログイン）
                  child: ElevatedButton(
                    // ログインボタンをタップしたときの処理
                    onPressed: () => _onSignUp(),
                    child: Text('ログイン'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  //ボタン（新規登録）
                  child: ElevatedButton(
                    //新規登録ボタンをタップしたときの処理
                    onPressed: () => _onSignUp(),
                    child: Text('新規登録'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _onSignIn() {
    //入力内容を確認する
    if (_formKey.currentState?.validate() != true) {
      //エラーメッセージがあるため処理を中断する
      return;
    }
    // 画像一覧画面に切り替え
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PhotoListScreen(),
      ),
    );
  }

  Future<void> _onSignUp() async {
    try {
      //入力内容を確認する
      if (_formKey.currentState?.validate() != true){
        //エラーメッセージがあるため処理を中断する
        return;
      }
      // メールアドレス・パスワードで新規登録
      // TextEditingControllerから入力内容を取得
      // Authenticationを使った複雑な処理はライブラリがやってくれる
      final String email = _emailController.text;
      final String password = _passwordController.text;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      //画像一覧画面に切り替え
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PhotoListScreen(),
        ),
      );
    } catch (e) {
      //　失敗したらエラーメッセージを表示
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('エラー'),
              content: Text(e.toString()),
            );
          },
      );
    }
  }
}