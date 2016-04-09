//
//  MFModel.swift
//  IconCut
//
//  Created by 刘荣 on 16/4/8.
//  Copyright © 2016年 Mog. All rights reserved.
//

import Cocoa

class MFModel {
    
    var path: String
    var name: String
    var ext: String
    var image: NSImage
    
    var exist = false
    
    init(path: String) {
        self.path = path
        let p = NSString(string: path)
        
        name = p.lastPathComponent
        let nsa = NSString(string: name)
        name = nsa.substringToIndex(nsa.rangeOfString(".").location)
        
        ext = p.pathExtension
        image = NSImage(contentsOfFile: path)!
        
        exist = NSFileManager.defaultManager().fileExistsAtPath(path)
    }
}
