import XCTest

final class ReplacingReproTests: XCTestCase {
    
    func testLeakage() {
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            for _ in 0...1_000_000 {
                _ = randomString().replacingOccurrences(of: "some", with: "")
            }
        }
    }
    
    func testNoLeakage() {
        let options = XCTMeasureOptions()
        options.iterationCount = 1
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            for _ in 0...1_000_000 {
                _ = randomString().newReplacingOccurrences(of: "some", with: "")
            }
        }
    }
    
    func randomString() -> String {
        let someChars: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let chars = (0...Int.random(in: 5...10)).map({ _ in someChars.randomElement()! })
        return String(chars)
    }
}

extension String {
    func newReplacingOccurrences(of target: String, with replacement: String) -> String {
        let targetLastIdx = target.count - 1
        let selfLength = self.count
        let targetEnumerated = target.enumerated()
        let selfChars: [Character] = .init(self)
        var newChars: [Character] = []
        var idxUsed: Int = -1
        
        for idx in (0..<self.count) where idx > idxUsed {
            for (ind, targetChar) in targetEnumerated {
                let index = idx + ind
                guard selfLength > index, selfChars[index] == targetChar else {
                    newChars.append(selfChars[idx])
                    break
                }
                if ind == targetLastIdx {
                    newChars.append(contentsOf: [Character](replacement))
                    idxUsed = index
                }
            }
        }
        
        return String(newChars)
    }
}
