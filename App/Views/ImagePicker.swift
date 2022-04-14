//
//  ImagePicker.swift
//  App
//
//  Created by Collin Geary on 3/30/22.
//

import Foundation
import SwiftUI
import AVKit


extension View {
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
         
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        //UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        let conScenes = UIApplication.shared.connectedScenes.first
        let windowSc = conScenes as? UIWindowScene
        windowSc?.keyWindow?.rootViewController?.view.addSubview(controller.view)
         
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
         
        //converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}
 
extension UIView {
//UIView to UIImage
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
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var image: Image?
    @Binding var url: NSURL?
    @Binding var isImage: Bool?
 
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
        @Binding var presentationMode: PresentationMode
        @Binding var image: Image?
        @Binding var url: NSURL?
        @Binding var isImage: Bool?
 
        init(presentationMode: Binding<PresentationMode>, image: Binding<Image?>, url: Binding<NSURL?>, isImage: Binding<Bool?>) {
            _presentationMode = presentationMode
            _image = image
            _url = url
            _isImage = isImage
        }
 
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
                if mediaType  == "public.image" {
                    url = info[UIImagePickerController.InfoKey.imageURL] as? NSURL
                    isImage = true
                }

                if mediaType == "public.movie" {
                    url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
                    isImage = false
                    
                    
                    
                    //NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
                    let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                    let videoData = NSData(contentsOf: videoURL!)
                    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    let documentsDirectory: String = paths[0]
                    let _ = print(documentsDirectory)
                   /* let today = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HHmmssEdMMMy"
                    let name = formatter.string(from: today)
                    let _ = print("NAME:")
                    let  _ = print(name)
                    let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let _ = print("CLEAN")
                    let _ = print(clean) */
                    let dataPath = documentsDirectory + "/vid2.mp4"
                    let _ = print("DATAPATH")
                    let _ = print(dataPath)
                    //let dataPath = documentsDirectory.appendingPathComponent("/vid1.mp4")
                    //url = NSURL(string:dataPath)
                    /*do {
                        try videoData!.write(to: URL(string:dataPath)!, atomically: true)
                        let input = try String(contentsOf: URL(string:dataPath)!)
                        print(input)
                    } catch {
                        print(error.localizedDescription)
                    }*/
                    videoData?.write(toFile: dataPath, atomically: false)
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    
                    
                    //NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/vid1.mp4"];
                    //BOOL success = [videoData writeToFile:tempPath atomically:NO];
                    //[picker dismissModalViewControllerAnimated:YES];
                }
            }

            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                image = Image(uiImage: uiImage)
            } else {
                let tempURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                let asset = AVAsset.init(url: tempURL)
                let generator = AVAssetImageGenerator.init(asset: asset)
                var time: CMTime = asset.duration
                time.value = 0
                let cgImage = try! generator.copyCGImage(at: time, actualTime: nil)
                let temp = UIImage(cgImage: cgImage) //firstFrame is UIImage in table cell
                image = Image(uiImage: temp)
            }
            
            presentationMode.dismiss()
 
        }
 
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
 
    }
 
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image, url: $url, isImage: $isImage)
    }
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.delegate = context.coordinator
        return picker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
 
}
