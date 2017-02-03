//
//  TrailTableViewController.swift
//  Trailblazer
//
//  Created by David Gong on 1/31/17.
//  Copyright © 2017 David Gong. All rights reserved.
//

import UIKit
import os.log
import HealthKit

class TrailTableViewController: UITableViewController {

    // MARK: Properties
    
    var trails = [Trail]()
    let healthKitManager: HealthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        // Load any saved trails, otherwise load sample data
        if let savedTrails = loadTrails() {
            trails += savedTrails
        } else {
            // Load the sample data.
            loadSamples()
        }

        // Get permission to access HealthKit data.
        getHealthKitPermission()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table View Data Sources

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trails.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TrailTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TrailTableViewCell else {
            fatalError("The dequeued cell is not an instance of TrailTableViewCell.")
        }
        
        // Fetches the appropriate trail for the data source layout.
        let trail = trails[indexPath.row]
        
        cell.nameLabel.text = trail.name
        cell.photoImageView.image = trail.photo
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        // Set the format to the current locale based on the user's preferences.
        dateFormatter.locale = Locale.autoupdatingCurrent
        cell.dateLabel.text = dateFormatter.string(for: trail.date)

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the data sample from the HealthKit store if present.
            if healthKitManager.isAuthorized(), let healthKitSample = trails[indexPath.row].healthKitSample {
                healthKitManager.deleteDistance(sample: healthKitSample)
                os_log("Deleted the data from the HealthKit store.", log: OSLog.default, type: .debug)
            }
            
            // Delete the row from the data source
            trails.remove(at: indexPath.row)
            saveTrails()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: Navigation

    // Prepare the trail view based on the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        // Preparing to add an item.
        case "AddItem":
            os_log("Adding a new trail.", log: OSLog.default, type: .debug)
            
        // Preparing to editing an existing view.
        case "ShowDetail":
            guard let trailViewController = segue.destination as? TrailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTrailCell = sender as? TrailTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTrailCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // Populate the view with the given trail data.
            let selectedTrail = trails[indexPath.row]
            trailViewController.trail = selectedTrail
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
    // MARK: Actions
    
    // Respond to unwind segues from TrailViewController.
    @IBAction func unwindToTrailList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TrailViewController, let trail = sourceViewController.trail {
            // If the TrailViewController was pushed, then update the table view and HealthKit data, otherwise add new data.
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if healthKitManager.isAuthorized() {
                    // If there was existing data for this trail, delete it.
                    if let existingSample = trails[selectedIndexPath.row].healthKitSample {
                        healthKitManager.deleteDistance(sample: existingSample)
                    }
                    
                    // Add the new data
                    if let distance = trail.distance {
                        trail.healthKitSample = healthKitManager.saveDistance(distance: distance, date: trail.date!)
                    }
                    
                    os_log("Updated the HealthKit data.", log: OSLog.default, type: .debug)
                }
                
                // Update an existing trail.
                trails[selectedIndexPath.row] = trail
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add the new trail data to HealthKit only if the new trail has a recorded distance.
                if healthKitManager.isAuthorized(), let distance = trail.distance {
                    trail.healthKitSample = healthKitManager.saveDistance(distance: distance, date: trail.date!)
                }
                
                // Add a new trail.
                let newIndexPath = IndexPath(row: trails.count, section: 0)
                
                trails.append(trail)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                os_log("Successfully added a new trail.", log: OSLog.default, type: .debug)x
            }
            
            // Save the trails.
            saveTrails()
        }
    }

    // MARK: Private Methods
    
    // Generate three example trails. Note that these trails are just examples and are not reflected in the Health app.
    private func loadSamples() {
        let photo1 = UIImage(named: "trail1")
        let photo2 = UIImage(named: "trail2")
        let photo3 = UIImage(named: "trail3")
        
        guard let trail1 = Trail(name: "Brisk Run In Iceland", photo: photo1, date: Date() - 100000, distance: 10.4, trailDescription: "It was a pretty cold run.", descriptionColor: UIColor.black) else {
            fatalError("Unable to instantiate trail1")
        }
        
        guard let trail2 = Trail(name: "Through The Seashore", photo: photo2, date: Date(), distance: 6.3, trailDescription: "A sunny day; an invigorating workout!", descriptionColor: UIColor.black) else {
            fatalError("Unable to instantiate trail2")
        }
        
        guard let trail3 = Trail(name: "Just Another Run", photo: photo3, date: Date() + 50000, distance: 5.0,trailDescription: "I saw some great plants today", descriptionColor: UIColor.black) else {
            fatalError("Unable to instantiate trail2")
        }
        
        trails += [trail1, trail2, trail3]
    }
    
    // Save the current trails in that exist in the trail list.
    private func saveTrails() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(trails, toFile: Trail.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Trails successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save trails.", log: OSLog.default, type: .error)
        }
    }
    
    // Load the trails from the archive.
    private func loadTrails() -> [Trail]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Trail.ArchiveURL.path) as? [Trail]
    }
    
    // Get permission to share distance data with the HealthKit store.
    private func getHealthKitPermission() {
        // Seek permission through the HealthKitManager class.
        healthKitManager.authorizeHealthKit {
            (authorized, error) -> Void in
            if !authorized {
                if error != nil {
                    fatalError("An error occurred attempting to grant permissions.")
                }
                os_log("Permission denied.", log: OSLog.default, type: .debug)
            }
        }
    }
}
