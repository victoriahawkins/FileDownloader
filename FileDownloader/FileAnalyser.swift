//
//  FileAnalyser.swift
//  FileDownloader
//
//  Created by Victoria Hawkins on 1/31/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import Foundation


class FileAnalyser:NSObject {
    
    
    
    
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
    func sortSequencesAscending(_ seqeuncesCounts: [String:Int])->[(String, Int)] {
        
        // return array sorted ascending order
        let sortedSeqeuncesAndCounts =  Array(seqeuncesCounts).sorted(by: {$0.1 > $1.1})
        
        
        debugPrint("Sorted page sequences for Users are:")
        for (sequence, appearances) in sortedSeqeuncesAndCounts  {
            
            debugPrint(" \(sequence) : \(appearances)")
        }
        
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
                    let ipAddress = String(fields[0])
                    let relativeURL = String(fields[6])
                    
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
    
    
}
