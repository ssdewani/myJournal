//
//  EntryViewController.swift
//  MyJournal
//
//  Created by Salim Dewani on 12/24/16.
//  Copyright © 2016 Salim Dewani. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var feelingTodayLabel: UITextView!
    @IBOutlet weak var planTodayLabel: UITextView!
    @IBOutlet weak var achievedTodayLabel: UITextView!
    @IBOutlet weak var planTomorrowLabel: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var entry: Entry?
    
    
 //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let button = sender as? UIBarButtonItem, button === saveButton {
            let feelingToday = feelingTodayLabel.text ?? ""
            let planToday = planTodayLabel.text ?? ""
            let achievedToday = achievedTodayLabel.text ?? ""
            let planTomorrow = planTomorrowLabel.text ?? ""
            let date = datePicker.date
        
            entry = Entry(feelingToday: feelingToday, planToday: planToday, achievedToday: achievedToday, planTomorrow: planTomorrow, date: date)
        }
        
        
    }
 
    
    //MARK: Actions
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The ViewController is not inside a navigation controller.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let entry = entry {
            feelingTodayLabel.text = entry.feelingToday
            planTodayLabel.text = entry.planToday
            achievedTodayLabel.text = entry.achievedToday
            planTomorrowLabel.text = entry.planTomorrow
            datePicker.date = entry.date
        } else {
            datePicker.date = Date()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

