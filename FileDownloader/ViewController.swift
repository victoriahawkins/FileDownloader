//
//  ViewController.swift
//  FileDownloader
//
//  Created by Victoria Hawkins on 1/29/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var downloadProgress: UIProgressView!
    
    @IBOutlet weak var downloadProgressText: UITextField!
    let client = FileDownloadClient()
    
    let parser = FileAnalyser()
    
    var downloadedFile:URL?
    
    var sortedSequencesAndCounts:[(String, Int)] = []
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetProgress();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    @IBAction func startDownload(_ sender: Any) {
        
        resetProgress();
        
        //        let url = URL(string: "https://scholar.princeton.edu/sites/default/files/oversize_pdf_test_0.pdf")!
        let url = URL(
            string: "https://dev.inspiringapps.com/Files/IAChallenge/30E02AAA-B947-4D4B-8FB6-9C57C43872A9/Apache.log")!
        
        let task = client.startSession().downloadTask(with: url)
        task.resume()
        client.delegate = self;
    }
    
    @IBAction func parseResults(_ sender: Any) {
        
        guard let file = downloadedFile else {
            debugPrint("Unable to retrieve the filename")
            return
        }
        
        
        
        // returns dictionary of IP->array of pages visited
        let visitedPages = parser.extractPageVisitsPerUser(file)
        
        updateParsingProgress(message: "Parsing started")

        
        // creates combined list of three page sequences found by traversing page visits lists

        let combinedSequences = parser.createPageSequencesPerUserVisits(visitedPages: visitedPages)
        
        // group similar page sequences and produce a count

        let unsortedSequencesAndCounts = parser.groupRelatedSequences(combinedSequences)
        
        // sort sequences ascending by their count seen
        sortedSequencesAndCounts = parser.sortSequencesAscending(unsortedSequencesAndCounts)
        
        updateParsingProgress(message:  "Parsing complete")
        
    }
    
    
    @IBAction func displayResults(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultsSegue" {
            
            if let destination = segue.destination as? Results {
                
                //                let resultsVC = destination.topViewController as! Results
                destination.pageResultsAndCounts = sortedSequencesAndCounts
            }
        }
    }
    
    func updateParsingProgress(message: String) {


            DispatchQueue.main.async{ () -> Void  in
                self.downloadProgressText.text = message
            }

    
    }
    
}



//MARK: ProgressDelegate -- functions for updating progress view, file name
extension ViewController: DownloadProgressDelegate {
    
    /* delegate method called once networking client completes the download and moves file into documents directory */
    func notifyFileURL(file: URL) {
        debugPrint("file downloaded and reported to viewcontroller is: \(file)")
        self.downloadedFile = file
    }
    
    
    /* delegate method called each time networking client receives updates to bytes received */
    func updateDownloadProgress(progress: Float) {
        debugPrint("Received Progress Update: \(progress)")
        
        DispatchQueue.main.async {
            
            self.downloadProgress.setProgress(progress, animated: true)
            
            self.downloadProgressText.text =  String(format: "%.1f%%", progress * 100)
        }
    }
    
    /* reset the progress view bar to beginning and text progress label to zero percent */
    func resetProgress() {
        self.downloadProgress.progress = 0;
        self.downloadProgressText.text =  String(format: "%.1f%%", 0)
    }
    


}

