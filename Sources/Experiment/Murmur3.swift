//
//  Murmur3.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation
    
private let C1_32: UInt32 = UInt32(bitPattern: -0x3361d2af)
private let C2_32: UInt32 = 0x1b873593
private let R1_32: UInt32 = 15
private let R2_32: UInt32 = 13
private let M_32: UInt32 = 5
private let N_32: UInt32 = UInt32(bitPattern: -0x19ab949c)

internal extension String {
    func murmurHash32x86(seed: Int) -> Int? {
        self.data(using: .utf8)?.murmurHash32x86(seed: seed)
    }
}

internal extension Data {
    
    func murmurHash32x86(seed: Int) -> Int {
        let length = self.count
        var hash = UInt32(seed)
        let nBlocks = length >> 2
        
        // body
        for i in 0..<nBlocks {
            let index = i << 2
            let k = self.readIntLe(index: index)
            hash = mix32(k: k, hash: hash)
        }
        
        // tail
        let index = nBlocks << 2
        var k1: UInt32 = 0
        switch length - index {
        case 3:
            k1 ^= UInt32(self[index + 2]) << 16
            k1 ^= UInt32(self[index + 1]) << 8
            k1 ^= UInt32(self[index])
            k1 &*= C1_32
            k1 = k1.rotateLeft(n: R1_32)
            k1 &*= C2_32
            hash ^= k1
            break
        case 2:
            k1 ^= UInt32(self[index + 1]) << 8
            k1 ^= UInt32(self[index])
            k1 &*= C1_32
            k1 = k1.rotateLeft(n: R1_32)
            k1 &*= C2_32
            hash ^= k1
            break
        case 1:
            k1 ^= UInt32(self[index])
            k1 &*= C1_32
            k1 = k1.rotateLeft(n: R1_32)
            k1 &*= C2_32
            hash ^= k1
            break
        default:
            break
        }
        hash ^= UInt32(length)
        return Int(fmix32(hash: hash))
    }
}

private func mix32(k: UInt32, hash: UInt32) -> UInt32 {
    var kResult = k
    var hashResult = hash
    kResult &*= C1_32
    kResult = kResult.rotateLeft(n: R1_32)
    kResult &*= C2_32
    hashResult ^= kResult
    hashResult = hashResult.rotateLeft(n: R2_32)
    hashResult &*= M_32
    return hashResult &+ N_32;
}

private func fmix32(hash: UInt32) -> UInt32 {
    var hashResult = hash
    hashResult ^= hashResult >> 16
    hashResult &*= UInt32(bitPattern: -0x7a143595)
    hashResult ^= hashResult >> 13
    hashResult &*= UInt32(bitPattern:-0x3d4d51cb)
    hashResult ^= hashResult >> 16
    return hashResult
}


private extension UInt32 {

    func rotateLeft(n: UInt32, width: UInt32 = 32) -> UInt32 {
        var un: UInt32 = n
        if n > width {
            un = un % width
        }
        let mask: UInt32 = (0xffffffff << (width &- un))
        let r = (self & mask) >> (width &- un)
        return (self << un) | r
    }
}

private extension Data {
    func readIntLe(index: Int) -> UInt32 {
        return UInt32(self[index]) | UInt32(self[index + 1]) << 8 | UInt32(self[index + 2]) << 16 | UInt32(self[index + 3]) << 24
    }
}
