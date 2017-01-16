//
//  EntryTableViewController.swift
//  MyJournal
//
//  Created by Salim Dewani on 12/24/16.
//  Copyright © 2016 Salim Dewani. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseAuth
import FirebaseStorage


class EntryTableViewController: UITableViewController {
    
    
    //MARK: Properties
    var entries = [Entry]()
    var ref: FIRDatabaseReference!
    var uid: String!
    var storage: FIRStorage!
    var storageRef: FIRStorageReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleData()
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            self.uid =  user!.uid
            self.ref = FIRDatabase.database().reference()
            self.loadRemoteEntries()
            self.storage = FIRStorage.storage()
            self.storageRef = self.storage.reference(forURL: "gs://myjournal-d55cc.appspot.com")
        }
        
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
//        let index = snippet.index(snippet.startIndex, offsetBy: min(snippet.characters.count,25))
//        cell.snippetLabel.text = snippet.substring(to: index)
        cell.snippetLabel.text  = snippet
        cell.photoImageView.image = entries[indexPath.row].image
    
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
                entries.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                tableView.reloadData()
                saveEntryRemote(entry: entry)
            } else {
                entries.append(entry)
                entries.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                tableView.reloadData()
                saveEntryRemote(entry: entry)            }
        }
//        saveEntries()
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
    
    
    private func saveEntryRemote(entry: Entry) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateText =  formatter.string(from: entry.date)
        
        let entryDict = ["feelingToday": entry.feelingToday, "planToday": entry.planToday, "affirmToday": entry.affirmToday, "achievedToday": entry.achievedToday, "reflectToday": entry.reflectToday, "planTomorrow": entry.planTomorrow, "date": dateText]
        
        self.ref.child(uid!).child("entries").child(entry.uuid).setValue(["data": entryDict])
        if (entry.image != nil) {
            saveImage(uuid: entry.uuid, image: entry.image!)
        }

    }
    
    private func loadRemoteEntries() {
        ref.child(uid!).child("entries").observeSingleEvent(of: .value, with: { (snapshot) in

            for item in snapshot.children {
                let child = item  as! FIRDataSnapshot
                let childSnapshot = child.childSnapshot(forPath: "data")
                
                let dataDict = childSnapshot.value as? NSDictionary
                let uuid =  child.key
                let feelingToday = dataDict?["feelingToday"] as! String
                let planToday = dataDict?["planToday"] as! String
                let affirmToday = dataDict?["affirmToday"] as! String
                let achievedToday = dataDict?["achievedToday"] as! String
                let reflectToday = dataDict?["reflectToday"] as! String
                let planTomorrow = dataDict?["planTomorrow"] as! String
                let dateString = dataDict?["date"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let date = dateFormatter.date(from: dateString)
                let entry = Entry(feelingToday: feelingToday, planToday: planToday, affirmToday: affirmToday, achievedToday: achievedToday, reflectToday: reflectToday, planTomorrow: planTomorrow, date: date!, image: nil, uuid: uuid)
                self.loadImage(entry: entry)
                self.entries.append(entry)
                         }
            self.tableView.reloadData()
                            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func saveImage (uuid:String, image: UIImage) {
        let data = UIImageJPEGRepresentation(image, 1.0)
        let path = uid + "/" + uuid + ".jpg"
        let imageRef = storageRef.child(path)
        let uploadTask = imageRef.put(data!, metadata: nil) { (metadata,error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            let downloadURL = metadata.downloadURL
            print(downloadURL)
        }
    }

    
    private func loadImage (entry:Entry) {
        let path = uid + "/" + entry.uuid + ".jpg"
        let imageRef = storageRef.child(path)
        imageRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                let image = UIImage(data: data!)
                entry.image = image
                let newIndex = self.entries.index(of: entry)
                let newIndexPath = IndexPath(row: newIndex!, section:0)
                self.tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
        }    }

}

