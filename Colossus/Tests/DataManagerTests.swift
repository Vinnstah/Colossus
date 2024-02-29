import XCTest
import Dependencies
import XCTestDynamicOverlay
@testable import Colossus

final class DataManagerTests: XCTestCase {
    @Dependency(\.dataManager) var dataManager
    @Dependency(\.uuid) var uuid
    
    func test__GIVEN__onboarding_completed__WHEN__fetchUser_called__THEN__return_user() {
        let model = try! withDependencies {
            $0.dataManager.fetchUser = { User(id: self.uuid(), name: "Test")}
            $0.uuid = .constant(.init(uuidString: "00000000-0000-0000-0000-000000000000")!)
        } operation: {
            try self.dataManager.fetchUser()
        }
        XCTAssertEqual(model, User(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, name: "Test"))
    }
    
    func test__GIVEN__onboarding_incomplete__WHEN__fetchUser_called__THEN__return_nil() {
        let model = try! withDependencies {
            $0.dataManager.fetchUser = { nil }
            $0.uuid = .constant(.init(uuidString: "00000000-0000-0000-0000-000000000000")!)
        } operation: {
            try self.dataManager.fetchUser()
        }
        
        XCTAssertEqual(model, nil)
    }
    
    func test__GIVEN__user__WHEN__addUser_called__THEN__return_user() {
        let user = User(id: self.uuid(), name: "Test")
        let model = try! withDependencies {
            $0.uuid = .constant(.init(uuidString: "00000000-0000-0000-0000-000000000002")!)
            $0.encode = .json
            $0.userDefaults = .testValue
            $0.dataManager.addUser(user)
         } operation: {
            try self.dataManager.addUser(user)
        }
        XCTAssertEqual(model, User(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Test"))
    }
}
