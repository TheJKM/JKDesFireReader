//
//  JKEssentials.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 03.07.19.
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

class essentials {
    // Convert an array of bytes as UInt8 (valid sizes 1 to 4) to an UInt32. Will retrun nil on invalid input
    static func byteArrayToInt(input: [UInt8]) -> UInt32? {
        guard (input.count >= 1 && input.count <= 4) else {
            return nil
        }
        var length: Int = input.count
        var inputArray: [UInt8] = input
        while length < 4 {
            inputArray.insert(0, at: 0)
            length += 1
        }
        let data: Data = Data(_: inputArray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
    
    // Convert an UInt32 to an array of bytes with length 4.
    static func intToByteArray(_ input: UInt32) -> [UInt8] {
        var bigEndian = input.bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }
    
    // Extract a part of an array
    static func splitArray(data: Array<UInt8>, start: Int, end: Int) -> Array<UInt8> {
        return Array(data[start..<end])
    }
}
