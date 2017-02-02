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
import FirebaseStorage
import GoogleSignIn




class EntryTableViewController: UITableViewController {
    
    
    //MARK: Properties
    var entries = [Entry]()
    var deleteEntryIndexPath: IndexPath? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSampleData()
        self.loadRemoteEntries()
        
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
        let originalFormatter = DateFormatter()
        originalFormatter.dateFormat = "yyyy-MM-dd"
        let date = originalFormatter.date(from: entries[indexPath.row].date)
        let newFormatter = DateFormatter()
        newFormatter.dateStyle = .medium
        
        cell.dateLabel.text = newFormatter.string(from: date!)
    
        let snippet = entries[indexPath.row].feelingToday as String
//        let index = snippet.index(snippet.startIndex, offsetBy: min(snippet.characters.count,25))
//        cell.snippetLabel.text = snippet.substring(to: index)
        cell.snippetLabel.text  = snippet
        cell.photoImageView.image = entries[indexPath.row].thumbnail
    
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteEntryIndexPath = indexPath
            confirmDelete()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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
        if (segue.identifier == "AddItem") {
            let navController = segue.destination as! UINavigationController
            let detailController = navController.topViewController as! EntryViewController
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let yesterdayString = formatter.string(from: yesterday!)
            
            let indexOfYesterday = entries.index(where: {$0.date == yesterdayString})
            if indexOfYesterday != nil {
                detailController.goalsFromPrevDay = entries[indexOfYesterday!].planTomorrow
            }
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

    
    
    @IBAction func didTapSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        dismiss(animated: true, completion: nil)
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
        
        let entryDict = ["feelingToday": entry.feelingToday, "planToday": entry.planToday, "affirmToday": entry.affirmToday, "achievedToday": entry.achievedToday, "reflectToday": entry.reflectToday, "planTomorrow": entry.planTomorrow, "date": entry.date]
        
        ref.child(uid!).child("entries").child(entry.uuid).setValue(["data": entryDict])
        if (entry.image != nil) {
            saveImage(uuid: entry.uuid, image: entry.image!, isThumbnail: false)
            saveImage(uuid: entry.uuid, image: entry.thumbnail!, isThumbnail: true)
        }

    }
    
    private func deleteEntryRemote(entry: Entry) {
        
        
        ref.child(uid!).child("entries").child(entry.uuid).removeValue()
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
                let date = dataDict?["date"] as! String
                let entry = Entry(feelingToday: feelingToday, planToday: planToday, affirmToday: affirmToday, achievedToday: achievedToday, reflectToday: reflectToday, planTomorrow: planTomorrow, date: date, image: nil, thumbnail: nil, uuid: uuid)
                self.loadThumbnail(entry: entry)
                self.entries.append(entry)
                         }
            self.entries.sort(by: { $0.date.compare($1.date) == .orderedDescending })
            self.tableView.reloadData()
                            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func saveImage (uuid:String, image: UIImage, isThumbnail: Bool) {
        let data = UIImageJPEGRepresentation(image, 1.0)
        var path: String
        
        if isThumbnail {
            path = uid + "/" + uuid + "_thumbnail.jpg"
        } else {
            path = uid + "/" + uuid + ".jpg"
        }
        
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

    private func deleteImage (entry: Entry) {
        let imagePath = uid + "/" + entry.uuid + "_thumbnail.jpg"
        let thumbnailPath = uid + "/" + entry.uuid + ".jpg"
        let imageRef = storageRef.child(imagePath)
        let thumbnailRef = storageRef.child(thumbnailPath)
        imageRef.delete(completion: { error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        })
        
        thumbnailRef.delete(completion: { error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        })
        
    }
    
    
    private func loadThumbnail (entry:Entry) {

        var path: String
        path = uid + "/" + entry.uuid + "_thumbnail.jpg"
        
        let imageRef = storageRef.child(path)
        imageRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                let image = UIImage(data: data!)
                entry.thumbnail = image
                
                let newIndex = self.entries.index(of: entry)
                let newIndexPath = IndexPath(row: newIndex!, section:0)
                self.tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    private func confirmDelete() {
        let alert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to permanently delete this entry?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteEntry)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteEntry)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.size.width / 2.0, y:self.view.bounds.size.height / 2.0, width:1.0, height:1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteEntry (alertAction: UIAlertAction!) {
        if let indexPath = deleteEntryIndexPath {
            let entry = entries[indexPath.row]
            tableView.beginUpdates()
            deleteEntryRemote(entry: entry)
            deleteImage(entry: entry)
            entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteEntryIndexPath = nil
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteEntry(alertAction: UIAlertAction!) {
        deleteEntryIndexPath = nil
    }

}

