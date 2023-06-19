
import Foundation
import UIKit
import CoreData

func seedData() {
    guard let url = Bundle.main.url(forResource: "movies", withExtension: "json") else {
        print("JSON file not found.")
        return
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error loading movies data: \(error)")
            return
        }
        
        guard let data = data else {
            print("Error: No data received.")
            return
        }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("AppDelegate not found.")
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            for jsonObject in jsonArray ?? [] {
                let movie = Movie(context: context)
                
                movie.title = jsonObject["title"] as? String
                movie.studio = jsonObject["studio"] as? String
                movie.criticsrating = jsonObject["criticsRating"] as? Double ?? 0.0
                
                if let imageUrlString = jsonObject["thumbnail"] as? String, let imageUrl = URL(string: imageUrlString) {
                    if let imageData = try? Data(contentsOf: imageUrl) {
                        movie.thumbnail = imageData
                    } else {
                        print("Failed to load image data for movie: \(movie.title ?? "")")
                    }
                }
                
                // Save the context after each movie is created
                do {
                    try context.save()
                } catch {
                    print("Failed to save movie: \(error)")
                }
            }
            
            print("Data seeded successfully.")
        } catch {
            print("Failed to read JSON file: \(error)")
        }
    }
    
    task.resume()
}

func deleteAllData() {
    let persistentContainer = NSPersistentContainer(name: "MDEV1001_M2023_Assignment_2")
    persistentContainer.loadPersistentStores { _, error in
        guard error == nil else {
            print("Failed to load persistent stores: \(error!)")
            return
        }
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All data deleted successfully.")
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}
    
