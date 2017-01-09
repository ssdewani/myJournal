//
//  EntryViewController.swift
//  MyJournal
//
//  Created by Salim Dewani on 12/24/16.
//  Copyright © 2016 Salim Dewani. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var feelingTodayLabel: UITextView!
    @IBOutlet weak var planTodayLabel: UITextView!
    @IBOutlet weak var affirmTodayLabel: UITextView!
    @IBOutlet weak var achievedTodayLabel: UITextView!
    @IBOutlet weak var reflectTodayLabel: UITextView!
    @IBOutlet weak var planTomorrowLabel: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var photoImageView: UIImageView!
    
  //  @IBOutlet weak var feelingTodayTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var feelingTodayTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var affirmTodayTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var planTodayTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reflectTodayTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var planTomorrowTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var achievedTodayTextViewHeight: NSLayoutConstraint!

    var entry: Entry?
    var uuid: String?
    
    let minTextViewHeight: CGFloat = 32
    let maxTextViewHeight: CGFloat = 192
    
    
 //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let button = sender as? UIBarButtonItem, button === saveButton {
            let feelingToday = feelingTodayLabel.text ?? ""
            let planToday = planTodayLabel.text ?? ""
            let affirmToday = affirmTodayLabel.text ?? ""
            let achievedToday = achievedTodayLabel.text ?? ""
            let reflectToday = reflectTodayLabel.text ?? ""
            let planTomorrow = planTomorrowLabel.text ?? ""
            let date = datePicker.date
            let image = photoImageView.image

            entry = Entry(feelingToday: feelingToday, planToday: planToday, affirmToday: affirmToday, achievedToday: achievedToday, reflectToday: reflectToday, planTomorrow: planTomorrow, date: date, image: image, uuid: uuid!)
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

    @IBAction func touchedImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        feelingTodayLabel.delegate = self
        planTodayLabel.delegate = self
        affirmTodayLabel.delegate = self
        achievedTodayLabel.delegate = self
        reflectTodayLabel.delegate = self
        planTomorrowLabel.delegate = self
        
        if let entry = entry {
            feelingTodayLabel.text = entry.feelingToday
            planTodayLabel.text = entry.planToday
            affirmTodayLabel.text = entry.affirmToday
            achievedTodayLabel.text = entry.achievedToday
            reflectTodayLabel.text = entry.reflectToday
            planTomorrowLabel.text = entry.planTomorrow
            datePicker.date = entry.date
            photoImageView.image = entry.image
            uuid = entry.uuid
        } else {
            datePicker.date = Date()
            uuid = UUID().uuidString
        }
        
        refreshTextViewHeight(textView: feelingTodayLabel, textViewHeightContraint: feelingTodayTextViewHeight)
        refreshTextViewHeight(textView: planTodayLabel, textViewHeightContraint: planTodayTextViewHeight)
        refreshTextViewHeight(textView: affirmTodayLabel, textViewHeightContraint: affirmTodayTextViewHeight)
        refreshTextViewHeight(textView: achievedTodayLabel, textViewHeightContraint: achievedTodayTextViewHeight)
        refreshTextViewHeight(textView: planTomorrowLabel, textViewHeightContraint: planTomorrowTextViewHeight)
        refreshTextViewHeight(textView: reflectTodayLabel, textViewHeightContraint: reflectTodayTextViewHeight)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextView Delegate
   
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case feelingTodayLabel:
            refreshTextViewHeight(textView: feelingTodayLabel, textViewHeightContraint: feelingTodayTextViewHeight)
        case planTodayLabel:
            refreshTextViewHeight(textView: planTodayLabel, textViewHeightContraint: planTodayTextViewHeight)
        case affirmTodayLabel:
            refreshTextViewHeight(textView: affirmTodayLabel, textViewHeightContraint: affirmTodayTextViewHeight)
        case achievedTodayLabel:
            refreshTextViewHeight(textView: achievedTodayLabel, textViewHeightContraint: achievedTodayTextViewHeight)
        case reflectTodayLabel:
            refreshTextViewHeight(textView: reflectTodayLabel, textViewHeightContraint: reflectTodayTextViewHeight)
        case planTomorrowLabel:
            refreshTextViewHeight(textView: planTomorrowLabel, textViewHeightContraint: planTomorrowTextViewHeight)
        default:
            print ("damn")
        }
     
    }

    //MARK: UIImagePicketControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private methods
    
    private func refreshTextViewHeight(textView: UITextView, textViewHeightContraint:NSLayoutConstraint) {
        var height = ceil(textView.contentSize.height)
        if (height < minTextViewHeight + 5) { // min cap, + 5 to avoid tiny height difference at min height
            height = minTextViewHeight
        }
        if (height > maxTextViewHeight) { // max cap
            height = maxTextViewHeight
        }
        
        if height != textViewHeightContraint.constant - 10 { // set when height changed
            textViewHeightContraint.constant = height + 10 // change the value of NSLayoutConstraint
            textView.setContentOffset(CGPoint.zero, animated: false) // scroll to top to avoid "wrong contentOffset" artefact when line count changes
        }
    }
    
    
}

