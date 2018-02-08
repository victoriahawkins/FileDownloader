#  FileDownloader
## Overview

A project in Swift 4 demonstrating how to download a file in the background, parse it and display the results in a tableview.  The parser expects file content conforming to an apache HTTP access log. The tableview displays the most common sequences of consecutive three page visits per IP address as well as a count observed.

For example, in the following symbolic log lines referring to an IP address and page hit:

IP 1: Page 1

IP 2: Page 1  
IP 2: Page 2  
IP 2: Page 3  
IP 2: Page 2  

IP 1: Page 2  
IP 1: Page 3  
IP 1: Page 4  
IP 1: Page 1  
IP 1: Page 2  

The most common three page sequence is 1-2-3 for each IP1 and IP2

## Classes
### FileDownloadClient
This class is a client for downloading a file in the background and follows the Apple guidelines outlined here:

https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background

First, a background session is created using URLSession and a downloadTask is created

```swift
// create a background URL session
private lazy var urlSession: URLSession = {

    let config = URLSessionConfiguration.background(withIdentifier: "MyBigFileSession")

    // time insensitive tasks allows continue if device plugged in or connected to wifi
    //        config.isDiscretionary = true

    // have system wake app if in background
    config.sessionSendsLaunchEvents = true

    // for potential asynchronous download operations (default nil creates a serial queue)
    weak var queue = OperationQueue()

    // this will create a new URLSession ore return the previously created one
    return URLSession(configuration: config, delegate: self, delegateQueue: queue)
}()
```
The view controlller starts the session and the download and sets itself as a delegate for asynchronous events
```swift
    let client = FileDownloadClient()// starts default session
    let task = client.downloadFileInBackground (with: url)
    task.resume()
    client.delegate = self;
```

The client notifies the view controller  of changes to the download progress and when a file has been saved in the Documents folder

```swift
protocol DownloadProgressDelegate: class {

    // return percentage for indicating progress made on download
    func updateDownloadProgress(progress: Float)

    // notify of final file url
    func notifyFileURL(file: URL)
}
```


### FileAnalyser
The Analyzer is the parser class.  After the file is downloaded, the view controller uses the Analyzer to load the file and parse it.  First a dictionary of IP and associated array of pages visited is constructed. Second the three page sequences are created from the page visit lists. Third, the three page sequences are totaled up. Last, a sorted array of page sequences to counts is created for display in the table view.

```Swift

// returns dictionary of IP->array of pages visited
let visitedPages = parser.extractPageVisitsPerUser(file)

// creates combined list of three page sequences found by traversing page visits lists
let combinedSequences = parser.createPageSequencesPerUserVisits(visitedPages: visitedPages)

// group similar page sequences and produce a count
let unsortedSequencesAndCounts = parser.groupRelatedSequences(combinedSequences)

// sort sequences ascending by their count seen
sortedSequencesAndCounts = parser.sortSequencesAscending(unsortedSequencesAndCounts)
```
### Results
This class is the UITableViewController that displays the sorted page sequence results.


## Tests
### SequenceTests
The majority of unit testing was to exercise the parsing code in SequenceTests.swift. Fake data as well as a sample slice of the apache test file were used. The tests to load a sample file, parse the file into arrays of pages visited, grouping and sorting are completely covered by this unit test class.

### FileDownloaderTests
The intention of these tests is to exercise FileDownloadClient networking code. The test will download a sample large file and exercise most of the client class. Tests were also added to simulate a URLSession and URLSessionDownloadTask using protocols, extensions and mock classes. The mocking code was added to FileDownloadClient.
