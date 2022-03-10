//
//  UploadMedia.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import UIKit

struct UploadMediaView: View {
    
    // show image picker
    @State var showImagePicker: Bool = false
    
    //show selected image
    @State var selectedImage: Image? = Image("")
    
    var body: some View {
        VStack{
            // create button to select image
            Button(action: {
                self.showImagePicker.toggle()
            }, label: {
                Text("Upload Media")
            })
            
            // show image
            self.selectedImage?.resizable().scaledToFit()
            
            //show button to upload iamge
            Button(action: {
                //
            }, label: {
                Text("Save Media")
            })
        }
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker(image: self.$selectedImage)
        })
    }
}

struct UploadMedia_Previews: PreviewProvider {
    static var previews: some View {
        UploadMediaView()
    }
}

