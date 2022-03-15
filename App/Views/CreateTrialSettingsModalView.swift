//
//  CreateTrialSettingsModalView.swift
//  App
//
//  Created by Anthony Tranduc on 3/14/22.
//

import SwiftUI
import CoreData

struct CreateTrialSettingsModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var screens: [Screen]
    @Binding var isModalPresented: Bool
    @State private var instructions: String = ""
    @State private var selectedType: Int64 = 0
    
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
            
            switch selectedType {
                case 0:
                    TextEditor(text: $instructions)
                
                default:
                    Text("")
            }
            
            Spacer()
            Button("Done", action: saveScreen).padding(.top, 20)
        }
    }
    
    func saveScreen() {
        let newScreen = Screen(context: self.viewContext)
        newScreen.instructions = self.instructions
        newScreen.type = self.selectedType
        
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
