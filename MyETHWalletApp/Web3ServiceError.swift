//
//  Web3ServiceError.swift
//  MyETHWalletApp
//
//  Created by Yuta Fujii on 2022/04/06.
//

import Foundation

enum Web3ServiceError:Error{
    case noAddress
    case noMnemonics
    case noKeyStore
    case noContract
    case noBalance
}
