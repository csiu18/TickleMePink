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
    
    @State private var partCondition:String = ""
    @State private var screens:[Int64] = []
    
    
    var body: some View {
        VStack(spacing: 20){
        Text("Create Trial Settings")
            VStack(alignment: .leading) {
                Text("Participant Condition")
                TextField("Enter Participant Condition...", text:$partCondition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 50)
            
                Text("Trial Sequence")
                
            
            }
            Spacer()
            Button("Save Sequence", action:saveSequence)
        }
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
    }
}
