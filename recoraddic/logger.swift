//
//  logger.swift
//  recoraddic
//
//  Created by 김지호 on 3/2/24.
//

import Foundation
import os.log



extension Logger {
//    static let loggingSubsystem: String = "iCloud.recoraddic"
    static let loggingSubsystem: String = "iCloud.com.ver1.recoraddic"
    
    static let ui = Logger(subsystem: Self.loggingSubsystem, category: "UI")
    static let database = Logger(subsystem: Self.loggingSubsystem, category: "Database")
    static let dataModel = Logger(subsystem: Self.loggingSubsystem, category: "DataModel")
}
