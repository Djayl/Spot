//
//  SpotCreationViewController.swift
//  Spot
//
//  Created by MacBook DS on 18/01/2020.
//  Copyright © 2020 Djilali Sakkar. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import Kingfisher
import ProgressHUD



@available(iOS 13.0, *)
final class SpotCreationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var creationButton: CustomButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    
    
    // MARK: - Properties
    
    var location: CLLocationCoordinate2D!
    var newLocation: CLLocation!
//    private var controller: MapViewController?
//    weak var delegate: AddSpotDelegate!
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    var myImage: UIImage?
    var spots = [Spot]()
    var userName = ""
    var imageURL: String?
    private var ownerId = ""
    private var imageId = ""
    var placeholderLbl = UILabel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("This is" + "\(newLocation as Any)")
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 21)!]
        self.navigationItem.title = "Création de Spot"
        setupPictureImageView()
        //        setupInputTextView()
        showKeyboard()
        fetchProfilInformation()
        setUpNavigationController()
        setupTextFields()
        setupView()
        handleTextView()
        hideKeyboardWhenTappedAround()
        setUpKeyboard()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .done, target: self, action: #selector(goBack))
        pictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhoto)))
        stateSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.navigationController?.isNavigationBarHidden = false
    //    }
    
    // MARK: - Actions
    
    @IBAction func sendData(_ sender: Any) {
        presentAlertWithAction(message: "Voulez-vous créer ce Spot?") {
            self.saveNewSpot()
        }
    }
    
    // MARK: - Methods
    
    
    fileprivate func setupPictureImageView() {
        pictureImageView.contentMode = .center
        pictureImageView.layer.borderWidth = 1
        pictureImageView.layer.borderColor = Colors.blueBalloon.cgColor
    }
    
    @objc private func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            switchLabel.text = "Spot public"
        } else {
            switchLabel.text = "Spot privé"
        }
    }
    
    fileprivate func setUpNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        //        navigationController?.navigationBar.tintColor = Colors.coolRed
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "Quicksand-Regular", size: 15)!, .foregroundColor : Colors.coolRed], for: .normal)
    }
    
    
    fileprivate func setupView() {
        //        descriptionTextView.text = "Type your description"
        //        descriptionTextView.font = UIFont(name: "Quicksand-Regular", size: 15)
        //        descriptionTextView.layer.cornerRadius = 5
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.layer.cornerRadius = 10
        pictureImageView.layer.masksToBounds = true
    }
    
    fileprivate func setupTextFields() {
        titleTextfield.delegate = self
        descriptionTextView.delegate = self
        titleTextfield.layer.borderColor = Colors.blueBalloon.cgColor
        titleTextfield.layer.borderWidth = 1
        titleTextfield.layer.cornerRadius = 5
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = Colors.blueBalloon.cgColor
        descriptionTextView.layer.cornerRadius = 5
        
    }
    
    @objc private func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func setProfilData(_ profil: Profil){
        userName = profil.userName
        ownerId = profil.identifier
    }
    
    private func fetchProfilInformation() {
        let firestoreService = FirestoreService<Profil>()
        firestoreService.fetchDocument(endpoint: .currentUser) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.setProfilData(profil)
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
    }
    
    private func saveNewSpot() {
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(location) { (placemarks, error) in
//            if error != nil {
//                print(error!)
//            }
//            if let coor = placemarks?.firstResult()?.coordinate {
        let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
                    if error != nil {
                        print(error!)
                    }
                    if let coor = placemarks?.first?.location?.coordinate {
                        guard self.myImage != nil else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir une image")
                    return
                }
                guard let name = self.titleTextfield.text, name.isEmptyOrWhitespace() == false else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un spot doit avoir un titre")
                    return
                }
                guard let description = self.descriptionTextView.text, self.validate(textView: self.descriptionTextView) else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un spot doit avoir une description")
                    return
                }
                let creatorName = self.userName
                let identifier = UUID().uuidString
