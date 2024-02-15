import XCTest
import Dependencies
import XCTestDynamicOverlay
@testable import Colossus

final class DataManagerTests: XCTestCase {
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.uuid) var uuid
    
    func test__GIVEN__no_user__WHEN__fetchUser_called__THEN__return_user() {
        try! withDependencies {
            $0.dataManager = .testValue
            $0.uuid = .incrementing
        } operation: {
            XCTAssertEqual(try self.dataManager.fetchUser(), User(id: self.uuid(), name: ""))
        }
    }
}
