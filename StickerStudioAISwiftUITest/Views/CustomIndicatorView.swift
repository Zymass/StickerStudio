//
//  CustomIndicatorView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 08.10.2023.
//

import SwiftUI

struct CustomIndicatorView: View {
    /// View Properties
    var totalPages: Int
    var currentPage: Int
    var activeTint: Color = .black
    var inActiveTint: Color = .gray.opacity(0.5)
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) {
                Circle()
                    .fill(currentPage == $0 ? activeTint : inActiveTint)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    CustomIndicatorView(totalPages: 0, currentPage: 0)
}
