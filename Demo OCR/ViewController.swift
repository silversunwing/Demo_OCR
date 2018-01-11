//
//  ViewController.swift
//  Demo OCR
//
//  Created by Bidhee iMac on 1/10/18.
//  Copyright © 2018 Crunchyiee Studio. All rights reserved.
//

import UIKit
import Foundation
import TesseractOCR

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var replaceTextfield: UITextField!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func textFieldEndOnExit(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func takeSnap(_ sender: Any) {
        view.endEditing(true)
        presentImagePicker()
    }
    
    @IBAction func swapReload(_ sender: Any) {
        view.endEditing(true)
        
        guard let text = textView.text,
        let findText = findTextField.text,
        let replacetext = replaceTextfield.text else {
            return
        }
        
        textView.text = text.replacingOccurrences(of: findText, with: replacetext)
        
        findTextField.text = nil
        replaceTextfield.text = nil
    }
    @IBAction func shareBtn(_ sender: Any) {
        if textView.text.isEmpty{
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [textView.text], applicationActivities: nil)
        
        let excludeActivities:[UIActivityType] = [.assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo ]
        activityViewController.excludedActivityTypes = excludeActivities
        present(activityViewController, animated: true, completion: nil)
    }
    
    func performImageRecognition(_ image: UIImage){
        if let tesseract = G8Tesseract(language: "eng+fra"){
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            textView.text = tesseract.recognizedText
        }
    activityindicator.stopAnimating()
    }
    
    func moveViewUp(){
        if topMarginConstraint.constant != 0{
            return
        }
        topMarginConstraint.constant -= 135
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveViewDown(){
        if topMarginConstraint.constant == 0{
            return
        }
        topMarginConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveViewUp()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveViewDown()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        moveViewDown()
        view.endEditing(true)
        return true
    }
}

extension ViewController : UINavigationControllerDelegate {
    
}

extension ViewController : UIImagePickerControllerDelegate{
    func presentImagePicker(){
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        let libraryButton = UIAlertAction(title: "Choose Existing", style: .default) { (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imagePickerActionSheet.addAction(cancelButton)
        present(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectPhoto.scaleImage(640){
            activityindicator.startAnimating()
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
}

extension UIImage{
    func scaleImage(_ maxdimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxdimension, height: maxdimension)
        
        if size.width > size.height{
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else{
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
        
    }
}
