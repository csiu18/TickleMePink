//
//  ContentView.swift
//  TestApp
//
//  Created by Cindy Siu on 1/29/22.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: UploadMediaView()) {
                    Text("Upload Media")
                }
                NavigationLink(destination: ViewMediaView()) {
                    Text("View Media")
                }
                NavigationLink(destination: CreateTrialSettingsView()) {
                    Text("Create Trial Settings")
                }
                NavigationLink(destination: EditTrialSettingsView()) {
                    Text("Edit Trial Settings")
                }
                NavigationLink(destination: StartATrialView()) {
                    Text("Start a Trial")
                }
                NavigationLink(destination: ExportDataView()) {
                    Text("Export Data")
                }
            }
            .navigationTitle("Menu")
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
