Konashi-iBeacon
===============
##概要
KonashiのAIO0ポートで取得した値をiBeaconのMajorNumberに乗せてブロードキャストを行います。
ブロードキャストされたデータは、他のiOSデバイスから参照することができます。

例えば、温度センサが接続されたKonashiとiPhoneを用意すれば、付近にある別のiPhoneに対して、温度のデータをブロードキャストすることができます。
また、iBeaconの機能と組み合わせることで、その情報がどの程度離れたところから発信されているかを知ることができます。

iBeacon関連のハードウェアはこれから多数登場することが予想されますが、既にお持ちのKonashiとこのアプリを組み合わせることで、iBeaconとフィジカルコンピューティングを組み合わせたプロトタイピングが可能になります。

Aio-Beacon-Sample は、KonashiとBluetooth LEで接続を行い、AIOポートから取得した値をiBeaconのMajorNumberとしてブロードキャストを行います。
Aio-Beacon-Receiver は、Aio-Beacon-Sampleがブロードキャストしているデータを受信します。

## 既知の問題
ブロードキャストされるデータの更新間隔はリアルタイムではありません。iOSの仕様により、データの更新までにはタイムラグがあります。
（いったんAdvertising Dataの内容を変更するには、Advertisingを停止する必要があるため。また、iBeaconの電波を受信するライブラリは１秒に１回しかデータをレポートしないためです。この問題の修正方法をご存知の方がいらっしゃいましたら、お知らせいただけると幸いです。）

アプリケーションがBackground, Suspendedの状態では動作しません。これは、iOSの仕様によるものと考えています。