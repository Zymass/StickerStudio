//
//  IntroView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 08.10.2023.
//

import SwiftUI
import AuthenticationServices

/// Intro View
struct IntroView: View {
    @Binding var intro: PageIntro
    @ObservedObject var viewModel: LoginViewModel
    var size: CGSize

    init(intro: Binding<PageIntro>, size: CGSize, viewModel: ObservedObject<LoginViewModel>) {
        self._intro = intro
        self.size = size
        self._viewModel = viewModel
    }

    /// Animation Properties
    @State private var showView: Bool = false
    @State private var hideWholeView: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            /// Image View
            GeometryReader {
                let size = $0.size

                Image(intro.introAssetImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(15)
                    .frame(width: size.width, height: size.height)
            }
            /// Moving Up
            .offset(y: showView ? 0 : -size.height / 2)
            .opacity(showView ? 1 : 0)

            /// Tile & Action's
            VStack(alignment: .leading, spacing: 10) {
                Spacer(minLength: 0)

                Text(intro.title)
                    .font(.system(size: 40))
                    .fontWeight(.black)

                Text(intro.subTitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 15)

                if !intro.displaysAction {
                    Group {
                        Spacer(minLength: 25)

                        /// Custom Indicator View
                        CustomIndicatorView(totalPages: filteredPages.count, currentPage: filteredPages.firstIndex(of: intro) ?? 0)
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 10)

                        Button {
                            changeIntro()
                        } label: {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: size.width * 0.4)
                                .padding(.vertical, 15)
                                .background {
                                    Capsule()
                                        .fill(.black)
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    /// Action View
                    VStack {
                        Spacer(minLength: 10)

                        Button {
                            viewModel.events.send(.pressRegistration)
                        } label: {
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(height: 60)
                                    .foregroundStyle(Color.black)
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            /// Moving Down
            .offset(y: showView ? 0 : size.height / 2)
            .opacity(showView ? 1 : 0)
        }
        .offset(y: hideWholeView ? size.height / 2 : 0)
        .opacity(hideWholeView ? 0 : 1)
        /// Back Button
        .overlay(alignment: .topLeading) {
            /// Hiding it for Very First Page, Since there is no previous page present
            if intro != pageIntros.first {
                Button {
                    changeIntro(true)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .contentShape(Rectangle())
                }
                .padding(10)
                /// Animating Back Button
                /// Comes From Top When Active
                .offset(y: showView ? 0 : -200)
                /// Hides by Going back to Top When In Active
                .offset(y: hideWholeView ? -200 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                showView = true
            }
        }
    }

    /// Updating Page Intro's
    func changeIntro(_ isPrevious: Bool = false) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            hideWholeView = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            /// Updating Page
            if let index = pageIntros.firstIndex(of: intro), (isPrevious ? index != 0 : index != pageIntros.count - 1) {
                intro = isPrevious ? pageIntros[index - 1] : pageIntros[index + 1]
            } else {
                intro = isPrevious ? pageIntros[0] : pageIntros[pageIntros.count - 1]
            }
            /// Re-Animating as Split Page
            hideWholeView = false
            showView = false

            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showView = true
            }
        }
    }

    var filteredPages: [PageIntro] {
        return pageIntros.filter { !$0.displaysAction }
    }
}
