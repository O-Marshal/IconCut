//
//  ViewController.swift
//  IconCut
//
//  Created by 刘荣 on 16/4/7.
//  Copyright © 2016年 Mog. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MDragViewProtocl, NSTextFieldDelegate {
    
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var widthTextField: NSTextField!
    @IBOutlet var heightTextField: NSTextField!
    @IBOutlet var scaleA: NSButton!
    @IBOutlet var scaleB: NSButton!
    @IBOutlet var scaleC: NSButton!
    @IBOutlet var clearButton: NSButton!
    @IBOutlet var exportButton: NSButton!
    
    
    @IBOutlet var mog: NSButton!
    
    var width: CGFloat = 30
    var height: CGFloat = 30
    
    var datas: [MFModel] = []
    var fileStrings: [String] = []
    
    var timefile = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wrapView = MDragView(frame: view.frame)
        wrapView.addSubview(view)
        wrapView.registerForDraggedTypes([NSFilenamesPboardType])
        wrapView.delegate = self
        view = wrapView
        
        scaleA.enabled = false
        
        mog.attributedTitle = NSAttributedString(string: "Mog", attributes: [NSForegroundColorAttributeName: NSColor.blueColor()])
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return datas.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn?.identifier == "name" {
            return datas[row].name
        } else {
            return datas[row].path
        }
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        imageView.image = datas[row].image
        return true
    }

    @IBAction func clearEvent(sender: NSButton) {
        datas = []
        fileStrings = []
        tableView.reloadData()
    }
    @IBAction func exportEvent(sender: NSButton) {
        if let width = Int(widthTextField.stringValue) {
            self.width = CGFloat(width)
        } else { alert("Width 不能为空"); return }
        if let height = Int(heightTextField.stringValue) {
            self.height = CGFloat(height)
        } else { alert("Height 不能为空"); return }
//
        let s2 = scaleB.state == 1 ? true : false
        let s3 = scaleC.state == 1 ? true : false
        
        exportFiels(s2, s3: s3)
    
    }
    
    func exportFiels(s2: Bool,s3: Bool) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        timefile = dateFormatter.stringFromDate(NSDate())
        
        for item in datas {
            dealImage(item)
            if s2 { dealImage(item, type: 2) }
            if s3 { dealImage(item, type: 3) }
        }
    }
    
    func imageDataWithImage(image: NSImage, bitmapImageFileType: NSBitmapImageFileType) -> NSData{
        let rep = NSBitmapImageRep(data: image.TIFFRepresentation!)
        return (rep?.representationUsingType(bitmapImageFileType, properties: [:]))!
    }
    
    func dealImage(model: MFModel, type: Int = 1 ) {

        let imgType: NSBitmapImageFileType = model.ext == "png" ? .NSPNGFileType : .NSJPEGFileType
        
        let saveData = imageDataWithImage(resizeImage(model.image, scale: CGFloat(type)), bitmapImageFileType: imgType)
        let x = type == 1 ? "" : type == 2 ? "@2x" : "@3x"
        let path = "\(getPath(model.name))/\(model.name)@\(x).\(model.ext)"
        saveData.writeToFile(path, atomically: true)
    }
    
    func getPath(name: String) -> String{
        let desktop = NSString(string: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).stringByAppendingPathComponent("IconCut")
        let path = NSString(string: NSString(string: desktop).stringByAppendingPathComponent(timefile)).stringByAppendingPathComponent(name)
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            try! NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }
    
    func resizeImage(image: NSImage, scale: CGFloat) -> NSImage {
        let baseWidth: CGFloat = width
        let baseHeight: CGFloat = height
        let size = CGSize(width: baseWidth * scale, height: baseHeight * scale)
        let targetFrame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let targetImage = NSImage(size: size)
        let sourceSize = image.size
        
        let ratioH = size.height / sourceSize.height
        let ratioW = size.width / sourceSize.width
        
        var cropRect = NSZeroRect
        
        if (ratioH >= ratioW) {
            cropRect.size.width = floor (size.width / ratioH)
            cropRect.size.height = sourceSize.height
        } else {
            cropRect.size.width = sourceSize.width
            cropRect.size.height = floor(size.height / ratioW)
        }
        
        cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 )
        cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 )
        
        
        targetImage.lockFocus()
        image.drawInRect(targetFrame, fromRect: cropRect, operation: .CompositeCopy, fraction: 1)
        image.drawInRect(targetFrame, fromRect: cropRect, operation: .CompositeCopy, fraction: 1, respectFlipped: true, hints: [NSImageHintInterpolation: 2])

        targetImage.unlockFocus()
        
        return targetImage
    }
    
    
    func alert(msg: String) {
        let alert = NSAlert()
        alert.alertStyle = .WarningAlertStyle
        alert.messageText = "错误"
        alert.informativeText = msg
        alert.addButtonWithTitle("ok")
        alert.beginSheetModalForWindow(view.window!, completionHandler: nil)
    }
    
    func dragFiles(files: [String]) {
        
        var arr: [MFModel] = []
        for item in files {
            
            if fileStrings.indexOf(item) != nil { continue } else { fileStrings.append(item) }
            
            let model = MFModel(path: item)
            if model.exist && ( model.ext == "png" || model.ext == "jpg" ) {
                arr.append(model)
            }
        }
        datas += arr
        tableView.reloadData()
    }
    
    
    
    @IBAction func openMog(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://mog.name")!)
    }

}

