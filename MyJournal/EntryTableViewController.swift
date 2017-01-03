//
//  EntryTableViewController.swift
//  MyJournal
//
//  Created by Salim Dewani on 12/24/16.
//  Copyright © 2016 Salim Dewani. All rights reserved.
//

import UIKit
import os.log


class EntryTableViewController: UITableViewController {
    
    
    //MARK: Properties
    var entries = [Entry]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleData()
        if let savedEntries = loadEntries() {
            entries += savedEntries
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return entries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTableViewCell", for: indexPath) as! EntryTableViewCell
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        cell.dateLabel.text =  formatter.string(from: entries[indexPath.row].date)
        let snippet = entries[indexPath.row].feelingToday as String
        let index = snippet.index(snippet.startIndex, offsetBy: min(snippet.characters.count,25))
        
        cell.snippetLabel.text = snippet.substring(to: index)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let selectedEntryViewController = segue.destination as! EntryViewController
            let selectedCell = sender as! EntryTableViewCell
            let indexPath = tableView.indexPath(for: selectedCell)
            selectedEntryViewController.entry = entries[indexPath!.row]
        }
        
    }
    
    @IBAction func unwindToEntryList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EntryViewController, let entry = sourceViewController.entry {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                entries[selectedIndexPath.row] = entry
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: entries.count, section: 0)
                entries.append(entry)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
            }
        }
        saveEntries()
    }


/*
    private func loadSampleData() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let a = Entry(feelingToday: "AA", planToday: "bb", achievedToday: "xx", planTomorrow: "yy", date: formatter.date(from: "2016/12/22")!)
        let b = Entry(feelingToday: "AA", planToday: "bb", achievedToday: "xx", planTomorrow: "yy", date: formatter.date(from: "2016/12/20")!)
        let c = Entry(feelingToday: "AA", planToday: "bb", achievedToday: "xx", planTomorrow: "yy", date: formatter.date(from: "2016/12/21")!)
        entries += [a,b,c]
        
    }
  */
    
    
    private func saveEntries() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(entries, toFile: Entry.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Entries successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save entries...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadEntries() -> [Entry]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Entry.ArchiveURL.path) as? [Entry]
    }
    
}
