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

### スキーマの記述
SQLite3のデータベースを用意する

 [packages/database/.env] 
```
DATABASE_URL="file:/path/to/database.sqlite"
```

[packages/database/prisma/schema.prisma]
```
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

model Record {
  id      Int    @id @default(autoincrement())
  title   String
  content String
}
```

### マイグレーションとPrismaClientの生成
```
$ npx -w database prisma migrate dev
```
マイグレーションが不要な場合はこちら
```
$ npx -w database prisma generate
```

### テストデータの用意
Prismaには、Prisma Studioという簡易的なビジュアルエディタがあるので、簡単にテストデータの追加・削除を行うことができます。
```
$ npx -w database prisma studio
```
これでdatabaseパッケージの準備が整いました。実際にアプリケーションからPrismaClientをインポートして使ってみましょう。


## 