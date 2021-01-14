//
//  FileManagerExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

extension FileManager {
    
    var tempDirectory: URL {
        FileManager.default.temporaryDirectory
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
    
    func replaceItemInTempFolder(from srcURL: URL, fileName: String) -> Bool {
        do {
            let dstURL = tempDirectory.appendingPathComponent(fileName)
            try copyItem(at: srcURL, to: dstURL)
            try removeItem(at: srcURL)
            return true
        } catch let error as NSError {
            if error.code == NSFileWriteFileExistsError {
                fatalError(error.description)
            }
            return false
        }
    }
    
    func removeFileFromTemp(withName name: String) -> Bool {
        do {
            let url = FileManager.default.tempDirectory.appendingPathComponent(name, isDirectory: false)
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            fatalError(error.description)
            return false
        }
    }
    
    func hasLocalFile(fileName: String) -> Bool {
        let fileUrl = tempDirectory.appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: fileUrl)
    }
    
    func convertToFile(data: Data, filename: String) {
        do {
            let filePathAndName = FileManager.default.tempDirectory.appendingPathComponent(filename)
            try data.write(to: filePathAndName)
        } catch let error as NSError {
            fatalError("Can't convert data to file")
        }
        //TODO: return result of converting
    }
    
    func removeAllFromTempDirectory() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: tempDirectory,
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
