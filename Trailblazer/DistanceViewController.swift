//
//  DistanceViewController.swift
//  Trailblazer
//
//  Created by David Gong on 2/2/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit

class DistanceViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    var distance: Double?
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable the Save button only if the text field has a valid value and there is a valid date
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button when editing.
        saveButton.isEnabled = false
    }

    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions

    // Delegate callbacks can't be used because the keyboard does not have a return key.
    @IBAction func dismissKeyboardOnTap(_ sender: UITapGestureRecognizer) {
        if let distance = Double(distanceTextField.text ?? "") {
            self.distance = distance
            distanceLabel.text = "\(String(format: "%.2f", distance)) miles"
        } else {
            self.distance = nil
            distanceLabel.text = "Distance (mi.)"
        }
        
        updateSaveButtonState()

        // Hide the keyboard.
        self.view.endEditing(false)
    }

    // MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Enable the save button if a valid (a double that is greater than or equal to 0) is entered.
        if let distance = Double(distanceTextField.text ?? "") {
            saveButton.isEnabled = distance >= 0
        } else {
            saveButton.isEnabled = false
        }
    }
}
