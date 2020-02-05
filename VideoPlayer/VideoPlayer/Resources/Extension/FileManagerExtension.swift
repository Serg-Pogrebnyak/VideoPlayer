//
//  FileManagerExtension.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

extension FileManager {    
    func getAllFilesWithExtension(directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true, fileExtension: String) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL,
                                                includingPropertiesForKeys: nil,
                                                options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        let filteredFiles = fileURLs?.filter{$0.lastPathComponent.contains(fileExtension)}
        
        return filteredFiles
    }
    
    func getURLS() -> URL {
        return urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!
    }
}
