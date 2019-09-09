//
//  JKDesFireValueFile.swift
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

public class JKDesFireValueFile: JKDesFireFileProtocol {
    
    // MARK: Properties
    
    let value: Int
    
    // MARK: Initialization
    
    init(data: [UInt8]) {
        if (data.count == 4) {
            var reverse: [UInt8] = data
            reverse.reverse()
            value = Int(essentials.byteArrayToInt(input: reverse)!)
        } else {
            value = 0
        }
    }
    
    // MARK: Value file functions
    
    public func getValue() -> Int {
        return value
    }
    
}
