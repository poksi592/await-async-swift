//: Playground - noun: a place where people can play

import UIKit

// 3 Asynchronous Tasks
//
func sum(number1: Int,
         number2: Int,
         completion: @escaping (Int) -> Void) {
    
    completion(number1+number2)
}

func sumAndDifference(number1: Int,
                      number2: Int,
                      completion: @escaping (Int, Int) -> Void) {
    
    completion(number1+number2, number1-number2)
}

func sumAndDifferenceAndMultiplication(number1: Int,
                                       number2: Int,
                                       completion: @escaping (Int, Int, Int) -> Void) {
    
    completion(number1+number2, number1-number2, number1*number2)
}

// Running them dependently with Semaphores
//
var semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue.global()

var sumResult: Int? = nil
var differenceResult: Int? = nil
var multiplicationResult: Int? = nil

sum(number1: 1, number2: 2) { (sum) in
    sumResult = sum
    semaphore.signal()
}
semaphore.wait(timeout: .now() + 2.0)
print(sumResult!)

semaphore = DispatchSemaphore(value: 0)
sumAndDifference(number1: sumResult!, number2: 3) { (sum, difference) in
    sumResult = sum
    differenceResult = difference
    semaphore.signal()
}
semaphore.wait(timeout: .now() + 2.0)
print(sumResult!)
print(differenceResult!)

semaphore = DispatchSemaphore(value: 0)
sumAndDifferenceAndMultiplication(number1: sumResult!,
                                          number2: differenceResult!)
                                          { (sum, difference, multiplication) in
    sumResult = sum
    differenceResult = difference
    multiplicationResult = multiplication
    semaphore.signal()
}
semaphore.wait(timeout: .now() + 2.0)
print(sumResult!)
print(differenceResult!)
print(multiplicationResult!)


// Async to the rescue!
//
class Async {
    
    var semaphore = DispatchSemaphore(value: 0)
    var return1: Any?
    var return2: Any?
    var return3: Any?
    
    // Single Parameter
    typealias OneParameter = (Any) -> Void
    func closure1Parameter() -> OneParameter {
        
        return { [weak self] (par1) in
            
            self?.return1 = par1
            self?.semaphore.signal()
        }
    }
    func await1Parameter(_ function: @escaping () -> Void) -> Any {
        
        function()
        semaphore.wait(timeout: .now() + 2.0)
        return return1!
    }
    
    // Two Parameters
    typealias TwoParameters = (Any,Any) -> Void
    func closure2Parameters() -> TwoParameters {
        
        return { [weak self] (par1, par2) in
            
            self?.return1 = par1
            self?.return2 = par2
            self?.semaphore.signal()
        }
    }
    func await2Parameters(_ function: @escaping () -> Void) -> (Any,Any) {
        
        function()
        semaphore.wait(timeout: .now() + 2.0)
        return (return1!, return2!)
    }
    
    // Three Parameters
    typealias ThreeParameters = (Any,Any,Any) -> Void
    func closure3Parameters() -> ThreeParameters {
        
        return { [weak self] (par1, par2, par3) in
            
            self?.return1 = par1
            self?.return2 = par2
            self?.return3 = par3
            self?.semaphore.signal()
        }
    }
    func await3Parameters(_ function: @escaping () -> Void) -> (Any,Any,Any) {
        
        function()
        semaphore.wait(timeout: .now() + 2.0)
        return (return1!, return2!, return3!)
    }
}

// Using the Async class
//
let async = Async()
let sum1 = async.await1Parameter { sum(number1: 1,
                                       number2: 2,
                                       completion: async.closure1Parameter()) }

let (sum2,diff1) = async.await2Parameters { sumAndDifference(number1: sum1 as! Int,
                                                            number2: 3,
                                                            completion: async.closure2Parameters()) }

let (sum3,diff2,mul1) = async.await3Parameters { sumAndDifferenceAndMultiplication(number1: sum2 as! Int,
                                                                                   number2: diff1 as! Int,
                                                                                   completion: async.closure3Parameters()) }

print(sum1)
print(sum2)
print(diff1)
print(sum3)
print(diff2)
print(mul1)






