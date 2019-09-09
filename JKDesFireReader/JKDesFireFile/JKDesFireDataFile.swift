//
//  JKDesFireDataFile.swift
//  JKDesFireReader
//
//  Created by Johannes Kreutz on 09.09.19.
//  Copyright © 2019 Johannes Kreutz. All rights reserved.
//

import Foundation

public class JKDesFireDataFile: JKDesFireFileProtocol {
    
    // MARK: Properties
    
    let data: [UInt8]
    
    // MARK: Initialization
    
    init(data: [UInt8]) {
        self.data = data
    }
    
    // MARK: Data file functions
    
    public func getRawData() -> [UInt8] {
        return data
    }
    
}
