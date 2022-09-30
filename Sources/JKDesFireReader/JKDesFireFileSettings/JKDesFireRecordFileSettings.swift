//
//  JKDesFireRecordFileSettings.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 08.09.19.
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

public class JKDesFireRecordFileSettings: JKDesFireFileSettings {

    // MARK: Properties
    
    let recordSize: UInt32?
    let maxRecords: UInt32?
    let currentRecords: UInt32?
    
    // MARK: Initialization
    
    override init(data: [UInt8]) {
        if (data.count < 16) {
            print("Invalid data")
            recordSize = 0
            maxRecords = 0
            currentRecords = 0
        } else {
            var reverseSize = essentials.splitArray(data: data, start: 4, end: 7)
            var reverseMax = essentials.splitArray(data: data, start: 8, end: 11)
            var reverseCurrent = essentials.splitArray(data: data, start: 12, end: 15)
            reverseSize.reverse()
            reverseMax.reverse()
            reverseCurrent.reverse()
            recordSize = essentials.byteArrayToInt(input: reverseSize)
            maxRecords = essentials.byteArrayToInt(input: reverseMax)
            currentRecords = essentials.byteArrayToInt(input: reverseCurrent)
        }
        super.init(data: data)
    }
    
    // MARK: Record file functions
    
    public func getRecordSize() -> UInt32 {
        if (recordSize != nil) {
            return recordSize!
        }
        return 0
    }
    
    public func getMaxRecords() -> UInt32 {
        if (maxRecords != nil) {
            return maxRecords!
        }
        return 0
    }
    
    public func getCurrentRecords() -> UInt32 {
        if (currentRecords != nil) {
            return currentRecords!
        }
        return 0
    }
    
}
