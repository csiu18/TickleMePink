//
//  ModalView.swift
//  App
//
//  Created by Anthony Tranduc on 3/14/22.
//

import SwiftUI

struct ModalViewModifier<T: View>: ViewModifier {
    let modal: T
    @Binding var isPresented: Bool
    private var title: String
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> T, title: String = "") {
        self._isPresented = isPresented
        self.title = title
        modal = content()
    }
    
    func body(content: Content) -> some View {
        content.overlay(modalContent())
    }
    
    @ViewBuilder private func modalContent() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width/1.2
            let height = geometry.size.height/1.2
            
            if isPresented {
                ZStack{
                    VStack {
                        HStack {
                            Spacer()
                            Text(self.title)
                                .offset(y: 30)
                            Spacer()
                            Button {
                                closeModal()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(red: 0.446, green: 0.446, blue: 0.446))
                            }.offset(x: -20, y: 20)
                                
                        }
                        Spacer()
                        modal
                        Spacer()
                    }

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor((Color(red: 0.944, green: 0.944, blue: 0.944)))
                        .zIndex(-1)
                }
                .frame(maxWidth: width,
                       maxHeight: height,
                       alignment: .center)
                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                
            }
        }
    }
    
    private func closeModal() {
        self.isPresented = false
    }
    
}


struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear
            .modifier(ModalViewModifier(isPresented: .constant(true),
                                        content: {Text("Content")},
                                        title: "Example Modal"))
    }
}
