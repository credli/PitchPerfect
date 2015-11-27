//
//  ListSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nicholas Credli on 11/26/15.
//  Copyright © 2015 Novium Collective SARL. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol ListSoundsViewControllerDelegate {
    func listSoundViewController(listSoundsViewController: ListSoundsViewController, didSelectSoundFile soundFilePath: NSURL)
}

class ListSoundsViewController: UITableViewController {
    var files: [NSURL]!
    var delegate: ListSoundsViewControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        files = getDirectoryContents()
        self.tableView.reloadData()
    }
    
    func getDirectoryContents() -> [NSURL]? {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let dirURL = NSURL(fileURLWithPath: dirPath, isDirectory: true)
        let properties = [NSURLLocalizedNameKey, NSURLCreationDateKey, NSURLContentModificationDateKey, NSURLLocalizedTypeDescriptionKey]
        var urls = [NSURL]()
        
        //taken form http://stackoverflow.com/questions/33032293/swift-2-ios-get-file-list-sorted-by-creation-date-more-concise-solution
        if let urlArray = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(dirURL, includingPropertiesForKeys: properties, options: .SkipsHiddenFiles) {
            var attributedDictionary: [String:AnyObject]?
            var dateLastModified: NSDate
            var urlDictionary = [NSURL: NSDate]()
            
            for url in urlArray {
                attributedDictionary = try? url.resourceValuesForKeys(properties)
                dateLastModified = attributedDictionary?[NSURLContentModificationDateKey] as! NSDate
                urlDictionary[url] = dateLastModified
            }
            urls = urlDictionary.filter { $0 != nil }.sort { $0.1.compare($1.1) == NSComparisonResult.OrderedDescending }.map { $0.0 }
        }
        return urls
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("fileCell", forIndexPath: indexPath)
        cell.textLabel?.text = files[indexPath.row].lastPathComponent!
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) { [unowned self] in
            if let d = self.delegate {
                d.listSoundViewController(self, didSelectSoundFile: self.files[indexPath.row])
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(files[indexPath.row])
                tableView.beginUpdates()
                files.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                tableView.endUpdates()
                print("file deleted")
            } catch {
                print("Could not delete file \(files[indexPath.row])")
            }
            
        }
    }
}

extension ListSoundsViewController : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        files = [NSURL]()
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "History's empty, go record something first!"
        let attribtues = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attribtues)
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return (files.count == 0)
    }
}