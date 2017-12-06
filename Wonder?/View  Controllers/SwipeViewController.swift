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
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    
    // MARK: - Properties
    var maxMovieGenreCount: Int?
    var indexOfGenre = 0
    var likedGenresCount: Int?
    var discoveredMovies: [Movie] = []
    var bottomCardImageHolder: UIImage?
    var questionCounter = 0
    var switchToQuestions = false
    var haveGenresReset = false
    
    
    
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
    
//    func programmaticallyTriggerPanGestureRecognizer() {
//        panGestureRecognizer.setTranslation(CGPoint(x: 200, y: 0), in: view)
//        panCard(panGestureRecognizer)
//    }


    
    // MARK: - Actions
    @IBAction func likeButtonPressed(_ sender: Any) {
        animateTopCardWhenLikeButtonIsPressed()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        animateTopCardWhenDislikeButtonIsPressed()
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {return }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        let scale = min(100/abs(xFromCenter), 1)
        
        panCardAnimation(card: card, point: point, xFromCenter: xFromCenter, scale: scale)
        
        let genreToModify = GenresController.shared.movieGenres[indexOfGenre]
        
        if sender.state == .ended {
            // After they have toggled a genre we need to figure out if we need to switch to movies
            guard let likedGenresCount = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {print("Broken likedGenreCount");return}
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    // This going to check if we need to start asking qustions or if we need to continue displaying genre types
                    if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                    } else {
                        // If they haven't picked three genres that they like make them start over
                        if self.indexOfGenre == maxMovieGenreCount - 1 && likedGenresCount != 3{
                            self.haveGenresReset = true
                            self.indexOfGenre = 0
                            self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                        } else {
                            // When this runs we are starting to ask general question before we start fetch movies
                            let question = QuestionController.shared.questions[self.questionCounter - 1 ]
                            self.prepareForNextQuestion(question: question, isLiked: false, completion: { (isComplete) in
                                if isComplete {
                                    // TODO: -  Fetch Movies
                                    self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                                }
                            })
                        }
                    }
                })
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    // This checks if it needs to switch to questions
                    if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: true)
                    } else {
                        let question = QuestionController.shared.questions[self.questionCounter - 1]
                        self.prepareForNextQuestion(question: question, isLiked: true, completion: { (isComplete) in
                            if isComplete {
                                // TODO: -  Fetch Movies
                                self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                            }
                        })
                    }
                    
                })
            } else {
                resetPostionOfCardWithAnimation(card)
            }
        }
        
    }

    // MARK: - Methods
    func prepareForNextQuestion(question: Question, isLiked: Bool, completion: (_ isComplete: Bool) -> Void ) {
        if questionCounter == 3 {
            self.configureBottomCardAsQuestion(self.bottomCardView)
            completion(true)
        } else {
            QuestionController.shared.toggleStatusForQuestion(question: question, isLiked: isLiked)
            self.configureBottomCardAsQuestion(self.bottomCardView)
            completion(false)
        }
        
    }
    
    func completeAnimationForGenreUsing(card: UIView, likedGenresCount: Int ,genreToModify: Genre, isLiked: Bool) {
        self.resetTopCardForGenres(card)
        self.checkIfTheGenreNeedsToggled(withCount: likedGenresCount, andGenre: genreToModify, isLiked: isLiked)
        
        guard let maxMovieGenreCount = maxMovieGenreCount else {return}
        
        var genreToFetch: Genre?
        var genreImageID: Int
        
        // This decides if we need to switch to questions or not
        if switchToQuestions == false {
            if (indexOfGenre + 1) != (maxMovieGenreCount){
                // Fetch the the new bottom card
                if haveGenresReset {
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre]
                    guard let id = genreToFetch?.id else {return}
                    genreImageID = id
                    haveGenresReset = false
                    // Fetch the top and bottom images
                    self.fetchTheTopCardImageWith(genreID: id)
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre + 1]
                    guard let secondID = genreToFetch?.id else {return}
                    self.fetchTheBottomCardImageWith(genreID: secondID)
                } else {
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre + 1]
                    guard let id = genreToFetch?.id else {return}
                    genreImageID = id
                    self.fetchTheBottomCardImageWith(genreID: genreImageID)
                }
            } else {
                // This sets the very last genre to the top card
                topCardImage.image = bottomCardImage.image
                customTopCardLabel.text = customBottomCardLabel.text
            }
        }
        else {
            configureBottomCardAsQuestion(bottomCardView)
        }
    }
    
    func panCardAnimation(card: UIView, point: CGPoint, xFromCenter: CGFloat, scale: CGFloat) {
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
    }
    
    // MARK: - Card Button Animations
    var  hasLikeButtonAnimationCompleted = true
    /// Animates the top card to slide to the right
    func animateTopCardWhenLikeButtonIsPressed() {
        guard let card = self.topCardView else {return}
        if hasLikeButtonAnimationCompleted {
            self.hasLikeButtonAnimationCompleted = false
            UIView.animate(withDuration: 1 , animations: {
                card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                card.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (_) in
                // This checks if it needs to switch to questions
                self.hasLikeButtonAnimationCompleted = true
                guard let likedGenresCount = self.likedGenresCount else {return}
                let genreToModify = GenresController.shared.movieGenres[self.indexOfGenre]
                if self.indexOfGenre + 1 != self.maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: true)
                } else {
                    let question = QuestionController.shared.questions[self.questionCounter - 1]
                    self.prepareForNextQuestion(question: question, isLiked: true, completion: { (isComplete) in
                        if isComplete {
                            // TODO: -  Fetch Movies
                            self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                        }
                    })
                }
            }
        }
    }
    
    var disLikeButtonAnimationCompleted = true
    /// Animates the top card to slide to the left
    func animateTopCardWhenDislikeButtonIsPressed() {
        guard let card = self.topCardView else {return}
        if disLikeButtonAnimationCompleted {
            self.disLikeButtonAnimationCompleted = false
            UIView.animate(withDuration: 1 , animations: {
                card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                card.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (_) in
                // This checks if it needs to switch to questions
                guard let likedGenresCount = self.likedGenresCount, let maxMovieGenreCount = self.maxMovieGenreCount else {print("Broken likedGenreCount");return}
                let genreToModify = GenresController.shared.movieGenres[self.indexOfGenre]
                // This going to check if we need to start asking qustions or if we need to continue displaying genre types
                if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                } else {
                    // If they haven't picked three genres that they like make them start over
                    if self.indexOfGenre == maxMovieGenreCount - 1 && likedGenresCount != 3{
                        self.haveGenresReset = true
                        self.indexOfGenre = 0
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                    } else {
                        // When this runs we are starting to ask general question before we start fetch movies
                        let question = QuestionController.shared.questions[self.questionCounter - 1 ]
                        self.prepareForNextQuestion(question: question, isLiked: false, completion: { (isComplete) in
                            if isComplete {
                                // TODO: -  Fetch Movies
                                self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                            }
                        })
                    }
                }
                self.disLikeButtonAnimationCompleted = true
            }
        }
    }
    
    
    // MARK: - SetUp UI
    func configureView() {
        // Reset this value evertime the view is loaded so the expirances is the same
        GenresController.shared.genreMoviesThatHaveAlreadyBeenDisplayed.removeAll()
        
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
        DispatchQueue.main.async {
            label.text = text
        }
    }
    
    func fetchTheTopCardImageWith(genreID id: Int) {
        GenresController.shared.fetchImageForGenre(with: id, completion: { (image) in
            guard let image = image else {print("Error with the top image in file: \(#file) and function: \(#function)")
                print("\(id)")
                return
                
            }
            DispatchQueue.main.async {
                self.topCardImage.image = image
            }
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
        })
    }
    
    func fetchTheBottomCardImageWith(genreID id: Int) {
            GenresController.shared.fetchImageForGenre(with: id, completion: { (image) in
                guard let image = image else {print("Error with the bottomimage in file: \(#file) and function: \(#function)")
                    print("\(id)")
                    return
                }
                DispatchQueue.main.async {
                    self.bottomCardImage.image = image
                }
                self.setCustomText(toLabel: self.customBottomCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
            })

    }
    
    func resetView() {
        GenresController.shared.likedMovieGenres.removeAll()
        GenresController.shared.unlikedMovieGenres.removeAll()
        indexOfGenre = 0
    }
    
    //    func checkLikedGenreCount(withCount count: Int) {
    //        guard let likedGenresCount = likedGenresCount else {print("Broken likedGenreCount"); return}
    //
    //        if likedGenresCount > 3 {
    //            // Fetch those movies
    //            let ids = GenresController.shared.likedMovieGenres.flatMap({ $0.id })
    //            MovieController.shared.fetchMoviesBasedOnGenresWith(ids: ids, pageCount: 1, completion: { (_) in})
    //
    //            let movie = discoveredMovies[0]
    //            MovieController.shared.fetchImageWith(endpoint: movie.posterPath, completion: { (image) in})
    //
    //        }
    //    }
    
    /// Checks to see if the genre needs to be toggled
    func checkIfTheGenreNeedsToggled(withCount count: Int, andGenre genre: Genre, isLiked: Bool) {
        // This will toggle the genre as long as they haven't already liked three.
        if count < 3 {
            GenresController.shared.toggleIsLikedStatusFor(genre: genre, isLiked: isLiked)
            if haveGenresReset {
                indexOfGenre = 0
            } else {
                indexOfGenre += 1
            }
        }
        
        // If the count is greater than three we need to swich to the question view.
    }
    
    // MARK: - Refresh Functions
    @objc func refreshLikeGenres(card: UIView?) {
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        
        guard let count = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {return}
        if count > 2  || indexOfGenre >= maxMovieGenreCount {
            // Sets the top card to start questions
            configureTopCardAsQuestion(topCardView)
            configureBottomCardAsQuestion(bottomCardImage)
            switchToQuestions = true
        }
        
        
        print("There are \(likedGenresCount!) Liked Genres")
    }
    
    
    private func resetTopCardForGenres(_ card: UIView?) {
        guard let card = card else {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
            return
        }
        topCardImage.image = bottomCardImage.image
        if haveGenresReset {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
        } else {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
        }
        resetPostitionOf(card: card)
        
    }
    
    private func configureTopCardAsQuestion(_ card: UIView) {
        if questionCounter < QuestionController.shared.questions.count && switchToQuestions == false {
            resetPostitionOf(card: card)
            self.topCardImage.image = #imageLiteral(resourceName: "noImageView")
            setCustomText(toLabel: customTopCardLabel, text: "\(QuestionController.shared.questions[questionCounter].text)")
        } else {
            // This will run after the bottom question card has initally been set that way it doesn't bounce
            if questionCounter <= 2 {
            self.topCardImage.image = #imageLiteral(resourceName: "noImageView")
            setCustomText(toLabel: customTopCardLabel, text: QuestionController.shared.questions[questionCounter].text)
            questionCounter += 1
            resetPostitionOf(card: card)
            } else {
                print("Didn't increase counter")
            }
        }
    }
    
    private func configureBottomCardAsQuestion(_ card: UIView) {
        
        if questionCounter + 1 < QuestionController.shared.questions.count && switchToQuestions == false {
            DispatchQueue.main.async {
                self.bottomCardImage.image = #imageLiteral(resourceName: "noImageView")
            }
            setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter].text)
        } else {
            DispatchQueue.main.async {
                self.bottomCardImage.image = #imageLiteral(resourceName: "noImageView")
            }
            // This is to check to see if this is the last question that needs to be displayed
            if questionCounter >= 2 {
                setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter - 1].text)
                configureTopCardAsQuestion(topCardView)
            } else {
                setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter + 1].text)
                configureTopCardAsQuestion(topCardView)
                
                // TODO: - Fetch Movies from here 
            }
        }
    }
    
    /// This repositions the card back to the center
    private func resetPostitionOf(card: UIView) {
            card.center = self.view.center
            self.thumbImageView.alpha = 0
            card.alpha = 1
            card.transform = .identity
    }
    
    private func resetPostionOfCardWithAnimation(_ card: UIView) {
        UIView.animate(withDuration: 0.3) {
            card.center = self.view.center
            self.thumbImageView.alpha = 0
            card.alpha = 1
            card.transform = .identity
        }
    }
}
