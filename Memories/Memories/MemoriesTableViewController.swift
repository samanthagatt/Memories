//
//  MemoriesTableViewController.swift
//  Memories
//
//  Created by Samantha Gatt on 8/1/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class MemoriesTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoryController.memories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath)

        let memory = memoryController.memories[indexPath.row]
        title = memory.title
        
        let image = UIImage(data: memory.imageData)
        // Basic style cells have an imageView so it's not nil right?
        cell.imageView?.image = image

        return cell
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memory = memoryController.memories[indexPath.row]
            memoryController.delete(memory: memory)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? MemoryDetailViewController else { return }
        destinationVC.memoryController = memoryController
        
        if segue.identifier == "ShowDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let memory = memoryController.memories[indexPath.row]
            destinationVC.memory = memory
        }
    }

    
    // MARK: - Properties
    
    let memoryController = MemoryController()
}
