//
//  FavouritesManager.swift
//  
//
//  Created by Marta Kalichynska on 01.02.2024.
//

import UIKit
import CoreData

class FavoritesManager {
    static let shared = FavoritesManager()

    private init() {}

    func addToFavorites(movieData: MoviesData, completion: @escaping (Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "FavoriteMovie", in: managedContext)!
        let favoriteMovie = NSManagedObject(entity: entity, insertInto: managedContext)

        setAttributes(for: favoriteMovie, with: movieData)

        do {
            try managedContext.save()
            print("Saved to favorites successfully")
            completion(true)
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
            completion(false)
        }
    }

    func toggleFavoriteStatus(for movieData: MoviesData, completion: @escaping (Bool) -> Void) {
        if isMovieFavorite(movieData: movieData) {
            removeFromFavorites(movieData: movieData, completion: completion)
        } else {
            addToFavorites(movieData: movieData, completion: completion)
        }
    }

    func isMovieFavorite(movieData: MoviesData) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: movieData.id))

        do {
            let result = try managedContext.fetch(fetchRequest)
            return !result.isEmpty
        } catch {
            print("Error fetching. \(error), \(error.localizedDescription)")
            return false
        }
    }

    private func removeFromFavorites(movieData: MoviesData, completion: @escaping (Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: movieData.id))

        do {
            if let result = try managedContext.fetch(fetchRequest).first as? NSManagedObject {
                managedContext.delete(result)
                try managedContext.save()
                completion(true)
            }
        } catch {
            print("Could not delete. \(error), \(error.localizedDescription)")
            completion(false)
        }
    }

    private func setAttributes(for favoriteMovie: NSManagedObject, with movieData: MoviesData) {
        favoriteMovie.setValue(movieData.id, forKey: "id")
        favoriteMovie.setValue(movieData.title, forKey: "title")
        favoriteMovie.setValue(movieData.posterPath, forKey: "posterPath")
    }
}
