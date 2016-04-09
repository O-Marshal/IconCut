//
//  MDragView.swift
//  IconCut
//
//  Created by 刘荣 on 16/4/7.
//  Copyright © 2016年 Mog. All rights reserved.
//

import Cocoa

protocol MDragViewProtocl {
    func dragFiles(files: [String])
}

class MDragView: NSView {
    
    var delegate: MDragViewProtocl?
    
    var isDragIn = false
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        layer?.backgroundColor = NSColor.whiteColor().CGColor
        if isDragIn {
            NSColor.whiteColor().setFill()
        } else {
            NSColor.windowBackgroundColor().setFill()
        }
        NSRectFill(dirtyRect)
    }
    
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if (sender.draggingPasteboard().types?.contains(NSFilenamesPboardType))! {
            isDragIn = true
            return NSDragOperation.Copy
        } else {
            isDragIn = false
            return NSDragOperation.None
        }
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        isDragIn = false
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        isDragIn = false
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        isDragIn = false
        needsDisplay = true
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let pasteboard = sender.draggingPasteboard()
        let fileArr = pasteboard.propertyListForType(NSFilenamesPboardType) as! [String]
        delegate?.dragFiles(fileArr)
        isDragIn = false
        return true
    }
    
    
    
}
