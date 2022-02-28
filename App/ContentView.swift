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
                NavigationLink(destination: UploadMedia()) {
                    Text("Upload Media")
                }
                NavigationLink(destination: ViewMedia()) {
                    Text("View Media")
                }
                NavigationLink(destination: CreateTrialSettingsView()) {
                    Text("Create Trial Settings")
                }
                NavigationLink(destination: EditTrialSettings()) {
                    Text("Edit Trial Settings")
                }
                NavigationLink(destination: StartATrial()) {
                    Text("Start a Trial")
                }
                NavigationLink(destination: ExportData()) {
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