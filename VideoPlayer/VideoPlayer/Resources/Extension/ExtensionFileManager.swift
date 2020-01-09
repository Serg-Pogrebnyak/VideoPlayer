//
//  ExtensionFileManager.swift
//  VideoPlayer
//
//  Created by Sergey Pohrebnuak on 09.01.2020.
//  Copyright © 2020 Sergey Pohrebnuak. All rights reserved.
//

import Foundation

extension FileManager {    
    func getAFilesWithExtension(directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true, fileExtension: String) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL,
                                                includingPropertiesForKeys: nil,
                                                options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        let filteredFiles = fileURLs?.filter{$0.lastPathComponent.contains(fileExtension)}
        
        return filteredFiles
    }
}
