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
    
    // 取得した歩数（画面側から監視できるように @Published をつける）
    //歩数は変わるから、変数であるvarを使う
    @Published var todaySteps: Int = 0
    //initはClassが呼び出された時に１回だけ実行
    init() {
        requestAuthorization()//許可を求める
    }
    func requestAuthorization() {
        //.stepCountを使うことで歩数専用の型情報を取得し、「HKQuantityType」というクラスに渡してる。.stepCountはシステム定義値なので絶対に値があるという宣言を意味する!をつける
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set = [stepType]//APIに渡すために、データの型を集合（Set）に変換している
        //toShareは書き込み権限、readは読み込み権限で：の後のやつをそれぞれ渡してる（）
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("許可されました")
                // クラス内メソッドの呼び出し
                //self.fetchTodaySteps()
            } else {
                print("エラーが起きました: \(String(describing: error))")
            }
        }
    }
}
