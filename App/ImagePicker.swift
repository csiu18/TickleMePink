//
//  ImagePicker.swift
//  App
//
//  Created by Collin Geary on 2/17/22.
//

import Foundation
import SwiftUI
 
extension View {
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
         
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
         
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
         
        // here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}
 
extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
 
struct ImagePicker: UIViewControllerRepresentable {
 
    @Environment(\.presentationMode)
    var presentationMode
 
    @Binding var image: Image?
    @Binding var url: NSURL?
 
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
        @Binding var presentationMode: PresentationMode
        @Binding var image: Image?
        @Binding var url: NSURL?
 
        init(presentationMode: Binding<PresentationMode>, image: Binding<Image?>, url: Binding<NSURL?>) {
            _presentationMode = presentationMode
            _image = image
            _url = url
        }
 
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
            let _ = print("please fuck work")
            let _ = print(imageURL)
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = Image(uiImage: uiImage)
            url = imageURL
            presentationMode.dismiss()
 
        }
        
       /* func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: NSURL) {
            let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            //let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = Image(uiImage: uiImage)
            presentationMode.dismiss()
 
        } */
 
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
 
    }
 
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image, url: $url)
    }
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
 
}
