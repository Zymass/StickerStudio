//
//  SubscribePlanView.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 17.12.2023.
//

import SwiftUI

struct SubscribePlanView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 60)
                .foregroundStyle(CustomColors.white)
                .shadow(color: CustomColors.black, radius: 5, x: 3, y: 2)
                .padding([.leading, .trailing])

            HStack {
                Image(.basePlan)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding([.leading, .trailing])
                Text("Stickers\ngenerated: 324")
                    .font(.headline)
                    .frame(alignment: .center)
                    .padding(.trailing)

            }
        }
    }
}

#Preview {
    SubscribePlanView()
}
