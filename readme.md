# npmのworkspaceでモノレポ化しつつ、prismaの型・スキーマを共有する構成
https://zenn.dev/greenspot/articles/021e5eda2057a6

## 主な構成
app1は、frontend, backendなどと置き換えてもらって構いません。
```
project/
 ├ apps/
 │  ├ app1/
 │  └ ...
 └ packages/
    └ database/
```

## プロジェクトの初期化
```
$ cd /path/to/project
$ npm init -y
```

## prismaのインストール

### ワークスペースの作成
databaseというワークスペースを作成
```
$ npm -w packages/database init -y
```
また、ルートのnode_modules/には、databaseワークスペースへのシンボリックリンクが自動生成されます。
