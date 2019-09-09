//
//  JKNFCReadingSession.swift
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


//
//  Session status values
//  -1: Session invalidated with error
//  0: Session uninitialized
//  1: Session initialized
//  2: Session is starting up
//  3: Session running
//

import Foundation
import CoreNFC
import os.log

class JKNFCReadingSession: NSObject, NFCTagReaderSessionDelegate {
    
    // MARK: Properties
    
    var session: NFCTagReaderSession? = nil
    var status: Int = 0
    var miFareTag: NFCMiFareTag? = nil
    var errorInfoText: String
    
    // MARK: Callbacks
    
    var sessionTagCallback: (NFCMiFareTag) -> Void
    var sessionErrorCallback: (JKDesFirePublicError) -> Void
    
    // MARK: Initialization
    
    init(sessionTagCallback: @escaping (NFCMiFareTag) -> Void, sessionErrorCallback: @escaping (JKDesFirePublicError) -> Void) {
        self.errorInfoText = "Error reading your tag."
        self.sessionTagCallback = sessionTagCallback
        self.sessionErrorCallback = sessionErrorCallback
        super.init()
        initializeSession(alertMessage: "Hold your NFC tag near the top of your iPhone.")
    }
    
    init(sessionTagCallback: @escaping (NFCMiFareTag) -> Void, sessionErrorCallback: @escaping (JKDesFirePublicError) -> Void, sessionInfoText: String, errorInfoText: String) {
        self.errorInfoText = errorInfoText
        self.sessionTagCallback = sessionTagCallback
        self.sessionErrorCallback = sessionErrorCallback
        super.init()
        initializeSession(alertMessage: sessionInfoText)
    }
    
    // MARK: Private helpers
    
    private func initializeSession(alertMessage: String) {
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.alertMessage = alertMessage
        status = 1
    }
    
    // MARK: Public functions
    
    func start() {
        if (status == 1) {
            session?.begin()
            status = 2
        }
    }
    
    func stop() {
        if (status == 3) {
            session?.invalidate()
            status = 1
        }
    }
    
    func stop(errorMessage: String) {
        if (status == 3) {
            session?.invalidate(errorMessage: errorMessage)
            status = 1
        }
    }
    
    func getTagObject() -> NFCMiFareTag? {
        return miFareTag
    }
    
    // MARK: NFCTagReaderSessionDelegate
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        status = 3
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        status = -1
        os_log("Error in NFC tag reading Session. Reason: %@.", error.localizedDescription)
        self.sessionErrorCallback(JKDesFirePublicError.ERR_SESSION_INVALIDATED)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let tag: NFCTag? = tags.first
        if case let .miFare(miFareTag) = tag {
            let miFareType: NFCMiFareFamily = miFareTag.mifareFamily
            if miFareType == .desfire {
                session.connect(to: tag!) {(error: Error?) in
                    guard error == nil else {
                        return
                    }
                    self.miFareTag = miFareTag
                    self.sessionTagCallback(self.miFareTag!)
                }
            } else if miFareType == .plus {
                session.invalidate(errorMessage: errorInfoText)
                self.sessionErrorCallback(JKDesFirePublicError.ERR_MIFARE_PLUS)
            } else if miFareType == .ultralight {
                session.invalidate(errorMessage: errorInfoText)
                self.sessionErrorCallback(JKDesFirePublicError.ERR_MIFARE_ULTRALIGHT)
            } else if miFareType == .unknown {
                session.invalidate(errorMessage: errorInfoText)
                self.sessionErrorCallback(JKDesFirePublicError.ERR_MIFARE_UNKNOWN)
            } else {
                session.invalidate(errorMessage: errorInfoText)
                self.sessionErrorCallback(JKDesFirePublicError.ERR_MIFARE_ERROR)
            }
        }
        if (tag == nil) {
            os_log("Error: No valid tag found.")
            session.invalidate(errorMessage: errorInfoText)
            self.sessionErrorCallback(JKDesFirePublicError.ERR_NO_TAG_FOUND)
        }
    }
}
