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
    
    @State private var partCondition: String = ""
    @State private var partCondIndex: Int = -1
    @State private var isCreateModalPresented = false
    @State private var isEditModalPresented = false
    @State private var insertIndex = -1
    @State private var screens: [Screen] = []
    @State private var toBeEdited: Int = -1
    @State private var confirmationShow: Bool = false

    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            Text("Edit Trial Settings").font(.title)
            VStack(alignment: .leading) {
                Text("Participant Condition")
                HStack {
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
                    }
                    if (self.partCondIndex != -1) {
                        Spacer()
                        Button("Delete Sequence", role: .destructive, action: {self.confirmationShow = true})
                            .confirmationDialog("Are you sure?", isPresented: $confirmationShow, titleVisibility: .visible) {
                                Button("Yes", role: .destructive, action: deleteSequence)
                            }
                    }
                }.padding(.bottom, self.partCondIndex == -1 ? 50 : 10)
                if (self.partCondIndex != -1) {
                    Text("New Participant Condition")
                    TextField("", text:$partCondition)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 50)
                }
                
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
                                        .frame(width: 250, height: 185)
                                        .border(Color.black, width: 2)
                                }
                            
                            }
                            Button {
                                addScreen(index: index + 1)
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                        }
                        if self.partCondIndex != -1 {
                            Button {
                                addScreen(index: self.screens.endIndex)
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
    
    func deleteSequence() {
        if (self.partCondIndex != -1) {
            let currSequence = self.trialSettings[self.partCondIndex]
            self.viewContext.delete(currSequence)
        }
        
        do {
            try self.viewContext.save()
        } catch {
            print("Error in deleting sequence: \(error.localizedDescription)")
        }

        self.presentationMode.wrappedValue.dismiss()
        
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
        if (self.partCondIndex != -1) {
            let currSettings = trialSettings[self.partCondIndex]
            
            let orderedSet = NSOrderedSet(array: self.screens)
            currSettings.screenToTrialSettings = orderedSet
            
            if (self.partCondition != "") {
                currSettings.partCondition = self.partCondition
            }
            
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
