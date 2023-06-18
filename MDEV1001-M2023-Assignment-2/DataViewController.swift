//
//  ViewController.swift
//  MDEV1001-M2023-ICE4
//
//  Created by Jaivleen Kour on 2023-06-03.
//

import UIKit
import CoreData

class DataViewController: UIViewController , UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    var movies: [Movie] = []
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
    }
    
    func fetchData() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            
            do {
                movies = try context.fetch(fetchRequest)
                tableView.reloadData()
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
    


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return movies.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
            
            let movie = movies[indexPath.row]
            index = indexPath.row
            cell.titleLabel?.text = movie.title
            cell.studioLabel?.text = movie.studio
            
            cell.ratingLabel?.text = "\(movie.criticsrating)"
            // Set the background color of criticsRatingLabel based on the rating
                   let rating = movie.criticsrating
                       
                   if rating > 7
                   {
                       cell.ratingLabel.backgroundColor = UIColor.green
                       cell.ratingLabel.textColor = UIColor.black
                   } else if rating > 5 {
                       cell.ratingLabel.backgroundColor = UIColor.yellow
                       cell.ratingLabel.textColor = UIColor.black
                   } else {
                       cell.ratingLabel.backgroundColor = UIColor.red
                       cell.ratingLabel.textColor = UIColor.white
                   }
            
       //     print("type", movie.thumbnail ?? "nil")
            var type = movie.thumbnail ?? "no"
            if  type == "no" || type ==  "" {
                cell.thumbnailImage.image = UIImage(named: "appleicon")}
            else{
                    cell.thumbnailImage.image = UIImage(url: URL(string: type))
                }
            
           
           // cell.thumbnailImage.image = UIImage(url: URL(string: movie.thumbnail!))
           
          // Create URL
          //  let url = URL(string: "\(String(describing: movie.thumbnail))")
           // print("img",movie.thumbnail)
           // print("url",url)
                // Fetch Image Data
//                if let data = try? Data(contentsOf: url) {
//                    // Create Image and Update Image View
//                    cell.thumbnailImage.image = UIImage(data: data)
//                }
            /*
            let imageURL = URL(string: type )

            // Creating a session object with the default configuration.
            // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
            let session = URLSession(configuration: .default)
            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
            let downloadPicTask = session.dataTask(with: movie.thumbnail) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        print("Downloaded cat picture with response code \(res.statusCode)")
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            let image = UIImage(data: imageData)
                            // Do something with your image.
                            cell.thumbnailImage.image = image
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
            */
            
                   return cell
            
           
        }
    
    
    // New for ICE5
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }
    
    // Swipe Left Gesture
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let movie = movies[indexPath.row]
            ShowDeleteConfirmationAlert(for: movie) { confirmed in
                if confirmed
                {
                    self.deleteMovie(at: indexPath)
                }
            }
        }
    }
    
    @IBAction func AddButton_Pressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "AddEditSegue"
        {
            if let addEditVC = segue.destination as? AddEditViewController
            {
                addEditVC.dataViewController = self
                if let indexPath = sender as? IndexPath
                {
                   // Editing existing movie
                   let movie = movies[indexPath.row]
                   addEditVC.movie = movie
                } else {
                    // Adding new movie
                    addEditVC.movie = nil
                }
            }
        }
    }
    
    func ShowDeleteConfirmationAlert(for movie: Movie, completion: @escaping (Bool) -> Void)
    {
        let alert = UIAlertController(title: "Delete Movie", message: "Are you sure you want to delete this movie?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteMovie(at indexPath: IndexPath)
    {
        let movie = movies[indexPath.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(movie)
        
        do {
            try context.save()
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } catch {
            print("Failed to delete movie: \(error)")
        }
    }


}
extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}




