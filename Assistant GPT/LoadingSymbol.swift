//
//  LoadingSymbol.swift
//  Assistant GPT
//
//  Created by Luke Drushell on 12/4/22.
//

import SwiftUI

struct LoadingSymbol: View {
    
    @State var bobs: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .foregroundColor(Color("purp"))
                .frame(width: 10, height: 10)
                .offset(y: bobs.0)
            Circle()
                .foregroundColor(Color("purp"))
                .frame(width: 10, height: 10)
                .offset(y: bobs.1)
            Circle()
                .foregroundColor(Color("purp"))
                .frame(width: 10, height: 10)
                .offset(y: bobs.2)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).repeatForever()) {
                bobs.0 = -5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation(.easeIn(duration: 0.5).repeatForever()) {
                    bobs.1 = -5
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                withAnimation(.easeIn(duration: 0.5).repeatForever()) {
                    bobs.2 = -5
                }
            })
        }
        .padding(5)
        .padding(.top, 3)
        .background(.regularMaterial)
        .cornerRadius(7)
        .padding()
        
    }
}

struct LoadingSymbol_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSymbol()
    }
}
