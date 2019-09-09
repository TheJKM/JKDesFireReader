//
//  JKDesFireFile.swift
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

protocol JKDesFireFileProtocol {}

class JKDesFireFile {
    
    // MARK: Static creator for file instances
    
    public static func createFileObject(data: [UInt8]) -> JKDesFireFileProtocol? {
        // First byte is file type
        if (data.count > 0 && data[0] == JKDesFireFileTypes.VALUE_FILE) {
            return JKDesFireValueFile(data: data)
        } else if (data.count > 0 && data[0] == JKDesFireFileTypes.DATA_FILE || data[0] == JKDesFireFileTypes.BACKUP_FILE) {
            return JKDesFireDataFile(data: data)
        } else {
            return nil
        }
    }
    
}
