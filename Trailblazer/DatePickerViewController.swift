//
//  DatePickerViewController.swift
//  Trailblazer
//
//  Created by David Gong on 2/1/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    //MARK: Properties
    
    var date: Date?
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
}
