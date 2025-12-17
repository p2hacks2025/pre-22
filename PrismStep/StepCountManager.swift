//
//  StepCountManager.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/16.
//

import Foundation
import HealthKit//ヘルスケアのデータを使うためにインポート
import Combine

class StepCountManager: ObservableObject {
    let healthStore = HKHealthStore()//データをアクセスするためのAppleが用意した道具
    //.stepCountを使うことで歩数専用の型情報を取得し、「HKQuantityType」というクラスに渡してる。.stepCountはシステム定義値なので絶対に値があるという宣言を意味する!をつける
    let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!//検索対象を歩数に限定する。クラス内全体で使えるように、ここで宣言。
    // 取得した歩数（画面側から監視できるように @Published をつける）
    //歩数は変わるから、変数であるvarを使う
    @Published var todaySteps: Int = 0
    //initはClassが呼び出された時に１回だけ実行
    init() {
        requestAuthorization()//許可を求める
    }
    func requestAuthorization() {
        let readTypes: Set = [stepType]
        //toShareは書き込み権限、readは読み込み権限で：の後のやつをそれぞれ渡してる（）
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("許可されました")
                // クラス内メソッドの呼び出し
                self.fetchTodaySteps()
            } else {
                print("エラーが起きました: \(String(describing: error))")
            }
        }
    }
    //今日の0時0分から現在時刻までの歩数を合計して、todaySteps 変数に入れる処理を行う関数
    func fetchTodaySteps(){
        //「今日の0時0分」から「今」までの期間を設定
        let now = Date()//現在時刻
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        //データを集計するクエリを作成
        //クエリはたくさんあるヘルスケアの情報から、歩数と今日の情報だよってことを検索するもの
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in

            // エラーチェック
            if let error = error {
                print("クエリエラー発生: \(error.localizedDescription)")
                return
            }
            // 結果を取り出す作業
            //guardはもし条件を満たさなかったら、ここで終了するよってもの
            guard let result = result, let sum = result.sumQuantity() else {
                print("データが見つかりませんでした（または0歩です）")
                return }
            let steps = Int(sum.doubleValue(for: HKUnit.count()))//歩数をintに変換して使いやすくする
            // コンソールに出力（ロジックが実装できているかの確認用）
            print("今日の歩数: \(steps)歩")
            // 取得した数図をアプリの画面に反映させる。UIの更新はメインスレッドで行うというiOSの鉄則を守るためのコード
            DispatchQueue.main.async {
                self.todaySteps = steps//ここで値を入れてる
            }
        }
        //クエリを実行する
        healthStore.execute(query)
    }
}
