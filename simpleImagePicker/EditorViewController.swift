//
//  EditorViewController.swift
//  simpleImagePicker
//
//  Created by Keith Doba on 5/7/18.
//  Copyright © 2018 Doba. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var meme = Meme()
    
    override func viewDidLoad() {
        //The delegate code came from https://stackoverflow.com/questions/23611104/textfielddidbeginediting-not-getting-called
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setTextFieldValues(textElement: topText, text: "TOP")
        setTextFieldValues(textElement: bottomText, text: "BOTTOM")
        shareButton.isEnabled = false
    }
    
    func setTextFieldValues(textElement: UITextField, text: String){

        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue:UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue:UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -2.0 ]
        textElement.text = text
        textElement.defaultTextAttributes = memeTextAttributes
        textElement.textAlignment = .center
        textElement.delegate = self
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }

    // used https://github.com/egorio/udacity-meme-me/blob/master/MemeMe/EditorViewController.swift to figure out how to format this call
    // I was uncertain how to make this call as I was instructed in my original submission.
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        pickAnImage(sourceType: .photoLibrary)
    }
    

    @IBAction func pickAnImageFromCamera(_ sender: Any) {

        pickAnImage(sourceType: .camera)
  
    }
    
    func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller, animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if bottomText.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ImageView.contentMode = .scaleAspectFit
            ImageView.image = chosenImage
        }
        self.dismiss(animated: true, completion: nil)  // used to dismiss and go back
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func save() {
        
        // Create the meme
        let memedImage = generateMemedImage()
//        struct Meme {
//            var topText : String
//            var bottomText : String
//            var image : UIImage
//            var memedImage: UIImage
//        }
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, image: ImageView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {

        // Hide toolbar
        hideToolbars()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar
        showToolbars()
        
        return memedImage
    }
    
    func hideToolbars() {
        toolbar.isHidden = true
        topToolbar.isHidden = true
    }
    
    func showToolbars() {
        toolbar.isHidden = false
        topToolbar.isHidden = false
    }
    
    @IBAction func shareAction(_ sender: Any) {

        let memedImage = generateMemedImage() // memedImage holdes the UIImage of the new picture
  //      UIImageWriteToSavedPhotosAlbum(memedImage, nil, nil, nil); // write to camera roll
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
             activityViewController.completionWithItemsHandler = {
                (activity, success, items, error) in
                if success {
                    self.save()
                }else if (error != nil) {
                    NSLog("There was an error = \(String(describing: error))")
                }else {
                    NSLog("Issue unknown")
                }
        }
        self.present(activityViewController,animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        shareButton.isEnabled = false
        topText.text = "TOP"
        ImageView.image = nil
        bottomText.text = "BOTTOM"
    }
}

