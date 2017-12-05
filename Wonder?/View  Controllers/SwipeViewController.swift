//
//  SwipeViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var bottomCardView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var topCardImage: UIImageView!
    @IBOutlet weak var bottomCardImage: UIImageView!
    @IBOutlet weak var customTopCardLabel: UILabel!
    @IBOutlet weak var customBottomCardLabel: UILabel!
    
    
    // MARK: - Properties
    var maxMovieGenreCount: Int?
    var indexOfGenre = 0
    var likedGenresCount: Int?
    var discoveredMovies: [Movie] = []
    var bottomCardImageHolder: UIImage?
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Watches to see if a genre has been updated
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLikeGenres), name: GenresController.likedMovieGenresArrayWasUpdated, object: nil)
        
        resetView()
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        
    }
    
    
    
    // MARK: - Actions
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {return }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        let scale = min(100/abs(xFromCenter), 1)
        
        if xFromCenter > 0 {
            // The card is going right
            thumbImageView.image = #imageLiteral(resourceName: "thumbsUp")
        } else {
            // The card is going left
            thumbImageView.image = #imageLiteral(resourceName: "thumbsDown")
        }
        
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: (xFromCenter / view.frame.width) * 0.61).scaledBy(x: scale, y: scale)
        
        
        let genreToModify = GenresController.shared.movieGenres[indexOfGenre]
        
        if sender.state == .ended {
            // After they have toggled a genre we need to figure out if we need to switch to movies
            //            checkLikedGenreCount(withCount: likedGenresCount)
            guard let likedGenresCount = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {print("Broken likedGenreCount");return}
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    if self.indexOfGenre + 1 != maxMovieGenreCount {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                    } else {
                    self.resetTopCardForQuestions(card)
                    }
                })
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    if self.indexOfGenre + 1 != maxMovieGenreCount {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: true)
                    } else {
                    self.resetTopCardForQuestions(card)
                    }
                    
                })
            } else {
                resetCard()
            }
        }
        
    }
    
    
    // MARK: - Methods
    
    func completeAnimationForGenreUsing(card: UIView, likedGenresCount: Int ,genreToModify: Genre, isLiked: Bool) {
        
        self.resetTopCardForGenres(card)
        self.checkIfTheGenreNeedsToggled(withCount: likedGenresCount, andGenre: genreToModify, isLiked: isLiked)
        // When fetching the bottom card we always need to be one ahead of the current index
        guard let maxMovieGenreCount = maxMovieGenreCount else {return}
        if (indexOfGenre + 1) != (maxMovieGenreCount){
            // Fetch the the new bottom card
            let genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre + 1]
            let genreImageID = genreToFetch.id
            self.fetchTheBottomCardImageWith(genreID: genreImageID)
        } else {
            topCardView = bottomCardView
            
        }
        print(indexOfGenre)
        print(maxMovieGenreCount)
        
    }
    
    // MARK: - SetUp UI
    func configureView() {
        maxMovieGenreCount = GenresController.shared.movieGenres.count
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        discoveredMovies = MovieController.shared.discoveredMoviesBasedOnGenres
        let genreImageIDForTopCard = GenresController.shared.movieGenres[indexOfGenre].id
        let genreImageIDForBottomCard = GenresController.shared.movieGenres[indexOfGenre + 1].id
        fetchTheTopCardImageWith(genreID: genreImageIDForTopCard)
        fetchTheBottomCardImageWith(genreID: genreImageIDForBottomCard)
        self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
        
    }
    
    private func setCustomText(toLabel label: UILabel, text: String) {
        label.text = text
    }
    
    func fetchTheTopCardImageWith(genreID id: Int) {
        GenresController.shared.fetchImageForGenre(with: id, completion: { (image) in
            guard let image = image else {print("Error with the top image in file: \(#file) and function: \(#function)")
                print("\(id)")
                return
                
            }
            DispatchQueue.main.async {
                self.topCardImage.image = image
                self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
            }
        })
    }
    
    func fetchTheBottomCardImageWith(genreID id: Int) {
        guard let maxMovieGenreCount = maxMovieGenreCount else {return}
        if indexOfGenre + 1 != maxMovieGenreCount {
            
            GenresController.shared.fetchImageForGenre(with: id, completion: { (image) in
                guard let image = image else {print("Error with the bottomimage in file: \(#file) and function: \(#function)")
                    print("\(id)")
                    return
                }
                DispatchQueue.main.async {
                    // MARK: - Set bottom card attributes here
                    self.bottomCardImage.image = image
                    self.setCustomText(toLabel: self.customBottomCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
                    
                }
            })
        } else {
            resetTopCardForQuestions(topCardView)
        }
    }
    
    func resetView() {
        GenresController.shared.likedMovieGenres.removeAll()
        GenresController.shared.unlikedMovieGenres.removeAll()
        indexOfGenre = 0
    }
    
    func checkLikedGenreCount(withCount count: Int) {
        guard let likedGenresCount = likedGenresCount else {print("Broken likedGenreCount"); return}
        
        if likedGenresCount > 3 {
            // Fetch those movies
            let ids = GenresController.shared.likedMovieGenres.flatMap({ $0.id })
            MovieController.shared.fetchMoviesBasedOnGenresWith(ids: ids, pageCount: 1, completion: { (_) in})
            
            let movie = discoveredMovies[0]
            MovieController.shared.fetchImageWith(endpoint: movie.posterPath, completion: { (image) in})
            
        }
    }
    
    /// Checks to see if the genre needs to be toggled
    func checkIfTheGenreNeedsToggled(withCount count: Int, andGenre genre: Genre, isLiked: Bool) {
        // This will toggle the genre as long as they haven't already liked three.
        if count < 3 {
            GenresController.shared.toggleIsLikedStatusFor(genre: genre, isLiked: isLiked)
            indexOfGenre += 1
        }
        
        // If the count is greater than three we need to swich to the question view.
    }
    
    @objc func refreshLikeGenres(card: UIView?) {
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        
        guard let count = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {return}
        if count > 2  || indexOfGenre >= maxMovieGenreCount {
            self.resetTopCardForQuestions(topCardView)
        }
        
        print("\(likedGenresCount!)")
    }
    
    
    private func resetTopCardForGenres(_ card: UIView?) {
        guard let card = card else {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
            return
        }
        topCardImage.image = bottomCardImage.image
        self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
        card.center = view.center
        thumbImageView.alpha = 0
        card.transform = .identity
        card.alpha = 1
        
    }
    
    private func resetTopCardForQuestions(_ card: UIView) {
        topCardImage.image = #imageLiteral(resourceName: "noImageView")
        setCustomText(toLabel: customTopCardLabel, text: "\(QuestionController.shared.questions[0].text)")
        card.center = view.center
        thumbImageView.alpha = 0
        card.transform = .identity
        card.alpha = 1
    }
    
    /// This repositions the card back to the center
    private func resetCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.topCardView.center = self.view.center
            self.thumbImageView.alpha = 0
            self.topCardView.alpha = 1
            self.topCardView.transform = .identity
        })
    }
    
    
}
