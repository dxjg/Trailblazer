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
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
