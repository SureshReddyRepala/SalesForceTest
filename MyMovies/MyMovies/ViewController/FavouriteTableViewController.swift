//
//  FavouriteTableViewController.swift
//  MyMovies
//
//  Created by Suresh on 09/05/21.
//

import UIKit
import CoreData

class FavouriteTableViewController: UITableViewController {

    var movies = [SearchModel.Search.Movie]()
    var dataArray: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI(){
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Favourites"

        fetchData()
    }
    
    func fetchData(){
        //1
         guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
             return
         }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         //2
         let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Movie")
         
         //3
         do {
            dataArray = try managedContext.fetch(fetchRequest)
            movies.removeAll()
            for movie in dataArray {
                if let name =  movie.value(forKeyPath: "name") as? String,
                   let type =  movie.value(forKeyPath: "type") as? String,
                   let year =  movie.value(forKeyPath: "year") as? String,
                   let poster =  movie.value(forKeyPath: "poster") as? String,
                   let imdbID =  movie.value(forKeyPath: "imdbID") as? String {
                    
                    let movie =  SearchModel.Search.Movie.init(title: name, year: year, imdbID: imdbID, type: type, poster: poster)
                    movies.append(movie)
                }
            }
            self.tableView.reloadData()
            
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MovieTableViewCell{
            cell.configureCell(with: movies[indexPath.row], forTableView:"Favourites")
            
            cell.favouriteButton.isEnabled = false
            cell.favouriteButton.isHidden = true
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Movie", sender: movies[indexPath.row].imdbID)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Movie" {
            if let viewController = segue.destination as? MovieDetailTableViewController, let movieID = sender as? String {
                viewController.imdbID = movieID
            }
        }
    }
}
