//
//  JKDesFireProtocol.swift
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
import CoreNFC
import PromiseKit

enum JKDesFireCommands: UInt8 {
    case GET_MANUFACTURING_DATA = 0x60
    case GET_APPLICATION_DIRECTORY = 0x6A
    case GET_ADDITIONAL_FRAME = 0xAF
    case SELECT_APPLICATION = 0x5A
    case READ_DATA = 0xBD
    case READ_RECORD = 0xBB
    case READ_VALUE = 0x6C
    case GET_FILES = 0x6F
    case GET_FILE_SETTINGS = 0xF5
}

enum JKDesFireReturnCodes: UInt8, LocalizedError {
    case SUCCESS = 0x00
    case PERMISSION_DENIED = 0x9D
    case AUTHENTICATION_ERROR = 0xAE
    case ADDITIONAL_FRAME = 0xAF
    case INVALID_RESPONSE = 0x99
    
    var localizedDescription: String {
        switch self {
            case .SUCCESS: return "Success"
            case .PERMISSION_DENIED: return "Permission denied"
            case .AUTHENTICATION_ERROR: return "Authentication error"
            case .ADDITIONAL_FRAME: return "Additional frame"
            case .INVALID_RESPONSE: return "Invalid response"
        }
    }
}

extension NFCMiFareTag {
    public func sendCommand(_ command: UInt8) -> Promise<Data> {
        return self.sendRequest(command, [])
    }
    
    public func sendRequest(_ command: UInt8, _ parameters: [UInt8]) -> Promise<Data> {
        return Promise { seal in
            func getTagData(_ cmd: UInt8, _ params: [UInt8], _ existingData: Data? = nil) {
                self.sendMiFareCommand(commandPacket: wrapCommand(cmd, params)) { (cmdResp, err) in
                    if let cmdErr = err {
                        print("Received error while sending command!", cmdErr)
                        seal.reject(JKDesFirePublicError.ERR_COMMAND_EXECUTION_ERROR)
                        return
                    }
                    
                    guard cmdResp[cmdResp.count - 2] == 0x91 else {
                        seal.reject(JKDesFirePublicError.ERR_UNKNOWN_RESULT)
                        return
                    }
                    
                    guard let rawStatusFrame = cmdResp.last, let statusFrame = JKDesFireReturnCodes(rawValue: rawStatusFrame) else {
                        print("Unknown status response!", cmdResp, cmdResp.hexEncodedString())
                        seal.reject(JKDesFirePublicError.ERR_UNKNOWN_RESULT)
                        return
                    }
                    
                    var allData: Data = cmdResp[0..<cmdResp.count - 2]
                    
                    if let existing = existingData {
                        allData.insert(contentsOf: existing, at: 0)
                    }
                    
                    switch statusFrame {
                        case .SUCCESS:
                            seal.fulfill(allData)
                            return
                        case .ADDITIONAL_FRAME:
                            getTagData(0xAF, [], allData)
                            return
                        default:
                            print("Received not good response", statusFrame, cmdResp.hexEncodedString(), "(command \(command) params \(parameters)")
                            seal.reject(self.translateErrorResponse(input: statusFrame))
                            return
                    }
                }
            }
            getTagData(command, parameters)
        }
    }
    
    public func wrapCommand(_ command: UInt8, _ parameters: [UInt8]) -> Data {
        var cmdArr: [UInt8] = [0x90, command, 0x00, 0x00]
        
        if !parameters.isEmpty {
            cmdArr.append(UInt8(parameters.count))
            cmdArr.append(contentsOf: parameters)
        }
        
        cmdArr.append(0x00)
        
        return Data(bytes: cmdArr, count: cmdArr.count)
    }
    
    func translateErrorResponse(input: JKDesFireReturnCodes) -> JKDesFirePublicError {
        switch input {
            case .AUTHENTICATION_ERROR:
                return .ERR_AUTHENTICATION_ERROR
            case .INVALID_RESPONSE:
                return .ERR_UNKNOWN_RESULT
            case .PERMISSION_DENIED:
                return .ERR_PERMISSION_DENIED
            default:
                return .ERR_UNKNOWN_ERROR
        }
    }
}
