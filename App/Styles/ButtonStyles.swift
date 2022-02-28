//
//  ButtonStyles.swift
//  App
//
//  Created by Anthony Tranduc on 2/24/22.
//

import SwiftUI

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
            .background(Color(red: 0.183, green: 0.51, blue: 1))
            .foregroundColor(Color(.white))
            .cornerRadius(8.3)
    }
}
