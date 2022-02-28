//
//  PageSettingModalView.swift
//  App
//
//  Created by Anthony Tranduc on 2/17/22.
//

import SwiftUI

enum ScreenType {
    case instructions, staticpage, interactive
}

struct PageSettingModalView: View {
    @State private var selectedScreenType: ScreenType = ScreenType.instructions
    @State private var screenText: String = ""
    
    var body: some View {
        VStack{
            Text("Add Sequence Event")
            Picker("Select type of screen", selection: $selectedScreenType) {
                Text("Instructions").tag(ScreenType.instructions)
                Text("Static").tag(ScreenType.staticpage)
                Text("Interactive").tag(ScreenType.interactive)
            }.pickerStyle(WheelPickerStyle())
            
            TextEditor(text: $screenText)
                .border(Color(red: 0.424, green: 0.424, blue: 0.424))
                .cornerRadius(5)
            
            Button("Done") {
                print("Done!")
            }.buttonStyle(BlueButton())
        }.padding()
        
    }
}

struct PageSettingModalView_Previews: PreviewProvider {
    static var previews: some View {
        PageSettingModalView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
