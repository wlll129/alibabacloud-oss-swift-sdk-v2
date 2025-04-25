import Foundation

public struct CRC64: Sendable {
    public static let `default` = CRC64()

    private let poly: UInt64 = 0xC96C_5795_D787_0F42
    private let table: [[UInt64]]
    private let isLittleEndian: Bool

    init() {
        let n: Int64 = 1
        isLittleEndian = (n == n.littleEndian)

        var crc: UInt64
        var table = [[UInt64]](repeating: [UInt64](repeating: 0, count: 256), count: 8)
        for n in 0 ..< 256 {
            crc = UInt64(n)
            for _ in 0 ..< 8 {
                crc = ((crc & 1) != 0) ? poly ^ (crc >> 1) : crc >> 1
            }
            table[0][n] = crc
        }

        for n in 0 ..< 256 {
            crc = table[0][n]
            for k in 1 ..< 8 {
                crc = table[0][Int(crc & 0xFF)] ^ (crc >> 8)
                table[k][n] = crc
            }
        }
        self.table = table

        if !isLittleEndian {
            for k in 0 ..< 8 {
                for n in 0 ..< 256 {
                    table[k][n] = rev8(a: table[k][n])
                }
            }
        }
    }

    @inlinable
    func rev8(a: UInt64) -> UInt64 {
        var m: UInt64
        m = 0xFF_00FF_00FF_00FF
        var a = ((a >> 8) & m) | (a & m) << 8
        m = 0xFFFF_0000_FFFF
        a = ((a >> 16) & m) | (a & m) << 16
        return a >> 32 | a << 32
    }

    public func crc64(crc: UInt64, buf: UnsafeRawPointer, len: Int) -> UInt64 {
        if isLittleEndian {
            return crc64Little(crc: crc, buf: buf, len: len)
        } else {
            return crc64Big(crc: crc, buf: buf, len: len)
        }
    }

    private func crc64Little(crc: UInt64, buf: UnsafeRawPointer, len: Int) -> UInt64 {
        var next = UnsafeMutableRawPointer(mutating: buf)
        var len = len

        var crc = ~crc
        while len > 0 && (Int(bitPattern: buf) & 7) != 0 {
            crc = table[0][Int((crc ^ UInt64(next.load(as: UInt8.self))) & 0xFF)] ^ (crc >> 8)
            next += 1
            len -= 1
        }

        while len >= 8 {
            crc ^= next.load(as: UInt64.self)
            crc = table[7][Int(crc & 0xFF)] ^
                table[6][Int((crc >> 8) & 0xFF)] ^
                table[5][Int((crc >> 16) & 0xFF)] ^
                table[4][Int((crc >> 24) & 0xFF)] ^
                table[3][Int((crc >> 32) & 0xFF)] ^
                table[2][Int((crc >> 40) & 0xFF)] ^
                table[1][Int((crc >> 48) & 0xFF)] ^
                table[0][Int(crc >> 56)]
            next += 8
            len -= 8
        }

        while len > 0 {
            crc = table[0][Int((crc ^ UInt64(next.load(as: UInt8.self))) & 0xFF)] ^ (crc >> 8)
            next += 1
            len -= 1
        }

        return ~crc
    }

    private func crc64Big(crc: UInt64, buf: UnsafeRawPointer, len: Int) -> UInt64 {
        var next = UnsafeMutableRawPointer(mutating: buf)
        var len = len

        var crc = ~rev8(a: crc)
        while len > 0 && (Int(bitPattern: buf) & 7) != 0 {
            crc = table[0][Int((crc >> 56) ^ UInt64(next.load(as: UInt8.self)))] ^ (crc << 8)
            next += 1
            len -= 1
        }

        while len >= 8 {
            crc ^= next.load(as: UInt64.self)
            crc = table[0][Int(crc & 0xFF)] ^
                table[1][Int((crc >> 8) & 0xFF)] ^
                table[2][Int((crc >> 16) & 0xFF)] ^
                table[3][Int((crc >> 24) & 0xFF)] ^
                table[4][Int((crc >> 32) & 0xFF)] ^
                table[5][Int((crc >> 40) & 0xFF)] ^
                table[6][Int((crc >> 48) & 0xFF)] ^
                table[7][Int(crc >> 56)]
            next += 8
            len -= 8
        }

        while len > 0 {
            crc = table[0][Int((crc >> 56) ^ UInt64(next.load(as: UInt8.self)))] ^ (crc << 8)
            next += 1
            len -= 1
        }

        return ~rev8(a: crc)
    }

    private func gf2MatrixTimes(_ mat: UnsafeMutablePointer<UInt64>, _ vec: UInt64) -> UInt64 {
        var mat = mat
        var vec = vec
        var sum: UInt64 = 0

        while vec != 0 {
            if (vec & 1) != 0 {
                sum ^= mat.pointee
            }
            vec >>= 1
            mat += 1
        }
        return sum
    }

    private func gf2MatrixSquare(_ square: UnsafeMutablePointer<UInt64>, _ mat: UnsafeMutablePointer<UInt64>) {
        for n in 0 ..< 64 {
            square[n] = gf2MatrixTimes(mat, mat[n])
        }
    }

    public func crc64Combine(crc1: UInt64, crc2: UInt64, len2: uintmax_t) -> UInt64 {
        var crc1 = crc1
        var len2 = len2
        var row: UInt64 = 1
        var even = [UInt64](repeating: 0, count: 64) /* even-power-of-two zeros operator */
        var odd = [UInt64](repeating: 0, count: 64) /* odd-power-of-two zeros operator */

        /* degenerate case */
        if len2 == 0 {
            return crc1
        }

        /* put operator for one zero bit in odd */
        odd[0] = 0xC96C_5795_D787_0F42 /* CRC-64 polynomial */
        for n in 1 ..< 64 {
            odd[n] = row
            row <<= 1
        }

        /* put operator for two zero bits in even */
        gf2MatrixSquare(&even, &odd)

        /* put operator for four zero bits in odd */
        gf2MatrixSquare(&odd, &even)

        /* apply len2 zeros to crc1 (first square will put the operator for one
         zero byte, eight zero bits, in even) */
        repeat {
            /* apply zeros operator for this bit of len2 */
            gf2MatrixSquare(&even, &odd)
            if (len2 & 1) != 0 {
                crc1 = gf2MatrixTimes(&even, crc1)
            }
            len2 >>= 1

            /* if no more bits set, then done */
            if len2 == 0 {
                break
            }

            /* another iteration of the loop with odd and even swapped */
            gf2MatrixSquare(&odd, &even)
            if (len2 & 1) != 0 {
                crc1 = gf2MatrixTimes(&odd, crc1)
            }
            len2 >>= 1

            /* if no more bits set, then done */
        } while len2 != 0

        /* return combined crc */
        crc1 ^= crc2
        return crc1
    }
}
