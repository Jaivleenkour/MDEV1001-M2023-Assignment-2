
import UIKit
import CoreData

class DataViewController: UIViewController , UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    var movies: [Movie] = []
    var index = Int()
    var selectedPosterImage: UIImage?
    
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
            let imgData = movie.thumbnail != nil ? UIImage(data: movie.thumbnail!) : nil
            cell.thumbnailImage?.image = imgData ?? selectedPosterImage
            return cell
            
           
        }
    
    
    // Tap on particular cell
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
                   // Edit existing movie
                   let movie = movies[indexPath.row]
                   addEditVC.movie = movie
                } else {
                    // Add new movie
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




