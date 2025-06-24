import Foundation
import Testing
@testable import BuddyFoundation

@Suite("Lock Tests")
struct LockTests {
    /// No expectations here other than it shouldn't crash.
    @Test func testConcurrentReadWriteProtected() async {
        let container = TestContainer()

        let maxCount = 10000
        let taskCount = 4

        await withTaskGroup { group in
            func runLoop() async {
                for i in 1...maxCount {
                    container.value.insert(i)
                    await Task.yield()
                    container.value2.insert(i)
                }
            }

            for _ in 0..<taskCount {
                group.addTask {
                    await runLoop()
                }
            }

            await group.waitForAll()
        }
    }
}

private final class TestContainer: @unchecked Sendable {
    @Lock var value: Set<Int> = []
    @Lock var value2: Set<Int> = []
}
