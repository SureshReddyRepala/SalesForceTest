//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Suresh on 09/05/21.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var plotSummary: UILabel!
    
    private let serviceManager = ServiceManager.shared()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with info: SearchModel.Search.Movie, forTableView: String ){
        let activityView = UIActivityIndicatorView()
        activityView.style = .medium
        
        posterImageView.image = UIImage()
        posterImageView.clipsToBounds = true
        posterImageView.addSubview(activityView)
        posterImageView.layer.cornerRadius = 5
        activityView.center = posterImageView.center
        activityView.startAnimating()
        
        serviceManager.getImage(url: info.poster, handler: { [weak self] (data, error) in
            if let _data = data {
                DispatchQueue.main.async {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    self?.posterImageView.image = UIImage(data: _data)
                    self?.posterImageView.contentMode = .scaleAspectFill
                }
            }
        })
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        nameLabel.text = info.title
        
        
        directorLabel.numberOfLines = 1
        directorLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        directorLabel.textColor = UIColor.gray
       // directorLabel.text = "(\(info.director))"
        
        yearLabel.numberOfLines = 1
        yearLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        yearLabel.textColor = UIColor.gray
        yearLabel.text = "(\(info.year))"
        
        plotSummary.numberOfLines = 0
        plotSummary.lineBreakMode = .byWordWrapping
        plotSummary.adjustsFontSizeToFitWidth = true
        plotSummary.minimumScaleFactor = 0.5
        plotSummary.font = UIFont.preferredFont(forTextStyle: .title3)
        plotSummary.textColor = UIColor.gray
       // plotSummary.text = "(\(info.plot))"
        
    }
}
