//
//  ViewController.swift
//  Project13
//
//  Created by Yulian Gyuroff on 21.10.23.
//
import CoreImage
import UIKit

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var intensity1: UISlider!
    @IBOutlet var intensity2: UISlider!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet var intensityLabel: UILabel!
    
    @IBOutlet var intensity1Label: UILabel!
    
    @IBOutlet var intensity2Label: UILabel!
    
    
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        filterButton.setTitle("Change Filter (CISepiaTone)", for: .normal)
        intensity.isEnabled = true
        intensity1.isEnabled = false
        intensity2.isEnabled = false
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
        
        imageView.alpha = 0
        currentImage = image
        UIView.animate(withDuration: 3, delay: 0, options: [], animations: { self.imageView.alpha = 1 }){ finished in
            print("finished Fade In")
        }
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel ))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
       
        guard let actionTitle = action.title else { return }
        print(actionTitle)
        currentFilter = CIFilter(name: actionTitle)
        filterButton.setTitle("Change Filter (\(actionTitle))", for: .normal)
        setUpSliders()
        
        guard currentImage != nil else { return }
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        //setUpSliders()
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            //print("No image ! ! !")
            let ac = UIAlertController(title: "No image", message: "First get some image!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            return
            
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
//        var sliderTag = 0
//        if let slider = sender as? UISlider {
//            sliderTag =  slider.tag
//        }
        applyProcessing()
    }
    
    func setUpSliders() {
        
        /*
         CIBumpDistortion
        inputKeys.inputKeys=4
        inputKeys=["inputImage", "inputCenter", "inputRadius", "inputScale"]
        CIGaussianBlur
        inputKeys.inputKeys=2
        inputKeys=["inputImage", "inputRadius"]
        CIPixellate
        inputKeys.inputKeys=3
        inputKeys=["inputImage", "inputCenter", "inputScale"]
        CISepiaTone
        inputKeys.inputKeys=2
        inputKeys=["inputImage", "inputIntensity"]
        CITwirlDistortion
        inputKeys.inputKeys=4
        inputKeys=["inputImage", "inputCenter", "inputRadius", "inputAngle"]
        CIUnsharpMask
        inputKeys.inputKeys=3
        inputKeys=["inputImage", "inputRadius", "inputIntensity"]
        CIVignette
        inputKeys.inputKeys=3
        inputKeys=["inputImage", "inputIntensity", "inputRadius"]
         */
        
        let inputKeys = currentFilter.inputKeys
        print("inputKeys.inputKeys=\(currentFilter.inputKeys.count)")
        print("inputKeys=\(currentFilter.inputKeys)")
        if inputKeys.count == 2 {
            intensity.isEnabled = true
            intensity1.isEnabled = false
            intensity2.isEnabled = false
            intensityLabel.text = removeInputStr(input: inputKeys[1])
            intensity1Label.text = "Intensity"
            intensity2Label.text = "Intensity"
        }else if inputKeys.count == 3 {
            intensity.isEnabled = true
            intensity1.isEnabled = true
            intensity2.isEnabled = false
            intensityLabel.text = removeInputStr(input: inputKeys[1])
            intensity1Label.text = removeInputStr(input: inputKeys[2])
            intensity2Label.text = "Intensity"
        }else if inputKeys.count == 4 {
            intensity.isEnabled = true
            intensity1.isEnabled = true
            intensity2.isEnabled = true
            intensityLabel.text = removeInputStr(input: inputKeys[1])
            intensity1Label.text = removeInputStr(input: inputKeys[2])
            intensity2Label.text = removeInputStr(input: inputKeys[3])
        }else{
            intensity.isEnabled = false
            intensity1.isEnabled = false
            intensity2.isEnabled = false
            intensityLabel.text = "Intensity"
            intensity1Label.text = "Intensity"
            intensity2Label.text = "Intensity"
        }
     }
    
    func removeInputStr(input: String) -> String {
        let str = input
        if let range = str.range(of: "input") {
            let substring = str[range.upperBound...]
            return String(substring)
        }
        else {
          return "Intensity"
        }
    }
    
    func applyProcessing() {
        //let inputKeys = currentFilter.inputKeys
        
        guard currentImage != nil else { return }
        
        if currentFilter.name == "CIBumpDistortion" {
            print("I am in CIBumpDistortion")
//            currentFilter.setValue(CIVector(x: currentImage.size.width / 2,y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
            currentFilter.setValue(CIVector(x: currentImage.size.width * CGFloat(intensity.value) ,y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
            currentFilter.setValue(intensity1.value*200, forKey: kCIInputRadiusKey)
            currentFilter.setValue(intensity2.value*10, forKey: kCIInputScaleKey)
            
        }
        if currentFilter.name == "CIGaussianBlur" {
            print("I am in CIGaussianBlur")
            currentFilter.setValue(intensity.value*200, forKey: kCIInputRadiusKey)
        }
        if currentFilter.name == "CIPixellate" {
            print("I am in CIPixellate")
            currentFilter.setValue(CIVector(x: currentImage.size.width * CGFloat(intensity.value) ,y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
            currentFilter.setValue(intensity1.value*10, forKey: kCIInputScaleKey)
        }
        if currentFilter.name == "CISepiaTone" {
            print("I am in CISepiaTone")
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            
        }
        if currentFilter.name == "CITwirlDistortion" {
            print("I am in CITwirlDistortion")
            currentFilter.setValue(CIVector(x: currentImage.size.width * CGFloat(intensity.value) ,y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
            currentFilter.setValue(intensity1.value*200, forKey: kCIInputRadiusKey)
            currentFilter.setValue(intensity2.value*10, forKey: kCIInputAngleKey)
        }
        if currentFilter.name == "CIUnsharpMask" {
            print("I am in CIUnsharpMask")
            currentFilter.setValue(intensity.value*200, forKey: kCIInputRadiusKey)
            currentFilter.setValue(intensity1.value, forKey: kCIInputIntensityKey)
        }
        if currentFilter.name == "CIVignette" {
            print("I am in CIVignette")
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            currentFilter.setValue(intensity1.value*200, forKey: kCIInputRadiusKey)
            
        }
         
        print("-------------------------")
        //        if inputKeys.contains(kCIInputIntensityKey) {
//            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
//            print("kCIInputIntensityKey")
//        }
//        if inputKeys.contains(kCIInputRadiusKey) {
//            currentFilter.setValue(intensity.value*200, forKey: kCIInputRadiusKey)
//            print("kCIInputRadiusKey")
//        }
//        if inputKeys.contains(kCIInputScaleKey) {
//            currentFilter.setValue(intensity.value*10, forKey: kCIInputScaleKey)
//            print("kCIInputScaleKey")
//        }
//        if inputKeys.contains(kCIInputCenterKey) {
//            currentFilter.setValue(CIVector(x: currentImage.size.width / 2,y: currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
//            print("kCIInputCenterKey")
//        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        //currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else{
            let ac = UIAlertController(title: "Saved", message: "Your altered image had been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
}

