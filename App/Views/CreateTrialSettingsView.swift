//
//  CreateTrialSettings.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import CoreData


struct CreateTrialSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isModalPresented = false
    @State private var partCondition:String = ""
    @State private var screens:[Screen] = []
    
    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            Text("Create Trial Settings").font(.title)
            VStack(alignment: .leading) {
                Text("Participant Condition")
                TextField("", text:$partCondition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 50)
            
                Text("Trial Sequence")
                ScrollView() {
                    LazyVGrid(columns:gridLayout) {
                        ForEach(self.screens){ screen in
                            switch screen.type{
                                case 0:
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 2)
                                        .foregroundColor(Color.white)
                                        .frame(width: 250, height: 185)
                                        .overlay(Text("Instructions").foregroundColor(.black))
                                default:
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 2)
                                        .foregroundColor(Color.white)
                                        .frame(width: 250, height: 185)
                                        .overlay(Text("No Type").foregroundColor(.white))
                            
                            }
                            Image(systemName: "arrow.right")
                        }
                        Button {
                            addScreen()
                        } label: {
                            Rectangle()
                                .foregroundColor(Color(red: 0.913, green: 0.913, blue: 0.913))
                                .frame(width: 250, height: 185)
                                .overlay(Text("Add More").foregroundColor(.black))
                                                            
                        }
                    }
                }
            
            }

            Spacer()
            Button("Save Sequence", action: saveSequence)
        }
        .padding(20)
        .modifier(ModalViewModifier(isPresented: $isModalPresented,
                                    content: {CreateTrialSettingsModalView(screens: $screens, isModalPresented: $isModalPresented)},
                                    title: "Add Sequence Event"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button {
            self.viewContext.rollback()
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        })
    }
    
    
    func addScreen() {
        self.isModalPresented = true
    }
    
    func saveSequence() {
        let newSettings = TrialSettings(context: self.viewContext)
        newSettings.partCondition = self.partCondition
        do {
            try self.viewContext.save()
        } catch {
            print("Error in saving sequence: \(error.localizedDescription)")
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct CreateTrialSettings_Previews: PreviewProvider {
    static var previews: some View {
        CreateTrialSettingsView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
