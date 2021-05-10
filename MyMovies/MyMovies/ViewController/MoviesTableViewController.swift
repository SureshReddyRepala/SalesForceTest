//
//  MoviesTableViewController.swift
//  MyMovies
//
//  Created by Suresh on 09/05/21.
//

import UIKit
import CoreData

class MoviesTableViewController: UITableViewController {
    
    private let serviceManager = ServiceManager.shared()
    private var movies = [SearchModel.Search.Movie]()
    
    private var searchParameters = (nextPage: 1,  batchCount: 0,  totalResults: 0)
    fileprivate var searchText: String?
    private let searchController = UISearchController(searchResultsController: nil)
    private var loadMoreIsCalled = false
    fileprivate var isLoading = false
    fileprivate var scrollDirection = ScrollDirection.up
    
    
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
        self.navigationItem.title = "Movies"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        showHelpLabel(withText: "Type a movie name")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourites", style: .plain, target: self, action: #selector(goToFavourites))
    }
    
    @objc func goToFavourites(){
        //        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavouriteTableViewControllerID") as! FavouriteTableViewController
        
        performSegue(withIdentifier: "Show Favourite Movies", sender:nil)
    }
    
    func showHelpLabel(withText text: String) {
        let helpLabel = UILabel()
        helpLabel.frame.size = CGSize.zero
        helpLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        helpLabel.textColor = UIColor.lightGray
        helpLabel.textAlignment = .center
        helpLabel.text = text
        helpLabel.sizeToFit()
        tableView.backgroundView = helpLabel
    }
    
    func search(for movieName: String, page: Int, handler: @escaping ((Bool, Error?) -> Void)) {
        serviceManager.search(for: movieName, page: page) { (searchObject, error) in
            if let search = searchObject, error == nil {
                if let searchReasults = searchObject?.results {
                    self.searchParameters.batchCount = searchReasults.count
                    self.searchParameters.nextPage = page + 1
                    self.searchParameters.totalResults = Int(search.totalResults ?? "0") ?? 0
                    self.movies = searchReasults
                    DispatchQueue.main.async {
                        self.tableView.backgroundView = UIView()
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.movies.removeAll()
                        self.showHelpLabel(withText: "Could not find anything!")
                        self.tableView.reloadData()
                    }
                }
                handler(true, nil)
            }else{
                print(error?.localizedDescription ?? "Error")
                self.alertUser(title: "Search failed!", message: error?.localizedDescription ?? "Error")
                handler(false, error)
            }
        }
    }
    
    func loadMore(for movieName: String, page: Int) {
        loadMoreIsCalled = true
        let spinner = UIActivityIndicatorView(style:.medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
        
        serviceManager.search(for: movieName, page: page) { [weak self] (searchObject, error) in
            DispatchQueue.main.async {
                self?.tableView.tableFooterView?.isHidden = true
                spinner.stopAnimating()
            }
            
            if let search = searchObject, error == nil {
                if let searchReasults = searchObject?.results {
                    self?.searchParameters.batchCount = searchReasults.count
                    self?.searchParameters.nextPage = page + 1
                    self?.searchParameters.totalResults = Int(search.totalResults ?? "0") ?? 0
                    self?.movies.append(contentsOf: searchReasults)
                    self?.isLoading = false
                    self?.loadMoreIsCalled = false
                    DispatchQueue.main.async {
                        let offset = self?.tableView.contentOffset
                        
                        self?.tableView.reloadData()
                        
                        if let _offset = offset {
                            self?.tableView.setContentOffset(_offset, animated: false)
                        }
                    }
                }
            }else{
                print(error?.localizedDescription ?? "Error")
                self?.alertUser(title: "Search failed!", message: error?.localizedDescription ?? "Error")
            }
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
            cell.configureCell(with: movies[indexPath.row], forTableView:"Search")
            
            
            cell.favouriteButton.setTitle("Add to Favourites", for: .normal)
            cell.favouriteButton.backgroundColor = UIColor.yellow
            
            cell.favouriteButton.addTarget(self, action: #selector(addToFavourites(_:)), for: .touchUpInside)
            cell.favouriteButton.tag = indexPath.row + 1
            
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    @objc func addToFavourites(_ sender : UIButton){
        
        if !isEntityAttributeExist(info: movies[sender.tag-1], entityName: "Movie"){
            saveAsFavourite(info: movies[sender.tag-1])
            sender.setTitle("Favourite", for: .normal)
            sender.backgroundColor = UIColor.green
        }
        else{
            print("Already Exist")
            self.alertUser(title: "Alert", message: "Already Movie Addedd to your Favourites")
        }
    }
    
    func isEntityAttributeExist(info: SearchModel.Search.Movie, entityName: String) -> Bool {
        //1
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        //3
        do {
            if let dataArray = try managedContext?.fetch(fetchRequest){
                for movie in dataArray {
                    if let imdbID =  movie.value(forKeyPath: "imdbID") as? String {
                        
                        if info.imdbID == imdbID{
                            return true
                        }
                    }
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func saveAsFavourite(info: SearchModel.Search.Movie) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Movie",
                                       in: managedContext)!
        
        let movie = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        // 3
        movie.setValue(info.title, forKeyPath: "name")
        movie.setValue(info.type, forKeyPath: "type")
        movie.setValue(info.year, forKeyPath: "year")
        movie.setValue(info.poster, forKeyPath: "poster")
        movie.setValue(info.imdbID, forKeyPath: "imdbID")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Movie", sender: movies[indexPath.row].imdbID)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        guard movies.count < searchParameters.totalResults else {return}
        
        if let visibleRow = self.tableView.visibleCells.last {
            guard self.loadMoreIsCalled == false else {return}
            if let lastVisibleRow = tableView.indexPath(for: visibleRow)?.row {
                if lastVisibleRow == self.movies.count - 2 {
                    if scrollDirection == .down {
                        if !isLoading {
                            self.loadMoreIsCalled = true
                            if let _searchText = self.searchText {
                                self.loadMore(for: _searchText, page: searchParameters.nextPage)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Show Movie" {
            if let viewController = segue.destination as? MovieDetailTableViewController, let movieID = sender as? String {
                viewController.imdbID = movieID
            }
        }
        if segue.identifier == "Show Favourite Movies" {
            if let viewController = segue.destination as? FavouriteTableViewController {
                //  viewController.movies = self.movies
            }
        }
    }
}

// MARK: - UIScrollView

extension MoviesTableViewController {
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y >= 0 {
            scrollDirection = .down
        }else{
            scrollDirection = .up
        }
        
    }
}

// MARK: - UISearchResultsUpdating

extension MoviesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            guard searchTerm.count > 2 else {return}
            self.searchText = searchTerm
            searchController.searchBar.isLoading = true
            search(for: searchTerm, page: 1) {[weak self] (done, error) in
                DispatchQueue.main.async {
                    self?.searchController.searchBar.isLoading = false
                }
                if !done {
                    print(error?.localizedDescription ?? "Error")
                    self?.alertUser(title: "Search failed!", message: error?.localizedDescription ?? "Error")
                }
            }
        }
    }
}
