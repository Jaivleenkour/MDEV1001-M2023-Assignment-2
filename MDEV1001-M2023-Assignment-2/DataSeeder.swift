//
//  DataSeeder.swift
//  MDEV1001-M2023-ICE4
//
//  Created by Jaivleen Kour on 2023-06-03.
//

import Foundation
import UIKit
import CoreData

func seedData() {
    guard let url = Bundle.main.url(forResource: "movies", withExtension: "json") else {
        print("JSON file not found.")
        return
    }
    
    guard let data = try? Data(contentsOf: url) else {
        print("Failed to read JSON file.")
        return
    }
    
    guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        print("Failed to parse JSON.")
        return
    }
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        print("AppDelegate not found.")
        return
    }
    
    let context = appDelegate.persistentContainer.viewContext
    
    for jsonObject in jsonArray {
        let movie = Movie(context: context)
        
       
        movie.title = jsonObject["title"] as? String
        movie.studio = jsonObject["studio"] as? String
        movie.criticsrating = jsonObject["criticsRating"] as? Double ?? 0.0
        movie.thumbnail = jsonObject["thumbnail"] as? String
        
        // Save the context after each movie is created
        do {
            try context.save()
        } catch {
            print("Failed to save movie: \(error)")
        }
    }
    
    print("Data seeded successfully.")
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
    
