//
//  MemoryDetailViewController.swift
//  Memories
//
//  Created by Samantha Gatt on 8/1/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import Photos

class MemoryDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }

    
    func updateViews() {
        guard let thisMemory = memory else { title = "Add new memory"; return }
        title = "Edit memory"
        titleTextField.text = thisMemory.title
        bodyTextView.text = thisMemory.body
        imageView.image = UIImage(data: thisMemory.imageData)
    }
    
    // MARK: - Functions
    
    func presentImagePickerController() {
        let imagePickerAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        if imagePickerAvailable == true {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    // Going to close the view by itself (i.e. don't have to call this func) b/c we didn't declare it -- it came with UIImagePickerControllerDelegate for free?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Selected image not a UIImage")
        }
        imageView.image = image
    }
    
    func showPrivacyAlert() {
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        let alert = UIAlertController(title: "Photo Library Access Denied", message: "Memories needs to access your photo library so you can add pictures to your memories. You can grant access from Settings -> Privacy -> Photos", preferredStyle: .alert)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func showSaveAlert() {
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        let alert = UIAlertController(title: "Not enough information", message: "Your memory doesn't seem to be complete. In order to save a memory, please fill out all prompts.", preferredStyle: .alert)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    

    @IBAction func addPhoto(_ sender: Any) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
            case .authorized:
                presentImagePickerController()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        self.presentImagePickerController()
                    } else {
                        self.showPrivacyAlert()
                    }
                }
            default:
                showPrivacyAlert()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let title = titleTextField.text,
            let body = bodyTextView.text,
            let image = imageView.image,
            let imageData = UIImagePNGRepresentation(image) else {
                showSaveAlert()
                return
        }
        if let thisMemory = memory {
            memoryController?.update(memory: thisMemory, title: title, body: body, imageData: imageData)
        } else {
            memoryController?.create(title: title, body: body, imageData: imageData)
        }
        navigationController?.popViewController(animated: true)
    }
    
    

    // MARK: - Properties
    
    var memory: Memory?
    var memoryController: MemoryController?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
}
