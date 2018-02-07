//
//  FileAnalyser.swift
//  FileDownloader
//
//  Created by Victoria Hawkins on 1/31/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import Foundation


class FileAnalyser:NSObject {
    
    let APACHE_FIELD_COUNT = 21 // field count for sample apache log
    
    
    //MARK: - create page sequences
    /* create list of three page sequences from array of pages for user. offset defines the number of pages to include in the sequence not including the current page
     default offset of 2 means that three pages are included in the sequence
     */
    func findPageSequencesForUser(_ pages: [String], offset: Int=2)->[String] {
        
        var pageSequences = [String]()
        for index in 0...pages.count {
            if index+offset>=pages.count {break}
            let tupleThree = pages[index...index+offset]
            //                        debugPrint("Tuple Found was \(tupleThree)")
            let pageSequence = tupleThree.joined(separator: ", ")
            pageSequences.append(pageSequence)
        }
        return pageSequences
    }
    
    
    //MARK: - group sequences
    /* group similar page sequences and produce a count
     */
    func groupRelatedSequences(_ pageSequences: [String])->[String:Int] {
        
        
        var combinedSequencesAndCounts = [String:Int]()
        
        for pageSequence in pageSequences {
            
            // if we find the page in dictionary, incrmenet count
            if let lastCount = combinedSequencesAndCounts[pageSequence] {
                combinedSequencesAndCounts[pageSequence] = lastCount+1
            } else {
                // assign one when first seen
                combinedSequencesAndCounts[pageSequence] = 1
            }
        }
        
        return combinedSequencesAndCounts
    }
    
    
    //MARK: - sort sequences and counts
    /* Sort sequences an counts in ascending order, largest count at the top */
    fileprivate func displaySortedMessagesForDebug(_ sortedSeqeuncesAndCounts: [(key: String, value: Int)]) {
        debugPrint("Sorted page sequences for Users are:")
        for (sequence, appearances) in sortedSeqeuncesAndCounts  {
            
            debugPrint(" \(sequence) : \(appearances)")
        }
    }
    
    func sortSequencesAscending(_ seqeuncesCounts: [String:Int])->[(String, Int)] {
        
        // return array sorted ascending order
        let sortedSeqeuncesAndCounts =  Array(seqeuncesCounts).sorted(by: {$0.1 > $1.1})
        
        
        // prevent from being called in release build
        debugPrint(displaySortedMessagesForDebug(sortedSeqeuncesAndCounts))
        
        return sortedSeqeuncesAndCounts
    }
    
    
    //MARK: - create ip to page visit data structure
    /*     create dictionary structure for IP address and list of pages visited
     [ 124.4.4.1 : [/page1, page2, page3],
     ...
     214.1.2.3 : [/page2, /page3, /page4]
     ]
     */
    func extractPageVisitsPerUser(_ documentURL: URL )-> [String:[String]]{
        
        var ipAndPagesVisited = [String:[String]]()
        
        debugPrint("docs URL to extractUsageData from was \(documentURL)")
        
        do {
            // read contents of file
            let contentString = try String(contentsOf: documentURL)
            // break contents on newline and add to array
            let lines: [String] = contentString.components(separatedBy: "\n")
            
            //            debugPrint ("Lines found were")
            var lineNumber=1;
            for line in lines {
                
                if (!line.isEmpty) {
                    //                    debugPrint("\(lineNumber) --- \(line)")
                    
                    let fields = line.split(separator: " ")
                    
                    
                    // expecting each line to return APACHE_FIELD_COUNT fields
//                    let count = fields.count
//                    guard count == APACHE_FIELD_COUNT else {
//
//                        debugPrint("Count of fields for line does not conform to expected: \(count) for line \(line)")
//
//                        return ipAndPagesVisited
//                    }
                    
                    let ipAddress = String(fields[0])
                    guard validIPAddress (ipAddress) else {
                        
                        debugPrint("Invalid IP address in first field: \(ipAddress)")

                        return ipAndPagesVisited

                    }
                    
                    let relativeURL = String(fields[6])
                    // at a minimum, match slash and a word
                    
                    let regex = try NSRegularExpression(pattern: "/(\\w)+")
                    
                    var matches =  [String]()
                    autoreleasepool { // solves the leak in NSRegularExpression

                        let results = regex.matches(in: relativeURL, range: NSRange(relativeURL.startIndex..., in: relativeURL))
                        
                        
                        
                        matches = results.map {
                            String(relativeURL[Range($0.range, in: relativeURL)!])
                        }
                        
                        //                    debugPrint ("matches are \(matches)")
         
                    }
                    
                    guard !matches.isEmpty else {
                        
                        debugPrint("Invalid url pattern match: \(relativeURL) ")
                        
                        return ipAndPagesVisited
                    }

                    
                    //                    debugPrint ("\(ipAddress) \(relativeURL)")
                    
                    
                    
                    if var pageList = ipAndPagesVisited[ipAddress]{
                        
                        pageList.append(relativeURL)
                        
                        ipAndPagesVisited[ipAddress] = pageList
                        
                        //                        debugPrint ("Appending \(ipAddress) \(relativeURL)")
                        
                        
                    } else {
                        var pageList = [String]()
                        pageList.append(relativeURL)
                        ipAndPagesVisited[ipAddress] = pageList
                        
                        //                        debugPrint ("Creating \(ipAddress) associated with \(relativeURL)")
                        
                        
                    }
                    
                    lineNumber = lineNumber+1
                }
            }
            
        } catch let err as NSError{
            print(err)
            
        }
        
        debugPrint("extractPageVisitsPerUser list of IP and total page visits:")
        for (ipAddress, pages) in ipAndPagesVisited {
            
            debugPrint("IP: \(ipAddress) PagesList: \(pages.count)")
            
        }
        
        
        return ipAndPagesVisited
    }
    
    
    //MARK: - compile sequences seen for all users
    
    /*  creates combined list of three page sequences found by traversing page visits lists
     */
    func createPageSequencesPerUserVisits( visitedPages: [String:[String]]) -> [String]{
        
        var combinedSequences = [String]()
        for (_, visits) in visitedPages {
            
            let threePageSequences = findPageSequencesForUser(visits)
            combinedSequences = combinedSequences + threePageSequences
        }
        
        return combinedSequences
    }
    
    
    func validIPAddress (_ ipAddress: String) ->Bool {
    
        var sin = sockaddr_in()

        if ipAddress.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            
            return true
        }
        
        
        return false
        

    }
}
