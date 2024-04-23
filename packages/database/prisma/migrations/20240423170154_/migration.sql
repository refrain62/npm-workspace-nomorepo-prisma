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
