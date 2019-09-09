//
//  JKDesFireFile.swift
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

public protocol JKDesFireFileSettingsProtocol {
    
    // MARK: Abstract functions
    
    func getFileType() -> UInt8
    func getAccessRights() -> [UInt8]
    
}

public class JKDesFireFileSettings: JKDesFireFileSettingsProtocol {
    
    // MARK: Properties
    
    let fileType: UInt8
    let accessRights: [UInt8]
    
    // MARK: Initialization
    
    init(data: [UInt8]) {
        switch(data[0]) {
            case 1:
                fileType = JKDesFireFileTypes.BACKUP_FILE
                break
            case 2:
                fileType = JKDesFireFileTypes.VALUE_FILE
                break
            case 3:
                fileType = JKDesFireFileTypes.LINEAR_RECORD_FILE
                break
            case 4:
                fileType = JKDesFireFileTypes.CYCLIC_RECORD_FILE
                break
            default:
                fileType = JKDesFireFileTypes.DATA_FILE
        }
        accessRights = essentials.splitArray(data: data, start: 2, end: 3)
    }
    
    // MARK: Protocol functions
    
    public func getFileType() -> UInt8 {
        return fileType
    }
    
    public func getAccessRights() -> [UInt8] {
        return accessRights
    }
    
    // MARK: Static creator for file instances
    
    static func createFileSettingsObject(data: [UInt8]) -> JKDesFireFileSettingsProtocol? {
        // First byte is file type
        if (data.count > 0 && data[0] == JKDesFireFileTypes.VALUE_FILE) {
            return JKDesFireValueFileSettings(data: data)
        } else if (data.count > 0 && data[0] == JKDesFireFileTypes.DATA_FILE || data[0] == JKDesFireFileTypes.BACKUP_FILE) {
            return JKDesFireDataFileSettings(data: data)
        } else if (data.count > 0 && data[0] == JKDesFireFileTypes.LINEAR_RECORD_FILE || data[0] == JKDesFireFileTypes.CYCLIC_RECORD_FILE) {
            return JKDesFireRecordFileSettings(data: data)
        } else {
            return nil
        }
    }
    
}
