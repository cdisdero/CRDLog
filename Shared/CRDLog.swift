//
//  CRDLog.swift
//  CRDLog
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

import Foundation

/**
 Class providing console and file logging to the app.
 */
public class CRDLog {
    
    // MARK: Private properties
    
    /// File handle to the log file.
    private let logFileURL: URL
    
    /// Queue for logging activities
    private let queue: DispatchQueue
    
    /// Delegate for log events
    private weak var delegate: CRDLogDelegate? = nil
    
    // MARK: Initializers
    
    /**
     Initializes a new CRDLog object with the given file name and optional delegate.
     
     - Parameter logFileName: The file name with extension to use for the log file in the cache directory. Defaults to 'app.log'.
     
     - Parameter logDelegate: An optional class instance that implements protocol CRDLogDelegate.
     */
    public init(logFileName: String = "app.log", logDelegate: CRDLogDelegate? = nil) {
        
        // Set the delegate
        delegate = logDelegate
        
        // Create the log queue.
        queue = DispatchQueue(label: "com.ChrisDisdero.CRDLog.queue", attributes: [])
        
        // Set the log file url.
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
        logFileURL = (cacheDirectory?.appendingPathComponent("\(logFileName)"))!
    }
    
    // MARK: - Public methods
    
    /**
     Writes an informational message to the log.
     
     - Parameter message: The message to write to the log.
     
     - Note: The actual log entry contains the current time, the tag 'INFO', and the message specified.
     */
    public func info(_ message: String) {
        
        write(type: "INFO", message: message)
    }
    
    /**
     Writes a warning message to the log.
     
     - Parameter message: The message to write to the log.
     
     - Note: The actual log entry contains the current time, the tag 'WARN', and the message specified.
     */
    public func warn(_ message: String) {
        
        write(type: "WARN", message: message)
    }
    
    /**
     Writes an error message to the log.
     
     - Parameter message: The message to write to the log.
     
     - Note: The actual log entry contains the current time, the tag 'ERROR', and the message specified.
     */
    public func error(_ message: String) {
        
        write(type: "ERROR", message: message)
    }
    
    /**
     Clears the log file.
     
     - Note: The log is cleared after any other pending writes to the log.
     */
    public func clear() {
        
        // The log clear operation.
        let clearClosure = {
            
            if let fileHandle = self.openFile() {
                
                // Clear the log and flush.
                fileHandle.truncateFile(atOffset: 0)
                fileHandle.synchronizeFile()
                
                fileHandle.closeFile()
            }
        }
        
        // Queue a log clear operation.
        queue.async(execute: clearClosure)
    }
    
    /**
     Reads content asynchronously from the log

     - Note: The log content will be read after any other pending operations with the log have completed.

     - Parameter completion: The completion handler to call with the string content read from the log.
     */
    public func contentsWithCompletion(_ completion: @escaping (_ result: String?)->Void) {
        
        // The log read operation.
        let logContentClosure = {
            
            var result: String? = nil
            
            if let fileHandle = self.openFile() {
                
                // Read the content of the log starting at the top and going to the end.
                fileHandle.seek(toFileOffset: 0)
                let data = fileHandle.readDataToEndOfFile()
                result = String(data: data, encoding: String.Encoding.utf8)
                
                fileHandle.closeFile()
            }
            
            // Call the completion handler specified with the resulting content read.
            completion(result)
        }
        
        // Queue a log read.
        queue.async(execute: logContentClosure)
    }
    
    // MARK: Private methods
    
    /**
     Opens the log file.
     
     - Note: If the log file doesn't exist, it is created. Errors are logged to the console.
     - Returns: The file handle to the log file, or nil if an error occurred.
     */
    private func openFile() -> FileHandle? {
        
        var fileHandle: FileHandle? = nil
        
        // If the log file doesn't exist, then create it.
        let path = logFileURL.path
        if !FileManager.default.fileExists(atPath: path) {
            
            if !FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
                
                print("(\(#function)) - Failed to create log file '\(logFileURL)'.")
            }
        }
        
        do {
            
            // Try to get a file handle on the log file.
            fileHandle = try FileHandle(forUpdating: logFileURL)
        }
        catch let error as NSError {
            
            print("(\(#function)) - Error occurred when writing to log file '\(logFileURL)': \(error)")
        }
        
        return fileHandle
    }

    /**
     Writes a message asynchronously to the log.

     - Parameter type: The type of the message to write to the log.  This is printed in the log file as a tag that can be used to filter messages.
     
     - Parameter message: The message to write to the log.
     
     - Note: If the log is empty before the message is written, a header defined by *header* will be written automatically.
     */
    private func write(type: String, message: String) {
        
        // The write operation
        let outputClosure = {
            
            if let fileHandle = self.openFile() {
                
                // Always append new content to the end of the log.
                let offset = fileHandle.seekToEndOfFile()
                
                // If the log file is empty, write the header if possible.
                if offset == 0 {
                    
                    if let delegate = self.delegate {
                        
                        if let header = delegate.logHeader!() {
                            
                            if let encodedData = "\(header)\n".data(using: String.Encoding.utf8) {
                                
                                print(header)
                                fileHandle.write(encodedData)
                                fileHandle.synchronizeFile()
                            }
                        }
                    }
                }
                
                // Create the log message with the current time, the message type, and the message.
                let message = "\(Date()) \(type) \(message)"
                if let encodedData = "\(message)\n".data(using: String.Encoding.utf8) {
                    
                    // Output the message to the debug console.
                    print(message)
                    
                    // Write the message to the log file and flush.
                    fileHandle.write(encodedData)
                    fileHandle.synchronizeFile()
                }
                
                // Close the log file
                fileHandle.closeFile()
            }
        }
        
        // Queue a write operation to the log.
        queue.async(execute: outputClosure)
    }
}
