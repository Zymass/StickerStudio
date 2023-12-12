//
//  CreateStickerView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI

struct CreateStickerView: View {
    @ObservedObject var viewModel = CreateStickerViewModel()
    @State var stickerViewOpacity = 1.0
    @State var telegramButtonOpacity = 1.0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                GeneratedStickerView(viewModel: viewModel)
                    .onTapGesture {
                        print("Image pressed")
                    }
                    .opacity(stickerViewOpacity)

                Button {
                    viewModel.events.send(.exportToTelegram)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 60)
                        HStack {
                            Text("Send to Telegram")
                                .foregroundStyle(CustomColors.white)
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(CustomColors.white)
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .frame(height: 80)
                .opacity(telegramButtonOpacity)

                VStack {
                    HStack {
                        Text("Prompts")
                            .padding(.leading, 20)
                            .padding(.bottom, -10)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(CustomColors.purple)
                        Spacer()
                    }
                    PromptField(promts: $viewModel.positivePromts)
                        .padding()
                }
                
                Spacer()

                Button {
                    viewModel.events.send(.tapMainButton)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 60)
                            .foregroundStyle(CustomColors.purple)
                        HStack {
                            Text("Generate Sticker")
                                .foregroundStyle(CustomColors.white)
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "doc.text.image.fill")
                                .foregroundStyle(CustomColors.white)
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .frame(height: 100)
            }
        }
        .background(CustomColors.white)
        .onReceive(keyboardPublisher) { value in
            withAnimation(.linear(duration: 0.2)) {
                stickerViewOpacity = value ? 0 : 1
                telegramButtonOpacity = value ? 0 : 1
            }
        }
    }
}

#Preview {
    CreateStickerView()
}
