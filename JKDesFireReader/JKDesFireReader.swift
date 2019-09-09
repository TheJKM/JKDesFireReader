//
//  JKDesFireReader.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 18.06.19.
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

public class JKDesFireReader {
    
    // MARK: Properties
    
    var readerSession: JKNFCReadingSession?
    var tag: NFCMiFareTag?
    var status: Int = 0
    var sessionInfoText: String?
    var errorInfoText: String?
    var lastOccuredError: JKDesFirePublicError?
    let delegate: JKDesFireReaderDelegate
    
    // MARK: Initialization
    
    public init(start: Bool, delegate: JKDesFireReaderDelegate) {
        self.delegate = delegate
        if start {
            _ = createReaderSession()
        }
    }
    
    // MARK: Callbacks
    
    private func sessionDidDetectTag(tag: NFCMiFareTag) {
        status = 2
        self.tag = tag
        delegate.didDetectDesFireTag()
    }
    
    private func sessionThrowError(error: JKDesFirePublicError) {
        status = -1
        lastOccuredError = error
        delegate.tagDetectionError(error: error)
    }
    
    // MARK: Public functions
    
    public func createReaderSession() -> Bool {
        if readerSession == nil {
            status = 1
            if sessionInfoText != nil && errorInfoText != nil {
                readerSession = JKNFCReadingSession(sessionTagCallback: sessionDidDetectTag(tag:), sessionErrorCallback: sessionThrowError(error:), sessionInfoText: sessionInfoText!, errorInfoText: errorInfoText!)
                readerSession?.start()
            } else {
                readerSession = JKNFCReadingSession(sessionTagCallback: sessionDidDetectTag(tag:), sessionErrorCallback: sessionThrowError(error:))
                readerSession?.start()
            }
            return true
        } else {
            return false
        }
    }
    
    public func setSessionInfoText(text: String) {
        sessionInfoText = text
    }
    
    public func setErrorInfoText(text: String) {
        errorInfoText = text
    }
    
    public func stopRunningSession() {
        if readerSession != nil {
            readerSession?.stop()
            readerSession = nil
        }
    }
    
    public func stopRunningSession(errorMessage: String) {
        if readerSession != nil {
            readerSession?.stop(errorMessage: errorMessage)
            readerSession = nil
        }
    }
    
    public func sessionIsOpen() -> Bool {
        if status == 2 {
            return true
        }
        return false
    }
    
    public func getErrorStatus() -> Bool {
        if status < 0 {
            return true
        }
        return false
    }
    
    public func getErrorReason() -> JKDesFirePublicError {
        return lastOccuredError!
    }
    
    // MARK: DesFire functions
    
    public func listApplications() -> Promise<[UInt32]> {
        return Promise<[UInt32]> { seal in
            tag!.sendCommand(JKDesFireCommands.GET_APPLICATION_DIRECTORY.rawValue)
            .done { data in
                // Create byte array from input data
                let byteArray: [UInt8] = [UInt8](data)
                
                // Byte count must be a multiple of 3, otherwise we don't have valid application ids
                guard (byteArray.count % 3 == 0) else {
                    NSLog("Response byte count is not a multiple of 3. Aborting.")
                    seal.reject(JKDesFirePublicError.ERR_UNKNOWN_RESULT)
                    return
                }
                
                // Convert application ids to integer values
                var applicationIds: [UInt32] = [UInt32]()
                var byteCounter: Int = 0
                for _ in 0...(byteArray.count / 3 - 1) {
                    let idAsBytes: [UInt8] = Array(byteArray[byteCounter...(byteCounter + 2)])
                    applicationIds.append(essentials.byteArrayToInt(input: idAsBytes)!)
                    byteCounter += 3
                }
                seal.fulfill(applicationIds)
            }.catch { error in
                NSLog("NFC command has thrown an error. Reason: " + error.localizedDescription)
            }
        }
    }
    
    public func selectApplication(applicationId: UInt32) -> Promise<JKDesFireApplication> {
        return Promise<JKDesFireApplication> { seal in
            // Create an empty byte array
            var byteArray: [UInt8] = [UInt8]()
            
            // Loop through the converted integer, remove most significant zeroes
            for byte in essentials.intToByteArray(applicationId) {
                if (byte != 0) {
                    byteArray.append(byte)
                }
            }
            
            // Check length
            guard (byteArray.count == 3) else {
                seal.reject(JKDesFirePublicError.ERR_WRONG_INPUT_LENGTH)
                return
            }
            
            // Send request to card and handle promise
            tag!.sendRequest(JKDesFireCommands.SELECT_APPLICATION.rawValue, byteArray).asVoid()
            .done { data in
                let applicationObject = JKDesFireApplication(id: applicationId, tag: self.tag!)
                    
                // Read file list on card
                applicationObject.listApplications()
                .done { status in
                    if (status) {
                        seal.fulfill(applicationObject)
                    } else {
                        seal.reject(JKDesFirePublicError.ERR_COMMAND_EXECUTION_ERROR)
                    }
                }.catch { error in
                    // Forward errors
                    if let knownError = error as? JKDesFirePublicError {
                        seal.reject(knownError)
                    } else {
                        seal.reject(JKDesFirePublicError.ERR_UNKNOWN_ERROR)
                    }
                }
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
    
}
