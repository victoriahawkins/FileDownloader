//
//  FileDownloadClient.swift
//  FileDownloader
//
//  Created by Victoria Hawkins on 1/29/18.
//  Copyright © 2018 Victoria Hawkins. All rights reserved.
//

//import Foundation
import UIKit

//MARK: - FileDownloadClient -- Download a single file in background
/* this class provides a client to download a single file in the background, and a delegate for providing a value to update a progress view in the view controller
 */
final class FileDownloadClient : NSObject {
    
    //MARK: - Main session
    
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
    

    //MARK: - Progress bar delegate
    weak var delegate: DownloadProgressDelegate?

    
    //MARK: startSession - return lazy session
    func startSession() -> URLSession {
        return urlSession;
    }
    
}

//MARK: - URLSessionDelegate -- updates for session level events
extension FileDownloadClient: URLSessionDelegate {

    // When all events have been delivered, system calls this method. Fetch the completion handler stored by the app delegate and execute it.
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        // executing completion handler on main queue because this method may have been called from secondary queue
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let completionHandler = appDelegate.backgroundURLSessionCompletionHandler else {
                return
            }
//            appDelegate.backgroundURLSessionCompletionHandler = nil
        
                completionHandler()
            
        }
    }


}

//MARK: - URLSessionDownloadDelegate -- updates for the transfer status
extension FileDownloadClient: URLSessionDownloadDelegate {
    

    // periodic information to delegate about download progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
                if totalBytesExpectedToWrite > 0 {
                    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    debugPrint("Progress \(downloadTask) \(progress)")
                    delegate?.updateDownloadProgress(progress: progress)
                }
        
    }
    
    // download task has finished
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        // check for server error and abort
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                print ("server error")
                return
        }
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            let savedURL = documentsURL.appendingPathComponent(
                location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: savedURL)
            //        try? FileManager.default.removeItem(at: location)

            debugPrint("Download finished and saved to: \(savedURL)")
            
            delegate?.notifyFileURL(file: savedURL)


        } catch {
            print ("file error: \(error)")
        }
        
        
        // update progress to complete
        delegate?.updateDownloadProgress(progress: 1.0)
    }
}

//MARK: - DownloadProgressDelegate - Update download progress
protocol DownloadProgressDelegate: class {
    
    // return percentage for indicating progress made on download
    func updateDownloadProgress(progress: Float)
    
    // notify of final file url
    func notifyFileURL(file: URL)
}

//MARK:


