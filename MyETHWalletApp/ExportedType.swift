//
//  ExportedType.swift
//  MyETHWalletApp
//
//  Created by Yuta Fujii on 2022/04/06.
//

import Foundation

enum ExportedType {
    case privateKey(key: String)
    case mnemonics(mnemonics: [String], key: String)
}
