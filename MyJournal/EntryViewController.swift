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
    
  
    var entry: Entry?
    var uuid: String?
    var goalsFromPrevDay: String?
    
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var image: UIImage?
            var thumbnail: UIImage?
            
            let date = formatter.string(from: datePicker.date)
            if photoImageView.image != #imageLiteral(resourceName: "defaultPhoto") {
                image = photoImageView.image
                thumbnail = resizeImage(image: image!, newWidth: 80)
            }

            entry = Entry(feelingToday: feelingToday, planToday: planToday, affirmToday: affirmToday, achievedToday: achievedToday, reflectToday: reflectToday, planTomorrow: planTomorrow, date: date, image: image, thumbnail: thumbnail, uuid: uuid!)
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            datePicker.date = formatter.date(from: entry.date)!
            
            if entry.image != nil {
                photoImageView.image = entry.image
            } else {
                loadImage(entry: entry)
            }
            uuid = entry.uuid
        } else {
            datePicker.date = Date()
            uuid = UUID().uuidString
            if goalsFromPrevDay != nil {
                planTodayLabel.text = goalsFromPrevDay
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextView Delegate
   

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "<Enter Text>" {
            if textView != affirmTodayLabel {
                textView.text = " \u{2022} "
            } else {
                textView.text = ""
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        if (textView.text.characters.count + text.characters.count - range.length > 500) {
            
            return false
            
        } else if (text == "\n") && (textView != affirmTodayLabel)  {
            
            if range.location == textView.text.characters.count {
                let updatedText: String = textView.text! + "\n \u{2022} "
                textView.text = updatedText
            }
            else {
                let textRange: UITextRange = textView.selectedTextRange!
                textView.replace(textRange, withText: "\n \u{2022} ")

                let cursor: NSRange = NSMakeRange(range.location + "\n \u{2022} ".characters.count, 0)
                textView.selectedRange = cursor
            }
            
            return false

        } else if (text == " ") && textView.text.characters.count >= 4 {
        
            let workingSet = CharacterSet.whitespacesAndNewlines
            let fullRange = rangeWithString(string: textView.text, range: NSMakeRange(0,range.location-1))
            let spaceRange = textView.text.rangeOfCharacter(from: workingSet, options: .backwards, range: fullRange)
            if spaceRange != nil {
                
                let lastWordRange = spaceRange!.upperBound..<textView.text.index(textView.text.startIndex, offsetBy: range.location+range.length)
                
                let bulletStartIndex = textView.text.index(lastWordRange.lowerBound, offsetBy: -3, limitedBy: textView.text.startIndex)
                
                if bulletStartIndex != nil {
                    
                    let bulletRange = bulletStartIndex! ..< lastWordRange.lowerBound
                    
                    if textView.text[bulletRange] == " \u{2022} " {
                        
                        let capitalizedLastWord = textView.text[lastWordRange].capitalized
                        print (capitalizedLastWord)
                        textView.text.replaceSubrange(lastWordRange, with: capitalizedLastWord)
                        
                    }
                    
                }
            }
            
            
        }
        return true
    }
    

    
    private func rangeWithString(string : String, range : NSRange) -> Range<String.Index> {
        return string.index(string.startIndex, offsetBy: range.location)..<string.index(string.startIndex, offsetBy: range.location+range.length)
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
        if selectedImage.size.width > 700 {
            photoImageView.image = resizeImage(image: selectedImage, newWidth: 700)
        } else {
            photoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private methods
    

    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    private func loadImage (entry:Entry) {
        
        var path: String
        path = uid + "/" + entry.uuid + ".jpg"
        
        let imageRef = storageRef.child(path)
        imageRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                let image = UIImage(data: data!)
                entry.image = image
                self.photoImageView.image = image
                
            }
        }
    }
}

