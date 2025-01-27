# QiitaWatch-iOS

公開用の Qiita 記事閲覧 iOS アプリ

## 技術スタック

- 言語: Swift
- フレームワーク: UIKit
- ライブラリ: Alamofire, Swift Concurrency, XCTest
- パッケージ管理: SPM
- IDE: Xcode_16.1
- アーキテクチャ
  - UI 層: MVVM
  - モデル層: Repository

## ビルド方法

### 前提

Xcode のバージョンは上記で指定した通り`16.1`を使用する。
下記コマンドでバージョンを確認し、必要に応じてバージョンを変更すること。

```
xcodebuild -version
```

### 手順

1. 以下コマンドで任意のローカルディレクトリにてリポジトリをクローンする

```
git clone https://github.com/stotic-dev/QiitaWatch-iOS.git
```

2. クローン後下記コマンドを実行する

```
cd QiitaWatch-iOS
make setup
```

3. 上記コマンドで Xcode が開くので、`Command + B`でビルドする
4. ビルド完了

## 機能説明

### ユーザー検索画面

- ユーザ ID の入力を受け付ける
- 検索ボタンタップで
- ユーザ情報取得を試みる
  - API: GET https://qiita.com/api/v2/users/:user_id
- 正常時にはユーザー情報画面にて検索結果を表示(Push 遷移)
- 異常時にはエラーをダイアログなどで表示
- 過去利用した検索ワードをテーブルで列挙
- 過去利用した検索ワードは永続化データとして保存する
- 検索ワードをタップするとテキストフィールドに入力する
- 検索ワードの表示は使用した(テキストフィールドに入力)日時の降順

### ユーザー詳細画面

- ユーザ情報を表示する
  - 表示項目
    - アイコン画像
    - ユーザ名 (id)
    - 自己紹介文
    - フォロー数、フォロワー数
- フォロー数、フォロワー数をタップした場合にフォロー、フォロワー画面に遷移する
- 記事一覧を表示する
  - API: https://qiita.com/api/v2/users/:uesr_id/items
  - 表示項目
    - タイトル
    - タグ
    - LGTM 数
    - 投稿日時
- 記事のセルをタップした場合に記事表示画面に遷移する(Push 遷移)
- 記事は 1 回の取得処理で 10 件ずつ取得する
- リストの上部で上から下にスワイプすると、新規記事がないか確認する
- リストの下部で下から上にスワイプスすると、次ページの記事を取得する
- リストは記事の投稿日時の降順で表示する

### 記事画面

- ユーザー詳細画面で取得した記事のリストから選択された記事を表示する
  - iOS なら SFSafariViewController, Android なら CustomTabs を利用する

### フォロー(フォロワー)画面

- フォロー (フォロワー) の一覧を表示する
  - API
    - followee: GET https://qiita.com/api/v2/users/:user_id/followees
    - follower: GET https://qiita.com/api/v2/users/:user_id/followers
  - 表示項目
  - アイコン画像
  - ユーザ名 (id)
  - フォロー数
  - フォロワー数
- セルをタップした場合にユーザー詳細画面に遷移する(Modal 遷移)
- ユーザーは 1 回の取得で 10 件取得する
- リストの上部で上から下にスワイプすると、新規ユーザーがないか確認する
- リストの下部で下から上にスワイプスすると、次ページのユーザーを取得する
- ユーザーは ID の昇順で表示する
