//
//  ViewController.swift
//  Trailblazer
//
//  Created by David Gong on 1/30/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    //MARK: Properties

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var trailDateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    static let descriptionPlaceholder = "Describe this desire line..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user inputs through delegate callbacks.
        nameTextField.delegate = self
        
        // Handle the text view's user inputs through delegate callbacks.
        descriptionTextView.delegate = self
        descriptionTextView.text = ViewController.descriptionPlaceholder
        descriptionTextView.textColor = UIColor.lightGray
        
        // Set up keyboard-triggered scrolling adjustments
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        trailNameLabel.text = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    
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
    
    //MARK: UITextViewDelegate
    
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
            textView.text = ViewController.descriptionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }

    //MARK: Actions
    
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
  
    // Set the date to the current date.
    @IBAction func setDefaultDateLabelText(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let date = Date()
        
        // Set the format to the current locale based on the user's preferences.
        dateFormatter.locale = Locale.autoupdatingCurrent
        trailDateLabel.text = dateFormatter.string(from: date)
    }
    
    // Force the first responder to resign by tapping the outermost view.
    @IBAction func dismissKeyboardOnTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    //MARK: Private Methods
    
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
    
}

