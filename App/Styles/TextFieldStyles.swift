//
//  TextFieldStyles.swift
//  App
//
//  Created by Anthony Tranduc on 2/24/22.
//
import SwiftUI

struct InstructionTextFieldStyle: TextEditorStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(20)
            .cornerRadius(5)
    }
}
