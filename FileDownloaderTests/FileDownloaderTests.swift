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
    
    let url = URL(string: "https://scholar.princeton.edu/sites/default/files/oversize_pdf_test_0.pdf")!
    
    var client:FileDownloadClient!
    
    let session = MockDownloadSession()

    
    override func setUp() {
        super.setUp()

        client = FileDownloadClient(session: session)
    
    }
    
    override func tearDown() {
    
        super.tearDown()
    }

    
    /* Test the URL for the download matches the URL that was passed */
    func testMockedLastURL() {
        
        _ = client.downloadFileInBackground(with: url)

        XCTAssertEqual(session.lastURL, url)
        
    }
    
    func testMockedDownloadStartsTheRequest() {
        
        let downloadTask = MockURLSessionDownloadTask()
        session.nextDownloadTask = downloadTask

        let task = client.downloadFileInBackground(with: url)
        task.resume()
        
        XCTAssert(downloadTask.resumeWasCalled)

    }
    
    func testRealSessionDownloadFileInBackground() {
        
        let client = FileDownloadClient()// starts default session
        let task = client.downloadFileInBackground (with: url)
        task.resume()  /// TODO encapsulate
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
