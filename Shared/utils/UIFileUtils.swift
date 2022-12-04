//
//  UIFileUtils.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 22.08.2022.
//

import Foundation

let THUMB_PATH = "/thumbs/"
let AUDIO_PATH = "/audios/"

class UIFileUtils
{
    static func getAnyDirectory(path: String) -> URL?
    {
        do
        {
            let manager = FileManager.default
            
            let dir = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let component = dir.appendingPathComponent(path, isDirectory: true)
            
            if !manager.fileExists(atPath: component.path) {
                try manager.createDirectory(atPath: component.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            return component
        } catch {
            print("getThumbDirectory: failed")
        }
        
        return nil
    }
    
    static func getAnyFileUri(path: String, fileName: String) -> URL?
    {
        return self.getAnyDirectory(path: path)?.appendingPathComponent(fileName)
    }
    
    static func existFile(fileUrl: URL) -> Bool
    {
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    static func createFile(path: String, data: Data)
    {
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    static func removeFile(fileUrl: URL) {
        do
        {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            print("removeFile: failed")
        }
    }
}
