//
//  ViewController.swift
//  Calculator
//
//  Created by Akifumi Yao on 04/09/2019.
//  Copyright © 2019 Akifumi Yao. All rights reserved.
//

import UIKit
import AVFoundation

enum Operator{
    case undefined   // 未定義
    case addition   // 加法
    case subtraction   // 減法
    case multiplication   // 乗法
    case division   // 除法
}


class ViewController: UIViewController, AVAudioPlayerDelegate {
    var firstValue: Float = 0   // 一回目の値
    var secondValue: Float = 0   // ２回目の値
    var currentOperator = Operator.undefined   // 現在の演算子
    var onDecimal = false
    var str : String = ""   // 入力中の文字列
    var pointButtonTapped = false   // 小数点入力のフラグ
    var audioPlayer: AVAudioPlayer!   // オーディオプレイヤー
    var soundFlg: Bool = false   // サウンドのOnOffフラグ
    var memoryPlus: Float = 0
    var memoryMinus: Float = 0
    var memoryState = 0   // 0...何も押されてない, 1...mr, 2...m-
    var allClearCancelState: Int = 0   // ACかCかの判別
    //var isZero: Bool = false   // 0かの判別フラグ
    
    // 横向きで出てくるスタックたち
    @IBOutlet weak var SideModeStack0: UIStackView!
    @IBOutlet weak var SideModeStack1: UIStackView!
    @IBOutlet weak var SideModeStack2: UIStackView!
    @IBOutlet weak var SideModeStack3: UIStackView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // 通知センターのオブジェクトをす作る
        let notification = NotificationCenter.default
//
        // デバイスの向きが変わった
        notification.addObserver(self,
                                selector: #selector(self.changeDeviceOrientation(_:)),
                                name: UIDevice.orientationDidChangeNotification, object: nil
        )
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
//    // イベントで呼び出されるメソッド
    @objc func changeDeviceOrientation(_ notification :Notification){
        // デバイスを取得する
        let device = UIDevice.current

        // デバイスの向きを調べる
        switch device.orientation {
        case .portrait:   // ポートレート
            self.SideModeStack0.isHidden = true
            self.SideModeStack1.isHidden = true
            self.SideModeStack2.isHidden = true
            self.SideModeStack3.isHidden = true
        case .landscapeLeft:   // デバイスは左回転
            self.SideModeStack0.isHidden = false
            self.SideModeStack1.isHidden = false
            self.SideModeStack2.isHidden = false
            self.SideModeStack3.isHidden = false
        case .landscapeRight:   // デバイスは右回転
            self.SideModeStack0.isHidden = false
            self.SideModeStack1.isHidden = false
            self.SideModeStack2.isHidden = false
            self.SideModeStack3.isHidden = false
        default:
            break
        }
    }
    
