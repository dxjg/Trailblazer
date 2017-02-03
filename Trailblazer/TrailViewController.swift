//
//  TrailViewController.swift
//  Trailblazer
//
//  Created by David Gong on 1/30/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit
import os.log

class TrailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // MARK: Properties

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // A local variable for storing the actual date object.
    // MARK: !
    // Eventually replace trailDateLabel with trailDescriptionLabel to include both date and distance. Might need some sort of struct.
    var trailDate: Date?
    var dateFormatter = DateFormatter()
    @IBOutlet weak var trailDateLabel: UILabel!
    var distance: Double?
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var editDateButton: UIButton!
    @IBOutlet weak var editDistanceButton: UIButton!

    
    /*
    This value is either passed by `TrailTableViewController` in `prepare(for:sender:)`
    or constructed as part of adding a new meal.
    */
    var trail: Trail?
    
    static let descriptionPlaceholder = "Describe this desire line..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user inputs through delegate callbacks.
        nameTextField.delegate = self
        
        // Handle the text view's user inputs through delegate callbacks.
        descriptionTextView.delegate = self
        descriptionTextView.text = TrailViewController.descriptionPlaceholder
        descriptionTextView.textColor = UIColor.lightGray
        
        // Set up the date formatter.
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.autoupdatingCurrent
        
        // Set up views if editing an existing trail.
        if let trail = trail {
            navigationItem.title = trail.name
            nameTextField.text = trail.name
            photoImageView.image = trail.photo
            trailDate = trail.date
            
            // Format the label text based on whether or not the distance is set.
            if let distance = trail.distance {
                trailDateLabel.text = "\(dateFormatter.string(from: trail.date!)), \(String(format: "%.2f", distance)) miles"
            } else {
                trailDateLabel.text = dateFormatter.string(from: trail.date!)
            }
            
            distance = trail.distance
            descriptionTextView.text = trail.trailDescription
            descriptionTextView.textColor = trail.descriptionColor
        }
        
        // Set up keyboard-triggered scrolling adjustments
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        // Enable the Save button only if the text field has a valid value and there is a valid date
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button when editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user cancelled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Reset the text view properties for editing.
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Display the default placeholder if the text view is empty.
        if textView.text.isEmpty {
            textView.text = TrailViewController.descriptionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddTrailMode = presentingViewController is UINavigationController
        if isPresentingInAddTrailMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The TrailViewController is not inside a navigation controller.")
        }
    }
    
    // This method configures the view controller before it's presented to the table view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        if let button = sender as? UIBarButtonItem, button === saveButton {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let date = trailDate ?? Date()
            let distance = self.distance
            let trailDescription = descriptionTextView.text ?? TrailViewController.descriptionPlaceholder
            let descriptionColor = descriptionTextView.textColor ?? UIColor.lightGray
            
            trail = Trail(name: name, photo: photo, date: date, distance: distance, trailDescription: trailDescription, descriptionColor: descriptionColor)
        } else if let button = sender as? UIButton, button === editDateButton {
            // Do not need to do anything.
        } else if let button = sender as? UIButton, button === editDistanceButton {
            // Do not need to do anything.
        } else {
            fatalError("An unexpected segue was requested: \(segue.destination)")
        }
    }

    // MARK: Actions
    
    // Allow the user to pick a photo from their photo library and add it to the trail.
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        self.view.endEditing(false)
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Force the first responder to resign by tapping the outermost view.
    @IBAction func dismissKeyboardOnTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    // Set the proper date or distance properties in response to an unwind segue from either the DatePickerViewController or the DistanceViewController.
    // MARK: !
    // This is a mess of if-else statements; Need to reimplement this later.
    @IBAction func unwindToTrail(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DatePickerViewController, let date = sourceViewController.date {
            // Set the date according to the user's selection.
            trailDate = date
            
            // Format the label text depending on if a distance was recorded or not.
            if let distance = distance {
                trailDateLabel.text = "\(dateFormatter.string(from: date)), \(String(format: "%.2f", distance)) miles"
            } else {
                trailDateLabel.text = dateFormatter.string(from: date)
            }
            
            updateSaveButtonState()
        } else if let sourceViewController = sender.source as? DistanceViewController, let distance = sourceViewController.distance {
            if distance == 0 {
                // A distance of 0 means that the user does not want to record a distance for this trail.
                self.distance = nil
                
                // Format the label text depending on if a date was recorded yet or not.
                if let date = trailDate {
                    trailDateLabel.text = dateFormatter.string(from: date)
                } else {
                    trailDateLabel.text = ""
                }
            } else {
                // Set the distance according to the user's input only if the set distance was not 0.
                self.distance = distance
                
                // Format the label text depending on if a date was recorded yet or not.
                if let date = trailDate {
                    trailDateLabel.text = "\(dateFormatter.string(from: date)), \(String(format: "%.2f", distance)) miles"
                } else {
                    trailDateLabel.text = "\(String(format: "%.2f", distance)) miles"
                }
            }
        }
    }
    
    // MARK: Helper Methods
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        // Determining the keyboard's end frame view.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
        
        // Update the content view's bottom inset based on the presence of the keyboard's view.
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset.bottom = 0
        } else {
            scrollView.contentInset.bottom = keyboardViewEndFrame.height
        }
        
        // Update the scroll indicator insets in order to avoid overlapping.
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field or the date label are empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty && trailDate != nil
    }
    
}

