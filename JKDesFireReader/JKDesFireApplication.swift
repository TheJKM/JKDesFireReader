//
//  JKDesFireApplication.swift
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
import CoreNFC
import PromiseKit

public class JKDesFireApplication {
    
    // MARK: Properties
    
    let id: UInt32
    let tag: NFCMiFareTag
    var files: [UInt8] = [UInt8]()
    
    // MARK: Initialization
    
    init(id: UInt32, tag: NFCMiFareTag) {
        self.id = id
        self.tag = tag
    }
    
    // MARK: Actions
    
    func listApplications() -> Promise<Bool> {
        return Promise<Bool> { seal in
            tag.sendCommand(JKDesFireCommands.GET_FILES.rawValue)
            .done { data in
                self.files = [UInt8](data)
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getFileSettings(fileId: UInt8) -> Promise<JKDesFireFileSettingsProtocol> {
        return Promise<JKDesFireFileSettingsProtocol> { seal in
            tag.sendRequest(JKDesFireCommands.GET_FILE_SETTINGS.rawValue, [fileId])
            .done { data in
                // Convert response from card to byte array
                let response: [UInt8] = [UInt8](data)
                
                // Create file settings object and return it
                let fileSettings: JKDesFireFileSettingsProtocol? = JKDesFireFileSettings.createFileSettingsObject(data: response)
                
                // Check for error
                guard (fileSettings != nil) else {
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_FILE_TYPE)
                    return
                }
                
                // Resolve promise with file settings object
                seal.fulfill(fileSettings!)
            }.catch { error in
                // Forward errors
                if let knownError = error as? JKDesFirePublicError {
                    seal.reject(knownError)
                } else {
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_ERROR)
                }
            }
        }
    }
    
    /*public func getFile(fileId: UInt8) -> Promise<Data> {
        return Promise<Data> { seal in
            // Check if given file id is a file of this application
            guard (files.contains(fileId)) else {
                seal.reject(JKDesFirePublicError.ERR_FILE_NOT_FOUND)
                return
            }
     
            tag.sendRequest(JKDesFireCommands.READ_DATA.rawValue, [fileId, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
            .done { data in
                    
            }.catch { error in
                // Forward errors
                if let knownError = error as? JKDesFirePublicError {
                    seal.reject(knownError)
                } else {
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_ERROR)
                }
            }
        }
    }*/
    
    /*public func getRecord(recordId: UInt8) -> Promise<Data> {
        return Promise<Data> { seal in
             // Check if given file id is a file of this application
             guard (files.contains(fileId)) else {
                 seal.reject(JKDesFirePublicError.ERR_FILE_NOT_FOUND)
                 return
             }
     
            tag.sendRequest(JKDesFireCommands.READ_RECORD.rawValue, [recordId, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
            .done { record in
                    
            }.catch { error in
                // Forward errors
                if let knownError = error as? JKDesFirePublicError {
                    seal.reject(knownError)
                } else {
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_ERROR)
                }
            }
        }
    }*/
    
    public func getValue(fileId: UInt8) -> Promise<JKDesFireValueFile> {
        return Promise<JKDesFireValueFile> { seal in
            //seal.reject(JKDesFirePublicError.ERR_FILE_NOT_FOUND)
            // Check if given file id is a file of this application
            guard (files.contains(fileId)) else {
                seal.reject(JKDesFirePublicError.ERR_FILE_NOT_FOUND)
                return
            }
            
            tag.sendRequest(JKDesFireCommands.READ_VALUE.rawValue, [fileId])
            .done { value in
                // Return value file object
                seal.fulfill(JKDesFireValueFile(data: [UInt8](value)))
            }.catch { error in
                // Forward errors
                if let knownError = error as? JKDesFirePublicError {
                    seal.reject(knownError)
                } else {
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_ERROR)
                }
            }
        }
    }
    
    // MARK: Getters
    
    public func getApplicationId() -> UInt32 {
        return id
    }
    
    public func getFileCount() -> Int {
        return files.count
    }
    
    public func getFiles() -> [UInt8] {
        return files
    }
    
}
