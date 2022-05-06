//
//  EditTrialSettingsModalView.swift
//  App
//
//  Created by Anthony Tranduc on 4/5/22.
//

import SwiftUI
import CoreData

struct EditTrialSettingsModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var mediaData: FetchedResults<Media>
    
    @Binding var screens: [Screen]
    @Binding var screenIndex: Int
    @Binding var isModalPresented: Bool
    @State private var isSaveAlert: Bool = false
    @State private var screen: Screen?
    @State private var instructions: String?
    @State private var screenType: Int64?
    @State private var selectedMediaIndex: Int = -1
    
    init (screens: Binding<[Screen]>, screenIndex: Binding<Int>, isModalPresented: Binding<Bool>) {
        self._screens = screens
        self._screenIndex = screenIndex
        self._isModalPresented = isModalPresented
        
        if (screenIndex.wrappedValue < screens.wrappedValue.count
            && screenIndex.wrappedValue != -1) {
            self._screen = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue])
            self._screenType = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue].type)
            self._instructions = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue].instructions ?? "")
        }
    }
    
    var body: some View {
        VStack {
            if self.screenType == 0 {
                TextEditor(text: Binding($instructions)!)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: self.isSaveAlert ? 1 : 0))

            } else {
                MediaPreviewView(selectedMediaIndex: $selectedMediaIndex, mediaData: mediaData)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: self.isSaveAlert ? 1 : 0))
            }
            
            Spacer()
            HStack {
                Button(action: saveScreen) {
                    Text("Done")
                        .fontWeight(.medium)
                        .padding(7).padding(.leading, 12).padding(.trailing, 12)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }.padding(.top, 20).padding(.bottom, -10).padding(.trailing, 10)
                Button(role: .destructive, action: deleteScreen) {
                    Text("Remove")
                        .fontWeight(.medium)
                        .padding(7).padding(.leading, 12).padding(.trailing, 12)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }.padding(.top, 20).padding(.bottom, -10)
            }
        }.onAppear(perform: loadMediaIndex)
    }
    
    func loadMediaIndex() {
        if (self.screenType != 0) {
//            let mediaIndex = self.mediaData.firstIndex(where: {$0.name == self.screens[self.screenIndex].media!.name ?? ""}) ?? -1
            let mediaIndex = self.mediaData.firstIndex(of: self.screens[self.screenIndex].media!) ?? -1
            self.selectedMediaIndex = mediaIndex
        }
        
    }
    
    func deleteScreen() {
        if (self.screen != nil) {
            self.screens.remove(at: self.screenIndex)
            self.viewContext.delete(self.screen!)
        }
        
        self.isModalPresented = false
    }
    
    func saveScreen() {
        if ((self.screenType == 0 && self.instructions == "") ||
            (self.screenType != 0 && self.selectedMediaIndex == -1)) {
            self.isSaveAlert = true
            return
        }
        
        if (self.screen != nil && self.screenType == 0) {
            self.screen!.instructions = self.instructions!
        } else if (self.screen != nil && self.screen!.media != nil && self.selectedMediaIndex != -1) {
            self.screen!.media = self.mediaData[self.selectedMediaIndex]
        }
        
        self.isModalPresented = false
    }
}
