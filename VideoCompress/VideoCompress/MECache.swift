//
//  MECache.swift
//  VideoCompress
//
//  Created by 马伟 on 2017/6/6.
//  Copyright © 2017年 facaishu. All rights reserved.
//

import UIKit

class MECache: NSObject {

    
//MARK:------ 计算缓存 ------
    /// 计算缓存大小
    ///
    /// - Parameter path: <#path description#>
    /// - Returns: <#return value description#>
    static func cacheSize(path: String) -> String {
    
        return String(String(format: "%.2fMB", folderSize(folderPath: path)))
    }
    
    

    /// 计算文件夹的大小
    ///
    /// - Parameter folderPath: <#folderPath description#>
    /// - Returns: <#return value description#>
    static func folderSize(folderPath : String) -> Double {
    
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: folderPath) {
            return 0.0
        }
        
        
        var folderSize = 0.0

        var isDir = ObjCBool(false)
        // 直接传入文件路径的情况下
        if manager.fileExists(atPath: folderPath, isDirectory: &isDir) {
            
            folderSize += fileSize(filePath: folderPath)
        }
        
        
        let subPaths = manager.subpaths(atPath: folderPath)
        for filePath in subPaths! {
            
            let fileAbsolutePath = folderPath + "/" + filePath
            
            folderSize += fileSize(filePath: fileAbsolutePath)
        }
        
        return folderSize / 1024 / 1024
    }
    
    
    /// 计算单个文件的大小
    ///
    /// - Parameter filePath: <#filePath description#>
    /// - Returns: <#return value description#>
    static func fileSize(filePath : String) -> Double {
    
        let manager = FileManager.default
        if !manager.fileExists(atPath: filePath) {
            return 0.0
        }
        
        guard let attri = try? manager.attributesOfItem(atPath: filePath) else { return 0.0 }
        
        let fileSize = attri[FileAttributeKey.init(rawValue: "NSFileSize")] as! Double
        
        return fileSize
    }
    
    
    
//MARK:------ 清除缓存 ------
    
    static func cleanCache(path : String) {
    
        deleteFolder(folderPath: path)
    }
    
    
    static func deleteFolder(folderPath : String) {
    
        let manager = FileManager.default
        if !manager.fileExists(atPath: folderPath) {
            return
        }
        
        guard let subPaths = manager.subpaths(atPath: folderPath) else { return }
        
        for subPath in subPaths {
            
            let subAbsolutePath = folderPath + "/" + subPath
            deleteFile(filePath: subAbsolutePath)
        }
    }
    
    static func deleteFile(filePath : String) {
    
        let manager = FileManager.default
        
        try? manager.removeItem(atPath: filePath)
    }
    
    
    
}
