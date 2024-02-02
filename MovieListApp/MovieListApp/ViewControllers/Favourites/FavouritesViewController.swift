//
//  FavouritesViewController.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class FavouritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    var favorites: [MoviesData] = []
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadFavorites()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = false
        tableView.register(MovieCell.self, forCellReuseIdentifier: "movieCell")
        tableView.backgroundColor = UIColor.black
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadFavorites() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] ?? []
            var uniqueMovieIDs = Set<Int>()
            var newFavorites: [MoviesData] = []
            
            let dispatchGroup = DispatchGroup()
            
            for object in result {
                guard let favoriteMovie = object as? NSManagedObject,
                      let posterPath = favoriteMovie.value(forKey: "posterPath") as? String,
                      let movieID = favoriteMovie.value(forKey: "id") as? Int,
                      !uniqueMovieIDs.contains(movieID) else {
                    continue
                }
                uniqueMovieIDs.insert(movieID)
                let movieData = MoviesData(
                    backdrop_path: nil,
                    id: movieID,
                    original_language: nil,
                    original_title: nil,
                    overview: nil,
                    posterPath: posterPath,
                    releaseDate: nil,
                    title: favoriteMovie.value(forKey: "title") as? String ?? ""
                )
                
                dispatchGroup.enter()
                movieData.fetchPosterImage { [weak self] posterImage in
                    dispatchGroup.leave()
                }
                
                newFavorites.append(movieData)
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                DispatchQueue.main.async {
                    self?.favorites = newFavorites
                    self?.tableView.reloadData()
                    FavoritesManager.shared.favoritesObservable
                        .observe(on: MainScheduler.instance)
                        .subscribe(onNext: { [weak self] updatedFavorites in
                            self?.favorites = updatedFavorites
                            self?.tableView.reloadData()
                        })
                        .disposed(by: self!.disposeBag)
                }
            }
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    
    private func deleteFavorite(at indexPath: IndexPath) {
        let favoriteToRemove = favorites[indexPath.row]
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
            fetchRequest.predicate = NSPredicate(format: "id == %d", favoriteToRemove.id)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                if let objectToDelete = result.first as? NSManagedObject {
                    managedContext.delete(objectToDelete)
                    
                    do {
                        try managedContext.save()
                    } catch {
                        print("Error saving after deletion: \(error)")
                    }
                }
            } catch {
                print("Error fetching object to delete: \(error)")
            }
        }
        favorites.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in section: \(favorites.count)")
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: favorites[indexPath.row])
        cell.contentView.backgroundColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFavorite(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.deleteFavorite(at: indexPath)
            completionHandler(true)
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FavouritesDetailsViewController()
        vc.movieId = favorites[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
        
}

extension MoviesData {
    func fetchPosterImage(completion: @escaping (UIImage?) -> Void) {
        guard let posterPath = self.posterPath,
              let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: imageURL)
                if let posterImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        completion(posterImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Error fetching image data: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
