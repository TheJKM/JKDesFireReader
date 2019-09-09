//
//  JKDesFireDataFileSettings.swift
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

public class JKDesFireDataFileSettings: JKDesFireFileSettings {

    // MARK: Properties
    
    let fileSize: UInt32?
    
    // MARK: Initialization
    
    override init(data: [UInt8]) {
        if (data.count < 8) {
            print("Invalid data")
            fileSize = 0
        } else {
            var reverseSize = essentials.splitArray(data: data, start: 4, end: 7)
            reverseSize.reverse()
            fileSize = essentials.byteArrayToInt(input: reverseSize)
        }
        super.init(data: data)
    }
    
    // MARK: Data file functions
    
    public func getFileSize() -> UInt32 {
        if (fileSize != nil) {
            return fileSize!
        }
        return 0
    }
    
}
