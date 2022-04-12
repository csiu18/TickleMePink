//
//  EditTrialSettings.swift
//  App
//
//  Created by Cindy Siu on 2/28/22.
//

import SwiftUI

struct EditTrialSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FetchRequest(
        entity: TrialSettings.entity(),
        sortDescriptors: [NSSortDescriptor(key: "partCondition", ascending: true)]
    ) var trialSettings: FetchedResults<TrialSettings>
    
    @State private var partCondIndex: Int = -1
    @State private var isCreateModalPresented = false
    @State private var isEditModalPresented = false
    @State private var screens: [Screen] = []
    @State private var toBeEdited: Int = -1

    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            Text("Edit Trial Settings").font(.title)
            VStack(alignment: .leading) {
                Text("Participant Condition")
                Picker("", selection: $partCondIndex) {
                    Text("Select Participant Condition...").tag(-1)
                    
                    ForEach(self.trialSettings.indices, id:\.self) { index in
                        Text(self.trialSettings[index].partCondition ?? "").tag(index)
                    }.onChange(of: self.partCondIndex) { newTrialSetting in
                        if partCondIndex != -1 {
                            self.screens = self.trialSettings[self.partCondIndex].screenToTrialSettings?.array as! [Screen]
                        } else {
                            self.screens = []
                        }
                    }
                }.padding(.bottom, 50)
            
                Text("Trial Sequence")
                ScrollView() {
                    LazyVGrid(columns:gridLayout) {
                        ForEach(self.screens.indices, id: \.self) { index in
                            if self.screens[index].type == 0{
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
                                        .scaledToFit()
                                        .frame(width: 250, height: 185)
                                        .border(Color.black, width: 2)
                                }
                            
                            }
                            Image(systemName: "arrow.right")
                        }
                        if self.partCondIndex != -1 {
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
            }
            Spacer()
            if self.partCondIndex != -1 {
                Button("Save Sequence", action: saveSequence)
            }
        }
        .padding(20)
        .modifier(ModalViewModifier(isPresented: $isCreateModalPresented,
                                    content: {CreateTrialSettingsModalView(screens: $screens, isModalPresented: $isCreateModalPresented)},
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
    
    func editScreen(toBeEdited: Int) {
        self.toBeEdited = toBeEdited
        self.isEditModalPresented = true
    }
    
    func addScreen() {
        self.isCreateModalPresented = true
    }
    
    func saveSequence() {
        if self.partCondIndex != -1 {
            let currSettings = trialSettings[self.partCondIndex]
            
            let orderedSet = NSOrderedSet(array: self.screens)
            currSettings.screenToTrialSettings = orderedSet
            
            do {
                try self.viewContext.save()
            } catch {
                print("Error in saving sequence: \(error.localizedDescription)")
            }
        }

        self.presentationMode.wrappedValue.dismiss()
    }
}


struct EditTrialSettings_Previews: PreviewProvider {
    static var previews: some View {
        EditTrialSettingsView()
    }
}
