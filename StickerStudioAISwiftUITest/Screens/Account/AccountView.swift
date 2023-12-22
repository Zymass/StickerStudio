//
//  AccountView.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 17.12.2023.
//

import SwiftUI

struct AccountView: View {

    @ObservedObject var viewModel = AccountViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack {
                SubscribePlanView()
                    .frame(height: 160)

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(geometry.size.width * 0.4)),
                            GridItem(.fixed(geometry.size.width * 0.4))
                        ],
                        spacing: 8
                    ) {
                        ForEach(viewModel.stickerModels, id: \.id) { item in
                            AccountStickerCell(image: item.image)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    AccountView()
}
