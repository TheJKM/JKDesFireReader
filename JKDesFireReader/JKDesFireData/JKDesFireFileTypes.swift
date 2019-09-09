//
//  JKDesFireFileTypes.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 20.06.19.
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

public struct JKDesFireFileTypes {
    
    // MARK: File types
    
    static let DATA_FILE: UInt8 = 0x00
    static let BACKUP_FILE: UInt8 = 0x01
    static let VALUE_FILE: UInt8 = 0x02
    static let LINEAR_RECORD_FILE: UInt8 = 0x03
    static let CYCLIC_RECORD_FILE: UInt8 = 0x04
    
}
