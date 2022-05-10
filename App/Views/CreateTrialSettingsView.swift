//
//  CreateTrialSettings.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import CoreData

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

struct CreateTrialSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FetchRequest(
        entity: TrialSettings.entity(),
        sortDescriptors: [NSSortDescriptor(key: "partCondition", ascending: true)]
    ) var trialSettings: FetchedResults<TrialSettings>
   
    @State private var isCreateModalPresented = false
    @State private var isEditModalPresented = false
    @State private var insertIndex = -1
    @State private var partCondition:String = ""
    @State private var screens:[Screen] = []
    @State private var toBeEdited: Int = -1
    @State private var isPartCondSaveAlert: Bool = false
    @State private var isScreensSaveAlert: Bool = false
    @State private var selectedColor = Color(red: 0.9882, green: 0.502, blue: 0.6471)
    @State private var strokeWidth: Double = 5
    
    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    var body: some View {
        VStack(spacing: 20){
            VStack(alignment: .leading) {
                HStack {
                    Text("Participant Condition").font(.system(size: 20.0))
                    Text("*")
                        .font(.system(size: 20.0))
                        .foregroundColor(Color.red)
                }
                TextField("", text:$partCondition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: self.isPartCondSaveAlert ? 1 : 0)
                    )
                    .padding(.bottom, 30)
            
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
                                        .overlay(Text("Add More")).font(.system(size: 20.0))
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
                                    .overlay(Text("Add More")).font(.system(size: 20.0))
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
            Button(action: saveSequence) {
                Text("Save Sequence")
                    .fontWeight(.medium)
                    .padding(7).padding(.leading, 12).padding(.trailing, 12)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .navigationBarTitle("Create Trial Settings")
        .navigationBarTitleDisplayMode(.inline)
        //.onAppear(perform: loadDefaultScreen)
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
        let partCondExists = trialSettings.firstIndex(where: {$0.partCondition == self.partCondition})
        if (self.partCondition == "" || partCondExists != nil) {
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
        newSettings.strokeRed = Double(UIColor(self.selectedColor).rgba.red)
        newSettings.strokeGreen = Double(UIColor(self.selectedColor).rgba.green)
        newSettings.strokeBlue = Double(UIColor(self.selectedColor).rgba.blue)
        newSettings.strokeWidth = self.strokeWidth
    
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
