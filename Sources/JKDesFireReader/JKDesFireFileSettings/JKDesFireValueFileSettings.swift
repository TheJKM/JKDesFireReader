//
//  JKDesFireValueFileSettings.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 17.08.19.
//  Copyright © 2019 Johannes Kreutz. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public class JKDesFireValueFileSettings: JKDesFireFileSettings {

    // MARK: Properties
    
    let lowerLimit: UInt32?
    let upperLimit: UInt32?
    let value: UInt32?
    let limitedCredit: UInt8
    
    // MARK: Initialization
    
    override init(data: [UInt8]) {
        if (data.count < 17) {
            print("Invalid data")
            lowerLimit = 0
            upperLimit = 0
            value = 0
            limitedCredit = 0
        } else {
            var reverseLower = essentials.splitArray(data: data, start: 4, end: 7)
            var reverseUpper = essentials.splitArray(data: data, start: 8, end: 11)
            var reverseValue = essentials.splitArray(data: data, start: 12, end: 15)
            reverseLower.reverse()
            reverseUpper.reverse()
            reverseValue.reverse()
            lowerLimit = essentials.byteArrayToInt(input: reverseLower)
            upperLimit = essentials.byteArrayToInt(input: reverseUpper)
            value = essentials.byteArrayToInt(input: reverseValue)
            limitedCredit = data[16]
        }
        super.init(data: data)
    }
    
    // MARK: Value file functions
    
    public func getLowerLimit() -> UInt32 {
        if (lowerLimit != nil) {
            return lowerLimit!
        }
        return 0
    }
    
    public func getUpperLimit() -> UInt32 {
        if (upperLimit != nil) {
            return upperLimit!
        }
        return 0
    }
    
    public func getValue() -> Int {
        if (value != nil) {
            return Int(value!)
        }
        return 0
    }
    
    public func getLimitedCredit() -> UInt8 {
        return limitedCredit
    }
    
}
