//
//  SolanaSDK+Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getSwapPools() -> Single<[Pool]> {
        if let pools = _swapPool {return .just(pools)}
        return getPools(swapProgramId: network.swapProgramId.base58EncodedString)
            .do(onSuccess: {self._swapPool = $0})
    }
    
    func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .flatMap {
                Single.zip(
                    try $0.filter {$0.account.data.value != nil}
                        .compactMap {
                            self.getPoolInfo(
                                address: try PublicKey(string: $0.pubkey),
                                swapData: $0.account.data.value!
                            )
                        }
                )
            }
    }
    
    func getPoolInfo(address: PublicKey, swapData: TokenSwapInfo) -> Single<Pool> {
        Single.zip([
            self.getMintData(mintAddress: swapData.mintA, programId: PublicKey.tokenProgramId),
            self.getMintData(mintAddress: swapData.mintB, programId: PublicKey.tokenProgramId),
            self.getMintData(mintAddress: swapData.tokenPool, programId: PublicKey.tokenProgramId)
        ])
            .map { mintDatas in
                guard let authority = mintDatas[2].mintAuthority else {
                    throw Error.other("Invalid mintAuthority")
                }
                return Pool(address: address, tokenAInfo: mintDatas[0], tokenBInfo: mintDatas[1], poolTokenMint: mintDatas[2], authority: authority, swapData: swapData)
            }
    }
    
    private func getMintData(
        mintAddress: PublicKey,
        programId: PublicKey
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self)
            .map {
                if $0.owner != programId.base58EncodedString {
                    throw Error.other("Invalid mint owner")
                }
                
                if let data = $0.data.value {
                    return data
                }
                
                throw Error.other("Invalid data")
            }
    }
}