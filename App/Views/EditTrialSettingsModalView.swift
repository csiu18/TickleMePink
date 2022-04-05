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
    
    @Binding var screens: [Screen]
    @Binding var screenIndex: Int
    @Binding var isModalPresented: Bool
    @State private var screen: Screen?
    @State private var instructions: String?
    @State private var screenType: Int64?
    
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
            switch self.screenType {
                case 0:
                    TextEditor(text: Binding($instructions)!)
                
                default:
                    Text("")
            }
            
            Spacer()
            Button("Done", action: saveScreen).padding(.top, 20)
        }
    }
    
    func saveScreen() {
        if self.screen != nil && self.instructions != nil {
            self.screen!.instructions = self.instructions!
        }
        
        self.isModalPresented = false
    }
}
