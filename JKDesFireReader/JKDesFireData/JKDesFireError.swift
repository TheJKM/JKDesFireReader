//
//  JKDesFireException.swift
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

enum JKDesFireError: Error {
    case commandError
    case sessionError
    case invalidMiFareTypeError
    case tagAuthenticationError
    case tagPermissionDenied
    case tagUnknownResult
}

public enum JKDesFirePublicError: Error {
    // Detected tag is of currently unsupported type MiFare Plus
    case ERR_MIFARE_PLUS
    // Detected tag is of currently unsupported type MiFare Ultralight
    case ERR_MIFARE_ULTRALIGHT
    // Detected tag is of an unknown MiFare type
    case ERR_MIFARE_UNKNOWN
    // An executed MiFare command has thrown an error
    case ERR_MIFARE_ERROR
    // CoreNFC could not detect any tags
    case ERR_NO_TAG_FOUND
    // You don't have the required permissions to run this tag command
    case ERR_PERMISSION_DENIED
    // Error authenticating on the tag
    case ERR_AUTHENTICATION_ERROR
    // Tag returned an unknown result
    case ERR_UNKNOWN_RESULT
    // Error executing tag command
    case ERR_COMMAND_EXECUTION_ERROR
    // You specified an unknown command
    case ERR_UNKNOWN_COMMAND
    // An unknown error occured
    case ERR_UNKNOWN_ERROR
    // The length of yout input data is not correct
    case ERR_WRONG_INPUT_LENGTH
    // The type byte of the file is unknown
    case ERR_UNKNOWN_FILE_TYPE
    // The provided file id was not found
    case ERR_FILE_NOT_FOUND
    // The session was invalidated
    case ERR_SESSION_INVALIDATED
    
    var localizedDescription: String {
        switch self {
            case .ERR_MIFARE_PLUS: return "This tag is a MiFare Plus tag, which is unsupported."
            case .ERR_MIFARE_ULTRALIGHT: return "This tag is a MiFare Ultralight tag, which is unsupported."
            case .ERR_MIFARE_UNKNOWN: return "This tag is an unknown MiFare tag, which is unsupported."
            case .ERR_MIFARE_ERROR: return "An error occured in the MiFare protocol."
            case .ERR_NO_TAG_FOUND: return "Unable to find a NFC tag."
            case .ERR_PERMISSION_DENIED: return "Permission denied."
            case .ERR_AUTHENTICATION_ERROR: return "Unable to authenticate."
            case .ERR_UNKNOWN_RESULT: return "Unknown result."
            case .ERR_COMMAND_EXECUTION_ERROR: return "Error while executing command on the tag."
            case .ERR_UNKNOWN_COMMAND: return "Unknown command."
            case .ERR_UNKNOWN_ERROR: return "An unknown error occured."
            case .ERR_WRONG_INPUT_LENGTH: return "The data you supplied have the wrong length."
            case .ERR_UNKNOWN_FILE_TYPE: return "Unable to determine the type of this file."
            case .ERR_FILE_NOT_FOUND: return "The file with this id could not be found."
            case .ERR_SESSION_INVALIDATED: return "The session was invalidated (user or system)."
        }
    }
}
