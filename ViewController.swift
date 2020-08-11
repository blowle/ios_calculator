//
//  ViewController.swift
//  SampleTest
//
//  Created by Dev on 2020/08/10.
//  Copyright © 2020 Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var showVal: UILabel!
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet var keypad: [UIButton]!
    @IBOutlet var oper: [UIButton]!
    
    let INIT_INPUT = "수식 입력"
    let PAREN_MAX = 6
    var priorityOfOp: [String: Int] = ["(": -1, "+": 0, "-": 0, "X": 1, "/": 1, "%": 1]
    var isOperator: Bool = true
    var isComplete: Bool = false
    var isStartedFromZero: Bool = false
    var isRightParen: Bool = false
    var isDot: Bool = false
    var parenCnt: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        showVal.text = INIT_INPUT;
        
        keypad.forEach {
            $0.addTarget(self, action: #selector(numberClicked), for: .touchUpInside)
        }
        
        oper.forEach {
            $0.addTarget(self, action:
                #selector(operationClicked), for: .touchUpInside)
        }
    }
    
    func initialVar(prevResult: String?) {
        isOperator = true
        isComplete = false
        lbResult.text = "결과 창"
        showVal.text = prevResult != nil ? prevResult : INIT_INPUT
        isDot = showVal.text?.contains(".") ?? false ? true : false
        isStartedFromZero = false
        isRightParen = false
        parenCnt = 0
    }
    
    @IBAction func parenthesis(_ sender: UIButton) {
        
        if isComplete {
            initialVar(prevResult: nil)
        }
        
        let prevContents: String = (showVal.text ?? "" == INIT_INPUT ? "" : showVal.text)!
        var paren: String = "";
        
        if isOperator {
            if parenCnt < PAREN_MAX {
                paren = "( "
                isRightParen = false
                parenCnt += 1
            }
        } else {
            
            if parenCnt > 0 {
                paren = " )"
                
                isRightParen = true
                parenCnt -= 1
            } else {
                
            }
        }
        
        showVal.text = prevContents + paren
    }
    
    func inToPostFix(_ exprs: Array<String>) -> Array<String> {
        
        var ret: Array<String> = []
        var tmp: Array<String> = []
        
        for str in exprs {
            if str == "X" || str == "/" || str == "+" || str == "-" || str == "%" {
                
                if tmp.isEmpty {
                    tmp.append(str)
                } else {
                    while let lastNumber = tmp.last, priorityOfOp[lastNumber]! >= priorityOfOp[str]! {
                        ret.append(tmp.popLast()!)
                    }
                    tmp.append(str)
                }
                
            } else if str == "(" {
                
                tmp.append(str)
                
            } else if str == ")" {
                while tmp.last != "(" {
                    ret.append(tmp.popLast()!)
                }
                tmp.popLast()
            } else {
                ret.append(str)
            }
        }
        
        while !tmp.isEmpty {
            ret.append(tmp.popLast()!)
        }
        
        return ret
    }
    
    
    func calculate(_ exprs: Array<String>) throws -> Double {
        var ret: Double = 0.0
        
        var operand: Array<Double> = []
        
        let expr: Array<String> = inToPostFix(exprs)
        
        var oper1: Double, oper2: Double;
        

        for oper in expr {
            switch oper {
            case "/":
                print("/")
                oper2 = operand.popLast()!
                oper1 = operand.popLast()!
                
                if let tmp: Double = oper1 / oper2 {
                    operand.append(tmp)
                }
                
            case "X":
                print("X")
                oper2 = operand.popLast()!
                oper1 = operand.popLast()!
                operand.append(oper1 * oper2)
            case "%":
                print("%")
                oper2 = operand.popLast()!
                oper1 = operand.popLast()!
                
                operand.append(oper1.truncatingRemainder(dividingBy: oper2))
            case "-":
                print("-")
                oper2 = operand.popLast()!
                oper1 = operand.popLast()!
                operand.append(oper1 - oper2)
    
            case "+":
                print("+")
                oper2 = operand.popLast()!
                oper1 = operand.popLast()!
                operand.append(oper1 + oper2)
            default:
                if let tmp = Double(oper) {
                    operand.append(tmp)
                }
            }
        }
        
        ret = operand.popLast()!
        
        return ret
    }
    
    
    // method to show result
    @IBAction func showResult(_ sender: UIButton) {
        
        if showVal.text?.last == " " || parenCnt > 0 {
            lbResult.text = "수식을 완료해 주세요."
            return
        }
        
        if isOperator || showVal.text == INIT_INPUT || showVal.text == "" {
            lbResult.text = "0"
            return
        }
        
        let expression: String = showVal.text ?? ""
        
        let arr: Array<String> = expression.components(separatedBy: " ")
        
        do {
            let ret: Double = try calculate(arr)
           
            if !ret.isInfinite && !ret.isNaN {
                let remain = ret.truncatingRemainder(dividingBy: 1.0)
                
                if  remain != 0.0 {
                    lbResult.text = String(Double(round(ret*100000000))/100000000)
                } else {
                    lbResult.text = String(Int(ret))
                }
            } else {
                lbResult.text = "잘못된 수식입니다."
            }
        } catch {
            lbResult.text = "잘못될 수식입니다."
        }
        
        showVal.text = INIT_INPUT
        isComplete = true
        isOperator = true
        
    }
    
    // the function to clear all input
    @IBAction func clearBtn(_ sender: UIButton) {
        
        initialVar(prevResult: nil)
    }
    
    // this event method occured when a operation is clicked
    @objc func operationClicked(_ sender: UIButton) {
        
        if isComplete {
           initialVar(prevResult: lbResult.text)
           isOperator = false
       }
        
        let tmpStr: String = sender.currentTitle ?? ""
        let oper = tmpStr[tmpStr.startIndex]
        let prevContents: String = showVal.text ?? ""
        let appendVal: String = " \(oper) "
        
        // to prevent double operators
        
        if (prevContents == "" || isOperator) {
            return
        }
        
        isDot = false
        isOperator = true
        isStartedFromZero = false
        showVal.text = prevContents + appendVal
        
    }
    
    @IBAction func DotBtn(_ sender: UIButton) {
        
        showVal.text = showVal.text == INIT_INPUT ? "" : showVal.text
        
        let prev = showVal.text ?? ""
        
        // already use dot
        if isDot {
            return
        }
        
        if prev.last == nil || prev.last == " " {
            showVal.text = prev + "0."
            isStartedFromZero = true
        } else {
            showVal.text = prev + "."
        }
        
        isDot = true
    }
    
    // this event method occured when a number keypad is clicked
    @objc func numberClicked(_ sender: UIButton) {
        
        // after calculation, initialize variable
        if isComplete {
            initialVar(prevResult: nil)
        }
        
        // not input a keypad on right side of right parenthesis,
        if !isOperator && parenCnt > 0 && isRightParen {
            return
        }
        
        // when showVal.text is init
        showVal.text = showVal.text == INIT_INPUT ? "" : showVal.text
        
        var prev = showVal.text ?? ""
        let appendVal = sender.currentTitle ?? ""
        
        if appendVal == "0" {
            // when this input is first input as a number
            if prev.last == nil || prev.last == " " {
                
                isStartedFromZero = true
                
            } else if isStartedFromZero {
                // after a first input is zero, continuously input zero.
                return
            }
        } else {
            if isStartedFromZero && !isDot {
                prev.removeLast()
                isStartedFromZero = false
            }
        }
        
        isOperator = false
        isRightParen = false
        showVal.text = prev + appendVal
    }
    
    // the function to delete last input
    @IBAction func delBtn(_ sender: UIButton) {
        
        var tmpStr: String = showVal.text ?? ""
        
        if tmpStr == INIT_INPUT {
            return
        }
        
        if tmpStr.count > 0 {
            
            let lastCh = tmpStr.last
            
            switch lastCh {
            case " ":
                // parenthesis or operator
                print(" ")
                tmpStr.removeLast()
                
                if tmpStr.last == "(" {
                    parenCnt -= 1
                    
                } else if tmpStr.last == ")" {
                    parenCnt += 1
                    tmpStr.removeLast()
                } else {
                    isOperator = false
                    tmpStr.removeLast()
                }
                
                tmpStr.removeLast()
                
                if tmpStr.last == ")" {
                    isRightParen = true
                } else {
                    isRightParen = false
                }
            case ")":
                parenCnt += 1
                tmpStr.removeLast()
                tmpStr.removeLast()
            case ".":
                print(".")
                tmpStr.removeLast()
                isDot = false
                
            case nil:
                print("nil")
            default:
                if tmpStr.count == 1 && tmpStr.last == "0" {
                    isStartedFromZero = false
                    
                } else if tmpStr.count > 1 && tmpStr[tmpStr.index(tmpStr.endIndex, offsetBy: -2)...] == " 0" {
                    isStartedFromZero = false
                    
                }
                tmpStr.removeLast()
            }
        
            showVal.text = tmpStr
        }
    }
    
}