    // 音声ファイルをさ再生する処理
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }
        
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self
            
            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }

    // 数字ボタンが押された処理
    @IBOutlet weak var ACButton: UIButton!
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        str += sender.currentTitle!
        
        if soundFlg{
            switch sender.currentTitle {
                case "1":
                    playSound(name: "do")
                case "2":
                    playSound(name: "re")
                case "3":
                    playSound(name: "mi")
                case "4":
                    playSound(name: "fa")
                case "5":
                    playSound(name: "so")
                case "6":
                    playSound(name: "ra")
                case "7":
                    playSound(name: "si")
                case "8":
                    playSound(name: "do1")
                default:
                    break
            }
        }
        
        // ACとCの切り替えステイト
        allClearCancelState = 1
        ACButton.setTitle("C", for: .normal)
        
        if currentOperator == .undefined {
            if let v = Float(str){
                firstValue = v
            }
            label.text = str
        }
        else {
            if let v = Float(str){
                secondValue = v
            }
            label.text = str
        }
    }
    
    // 小数点ボタンが押された時の処理
    @IBAction func pointButtonTapped(_ sender: UIButton) {
        if !pointButtonTapped {
            str += sender.currentTitle!
            if let v = Float(str){
                firstValue = v
            }
            label.text = str
            pointButtonTapped = true
        }
        
    }
    // 演算子ボタンが押された処理
    @IBAction func opperatorButtonTapped(_ sender: UIButton) {
        if currentOperator != .undefined{
            Calculate()
        }
        switch sender.currentTitle! {
        case "+":
            currentOperator = .addition
        case "-":
            currentOperator = .subtraction
        case "×":
            currentOperator = .multiplication
        case "÷":
            currentOperator = .division
        default:
            currentOperator = .undefined
        }
        
        str = ""
        pointButtonTapped = false
    }
    
    // 計算する処理
    func Calculate(){
        var value: Float = 0
        switch currentOperator{
            case .addition:
                value = firstValue + secondValue
            case .subtraction:
                value = firstValue - secondValue
            case .multiplication:
                value = firstValue * secondValue
            case .division:
                value = firstValue / secondValue
            case .undefined:
                value = firstValue
        }
        
        label.text = "\(value)"
        firstValue = value
        pointButtonTapped = false
    }
    // イコールボタンが押された処理
    @IBAction func equalButtonTapped(_ sender: UIButton) {
        Calculate()
    }
    
    // ACボタンが押された処理
    @IBAction func allClearButtonTapped(_ sender: UIButton) {
        if allClearCancelState == 0{
            currentOperator = .undefined
        }
        if allClearCancelState == 1{
            ACButton.setTitle("AC", for: .normal)
            allClearCancelState = 0
        }
        if currentOperator == .undefined
        {
            firstValue = 0
            label.text = "0"
        } else {
            secondValue = 0
            label.text = "0"
        }
        
        pointButtonTapped = false
        str = ""
    }
    
    // +/-ボタンが押された処理
    @IBAction func changeSignButtonTapped(_ sender: UIButton) {
        if currentOperator == .undefined {
            firstValue *= -1
            label.text = "\(firstValue)"
        } else {
            secondValue *= -1
            label.text = "\(secondValue)"
        }
    }
    
    // %ボタンが押された処理
    @IBAction func percentButtonTapped(_ sender: UIButton) {
        if currentOperator == .undefined {
            firstValue /= 100
            label.text = "\(firstValue)"
        } else {
            secondValue /= 100
            label.text = "\(secondValue)"
        }
    }
    
    // x^2の計算
    @IBAction func squareButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        if currentOperator == .undefined{
            firstValue *= firstValue
            value = firstValue
        } else {
            secondValue *= secondValue
            value = secondValue
        }
        label.text = "\(value)"
        str = ""
    }
    
    // x^3の計算
    @IBAction func cubeButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        if currentOperator == .undefined{
            firstValue = firstValue * firstValue * firstValue
            value = firstValue
        } else {
            secondValue = secondValue * secondValue * secondValue
            value = secondValue
        }
        label.text = "\(value)"
        str = ""
    }
    
    // eボタンを押した時の処理
    @IBAction func eButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        if currentOperator == .undefined{
            firstValue = 2.718281828459045
            value = firstValue
        } else {
            secondValue = 2.718281828459045
            value = secondValue
        }
        label.text = "\(value)"
        str = ""
    }
    
    // πボタンを押した時の処理
    @IBAction func piButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        if currentOperator == .undefined{
            firstValue = 3.141592653589793
            value = firstValue
        } else {
            secondValue = 3.141592653589793
            value = secondValue
        }
        label.text = "\(value)"
        str = ""
    }
    
    // taxボタンを押した時の処理
    @IBAction func taxButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        if currentOperator == .undefined{
            firstValue *= 1.08
            value = firstValue
        } else {
            secondValue *= 1.08
            value = secondValue
        }
        label.text = "\(value)"
        str = ""
    }
    
    // sdボタンを押した時の色の切り替え
    @IBOutlet weak var sdButton: UIButton!
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        if soundFlg {
            sdButton.backgroundColor = UIColor(red:64/255, green:64/255, blue:61/255, alpha:1.0)
            sdButton.setTitleColor(UIColor.white, for: .normal)
            soundFlg = false
        } else {
            sdButton.backgroundColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
            sdButton.setTitleColor(UIColor.black, for: .normal)
            soundFlg = true
        }
    }
    
    // mrボタンの処理
    @IBOutlet weak var mrButton: UIButton!
    @IBAction func memoryRecallButtonTapped(_ sender: UIButton) {
        var value: Float = 0
        switch memoryState {
        case 1:
            if currentOperator == .undefined{
                firstValue = memoryPlus
                value = firstValue
            } else {
                secondValue = memoryPlus
                value = secondValue
            }
            label.text = "\(value)"
        case 2:
            if currentOperator == .undefined{
                firstValue = memoryMinus
                value = firstValue
            } else {
                secondValue = memoryMinus
                value = secondValue
            }
            label.text = "\(value)"
        default:
            break
        }
    }
    
    // m-ボタンを押した時の処理
    @IBAction func memoryMinusButtonTapped(_ sender: UIButton) {
        if currentOperator == .undefined{
            memoryMinus = firstValue * -1
        } else {
            memoryMinus = secondValue * -1
        }
        mrButton.setTitleColor(UIColor.black, for: .normal)
        mrButton.backgroundColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
        memoryState = 2
    }
    
    // m+ボタンを押した時の処理
    @IBAction func memoryPlusButtonTapped(_ sender: UIButton) {
        //var value: Float = 0
        if currentOperator == .undefined{
            memoryPlus = firstValue
        } else {
            memoryPlus = secondValue
        }
        mrButton.setTitleColor(UIColor.black, for: .normal)
        mrButton.backgroundColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
        memoryState = 2
        memoryState = 1
    }
    
    // mcボタンを押した時の処理
    @IBAction func memoryClearButtonTapped(_ sender: UIButton) {
        mrButton.setTitleColor(UIColor.white, for: .normal)
        mrButton.backgroundColor = UIColor(red:64/255, green:64/255, blue:61/255, alpha:1.0)
        memoryPlus = 0
        memoryMinus = 0
        memoryState = 0
    }
}

