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
    @State private var isScreensSaveAlert: Bool = false
    @State private var isPartCondSaveAlert: Bool = false
    @State private var selectedColor = Color(red: 0.9882, green: 0.502, blue: 0.6471)
    @State private var strokeWidth: Double = 5

    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            VStack(alignment: .leading) {
                Text("Participant Condition").font(.system(size: 20.0))
                HStack {
                    Picker("", selection: $partCondIndex) {
                        Text("Select Participant Condition...").tag(-1)
                        
                        ForEach(self.trialSettings.indices, id:\.self) { index in
                            Text(self.trialSettings[index].partCondition ?? "").tag(index)
                        }.onChange(of: self.partCondIndex) { newTrialSetting in
                            if partCondIndex != -1 {
                                let settings = self.trialSettings[self.partCondIndex]
                                self.screens = settings.screenToTrialSettings?.array as! [Screen]
                                self.selectedColor = Color(red: settings.strokeRed, green: settings.strokeGreen, blue: settings.strokeBlue)
                                self.strokeWidth = settings.strokeWidth
                            } else {
                                self.screens = []
                            }
                        }
                    }
                    if (self.partCondIndex != -1) {
                        Spacer()
                        Button(role: .destructive, action: {self.confirmationShow = true}) {
                            Text("Delete Sequence")
                                .fontWeight(.medium)
                                .padding(7).padding(.leading, 12).padding(.trailing, 12)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                            .confirmationDialog("Are you sure?", isPresented: $confirmationShow, titleVisibility: .visible) {
                                Button("Yes", role: .destructive, action: deleteSequence)
                            }
                    }
                }.padding(.bottom, self.partCondIndex == -1 ? 50 : 10)
                if (self.partCondIndex != -1) {
                    Text("New Participant Condition").font(.system(size: 20.0))
                    TextField("", text:$partCondition)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: self.isPartCondSaveAlert ? 1 : 0)
                        )
                        .padding(.bottom, 50)
                }
                
                Text("Trial Sequence").font(.system(size: 20.0))
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
                        ForEach(self.screens.indices, id: \.self) { index in
                            VStack {
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
                                Text(self.screens[index].type == 0 ? " " : self.screens[index].media!.name!)
                                    .lineLimit(1)
                            }
                            Button {
                                addScreen(index: index + 1)
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                        }
                        if self.partCondIndex != -1 {
                            VStack{
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
                }.overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: self.isScreensSaveAlert ? 1 : 0)
                )
            }
            HStack {
                ColorPicker("Stroke Color", selection: $selectedColor)
                    .frame(width: 160, alignment: .leading)
                    .font(.system(size: 20.0))
                Text("Stroke Width")
                    .font(.system(size: 20.0))
                    .padding(.leading, 50).padding(.trailing, 5)
                TextField("", value: $strokeWidth, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                Spacer()
            }
            Spacer()
            if self.partCondIndex != -1 {
                Button(action: saveSequence) {
                    Text("Save Sequence")
                        .fontWeight(.medium)
                        .padding(7).padding(.leading, 12).padding(.trailing, 12)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .navigationBarTitle("Edit Trial Settings")
        .navigationBarTitleDisplayMode(.inline)
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
            if (self.screens.count == 0) {
                self.isScreensSaveAlert = true
                return
            }
            
            self.isScreensSaveAlert = false
            
            let currSettings = trialSettings[self.partCondIndex]
            
            let orderedSet = NSOrderedSet(array: self.screens)
            currSettings.screenToTrialSettings = orderedSet
            
            let partCondExists = trialSettings.firstIndex(where: {$0.partCondition == self.partCondition})
            if (partCondExists != nil) {
                self.isPartCondSaveAlert = true
                return
            }
            
            self.isPartCondSaveAlert = false
            if (self.partCondition != "") {
                currSettings.partCondition = self.partCondition
            }
            
            currSettings.strokeRed = Double(UIColor(self.selectedColor).rgba.red)
            currSettings.strokeGreen = Double(UIColor(self.selectedColor).rgba.green)
            currSettings.strokeBlue = Double(UIColor(self.selectedColor).rgba.blue)
            currSettings.strokeWidth = self.strokeWidth
            
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
