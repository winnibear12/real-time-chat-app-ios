//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Simon Lee on 2023-05-14.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
