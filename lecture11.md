# Lecture11

1. [IaC開発支援ツール](#1-iac開発支援ツール)
2. [インフラのテスト](#2-インフラのテスト)
3. [ServerSpec](#3-serverspec)
4. [感想](#4-感想)
5. [コード](#5-コード)

## 1. IaC開発支援ツール
---
CloudFormationはYAML形式で記述しやすいが、繰り返し処理ができずDRY原則(Don't Repeat Yourself)に反してしまう。これを回避するためのツールがいくつか存在する。  
現場によって使用されるツールが異なるため、どんなものでもある程度理解できるようにベースを固めておくのがよろしい。  
  
- Terraform
現時点でシェアが最も高い。独自言語のHCLで記述する。  
AWSだけでなくAzure、GCPもほぼ同じコードで書くことができるのが強み。  
  
- Pulumi
シェア率はそんなに高くない。こちらもマルチクラウドに対応。  
記述に一般的な複数言語を使用することができる。  
機能的にはTerraformと比較しても見劣りしない。  
  
- AWS CDK (Cloud Development Kit)  
コードからCloudFormationのテンプレートが生成され、実行自体をCFnで行う。≒コードでCFnを管理する
上記の２つと異なり、CFn上で動作するため、ドリフト検知などの機能が使用できる？  
  
   
## 2. インフラのテスト
原則「仕様通り」に構築されているかの確認。サーバーが動いているか、ポートが空いているかという箇所の確認など。
インフラのスペックで解決するのであればスペック自体をあげてしまうことが最近のトレンド。  
  
- テスト駆動開発(Test Driven Development : TDD)  
テストを先に作成して、テストに通るようにプログラムを作成していくやり方。
インフラではあまりやらないが、プログラム領域ではよく使われる。
ただ、テストプログラムを作ってそれを通すとヒューマンエラーの削減や担保になるので、できればやった方がいい。  
  
- ServerSpec  
Rubyで作成されたインフラ環境をテストするためのテスティングフレームワーク。
特定のモジュールがインストールされているか、ポートの確認、任意のファイルの存在などサーバーの環境構成に関わるテストが書ける。
類似にawspecというものがある。（AWS特化）  
何度やっても同じ結果を出してくれるので信頼度が高く、素早くテストできる。コードの変更などにエラーが出たら、仕様に合わなくなっていることが検出できたりする。  
インフラの自動テストの仕組みとして提供されているものがServerSpec。  
  
テストでは途中経過が非常に大事。この経過を考えることが難しい。  
  
## 3. ServerSpec
- 初期設定  
テストしたい環境にServerSpecをインストールする必要があるが、Gemでインストールするだけなので簡単。
```
# Gemfile
gem "serverspec"
gem "rake" 
```
初期設定を済ませるとspecディレクトリ配下にサンプルが作成される
```
# ServerSpec初期設定
$ bundle install
$ bundle exec serverspec-init

#SeverSpec実行コマンド
$ bundle exec rake spec
```
  
### テストに使用したコードの備忘録([ソースコード自体は#5に記載](#5-コード))
- パッケージがインストールされているかの確認  
amazon linuxのOSファミリーは’amazon’  
このコードはOSがamazon系だった場合nginxがインストールされているか確認する。  
単にif else文でOSの判定だけもできる。
```
require 'spec_helper'

# package 
describe package('nginx'), :if => os[:family] == 'amazon' do
  it { should be_installed }
end
```
  
- 配列を使用して複数パッケージの確認  
%wは配列の作成に使用される記法。
eachはループ処理。
```
#　複数パッケージ
%w{git gcc make}.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
```

- パッケージ管理システムの確認、バージョンの指定も可能  
メジャーバージョンのみの指定も可能
```
# yarn
describe package('yarn') do
  it {should be_installed.by('npm')}
end

# rails & version
describe package('rails') do
  it { should be_installed.by('gem').with_version('7.0.4') }
end
```

- 汎用コマンドの出力を使用してテスト  
```
# コマンドでrubyバージョンチェック
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

# パスの確認
describe command('which mysql') do
  its(:exit_status) { should eq 0 }
end
```

- HTTPステータスコードの確認
```
listen_port = "80"

# HTTP 200 OK 
describe command("curl http://127.0.0.1:#{listen_port} -o /dev/null -w \"%{http_code}\\n\" -s") do
  its(:stdout) { should match /^200$/ }
end
```
`/  /`で囲うと正規表現になる。`^`は行のはじめ、`$`は行の終わり。なので、`its(:stdout) {should match /^200$/}`は`200`に完全一致した時にテストをパスする。  
正規表現内の`.`はメタ文字のため、バックスラッシュが必要。  
  
`'curl http://127.0.0.1:#{listen_port}/_plugin/head/ "%{http_code}\n" -s'`  
上は元のサンプルコードのオプション部分以外の抜粋だが、これに書かれている`_plugin/head/`はElasticSearchをインストールしないと(?)使えず、エラーが出ていたので該当の箇所を削除した。  
また、構文にもエラーがあり、curlの前のクォートがシングルだったため、#{listen_port}が展開されていなかった。  
ダブルクォートにすると%{http_code}前のダブルクォートと干渉するため、エスケープする必要がある。最終的にダブルクォートとバックスラッシュをエスケープして、_plugin/headを削除したらテストが通った。  

|    項目　　       | クォートの説明 |
| --               | --           |
|ダブルクォート "    |変数展開やエスケープシーケンスが有効になる。#{listen_port}には代入した 80 が読み込まれる。|
|シングルクォート '  |クォートに囲われた文字はただの文字列と認識される。#{listen_port}はそのまま認識される。|
|バッククォート `    |コマンド実行に使用される。囲われた文字はコマンドに置換される。|

## 4. 感想
ServerSpecの実行
``` shell
$ bundle exec rake spec

Package "nginx"
  is expected to be installed

Package "git"
  is expected to be installed

Package "gcc"
  is expected to be installed

Package "make"
  is expected to be installed

Package "yarn"
  is expected to be installed by "npm"

Package "rails"
  is expected to be installed by "gem" with version "7.0.4"

Command "ruby -v"
  stdout
    is expected to match /ruby 3\.1\.2/

Command "which mysql"
  exit_status
    is expected to eq 0

Command "curl http://127.0.0.1:80 -o /dev/null -w "%{http_code}\n" -s"
  stdout
    is expected to match /^200$/

Command "size=`df -h |grep /dev/xvda | awk '{printf ("%4.0f", $2)}'`; test $size -eq 8; echo $?"
  stdout
    is expected to match "0"

Port "80"
  is expected to be listening

Service "nginx"
  is expected to be enabled
  is expected to be running

File "/home/ec2-user/raisetech-live8-sample-app/config/database.yml"
  content
    is expected to match /socket:\s*\/var\/lib\/mysql\/mysql\.sock/

File "/home/ec2-user/.ssh"
  is expected to be directory
  is expected to be owned by "ec2-user"
  is expected to be grouped into "ec2-user"
  is expected to be mode "700"

Finished in 1.44 seconds (files took 0.54266 seconds to load)
18 examples, 0 failures
```


## 5. コード
テストのために作成したコードは"lec11_serverspec"にアップロードしました。  