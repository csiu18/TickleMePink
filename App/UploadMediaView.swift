//
//  UploadMedia.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import UIKit
import CoreData
import Combine

struct UploadMediaView: View {
    //var mutArray : NSMutableArray = []
    
    // show image picker
    @State var showImagePicker: Bool = false
    
    @State var videoPicker: VideoPicker!
    
    //show selected image
    @State var selectedImage: Image? = Image("")
    
    @State var mediaURL: NSURL?
    
    // get the context
    @Environment(\.managedObjectContext) private var viewContext
    // get the fetch request
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var configs: FetchedResults<Media>
    
    var body: some View {
        VStack{
            // create button to select image
            Button(action: {
                self.showImagePicker.toggle()
            }, label: {
                Text("Upload Image")
            })
            
            // show image
            self.selectedImage?.resizable().scaledToFit()
            let _ = print("This be the URL")
            let _ = print(mediaURL)
            
            //show button to upload iamge
            Button(action: {
                let uiImage: UIImage = self.selectedImage.asUIImage()
                let imageData = uiImage.jpegData(compressionQuality: 1.0)
                //let persistenceController = PersistenceController.shared
                
                //let entityName = NSEntityDescription.entity(forEntityName: "Media", in: viewContext)
                let imageInstance = Media(context: viewContext)
                imageInstance.data = imageData
           
            }, label: {
                Text("Save Media")
            })
        }
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker(image: self.$selectedImage, url: self.$mediaURL)
        })
    }
}

struct UploadMedia_Previews: PreviewProvider {
    static var previews: some View {
        UploadMediaView()
    }
}
