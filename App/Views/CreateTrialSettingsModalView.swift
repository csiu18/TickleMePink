//
//  CreateTrialSettingsModalView.swift
//  App
//
//  Created by Anthony Tranduc on 3/14/22.
//

import SwiftUI
import CoreData

struct MediaPreviewView: View {
    @Binding var selectedMediaIndex: Int
    private var mediaData: FetchedResults<Media>
    
    init (selectedMediaIndex: Binding<Int>, mediaData: FetchedResults<Media>) {
        self._selectedMediaIndex = selectedMediaIndex
        self.mediaData = mediaData
    }
    
    private var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView() {
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(mediaData.indices, id: \.self) { i in
                    Button {
                        selectMedia(id: i)
                    } label: {
                        VStack{
                            ZStack{
                                if (!mediaData[i].isImage) {
                                    Image(systemName: "video.fill").zIndex(1)
                                        .foregroundColor(Color.white)
                                }
                                Image(uiImage: UIImage(data: mediaData[i].data!)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .border(Color.black, width: self.selectedMediaIndex == i ? 4 : 0)
                                    .cornerRadius(10)
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                              
                            }
                            Text(mediaData[i].name!)
                                .foregroundColor(Color.black)
                                .frame(height: 25)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
    
    func selectMedia(id: Int) {
        self.selectedMediaIndex = id
    }
}

struct CreateTrialSettingsModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Media.entity(), sortDescriptors: [])
        var mediaData: FetchedResults<Media>
    
    @Binding var screens: [Screen]
    @Binding var isModalPresented: Bool
    @Binding var insertIndex: Int
    @State private var isSaveAlert: Bool = false
    @State private var instructions: String = ""
    @State private var selectedType: Int = 0
    @State private var selectedMediaIndex: Int = -1
    @FocusState private var isTextFieldFocused: Bool
    
    
    init (screens: Binding<[Screen]>, isModalPresented: Binding<Bool>, insertIndex: Binding<Int>) {
        self._screens = screens
        self._isModalPresented = isModalPresented
        self._insertIndex = insertIndex
    }
    
    var body: some View {
        VStack {
            if (!isTextFieldFocused) {
                VStack(alignment: .leading) {
                    Text("Type of Screen:")
                    Picker("", selection: $selectedType) {
                        Text("Instructions").tag(0)
                        Text("Static").tag(1)
                        Text("Interactive").tag(2)
                    }
                    .padding(.bottom, 20)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if self.selectedType == 0 {
                TextEditor(text: $instructions)
                    .focused($isTextFieldFocused)
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
            Button(action: saveScreen){
                Text("Done")
                    .fontWeight(.medium)
                    .padding(7).padding(.leading, 12).padding(.trailing, 12)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }.padding(.top, 20).padding(.bottom, -10)
        }
    }
    
    func saveScreen() {
        if ((self.selectedType == 0 && self.instructions == "") ||
            (self.selectedType != 0 && self.selectedMediaIndex == -1)) {
            self.isSaveAlert = true
            return
        }
        
        let newScreen = Screen(context: self.viewContext)
        newScreen.type = Int64(self.selectedType)
        
        if self.selectedType == 0 {
            newScreen.instructions = self.instructions
        } else {
            newScreen.media = self.mediaData[self.selectedMediaIndex]
        }
        
        self.screens.insert(newScreen, at: self.insertIndex)
        
        self.isModalPresented = false
        
    }
}
