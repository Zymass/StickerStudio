//
//  PromptView.swift
//  StickerStudioAISwiftUI
//
//  Created by Ilia Filiaev on 04.10.2023.
//

import SwiftUI

struct PromptField: View {
    @Binding var promts: [Prompt]

    var body: some View {
        PromptLayout(alignment: .leading) {
            ForEach($promts) { $prompt in
                PromtView(promt: $prompt, allPromts: $promts)
                    .onChange(of: prompt.value) { newValue in
                        if newValue.last == "," {
                            prompt.value.removeLast()
                            if !prompt.value.isEmpty {
                                promts.append(.init(value: ""))
                            }
                        }
                    }
            }
        }
        .clipped()
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(.bar, in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            if promts.isEmpty {
                promts.append(.init(value: "", isInitial: true))
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
            perform: { _ in
            if let lastTag = promts.last, !lastTag.value.isEmpty {
                promts.append(.init(value: "", isInitial: true))
            }
        })
    }
}

fileprivate struct PromtView: View {
    @Binding var promt: Prompt
    @Binding var allPromts: [Prompt]
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        BackSpaceListnerTextField(hint: "Tag", text: $promt.value, onBackPressed: {
            if allPromts.count > 1 {
                if promt.value.isEmpty {
                    allPromts.removeAll(where: { $0.id == promt.id })
                    if let lastIndex = allPromts.indices.last {
                        allPromts[lastIndex].isInitial = false
                    }
                }
            }
        })
        .focused($isFocused)
        .padding(.horizontal, isFocused || promt.value.isEmpty ? 0 : 10)
        .padding(.vertical, 10)
        .background(
            (colorScheme == .dark ? Color.black : Color.white).opacity(isFocused || promt.value.isEmpty ? 0 : 1),
            in: RoundedRectangle(cornerRadius: 5)
        )
        .disabled(promt.isInitial)
        .onChange(of: allPromts, perform: { newValue in
            if newValue.last?.id == promt.id && !(newValue.last?.isInitial ?? false) && !isFocused {
                isFocused = true
            }
        })
        .overlay {
            if promt.isInitial {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if allPromts.last?.id == promt.id {
                            promt.isInitial = false
                            isFocused = true
                        }
                    }
            }
        }
        .onChange(of: isFocused) { newValue in
            if !isFocused {
                promt.isInitial = true
            }
        }
    }
}

fileprivate struct BackSpaceListnerTextField: UIViewRepresentable {
    var hint: String = "Tag"
    @Binding var text: String
    var onBackPressed: () -> ()

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    func makeUIView(context: Context) -> CustomTextField {
        let textField = CustomTextField()
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(textField:)), for: .editingChanged)
        textField.onBackPressed = onBackPressed
        textField.placeholder = hint
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .clear
        return textField
    }

    func updateUIView(_ uiView: CustomTextField, context: Context) {
        uiView.text = text
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CustomTextField, context: Context) -> CGSize? {
        return uiView.intrinsicContentSize
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }

        @objc
        func textChanged(textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
    }
}

fileprivate class CustomTextField: UITextField {
    open var onBackPressed: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func deleteBackward() {
        onBackPressed?()
        super.deleteBackward()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
