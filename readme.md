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


### 必要なパッケージのインストール
database ワークスペースにprismaをインストールする。
ワークスペース内でnpmコマンドを実行するには、基本的に`npm -w {workspace} {command}`と記述する。npxも同様
```
$ npm -w database i @prisma/client
$ npm -w database i prisma -D
$ npx -w database prisma init
```
`npx prisma init`コマンドで、下記ファイルの雛形が用意されます。

- `packages/database/.env`
- `packages/database/prisma/schema.prisma`


