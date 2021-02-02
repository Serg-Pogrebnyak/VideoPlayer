//
//  FileManagerExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

extension FileManager {
    
    var applicationSupportDirectory: URL {
        let documentDirectory = FileManager.SearchPathDirectory.applicationSupportDirectory
        guard let documentsURL = urls(for: documentDirectory, in: .userDomainMask).first else {
            //TODO: handle this fatal error
            fatalError("Can't create document directory")
        }
        return documentsURL
    }
    
    func getFilesFromDocumentDirectory(withFileExtension fileExtension: String) -> [URL] {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        guard let documentsURL = urls(for: documentDirectory, in: .userDomainMask).first else {
            fatalError("document not found")
            //return [URL]()
        }
        
        guard let fileURLs = try? contentsOfDirectory(at: documentsURL,
                                                      includingPropertiesForKeys: nil,
                                                      options: .skipsHiddenFiles)
        else {
            fatalError("document not found")
            //return [URL]()
        }
        
        return fileURLs.filter{$0.lastPathComponent.contains(fileExtension)}
    }
    
    func replaceItemInApplicationSupportFolder(from srcURL: URL, fileName: String) -> Bool {
        do {
            let dstURL = applicationSupportDirectory.appendingPathComponent(fileName)
            try copyItem(at: srcURL, to: dstURL)
            try removeItem(at: srcURL)
            return true
        } catch let error as NSError {
            print(error.description)
            return false
        }
    }
    
    func removeFileFromApplicationSupportDirectory(withName name: String) -> Bool {
        do {
            let url = FileManager.default.applicationSupportDirectory.appendingPathComponent(name, isDirectory: false)
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            fatalError(error.description)
            return false
        }
    }
    
    func hasLocalFile(fileName: String) -> Bool {
        let fileUrl = applicationSupportDirectory.appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: fileUrl)
    }
    
    func convertToFile(data: Data, filename: String) {
        do {
            let filePathAndName = FileManager.default.applicationSupportDirectory.appendingPathComponent(filename)
            try data.write(to: filePathAndName)
        } catch let error as NSError {
            fatalError("Can't convert data to file")
        }
        //TODO: return result of converting
    }
    
    func removeAllFromApplicationSupportDirectory() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: applicationSupportDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp3" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  let error as NSError {
            fatalError(error.description)
        }
    }
    
}
