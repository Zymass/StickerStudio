//
//  AccountStickerCell.swift
//  StickerStudioAISwiftUITest
//
//  Created by Ilia Filiaev on 17.12.2023.
//

import SwiftUI

struct AccountStickerCell: View {

    let image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    AccountStickerCell(image: Image(.proPlan))
}
