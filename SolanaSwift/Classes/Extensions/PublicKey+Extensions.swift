//
//  PublicKeys.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/01/2021.
//

import Foundation

public extension SolanaSDK.PublicKey {
    static let tokenProgramId = try! SolanaSDK.PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
    static let sysvarRent = try! SolanaSDK.PublicKey(string: "SysvarRent111111111111111111111111111111111")
    static let programId = try! SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
    static let wrappedSOLMint = try! SolanaSDK.PublicKey(string: "So11111111111111111111111111111111111111112")
}