//
//  View Media.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import UIKit

struct ViewMedia: View {
    init(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
    }
    
    var media: [String] = ["scene2-static-with-numbers", "scene2-static-without-numbers"]
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
//        List(media, id: \.self) { item in
//            NavigationLink(destination: MediaItem(name: item)) {
//                VStack(alignment: .leading, spacing: 10) {
//                    Image(item)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 150)
//                        .cornerRadius(10)
//                        .padding(.top, 10)
//                        .padding(.bottom, 5)
//                    Text(item)
//                        .minimumScaleFactor(0.5)
//                        .padding(.bottom, 10)
//                }
//            }
//        }
        LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(media, id: \.self) { item in
                NavigationLink(destination: MediaItem(name: item)) {
                    VStack(spacing: 10) {
                        Image(item)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        Text(item)
                            .minimumScaleFactor(0.5)
                            .padding(.bottom, 10)
                    }
                }
            }
        }
        .navigationBarTitle("View Media")
        .navigationBarTitleDisplayMode(.inline)
//        .edgesIgnoringSafeArea([.top, .bottom])
        .background(Color.white)
        Spacer()
    }
}

struct MediaItem: View {
    let name: String
    
    var body: some View {
        VStack() {
            Image(name)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 10)
            Text(name)
                .padding(.bottom, 10)
        }
    }
}


class ViewMediaController: UIViewController {
    fileprivate let contentView = UIHostingController(rootView: ViewMedia())
    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasSuffix(".png") {
                pictures.append(item)

            }
        }
        print(pictures)
        
        setupHC()
        setupConstraints()

      
    }
    
    fileprivate func setupHC() {
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
    }

    fileprivate func setupConstraints() {
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
