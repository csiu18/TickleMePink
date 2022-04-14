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
        Image(uiImage: UIImage(data: item.data!)!)
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .frame(width: 970)
    }
}

struct ViewMediaView: View {
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var mediaData: FetchedResults<Media>
    
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(mediaData.indices, id: \.self) { i in
                    let item =  mediaData[i]
                    VStack {
                        ZStack (alignment: .topTrailing) {
                            VStack(spacing: 10) {
                                Text("x")
                                    .foregroundColor(Color.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.clear)
                                    .offset(x: 15, y: 45)
                                Button(action : {
                                    let alertHC = UIHostingController(rootView: MediaItemView(item: item))
                                    alertHC.view.backgroundColor = .clear
                                    alertHC.preferredContentSize = CGSize(width: 1000, height: 1000)
                                    alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                                    UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                                }) {
                                    Image(uiImage: UIImage(data: item.data!)!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(10)
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                }
                            }
                            Button(action : {
                                let alertHC = UIHostingController(rootView: ConfirmView(item: item).environment(\.managedObjectContext, viewContext))
                                alertHC.preferredContentSize = CGSize(width: 320, height: 115)
                                alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet
                                UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                            })
                            {
                                Text("x")
                                    .font(.system(size: 20.0))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black)
                                    .cornerRadius(100)
                            }.offset(x: 15, y: 45)
                        }.padding(.top, -10)
                        Button(action : {
                            let alertHC = UIHostingController(rootView: AlertView(item: item).environment(\.managedObjectContext, viewContext))
                            alertHC.preferredContentSize = CGSize(width: 500, height: 175)
                            alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet
                            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                        })
                        {
                            Text(item.name!).padding(10).padding(.top, -5).font(.system(size: 20.0)).foregroundColor(Color.black)
                        }
                    }
                }
            }
                .navigationBarTitle("View Media")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.white)
            Spacer()
        }
    }
}

struct ConfirmView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let item: Media
    
    var body: some View {
        VStack {
            Text("Are you sure you want to delete?").font(.headline).padding(.top, 20).padding(.bottom, 20)
            Divider()
            HStack {
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    let _ = viewContext.delete(item)
                    try? viewContext.save()
                }) {
                    Text("Yes").frame(width: 150, height: 30)
                }.padding(.bottom,5)
                Divider()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("No").frame(width: 150, height: 30).foregroundColor(Color.red)
                }.padding(.bottom, 5)
            }.frame(height: 40).padding(0)
            }.background(Color(white: 0.9))
    }
}

struct AlertView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var text: String = ""
    let item: Media
    
    var body: some View {
        VStack {
            Text("Rename Media").font(.headline).padding(.top, 20).padding(.bottom, 0)
            TextField("Name...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding().padding(.trailing, 10).padding(.leading, 10)
            Divider()
            HStack {
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
                    Text("Save").frame(width: 240, height: 30)
                }.padding(.bottom, 5)
                Divider()
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("Cancel").frame(width: 240, height: 30)
                }.padding(.bottom,5)
            }.frame(height: 40).padding(0)
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
