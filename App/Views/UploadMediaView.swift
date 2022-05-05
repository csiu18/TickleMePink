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
import AVKit

struct UploadMediaView: View {
    // show image picker
    @State var showImagePicker: Bool = false
    
    //show selected image
    @State var selectedImage: Image? = Image("")
    
    @State var mediaURL: NSURL?
    
    @State var type: Bool?
    
    @State var mediaPath: String?
    @State private var text: String = ""
    
    @State private var nameExistsBool: Bool = false
    
   // @State var url2: String = ""
    
    // get the context
    @Environment(\.managedObjectContext) private var viewContext
    // get the fetch request
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var configs: FetchedResults<Media>
    
    var body: some View {
        VStack{
            Text("Upload Media")
                .font(.system(size: 20.0))
                .foregroundColor(Color.black)
                .padding(.top, 30)
            
            nameExistsBool ? Text("Name already exists").foregroundColor(Color.red).padding(.bottom, -15).padding(.top, 5) : nil
            
            TextField("Name media (optional)", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding().padding(.trailing, 15).padding(.leading, 15)
            
            // create button to select image
            Button(action: {
                self.showImagePicker.toggle()
            }, label: {
                Text("Choose Media")
                    .font(.system(size: 20.0))
                    .foregroundColor(Color.black)
                    .padding(7).padding(.leading, 12).padding(.trailing, 12)
                    .background(Color(white: 0.8))
                    .cornerRadius(8)
                    
            }).padding(.bottom, 10)
            
            // show image
            self.selectedImage?.resizable().scaledToFit()

            //show button to upload iamge
            Button(action: {
                if (mediaURL != nil) {
                    nameExistsBool = nameExists(mediaData: configs, mediaName: text)
                    let uiImage: UIImage = self.selectedImage.asUIImage()
                    let imageData = uiImage.jpegData(compressionQuality: 1.0)
                    let url2: NSURL = mediaURL!
                    let mediaType: Bool = type!
                    mediaPath = url2.absoluteString
                    
                    if ((text != "" && !nameExistsBool) || text == "") {
                        let imageInstance = Media(context: viewContext)
                        imageInstance.data = imageData
                        imageInstance.name = text != "" ? text : String(mediaPath![mediaPath!.lastIndex(of: "/")!...].dropFirst(1))
                        imageInstance.isImage = mediaType
                        imageInstance.url = mediaPath
                    
                        try? viewContext.save()
                        
                        self.selectedImage = Image("")
                        text = ""
                    }
                }
            }, label: {
                Text("Save")
                    .fontWeight(.medium)
                    .padding(7).padding(.leading, 12).padding(.trailing, 12)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    
            }).padding(.bottom, 20).padding(.top, 10)
        }
        .frame(width: 800, height: 600)
        .background(Color(white: 0.95))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.25), radius: 5, x: 2, y: 3)
    
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker(image: self.$selectedImage, url: self.$mediaURL, isImage: self.$type)
        })
        .padding(.top, -50)
    }
}

struct UploadMedia_Previews: PreviewProvider {
    static var previews: some View {
        UploadMediaView()
    }
}

