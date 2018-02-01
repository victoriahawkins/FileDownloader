//
//  FileDownloaderTests.swift
//  FileDownloaderTests
//
//  Created by Victoria Hawkins on 1/29/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import XCTest

@testable import FileDownloader

class FileDownloaderTests: XCTestCase {
    
    var client:FileDownloadClient!
    
//    let session = MockURLSession()

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        client = FileDownloadClient()


    }
    
    override func tearDown() {
        
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDownloadFileInBackground() {
        
        let url = URL(string: "https://scholar.princeton.edu/sites/default/files/oversize_pdf_test_0.pdf")!
        let task = client.startSession().downloadTask(with: url)
        task.resume()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
