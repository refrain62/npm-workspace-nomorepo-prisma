# npmのworkspaceでモノレポ化しつつ、prismaの型・スキーマを共有する構成
https://zenn.dev/greenspot/articles/021e5eda2057a6 の写経

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

または、マイグレーションの内容を変更して再適用する
migration_sql
```
-- CreateTable
CREATE TABLE "Record" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL
);

INSERT INTO "Record"
(
    id,
    title,
    content
)
VALUES
(
    1,
    'テスト1',
    'テスト1内容'
),
(
    2,
    'テスト2',
    'テスト2内容'
)
;
```
そして再適用
```
npx -w database prisma migrate dev
```


## アプリケーションでPrismaを使う
### TypeScriptの初期設定
※TypeScriptに対応したセットアップツールを使い、ワークスペース単位で対応する場合はこの作業は必要ありません。

TypeScriptはモノレポ全体で共通の設定で使いたいため、各ワークスペースではなくプロジェクト自体に設定します。`tsconfig.json`については、適宜変更してください。
```
$ npm i -D @types/node ts-node typescript
$ npx tsc --init
```
※ワークスペースごとにTypeScriptを設定したい場合は、これまでと同様に`-w`オプションを使います。
```
$ npm -w app1 i -D @types/node ts-node typescript
$ npx -w app1 tsc --init
```

### ワークスペースの作成
```
$ npm -w apps/app1 init -y
```

### 実際にPrismaClientを使ってみる
作成したワークスペースapps/app1に、テスト用のスクリプトを用意します。

apps/app1/index.ts
```
import { PrismaClient } from "@prisma/client"

main()

async function main() {
  const prisma = new PrismaClient()
  const records = await prisma.record.findMany({})
  console.log(records)
}
```

### コンパイル
下記を実行し、apps/app1/index.jsが生成されたら成功です。
```
$ npx -w app1 tsc
```
### 実行
生成されたファイルを実行し、Prisma Studioで入力したテストデータが表示されたら成功です。
```
$ node apps/app1/index.js 
[
  { id: 1, title: 'テスト1', content: 'テスト1内容' },
  { id: 2, title: 'テスト2', content: 'テスト1内容' }
]
```

## その他のアプリケーションを追加する
ワークスペースからのPrismaClientのインポートについては、上記で見たように、階層を特に気にせずに読み込むことができます。
```
import { PrismaClient } from "@prisma/client"
```

### npm create vite
各種フレームワークをセットアップする場合、Viteなどのツールを使うかと思います。
```
$ npm -w apps/app2 init -y
$ npm -w apps/app2 create vite@latest
✔ Project name: … .
...
```
この時Project nameを指定すると、ワークスペース下にもう一つ階層ができてしまうので、.と入力しましょう。npm createコマンド時に指定することもできます。
```
$ npm -w apps/app2 create vite@latest .
```
アプリを起動する
```
$  npm -w apps/app2 run dev
```

## npm init以外のワークスペースの追加方法
開発中に、特定のディレクトリをワークスペースとして追加したい場合は、ルートのpackage.jsonを編集する必要があります。workspaces配列にパスを追加しましょう。

package.json
```
{
  ...
  "workspaces": [
    "apps/app1"
  ]
}
```
