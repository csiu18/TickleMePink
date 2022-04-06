//
//  ContentView.swift
//  TestApp
//
//  Created by Cindy Siu on 1/29/22.
//

import SwiftUI


struct ContentView: View {
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25){
                NavigationLink(destination: UploadMediaView()) {
                    Text("Upload Media").font(.title).fontWeight(.medium)
                }
                NavigationLink(destination: ViewMediaView()) {
                    Text("View Media").font(.title).fontWeight(.medium)
                }
                NavigationLink(destination: CreateTrialSettingsView()) {
                    Text("Create Trial Settings").font(.title).fontWeight(.medium)
                }
                NavigationLink(destination: EditTrialSettingsView()) {
                    Text("Edit Trial Settings").font(.title).fontWeight(.medium)
                }
                NavigationLink(destination: StartATrialView()) {
                    Text("Start a Trial").font(.title).fontWeight(.medium)
                }
                NavigationLink(destination: ExportDataView()) {
                    Text("Export Data").font(.title).fontWeight(.medium)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
