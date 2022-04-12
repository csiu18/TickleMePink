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
        LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(mediaData.indices, id: \.self) { i in
                ZStack{
                    Button {
                        selectMedia(id: i)
                    } label: {
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
    @State private var instructions: String = ""
    @State private var selectedType: Int = 0
    @State private var selectedMediaIndex: Int = -1
    
    
    init (screens: Binding<[Screen]>, isModalPresented: Binding<Bool>) {
        self._screens = screens
        self._isModalPresented = isModalPresented
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Type of Screen:")
                Picker("", selection: $selectedType) {
                    Text("Instructions").tag(0)
                    Text("Static").tag(1)
                    Text("Interactive").tag(2)
                }.padding(.bottom, 20)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            if self.selectedType == 0 {
                TextEditor(text: $instructions)
            } else {
                MediaPreviewView(selectedMediaIndex: $selectedMediaIndex, mediaData: mediaData)
            }
            
            Spacer()
            Button("Done", action: saveScreen).padding(.top, 20)
        }
    }
    
    func saveScreen() {
        let newScreen = Screen(context: self.viewContext)
        newScreen.type = Int64(self.selectedType)
        
        if self.selectedType == 0 {
            newScreen.instructions = self.instructions
            
        } else {
            newScreen.media = self.mediaData[self.selectedMediaIndex]
        }
        
        self.screens.append(newScreen)
        self.isModalPresented = false
    }
}

struct CreateTrialSettingsModalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTrialSettingsModalView(screens: .constant([]), isModalPresented: .constant(true))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
