//
//  FunctionListTableViewController.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 5/3/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit

@objc protocol FunctionStepSelectionDelegate: AnyObject {
    func didSelectFunction(functionStep: String)
}

class FunctionListTableViewController: UITableViewController {

    var functions: [String] = []
    weak var selectionDelegate: FunctionStepSelectionDelegate?
    
    init(functions: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.functions = functions
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem\
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        self.tableView.register(UINib(nibName: "FunctionListCell", bundle: bundle), forCellReuseIdentifier: "functionListCell")
        self.tableView.backgroundColor = .clear
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return functions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FunctionListCell = tableView.dequeueReusableCell(withIdentifier: "functionListCell", for: indexPath) as! FunctionListCell

        cell.title.text = functions[indexPath.row]
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionDelegate?.didSelectFunction(functionStep: functions[indexPath.row])
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
