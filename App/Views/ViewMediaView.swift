//
//  View Media.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import UIKit
import AVKit

struct MediaItemView: View {
    let item: Media

    var body: some View {
        VStack() {
            Image(uiImage: UIImage(data: item.data!)!)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 10)
            Text(item.name!)
                .padding(.bottom, 10)
        }
    }
}

struct ViewMediaView: View {
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var mediaData: FetchedResults<Media>
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(mediaData.indices, id: \.self) { i in
                let item =  mediaData[i]
                let mediaName = item.name
                    ZStack {
                        NavigationLink(destination: MediaItemView(item: item)) {
                            VStack(spacing: 10) {
                                Image(uiImage: UIImage(data: item.data!)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                                Button(action : {
                                    let alertHC = UIHostingController(rootView: AlertView(item: item).environment(\.managedObjectContext, viewContext))

                                    alertHC.preferredContentSize = CGSize(width: 300, height: 175)
                                    alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                                    UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                                })
                                {
                                    Text(mediaName!)
                                    .minimumScaleFactor(0.5)
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                        Button(action : {
                            let _ = viewContext.delete(item)
                            try? viewContext.save()
                        })
                        {
                            Text("x")
                                .foregroundColor(.white)
                                .frame(width:40,height:40)
                                .background(Color.black)
                                .cornerRadius(100)
                        }.offset(x:130,y:-90)
                    }
            }
        }
        .navigationBarTitle("View Media")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        Spacer()
    }
}

struct AlertView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var text: String = ""
    @State private var showingAlert = false
    let item: Media
    
    var body: some View {
        VStack {
            Text("Enter Media Name").font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 0)

            TextField("Name...", text: $text).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            Divider()
            HStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
            
                    if (text != "") {
                        item.name = text
                        do {
                            try viewContext.save()
                        }
                        catch {
                            print("Error saving name: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Save")
                }.padding(.bottom,5)
                Spacer()
                Divider()
                Spacer()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("Cancel")
                }.padding(.bottom,5)
                Spacer()
            }
            .frame(height: 40)
            .padding(0)
            }.background(Color(white: 0.9))
    }
}

struct ViewMedia_Previews: PreviewProvider {
    static var previews: some View {
        ViewMediaView()
    }
}

// Old code
//    var body: some View {
//        LazyVGrid(columns: gridItems, spacing: 10) {
//            ForEach(mediaData.media.indices, id: \.self) { i in
//                let item =  mediaData.media[i]
//                let mediaName = String(item.dropLast(4))
//                ZStack {
//                    NavigationLink(destination: MediaItemView(name: item)) {
//                            VStack(spacing: 10) {
//                                if (item.contains(".png")) {
//                                    Image(mediaName)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: 150)
//                                        .cornerRadius(10)
//                                        .padding(.top, 10)
//                                        .padding(.bottom, 5)
//                                } else {
//                                    let path = Bundle.main.url(forResource: mediaName, withExtension: "mov")!
//                                    let aspectRatio: CGFloat = 1552 / 2880
//
//                                    GeometryReader { geo in
//                                        VideoPlayer(player: AVPlayer(url: path))
//                                            .frame( height: geo.size.width * aspectRatio)
//
//                                    }
//                                    .frame(width: 278, height: 150)
//                                    .cornerRadius(10)
//                                    .padding(.top, 10)
//                                    .padding(.bottom, 5)
//
//                                }
//                                Text(mediaName)
//                                    .minimumScaleFactor(0.5)
//                                    .padding(.bottom, 10)
//                            }
//                    }
//                    Button(action : {
//                        mediaData.media.remove(at: i)
//                        print("item deleted", i)
//                    })
//                    {
//                        Text("x")
//                            .foregroundColor(.white)
//                            .frame(width:40,height:40)
//                            .background(Color.black)
//                            .cornerRadius(100)
//                    }.offset(x:130,y:-90)
//                }
//            }
//        }
//        .navigationBarTitle("View Media")
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color.white)
//
//        Spacer()
//    }
