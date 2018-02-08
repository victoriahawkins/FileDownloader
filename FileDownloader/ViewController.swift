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
    
    var client: FileDownloadClient?
    
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
        
        // reset progress bar and message
        resetProgress();
        
        // remove existing downloaded files in documents folder since we only want to keep
        // most recent downloaded
        removeExistingFiles();
        
        let url = URL(
            string: "https://dev.inspiringapps.com/Files/IAChallenge/30E02AAA-B947-4D4B-8FB6-9C57C43872A9/Apache.log")!
        
        
        let client = FileDownloadClient()// starts default session
        let task = client.downloadFileInBackground (with: url)
        task.resume()  /// TODO encapsulate
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
    
    /* remove existing files in Documents folder */
    func removeExistingFiles() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                debugPrint("Removing file found at \(file)")
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            debugPrint("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
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
