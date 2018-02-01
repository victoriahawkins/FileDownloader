//
//  SequenceTests.swift
//  FileDownloaderTests
//
//  Created by Victoria Hawkins on 1/30/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import XCTest
import UIKit

@testable import FileDownloader

class SequenceTests: XCTestCase {
    
    var analyzer:FileAnalyser!
    
    let user1 = ["Page 1", "Page 2", "Page 3", "Page 4", "Page 1", "Page 2", "Page 9"]
    let user2 = ["Page 1", "Page 2", "Page 3", "Page 4", "Page 5", "Page 2", "Page 9", "Page 10"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        analyzer = FileAnalyser()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        analyzer = nil
    }
    
    func testFindSequencesUser1() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
        let user1Sequences = analyzer.findPageSequencesForUser(user1)
        
        debugPrint("User1 sequences are:")
        for seqeunce in user1Sequences {
            debugPrint(" \(seqeunce)")
        }

        XCTAssertEqual(user1Sequences,
            [ "Page 1, Page 2, Page 3",
              "Page 2, Page 3, Page 4",
              "Page 3, Page 4, Page 1",
              "Page 4, Page 1, Page 2",
              "Page 1, Page 2, Page 9"], "user 1 sequences are equal")
        
    }
    
    func testFindSequencesUser2() {

        let user2Sequences = analyzer.findPageSequencesForUser(user2)
        
        debugPrint("User2 sequences are:")
        for sequence in user2Sequences {
            debugPrint(" \(sequence)")
        }
        
        XCTAssertEqual(user2Sequences,
                       [ "Page 1, Page 2, Page 3",
                         "Page 2, Page 3, Page 4",
                         "Page 3, Page 4, Page 5",
                         "Page 4, Page 5, Page 2",
                         "Page 5, Page 2, Page 9",
                         "Page 2, Page 9, Page 10"], "user 2 sequences are equal")

        
        
    }
    

    func testFindCommonSequencesBetweenUser1AndUser2() {
        
        let combinedSequences = analyzer.findPageSequencesForUser(user1) +
            analyzer.findPageSequencesForUser(user2)
        
        let unsortedSequencesAndCounts = analyzer.groupRelatedSequences(combinedSequences);
        
        let sortedSequencesAndCounts = analyzer.sortSequencesAscending(unsortedSequencesAndCounts)
        
        debugPrint("Sorted sequences for Users were:")
        for (sequence, appearances) in sortedSequencesAndCounts  {
            
            debugPrint(" \(sequence) : \(appearances)")
        }
        
        var (first, second) = sortedSequencesAndCounts[0]
        XCTAssertEqual(first,"Page 1, Page 2, Page 3")
        XCTAssertEqual(second,2)
        
        (first, second) = sortedSequencesAndCounts[1]
        XCTAssertEqual(first,"Page 2, Page 3, Page 4")
        XCTAssertEqual(second,2)
        
        (first, second) = sortedSequencesAndCounts[2]
        XCTAssertEqual(first,"Page 2, Page 9, Page 10")
        XCTAssertEqual(second,1)

        (first, second) = sortedSequencesAndCounts[3]
        XCTAssertEqual(first,"Page 1, Page 2, Page 9")
        XCTAssertEqual(second,1)
        
        (first, second) = sortedSequencesAndCounts[4]
        XCTAssertEqual(first,"Page 4, Page 5, Page 2")
        XCTAssertEqual(second,1)
        
        (first, second) = sortedSequencesAndCounts[5]
        XCTAssertEqual(first,"Page 5, Page 2, Page 9")
        XCTAssertEqual(second,1)
        
        (first, second) = sortedSequencesAndCounts[6]
        XCTAssertEqual(first,"Page 4, Page 1, Page 2")
        XCTAssertEqual(second,1)
        
        (first, second) = sortedSequencesAndCounts[7]
        XCTAssertEqual(first,"Page 3, Page 4, Page 1")
        XCTAssertEqual(second,1)
        
        (first, second) = sortedSequencesAndCounts[8]
        XCTAssertEqual(first,"Page 3, Page 4, Page 5")
        XCTAssertEqual(second,1)
        
        
//        XCTAssertEqual(sortedSequencesAndCounts,
//                       [ ("Page 1, Page 2, Page 3", 2),
//                        ("Page 2, Page 3, Page 4" , 2),
//                        ("Page 2, Page 9, Page 10" , 1),
//                        ("Page 1, Page 2, Page 9" , 1),
//                        ("Page 4, Page 5, Page 2" , 1),
//                        ("Page 5, Page 2, Page 9" , 1),
//                        ("Page 4, Page 1, Page 2" , 1),
//                        ("Page 3, Page 4, Page 1" , 1),
//                        ("Page 3, Page 4, Page 5" , 1)])


        
    }
    
    func testFindCountPageHitsPerIP() {
        
        /*"IP: 123.4.5.7 PagesList: 1093"
         "IP: 123.4.5.6 PagesList: 1108"
         "IP: 123.4.5.1 PagesList: 1114"
         "IP: 123.4.5.3 PagesList: 1091"
         "IP: 123.4.5.9 PagesList: 1115"
         "IP: 123.4.5.2 PagesList: 1145"
         "IP: 123.4.5.4 PagesList: 1111"
         "IP: 123.4.5.8 PagesList: 1088"
         "IP: 123.4.5.5 PagesList: 1135"
         
         1093 + 1108 + 1114 + 1091 + 1115 + 1145 + 1111 + 1088 + 1135
         */
    }
    
    func testAnalyzeSampleFile() {
        
        
        let urlpath     = Bundle.main.path(forResource: "sampleApacheFile", ofType: "txt")
        let url         = NSURL.fileURL(withPath: urlpath!)

        
        let visitedPages = analyzer.extractPageVisitsPerUser(url)

        XCTAssertNotNil(visitedPages)
        
        let combinedSequences = analyzer.createPageSequencesPerUserVisits(visitedPages: visitedPages)
        
        XCTAssertNotNil(visitedPages)

        // group similar page sequences and produce a count
        let unsortedSequencesAndCounts = analyzer.groupRelatedSequences(combinedSequences)
        
        XCTAssertNotNil(unsortedSequencesAndCounts)

        let sortedSequencesAndCounts = analyzer.sortSequencesAscending(unsortedSequencesAndCounts)
        
        var (pages, count) = sortedSequencesAndCounts[0]
        XCTAssertEqual(pages,"/about/, /products/car/, /contact/")
        XCTAssertEqual(count,2)
        
        (pages, count) = sortedSequencesAndCounts[1]
        XCTAssertEqual(pages,"/jobs/, /team/, /products/phone/")
        XCTAssertEqual(count,1)
        
        (pages, count) = sortedSequencesAndCounts[2]
        XCTAssertEqual(pages,"/about/, /access/, /login/")
        XCTAssertEqual(count,1)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            testAnalyzeSampleFile()
        }
    }
    
}
