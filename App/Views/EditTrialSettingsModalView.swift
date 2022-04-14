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
    @State private var screen: Screen?
    @State private var instructions: String?
    @State private var screenType: Int64?
    @State private var selectedMediaIndex: Int = -1
    
    init (screens: Binding<[Screen]>, screenIndex: Binding<Int>, isModalPresented: Binding<Bool>) {
        self._screens = screens
        self._screenIndex = screenIndex
        self._isModalPresented = isModalPresented
        
        if screenIndex.wrappedValue != -1 {
            self._screen = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue])
            self._screenType = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue].type)
            self._instructions = State(initialValue: screens.wrappedValue[screenIndex.wrappedValue].instructions ?? "")
        }
    }
    
    var body: some View {
        VStack {
            if self.screenType == 0 {
                TextEditor(text: Binding($instructions)!)
            } else {
                MediaPreviewView(selectedMediaIndex: $selectedMediaIndex, mediaData: mediaData)
            }
            
            Spacer()
            HStack {
                Button("Done", action: saveScreen).padding(.top, 20)
                Button("Remove", role: .destructive, action: deleteScreen).padding(.top, 20)
            }
        }
    }
    
    func deleteScreen() {
        if (self.screen != nil) {
            self.viewContext.delete(self.screen!)
            self.screens.remove(at: self.screenIndex)
        }
        
        self.isModalPresented = false
    }
    
    func saveScreen() {
        if (self.screen != nil && self.screenType == 0) {
            self.screen!.instructions = self.instructions!
        } else if (self.screen != nil && self.screen!.media != nil && self.selectedMediaIndex != -1) {
            self.screen!.media = self.mediaData[self.selectedMediaIndex]
        }
        
        self.isModalPresented = false
    }
}
