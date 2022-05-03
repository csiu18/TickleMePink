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
   
    @State private var isCreateModalPresented = false
    @State private var isEditModalPresented = false
    @State private var insertIndex = -1
    @State private var partCondition:String = ""
    @State private var screens:[Screen] = []
    @State private var toBeEdited: Int = -1
    @State private var isPartCondSaveAlert: Bool = false
    @State private var isScreensSaveAlert: Bool = false
    
    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            Text("Create Trial Settings").font(.title)
            VStack(alignment: .leading) {
                Text("Participant Condition *")
                    .foregroundColor(self.isPartCondSaveAlert ? Color.red : Color.black)
                TextField("", text:$partCondition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: self.isPartCondSaveAlert ? 1 : 0)
                    )
                    .padding(.bottom, 50)
            
                Text("Trial Sequence")
                ScrollView() {
                    LazyVGrid(columns:gridLayout) {
                        if (self.screens.count > 0) {
                            VStack{
                                Button {
                                    addScreen(index: 0)
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color(red: 0.913, green: 0.913, blue: 0.913))
                                        .frame(width: 250, height: 185)
                                        .overlay(Text("Add More").foregroundColor(.black))
                                }
                                Text(" ")
                            }
                            Button {
                                addScreen(index: 0)
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                        }
                        ForEach(self.screens.indices, id: \.self){ index in
                            VStack{
                                if self.screens[index].type == 0 {
                                    Button {
                                        editScreen(toBeEdited: index)
                                    } label: {
                                        Rectangle()
                                            .stroke(Color.black, lineWidth: 2)
                                            .foregroundColor(Color.white)
                                            .frame(width: 250, height: 185)
                                            .overlay(Text("Instructions").foregroundColor(.black))
                                    }
                                } else {
                                    Button {
                                        editScreen(toBeEdited: index)
                                    } label: {
                                        Image(uiImage: UIImage(data: self.screens[index].media!.data!)!)
                                            .resizable()
                                            .frame(width: 250, height: 185)
                                            .border(Color.black, width: 2)
                                    }
                                }
                                Text(self.screens[index].type == 0 ? " " : self.screens[index].media!.name!)
                                    .lineLimit(1)
                            }
                            Button {
                                addScreen(index: index + 1)
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                            
                        }
                        VStack {
                            Button {
                                addScreen(index: self.screens.endIndex)
                            } label: {
                                Rectangle()
                                    .foregroundColor(Color(red: 0.913, green: 0.913, blue: 0.913))
                                    .frame(width: 250, height: 185)
                                    .overlay(Text("Add More").foregroundColor(.black))
                                                                
                            }
                            Text(" ")
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: self.isScreensSaveAlert ? 1 : 0)
                )
            }

            Spacer()
            Button("Save Sequence", action: saveSequence)
        }
        .onAppear(perform: loadDefaultScreen)
        .padding(20)
        .modifier(ModalViewModifier(isPresented: $isCreateModalPresented,
                                    content: {CreateTrialSettingsModalView(screens: $screens, isModalPresented: $isCreateModalPresented, insertIndex: $insertIndex)},
                                    title: "Add Sequence Event"))
        .modifier(ModalViewModifier(isPresented: $isEditModalPresented,
                                    content: {EditTrialSettingsModalView(screens: $screens, screenIndex: $toBeEdited, isModalPresented: $isEditModalPresented)},
                                    title: "Edit Sequence Event"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button {
            self.viewContext.rollback()
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        })
    }
    
    func loadDefaultScreen() {
        let handBackScreen = Screen(context: self.viewContext)
        handBackScreen.instructions = "Trial is complete. Please hand iPad back."
        handBackScreen.type = Int64(0)
        self.screens.append(handBackScreen)
    }
    
    func editScreen(toBeEdited: Int) {
        self.toBeEdited = toBeEdited
        self.isEditModalPresented = true
    }
    
    func addScreen(index: Int) {
        self.insertIndex = index
        self.isCreateModalPresented = true
    }
    
    func saveSequence() {
        if (self.partCondition == "") {
            self.isPartCondSaveAlert = true
        }
        if (self.screens.count == 0) {
            self.isScreensSaveAlert = true
        }
        
        if (self.isScreensSaveAlert || self.isPartCondSaveAlert) {
            return
        }
        
        self.isPartCondSaveAlert = false
        self.isScreensSaveAlert = false
        let newSettings = TrialSettings(context: self.viewContext)
        newSettings.partCondition = self.partCondition
        
        let orderedSet = NSOrderedSet(array: self.screens)
        newSettings.addToScreenToTrialSettings(orderedSet)
        
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