//                let spot = Spot(position: coor)
//                let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: UIColor.darkGray)
//                spot.iconView = customMarker
//                spot.title = name
//                spot.snippet = description
//                spot.coordinate = coor
                self.getImage { (imageUrl) in
                    ProgressHUD.show()
                    let privateSpot = Marker(identifier: identifier, name: name, description: description, coordinate: GeoPoint(latitude: coor.latitude, longitude: coor.longitude), imageURL: imageUrl, ownerId: self.ownerId,publicSpot: false , creatorName: creatorName, creationDate: Date(), imageID: self.imageId)
                    let publicSpot = Marker(identifier: identifier, name: name, description: description, coordinate: GeoPoint(latitude: coor.latitude, longitude: coor.longitude), imageURL: imageUrl, ownerId: self.ownerId,publicSpot: true , creatorName: creatorName, creationDate: Date(), imageID: self.imageId)
                    DispatchQueue.main.async {
                        if self.stateSwitch.isOn {
                            ProgressHUD.showSuccess(NSLocalizedString("Spot public créé!", comment: ""))
                            self.savePublicSpotInFirestore(identifier: identifier, spot: publicSpot)
                            self.saveSpotInFirestore(identifier: identifier, spot: publicSpot)
                            NotificationCenter.default.post(name: Notification.Name("showSpots"), object: nil)
                            print("Public Spot successfully added in private and public BDD")
                        } else {
                            ProgressHUD.showSuccess(NSLocalizedString("Spot privé créé!", comment: ""))
                            self.saveSpotInFirestore(identifier: identifier, spot: privateSpot)
                            NotificationCenter.default.post(name: Notification.Name("showMySpot"), object: nil)
                            print("Private Spot successfully added")
                        }
                    }
                }
                //                self.delegate.addSpotToMapView(marker: spot)
                self.goToMapView()
            }
        }
    }
    
    private func saveSpotInFirestore(identifier: String, spot: Marker) {
        //        ProgressHUD.showSuccess(NSLocalizedString("Spot privé créé!", comment: ""))
        let firestoreService = FirestoreService<Marker>()
        firestoreService.saveData(endpoint: .spot, identifier: identifier, data: spot.dictionary) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Error adding document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    private func savePublicSpotInFirestore(identifier: String, spot: Marker) {
        let firestoreService = FirestoreService<Marker>()
        //        ProgressHUD.showSuccess(NSLocalizedString("Spot public créé!", comment: ""))
        firestoreService.saveData(endpoint: .publicCollection, identifier: identifier, data: spot.dictionary) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Error adding document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    @objc private func goToMapView() {
        //        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc private func addPhoto() {
        showImagePicckerControllerActionSheet()
    }
    
    private func getImage(_ completion: @escaping (String)->Void) {
        guard let image = myImage, let data = image.jpegData(compressionQuality: 1.0) else {
            presentAlert(with: "Il semble y avoir une erreur")
            return
        }
        let firebaseStorageManager = FirebaseStorageManager()
        let imageName = UUID().uuidString
        imageId = imageName
        firebaseStorageManager.uploadImageData(data: data, serverFileName: imageName) { (isSuccess, url) in
            guard let imageUrl = url else {return}
            completion(imageUrl)
        }
    }
    
    //    func setupInputTextView() {
    //
    //        descriptionTextView.delegate = self
    //        placeholderLbl.isHidden = false
    //        let placeholderX: CGFloat = self.view.frame.size.width / 75
    //        let placeholderY: CGFloat = 0
    //        let placeholderWidth: CGFloat = descriptionTextView.bounds.width - placeholderX
    //
    //        let placeholderHeight: CGFloat = descriptionTextView.bounds.height
    //
    //        let placeholderFontSize = self.view.frame.size.width / 25
    //
    //        placeholderLbl.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
    //        placeholderLbl.text = "Décrivez votre Spot"
    //        placeholderLbl.font = UIFont.systemFont(ofSize: placeholderFontSize)
    //        placeholderLbl.textColor = .lightGray
    //        placeholderLbl.textAlignment = .left
    //
    //        descriptionTextView.addSubview(placeholderLbl)
    //
    //    }
    
    //    func textViewDidChange(_ textView: UITextView) {
    //        let spacing = CharacterSet.whitespacesAndNewlines
    //        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
    //            _ = textView.text.trimmingCharacters(in: spacing)
    //            placeholderLbl.isHidden = true
    //        } else {
    //            placeholderLbl.isHidden = false
    //        }
    //    }
    
    internal func handleTextView() {
        descriptionTextView.layer.cornerRadius = 5
        //        descriptionTextView.text = "Décrivez votre Spot"
        //        descriptionTextView.textColor = UIColor.systemGray
        descriptionTextView.font = UIFont.systemFont(ofSize: 17)
        descriptionTextView.returnKeyType = .done
    }
    
    private func textViewShouldReturn(_ textView: UITextView) -> Bool {
        descriptionTextView.resignFirstResponder()
        return true
    }
    
    //    internal func textViewDidBeginEditing(_ textView: UITextView) {
    //        if textView.text == "Décrivez votre Spot" {
    //            textView.text = ""
    //            textView.textColor = UIColor.white
    //            textView.font = UIFont.systemFont(ofSize: 17)
    //        }
    //    }
    //
    //    internal func textViewDidEndEditing(_ textView: UITextView) {
    //        if textView.text == "" || textView.text == "\n"{
    //            textView.text = "Décrivez votre Spot"
    //            textView.textColor = UIColor.systemGray
    //            textView.font = UIFont.systemFont(ofSize: 17)
    //        }
    //    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        // Attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // Add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        // Make sure the result is under 16 characters
        return updatedText.count <= 25
    }
    
    //    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //        // Get the current text, or use an empty string if that failed
    //        let currentText = textView.text ?? ""
    //        // Attempt to read the range they are trying to change, or exit if we can't
    //        guard let stringRange = Range(range, in: currentText) else { return false }
    //        // Add their new text to the existing text
    //        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    //        // Make sure the result is under 16 characters
    //        return updatedText.count <= 30
    //    }
}

// MARK: - ImagePicker Delegate
@available(iOS 13.0, *)
extension SpotCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicckerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Ouvrir la photothèque", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Prendre une photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        AlertService.showAlert(style: .actionSheet, title: "Choisissez votre image", message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //        pictureImageView.contentMode = .center
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            pictureImageView.image = editedImage
            pictureImageView.contentMode = .scaleAspectFill
            myImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImage = originalImage
            pictureImageView.contentMode = .scaleAspectFill
            pictureImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

