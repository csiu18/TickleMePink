//
//  CreateTrialSettings.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import SwiftUI
import CoreData

struct ContextConfig<Object: NSManagedObject>: Identifiable {
    let id = UUID()
    let childContext: NSManagedObjectContext
    let object: Object
    
    init(parentContext: NSManagedObjectContext) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        object = Object(context: childContext)
    }
}


struct CreateTrialSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isModalPresented = false
    @State private var partCondition:String = ""
    @State private var screens:[Int64] = []
    
    private var gridLayout = [GridItem(.adaptive(minimum: 250))]
    
    var body: some View {
        VStack(spacing: 20){
        Text("Create Trial Settings")
            VStack(alignment: .leading) {
                Text("Participant Condition")
                TextField("Enter Participant Condition...", text:$partCondition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 50)
            
                Text("Trial Sequence")
                ScrollView() {
                    LazyVGrid(columns:gridLayout) {
                        ForEach(0..<5) { value in
                            Rectangle()
                                .foregroundColor(Color.green)
                                .frame(width: 250, height: 185)
                                .overlay(Text("\(value)").foregroundColor(.white))
                            
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
        .modifier(ModalViewModifier(isPresented: $isModalPresented,
                                    content: {CreateTrialSettingsModalView()},
                                    title: "Add Sequence Event"))
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
    }
}

struct CreateTrialSettings_Previews: PreviewProvider {
    static var previews: some View {
        CreateTrialSettingsView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
