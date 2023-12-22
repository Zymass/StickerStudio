//
//  GeneratedStickerView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI

struct GeneratedStickerView: View {
    @ObservedObject var viewModel: CreateStickerViewModel

    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .top) {
                if viewModel.isLoading {
                    LottieView(url: Bundle.main.url(
                        forResource: "loadingAnimation",
                        withExtension: "lottie"
                    )!)
                    .scaledToFit()
                    .frame(
                        height: geometry.size.width * 0.9,
                        alignment: .center
                    )
                    .background(CustomColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                    .shadow(color: CustomColors.black, radius: 5, x: 3, y: 2)
                    .padding([.leading, .trailing])
                } else {
                    viewModel.textToImage
                        .resizable()
                        .scaledToFit()
                        .frame(
                            height: geometry.size.width * 0.9,
                            alignment: .center
                        )
                        .background(CustomColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: 60))
                        .shadow(color: CustomColors.black, radius: 5, x: 3, y: 2)
                        .padding([.leading, .trailing])
                }
                HStack {
                    Spacer()
                    VStack {
                        ShareLink(
                            item: viewModel.textToImage,
                            preview: SharePreview(
                                "StickerStudio",
                                image: viewModel.textToImage
                            )) {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(CustomColors.purple)
                        }
                        Button(action: {
                            viewModel.events.send(.tapSaveImage)
                        }, label: {
                            Image(systemName: "arrow.down.to.line.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(CustomColors.purple)
                        })
                    }
                    .padding(.trailing, -4)
                }
                .padding()
            }
        })
    }
}

#Preview {
    return GeneratedStickerView(viewModel: CreateStickerViewModel())
}
