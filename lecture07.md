# Lecture07

##　現環境で考えられる脆弱性と対策
---
**1. アプリ、ミドルウェアの脆弱性**  

+ Web上にアプリケーションを公開しているため、SSL化とWAFを導入したほうがいい。
+ Amazon InspectorでEC2の脆弱性を診断して対策をとる。
+ EC2のセキュリティグループでSSHポートを開放しているため、キーペアが流出した際に簡単にアクセスされてしまう。IPを適切に設定する。

**2. 認証情報の管理**  

+ SSMでDBのマスターユーザーとパスワードを管理して、自動でローテーションさせる。
+ 現在アプリのクレデンシャルファイルに書き込まれているS3管理用のアクセスキーとシークレットキーをKMSで管理。また、定期的に変更する。
+ その他のIAMユーザーのパスワード/アクセスキーを定期的に変更。
+ 上記を安全に運用するために適切に権限をアタッチする必要がある。

**3. セキュリティグループの設定**  

外出先でも作業するために、都度自身のIPをインバウンドルールに反映させるスクリプトを作成した。
```
# addssh.sh
MYSECURITYGROUP=sg-******
# IP取得
MYIP=`curl -s ifconfig.me`

# インバウンドルールにIP追加
aws ec2 authorize-security-group-ingress --group-id $MYSECURITYGROUP --protocol tcp --port 22 --cidr $MYIP/32 
#　追加したIPを削除
#aws ec2 revoke-security-group-ingress --group-id $MYSECURITYGROUP --protocol tcp --port 22 --cidr $MYIP/32
```