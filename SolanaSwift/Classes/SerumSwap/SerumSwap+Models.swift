//
//  SerumSwap+Models.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SerumSwap {
    public struct SignersAndInstructions {
        let signers: [Account]
        let instructions: [TransactionInstruction]
    }
    
    public struct SwapParams {
        public init(fromMint: SerumSwap.PublicKey, toMint: SerumSwap.PublicKey, amount: SerumSwap.Lamports, minExpectedSwapAmount: SerumSwap.Lamports? = nil, referral: SerumSwap.PublicKey?, quoteWallet: SerumSwap.PublicKey?, fromWallet: SerumSwap.PublicKey, toWallet: SerumSwap.PublicKey?, feePayer: SerumSwap.PublicKey?, configs: SolanaSDK.RequestConfiguration? = nil) {
            self.fromMint = fromMint
            self.toMint = toMint
            self.amount = amount
            self.minExpectedSwapAmount = minExpectedSwapAmount
            self.referral = referral
            self.quoteWallet = quoteWallet
            self.fromWallet = fromWallet
            self.toWallet = toWallet
            self.feePayer = feePayer
            self.configs = configs
        }
        
        let fromMint: PublicKey
        let toMint: PublicKey
        let amount: Lamports
        var minExpectedSwapAmount: Lamports?
        let referral: PublicKey?
        let quoteWallet: PublicKey?
        let fromWallet: PublicKey
        let toWallet: PublicKey?
        let feePayer: PublicKey?
        var configs: SolanaSDK.RequestConfiguration? = nil
    }
    
    public struct DidSwap: BufferLayout {
        public let givenAmount: UInt64
        public let minExpectedSwapAmount: UInt64
        public let fromAmount: UInt64
        public let toAmount: UInt64
        public let spillAmount: UInt64
        public let fromMint: PublicKey
        public let toMint: PublicKey
        public let quoteMint: PublicKey
        public let authority: PublicKey
    }
    
    // Side rust enum used for the program's RPC API.
    public enum Side {
        case bid, ask
        var params: [String: [String: String]] {
            switch self {
            case .bid:
                return ["bid": [:]]
            case .ask:
                return ["ask": [:]]
            }
        }
        var byte: UInt8 {
            switch self {
            case .bid:
                return 0
            case .ask:
                return 1
            }
        }
    }
}

// MARK: - BufferLayout properties
extension SerumSwap {
    public struct Blob5: BufferLayoutProperty {
        public static var numberOfBytes: Int {5}
        
        public static func fromBytes(bytes: [UInt8]) throws -> Blob5 {
            Blob5()
        }
    }

    public struct AccountFlags: BufferLayout, BufferLayoutProperty {
        private(set) var initialized: Bool
        private(set) var market: Bool
        private(set) var openOrders: Bool
        private(set) var requestQueue: Bool
        private(set) var eventQueue: Bool
        private(set) var bids: Bool
        private(set) var asks: Bool
        
        public static var numberOfBytes: Int { 8 }
        
        public static func fromBytes(bytes: [UInt8]) throws -> AccountFlags {
            try .init(buffer: Data(bytes))
        }
    }

    public struct Seq128Elements<T: FixedWidthInteger>: BufferLayoutProperty {
        var elements: [T]
        
        public static var numberOfBytes: Int {
            128 * MemoryLayout<T>.size
        }
        
        public static func fromBytes(bytes: [UInt8]) throws -> Seq128Elements<T> {
            guard bytes.count > Self.numberOfBytes else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            var elements = [T]()
            let chunkedArray = bytes.chunked(into: MemoryLayout<T>.size)
            for element in chunkedArray {
                let data = Data(element)
                let num = T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
                elements.append(num)
            }
            return .init(elements: elements)
        }
    }
    
    public struct Blob1024: BufferLayoutProperty {
        public static var numberOfBytes: Int {1024}
        
        public static func fromBytes(bytes: [UInt8]) throws -> Blob1024 {
            Blob1024()
        }
    }

    public struct Blob7: BufferLayoutProperty {
        public static var numberOfBytes: Int {7}
        
        public static func fromBytes(bytes: [UInt8]) throws -> Blob7 {
            Blob7()
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
