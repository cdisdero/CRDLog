//
//  CRDLogTests.swift
//  CRDLogTests
//
//  Created by Christopher Disdero on 4/1/17.
//
/*
 Copyright © 2017 Christopher Disdero.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
#if os(iOS)
    @testable import CRDLogMobile
#elseif os(macOS)
    @testable import CRDLogMac
#elseif os(tvOS)
    @testable import CRDLogTV
#endif

class CRDLogTests: XCTestCase, CRDLogDelegate {
    
    // MARK: - Private properties
    
    private var log: CRDLog? = nil
    
    // MARK: - Test setup and teardown.
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Create the instance of the log to use for testing.
        log = CRDLog(logDelegate: self)
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - CRDLogDelegate methods
    
    func logHeader() -> String? {
        
        return "Header written"
    }
    
    // MARK: - Tests
    
    /// Tests writing several entries, clearing, then writing more entries.
    func testBasicLogWrites() {
        
        // Expected header written.
        let expectedHeader = "Header written"
        
        // Expected log content.
        var expectedLogContent: [String] = [
            "Log entry 1",
            "Log entry 2"
        ]

        // Clear the log
        log?.clear()
        
        // Get the current content of the log
        
        var actualLogContent: String? = nil
        var semaphore = DispatchSemaphore(value: 0)
        
        log?.contentsWithCompletion { (result: String?) in
            
            actualLogContent = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(30)) / Double(NSEC_PER_SEC))
        
        XCTAssertNotNil(actualLogContent, "Expected non-nil log file content.")
        XCTAssertTrue((actualLogContent?.isEmpty)!, "Expected empty log content.")

        // Write some entries.
        for entry in expectedLogContent {
            
            log?.info(entry)
        }

        // Get the current content of the log

        actualLogContent = nil
        semaphore = DispatchSemaphore(value: 0)
        
        log?.contentsWithCompletion { (result: String?) in
            
            actualLogContent = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(30)) / Double(NSEC_PER_SEC))
        
        XCTAssertNotNil(actualLogContent, "Expected non-nil log file content.")
        
        XCTAssertTrue((actualLogContent?.hasPrefix(expectedHeader))!, "Expected header not found.")
        for expectedEntry in expectedLogContent {
            
            XCTAssertTrue((actualLogContent?.contains("INFO \(expectedEntry)"))!, "Expected entry '\(expectedEntry)' not found.")
        }
        
        // Clear the log
        log?.clear()
        
        expectedLogContent = [
            "Log entry 3",
            "Log entry 4"
        ]

        // Write some entries.
        for entry in expectedLogContent {
            
            log?.warn(entry)
        }
        
        // Get the current content of the log
        
        actualLogContent = nil
        semaphore = DispatchSemaphore(value: 0)
        
        log?.contentsWithCompletion { (result: String?) in
            
            actualLogContent = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(30)) / Double(NSEC_PER_SEC))
        
        XCTAssertNotNil(actualLogContent, "Expected non-nil log file content.")
        
        XCTAssertTrue((actualLogContent?.hasPrefix(expectedHeader))!, "Expected header not found.")
        for expectedEntry in expectedLogContent {
            
            XCTAssertTrue((actualLogContent?.contains("WARN \(expectedEntry)"))!, "Expected entry '\(expectedEntry)' not found.")
        }
    }
    
    /// Tests writing a large number of messages to the log in a burst.
    func testBurstLogWrites() {
        
        // The expected header in the log.
        let expectedHeader = "Header written"
        
        // Clear the log
        log?.clear()
        
        // Get the current content of the log
        
        var actualLogContent: String? = nil
        var semaphore = DispatchSemaphore(value: 0)
        
        log?.contentsWithCompletion { (result: String?) in
            
            actualLogContent = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(30)) / Double(NSEC_PER_SEC))
        
        XCTAssertNotNil(actualLogContent, "Expected non-nil log file content.")
        XCTAssertTrue((actualLogContent?.isEmpty)!, "Expected empty log content.")
        
        // Set the expected log content after the burst.
        var expectedLogContent: [String] = []
        
        // Write many messages in a burst.
        for i in 0 ..< 500 {
            
            // Form the new message to write.
            let message = "Log entry \(i)"
            
            // Update the expected log content with the new message.
            expectedLogContent.append(message)
            
            // Write the message to the log.
            log?.error(message)
        }
        
        // Get the current content of the log

        actualLogContent = nil
        semaphore = DispatchSemaphore(value: 0)
        
        log?.contentsWithCompletion { (result: String?) in
            
            actualLogContent = result
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(30)) / Double(NSEC_PER_SEC))
        
        XCTAssertNotNil(actualLogContent, "Expected non-nil log file content.")
        
        XCTAssertTrue((actualLogContent?.hasPrefix(expectedHeader))!, "Expected header not found.")
        for expectedEntry in expectedLogContent {
            
            XCTAssertTrue((actualLogContent?.contains("ERROR \(expectedEntry)"))!, "Expected entry '\(expectedEntry)' not found.")
        }
    }
}
