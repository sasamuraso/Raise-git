## Lecture03 

### Webアプリケーションのデプロイ
[app画面.png](./image/Lecture03/L3_l3app.png "app画面.png")

動画を参考にコマンドを打ち込むも"接続が拒否されました"と表示された。
環境構築が間違っていたのかと思い何度かEC2インスタンスを建て直したが、
プレビュー画面で表示できないだけでブラウザで開いたらちゃんと起動できていた。Wow!

### APサーバーとDBサーバー
**・APサーバーはアプリケーションを動作させるためのサーバー。**<br>
本レクチャーではPumaを使用していた。<br>
```
 $ rails s
 
 Puma version: 5.6.5 (ruby 3.1.2-p20) ("Birdie's Version")
```


**・DBサーバーはMyAQLを使用している。入力されたデータを管理するシステム。**
```
mysql> status
--------------
mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)

Server version:         8.0.33 MySQL Community Server - GPL
```


**・APサーバー停止**
```
kill -9 <>
```
アプリケーションサーバーが動いていないため以下のメッセージが表示される。<br>
[AP stop.png](./image/Lecture03/L3_APstop.png "APstop.png")


**・DBサーバー停止**
```
$ sudo service mysqld stop
```
MySQLサーバーのソケットファイルに接続できないとエラー表示<br>
[DB stop.png](./image/Lecture03/L3_DBstop.png "DB stop.png")

**・Puma、mysql共に再起動するとアプリケーションページは正常に表示される。**

### Rails構成管理ツール
今回使用したのはBundler<br>
アプリごとに異なる必要なGemをまとめてインストールしてくれるもの


### Lecture03まとめ
**・Ruby Webアプリケーションのデプロイの流れ**<br>
-アプリの指定するバージョンのRubyとBundlerとyarn(or npm)のインストール<br>
-DBサーバーをたてる<br>
-bundlerで必要なGemをインストール<br>
-bin/devでアプリケーション起動<br>

**・bin/dev**：binには起動時やメンテ時に必要なコマンドが格納されている<br>
  devには railsアプリを起動するためのシェルスクリプトが記述されている<br>
  
**・bundle exec rails db:create**<br>
 Gemfileに記述された環境でデータベースを作成する<br>
 
**・Gemfile**：Gemの依存関係を記述したもの<br>
**・foreman**：Pricfileに記述されたコマンドを同時に実行できる。アプリ開発でよく使われる。<br>
**・yarn**：javascriptのパッケージマネージャー≒npm　どちらを使うかはアプリケーション次第<br>
**・Cloud9のプレビューではアプリは表示されない**
