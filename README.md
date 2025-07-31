# exam-app-ios

**A study support iOS app specialized for practicing past exam questions**

This iOS application helps users efficiently prepare for exams by offering features such as time management, listening practice, and visualized study logs.

---

## Features

### Time Management
- Create tests composed of multiple sections
- Customize each section with title, icon, color, time limit, and scheduled date/time
- Add detailed elements within sections (e.g., “Question 1: 30 minutes”) for precise control
- Display remaining time with an in-app clock
- Supports pause, resume, and saving during test sessions

### Listening Practice
- Load audio files for listening exercises
- Combine multiple audio segments to create custom study flows
- Fine-grained control over playback: play, pause, repeat, etc.

### Study Logs
- Save test results by date
- Visualize time spent per section using pie charts
- View time trends across tests via bar graphs
- Includes a feature to delete saved records

### Notification System
- Schedule notifications based on test start times
- Support for notifications at the end of tests or per section
- Choose from multiple notification sounds

### User Authentication
- Login and sign-up via Google, Apple (pending verification), or Email
- Secure authentication using Firebase Authentication
- Users can change display names and sign out

### Settings
- Customize clock display (analog/digital)
- Toggle notifications on/off (test day, start/end time, in-app alerts)
- View Privacy Policy and Terms of Service

---

## 🛠 Tech Stack

| Category         | Technologies                             |
|------------------|------------------------------------------|
| Frontend         | SwiftUI                                  |
| Authentication   | Firebase Authentication (Google, Apple, Email/Password) |
| Database         | Firebase Firestore                       |
| Charts           | Charts (Swift Charts)                    |
| Audio Processing | AVFoundation                             |
| Notifications    | UserNotifications                        |
| Others           | AudioToolbox, AuthenticationServices, CryptoKit, Security |

---

## Development & Build

This project is currently in personal development.  
To run or build the app, please use Xcode.

---

## License

MIT License

---

## Author

Developer: **Takafumi Miyata** (The University of Tokyo, English Literature Major)  
GitHub: [https://github.com/Takafumi2864](https://github.com/Takafumi2864)




## 日本語版 README
**過去問演習に特化した学習サポート iOS アプリ**

試験合格に向けた効率的な学習を支援するため、時間配分の管理、リスニング練習、学習記録の可視化などの機能を備えた iOS アプリです。

---

## 主な機能

### 時間配分管理
- 複数のセクションで構成されるテストを作成可能
- 各項目に「名称 / アイコン / 色 / 制限時間 / 日時」などを設定
- セクションごとに詳細な要素（例：問1、30分）を設定し、正確な時間管理が可能
- 時計で残り時間を表示
- テスト中の一時停止・再開・記録に対応

### リスニング学習
- 音声ファイルを読み込み、リスニング演習に活用
- 複数の再生要素を組み合わせて独自の学習フローを構築
- 音声再生・一時停止・繰り返しなど細かい制御が可能

### 学習記録
- 実施したテスト結果を日付ごとに保存
- セクションごとにかかった時間を円グラフで可視化
- テスト全体の時間推移を棒グラフで表示
- 記録の削除機能も搭載

### 通知機能
- テスト開始時刻に応じて通知をスケジューリング
- テスト終了時やセクションごとの通知に対応
- 通知音は複数パターンから選択可能

### ユーザー認証
- Google / Apple（未確認） / Email によるログイン・新規登録
- Firebase Authentication による安全な認証処理
- ユーザー名の変更やサインアウト機能も実装

### 設定関連
- 時計表示のカスタマイズ（アナログ / デジタル）
- 通知設定（テスト日、開始 / 終了、アプリ内通知など）のオン / オフ切り替え
- プライバシーポリシー・利用規約の確認機能

---

## 🛠 技術スタック

| 分類 | 使用技術 |
|------|----------|
| フロントエンド | SwiftUI |
| 認証 | Firebase Authentication (Google, Apple, Email/Password) |
| データベース | Firebase Firestore |
| グラフ描画 | Charts (Swift Charts) |
| 音声処理 | AVFoundation |
| 通知 | UserNotifications |
| その他 | AudioToolbox, AuthenticationServices, CryptoKit, Security |

---

## 開発・ビルド

※現在は個人開発中のプロジェクトのため、Xcode でのビルド・実行が前提です。

---

## ライセンス

MIT License

---

## 制作

開発者：宮田尚文（東京大学 英文学専攻）  
GitHubプロフィール：https://github.com/Takafumi2864
