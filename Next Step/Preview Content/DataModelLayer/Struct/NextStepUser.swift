//
//  NextStepUser.swift
//  Next Step
//
//  Created by Jan on 21/11/2024.
//

import Foundation
import SwiftUICore

struct UserSettings : Codable{
    var backgroundColor:String = ".primary"
    var isNotificationEnabled:Bool = false
}

struct UserData : Codable{
    var ID: Int
    var name: String
    var surname: String
    var email: String
    var creationDate: Date = .now
    var profilePicture: String?
}
