//
//  ViewController.swift
//  Project 13
//
//  Created by Христина Мізинюк on 24.03.2023.
//
import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var changeFilter: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var filterIntensity: UISlider!
    @IBOutlet var filter: UILabel!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
        
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISharpenLuminance", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBloom", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    func applyProcessing() {
        var inputKeys = currentFilter.inputKeys
        for key in inputKeys {
            var filtres = Filtres(rawValue: key)
            switch filtres {
            case.inputIntensity:
                currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            case.inputTypeScalar:
                currentFilter.setValue(intensity.value, forKey: kCIAttributeTypeScalar)
            case.inputRadius:
                currentFilter.setValue(intensity.value * 400, forKey: kCIInputRadiusKey)
            case.inputScale:
                currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
            case.inputSharpness:
                currentFilter.setValue(intensity.value * 50, forKey: kCIInputSharpnessKey)
            case.inputCenter:
                currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            case .none:
                break
            }
        }
        
        enum Filtres: String {
            case inputIntensity
            case inputTypeScalar
            case inputRadius
            case inputScale
            case inputSharpness
            case inputCenter
        }

            guard let outputImage = currentFilter.outputImage else { return }
            
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgImage)
                imageView.image = processedImage
            }
        }
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            } else {
                let ac = UIAlertController(title: "Saved!", message: "New image has been saved to your photos", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
            }
            
        }
        
        @IBAction func filterIntensityChanged(_ sender: Any) {
            
        }
    }

        
