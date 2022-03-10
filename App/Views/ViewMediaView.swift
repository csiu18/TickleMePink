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
    let name: String

    var body: some View {
        let mediaName = String(name.dropLast(4))
        VStack() {
            if (name.contains("png")) {
                Image(mediaName)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 10)
            } else {
                let path = Bundle.main.url(forResource: mediaName, withExtension: "mov")!

                VideoPlayer(player: AVPlayer(url: path))
                    .scaledToFit()
                    .padding(.bottom, 10)
            }
            Text(mediaName)
                .padding(.bottom, 10)
        }
    }
}


class MediaData: ObservableObject {
    @Published var media: [String] = []
}

struct ViewMedia: View {
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
    }
    
    @EnvironmentObject var mediaData: MediaData
    
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(mediaData.media.indices, id: \.self) { i in
                let item =  mediaData.media[i]
                let mediaName = String(item.dropLast(4))
                ZStack {
                    NavigationLink(destination: MediaItemView(name: item)) {
                            VStack(spacing: 10) {
                                if (item.contains(".png")) {
                                    Image(mediaName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(10)
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                } else {
                                    let path = Bundle.main.url(forResource: mediaName, withExtension: "mov")!

                                    VideoPlayer(player: AVPlayer(url: path))
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                }
                                Text(mediaName)
                                    .minimumScaleFactor(0.5)
                                    .padding(.bottom, 10)
                            }
                    }
                    Button(action : {
                        mediaData.media.remove(at: i)
                        print("item deleted", i)
                    })
                    {
                        Text("x")
                            .foregroundColor(.white)
                            .frame(width:40,height:40)
                            .background(Color.black)
                            .cornerRadius(100)
                    }.offset(x:(item.contains(".png")) ? 130 : 70,y:-90)
                }
            }
        }
        .navigationBarTitle("View Media")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        
        Spacer()
    }
}


class ViewMediaController: UIViewController {
    var pictures = [String]()
    @IBOutlet var mediaList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // may not need this later -------------
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if (item.hasSuffix(".png") || item.hasSuffix(".mov")) {
                pictures.append(item)
            }
        }
        print(pictures)
        // -------------------------------------
        
        var temp: [String] = []
        for picture in pictures {
            temp.append(picture)
        }
        
        let mediaView = MediaData()
        mediaView.media = temp
        let contentView = UIHostingController(rootView: ViewMedia().environmentObject(mediaView))
        
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

struct ViewMediaView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewMediaController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

    }
}

struct ViewMedia_Previews: PreviewProvider {
    static var previews: some View {
        ViewMediaView()
    }
}
