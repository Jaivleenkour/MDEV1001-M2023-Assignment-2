//
//  AddEditViewController.swift
//  MDEV1001-M2023-ICE4
//
//  Created by Jaivleen Kour on 2023-06-11.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController, UIDocumentPickerDelegate
{
    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var studioTextField: UITextField!
    @IBOutlet weak var criticsRatingTextField: UITextField!
    
    var movie: Movie?
    var dataViewController: DataViewController?
    var selectedPosterImage: UIImage?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let movie = movie
        {
            // Editing existing movie
            titleTextField.text = movie.title
            studioTextField.text = movie.studio
            criticsRatingTextField.text = "\(movie.criticsrating)"
            if let imageData = movie.thumbnail, let image = UIImage(data: imageData) {
                thumbnailImage.image = image
                }
        }
        else
        {
            AddEditTitleLabel.text = "Add Movie"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton)
    {
        // Retrieve the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }

        // Retrieve the managed object context
        let context = appDelegate.persistentContainer.viewContext
        dataViewController?.selectedPosterImage = selectedPosterImage
        

        if let movie = movie
        {
            // Editing existing movie
            movie.title = titleTextField.text
            movie.studio = studioTextField.text
            movie.criticsrating = Double(criticsRatingTextField.text ?? "") ?? 0.0
            movie.thumbnail = selectedPosterImage?.jpegData(compressionQuality: 1.0)
        } else {
            // Creating a new movie
            let newMovie = Movie(context: context)
            newMovie.title = titleTextField.text
            newMovie.studio = studioTextField.text
            newMovie.criticsrating = Double(criticsRatingTextField.text ?? "") ?? 0.0
            newMovie.thumbnail = selectedPosterImage?.jpegData(compressionQuality: 1.0)
        }

        // Save the changes in the context
        do {
            try context.save()
            dataViewController?.fetchData()
            dismiss(animated: true, completion: nil)
        } catch {
            print("Failed to save data: \(error)")
            
        }
    }
    @IBAction func uploadImageButton(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)

    }
    
  
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: selectedFileURL.path) {
            if let imageData = fileManager.contents(atPath: selectedFileURL.path), let image = UIImage(data: imageData) {
                thumbnailImage.image = image
                selectedPosterImage = image
            } else {
                print("Failed to read image data from URL: \(selectedFileURL)")
            }
        } else {
            print("Selected file does not exist at URL: \(selectedFileURL)")
        }
    }

    
}
