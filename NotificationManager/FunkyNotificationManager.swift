

//
//  FunkyNotificationManager.swift
//  NotificationManager
//
//  Created by Piyush Sharma on 9/2/16.
//  Copyright © 2016 Piyush Sharma. All rights reserved.
//

import Foundation

enum DataType {
    
    case AsString(value: String)
    case AsAnyObject(value: AnyObject)
    case AsClosure(value: (() -> Void))
    
    var value: Any {
        
        switch self {
        case .AsString(let value):
            return value
        case .AsAnyObject(let observer):
            return observer
        case .AsClosure(let closure):
            return closure
        }
    }
}


class FunkyNotificationManager {
    
    fileprivate static var privateInstance: FunkyNotificationManager?
    private var allObserverDict = [String: [[String : DataType]] ]()
    
    static var sharedInstance: FunkyNotificationManager? {
        
        guard let sharedPrivateInstance = self.privateInstance else {
            privateInstance = FunkyNotificationManager()
            return privateInstance
        }
        
        return sharedPrivateInstance
    }
    
    
    fileprivate init() {}
    
    func addNotificationObserver(name: String?, observer: AnyObject?, block:  (() -> Void)) {
        
        //Create a new observer entry
        let newObserverDict: [String : DataType] = ["observer" : DataType.AsAnyObject(value: observer!),"block" : DataType.AsClosure(value: block)]
        
        if let _  = allObserverDict[name!] {
            
            var currentObserversArray: [[String : DataType]] = allObserverDict[name!]!
            currentObserversArray.append(newObserverDict)
            allObserverDict.updateValue(currentObserversArray, forKey: name!)
        }
        else {
            allObserverDict.updateValue([newObserverDict], forKey: name!)
        }
    }

    
    func postNotification(_ name: String?) {
        
        if let observersArr = allObserverDict[name!] {
            
            if observersArr.count > 1 {
                
                for currentObserverDict in observersArr {
                    let handler = currentObserverDict["block"]!.value as? (() -> Void)
                    handler!()
                }
            }
            else {
                let handler = observersArr[0]["block"]!.value as? (() -> Void)
                handler!()
            }
        }
    }
    
    func remove(name: String?, observer: AnyObject?) {
        
        if allObserverDict.keys.count == 0 {
            return
        }
        
        if let observersArr = allObserverDict[name!], observersArr.count > 1 {
            
            var tempObservers = observersArr
            for (index, currentObserverDict) in observersArr.enumerated() {
                if currentObserverDict["observer"]!.value as AnyObject === observer! {
                    tempObservers.remove(at: index)
                    allObserverDict.updateValue(tempObservers, forKey: name!)
                }
            }
        }
        else {
            if let currentObserverDict: [String : DataType] = allObserverDict[name!]?[0] {
                if (currentObserverDict["observer"]!.value as AnyObject)  === observer! {
                    allObserverDict.removeValue(forKey: name!)
                }
            }
        }
        
        if allObserverDict.keys.count == 0 {
            print("All observers removed")
        }
    }
    
    func destroy() {
        allObserverDict.removeAll()
    }
}
