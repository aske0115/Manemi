//
//  PostContainer.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/27.
//

import SwiftUI
import ComposableArchitecture

struct TextContainerViewFeature: ReducerProtocol {
    struct State: Equatable {
        var text: String
        var isModifying = false
        var isFirstResponder = false
    }
    
    enum Action: Equatable {
        case loadData(String)
        case beginEditing
        case endEditing(String)
        case showKeyboard
        case hideKeyboard
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadData(let text):
            state.text = text
            return .task {
                .beginEditing
            }
        case .beginEditing:
            state.isModifying = true
            state.isFirstResponder = true
            return .none
        case .endEditing(let text):
            state.isModifying = false
            state.text = text
            return .task {
                .hideKeyboard
            }
        case .showKeyboard:
            state.isFirstResponder = true
            return .none
        case .hideKeyboard:
            state.isFirstResponder = false
            return .none
        }
    }
}

struct ImageContainerViewFeature: ReducerProtocol {
    struct State: Equatable {
        var image: [UIImage]
        var showPicker = false
    }
    
    enum Action: Equatable {
        case loadData([UIImage])
        case insertImage(UIImage)
        case removeImage(UIImage)
        case showPicker(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadData(let images):
            state.image = images
            return .none
        case .insertImage(let image):
            state.image.append(image)
            return .none
        case .removeImage(let image):
            state.image.removeAll { $0 == image }
            let images = state.image
            return .task {
                .loadData(images)
            }
        case .showPicker(let show):
            state.showPicker = show
            return .none
        }
    }
}

struct Container: Identifiable, Equatable, Hashable, Codable {
    var text: String?
    var image: [UIImage]? = []
    var id: UUID
    
    init(_ text: String? = nil, _ image: [UIImage]? = []) {
        self.text = text
        self.image = image
        self.id = UUID()
    }
    
    enum CondingKeys: CodingKey {
        case text
        case image
        case id
    }
    
    init(from decoder: Decoder) throws {
        let decodeContainer = try decoder.container(keyedBy: CondingKeys.self)
        
        if let text = try decodeContainer.decodeIfPresent(String.self, forKey: .text) {
            self.text = text
        }
        
        if let base64 = try decodeContainer.decodeIfPresent([String].self, forKey: .image) {
            for i in base64 {
                if let data = Data(base64Encoded: i), let image = UIImage(data: data) {
                    self.image?.append(image)
                }
            }
        }
        
        id = try decodeContainer.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var encodeContainer = encoder.container(keyedBy: CondingKeys.self)
        
        try encodeContainer.encode(text, forKey: .text)
        if let image = image {
            let datas = image.compactMap { convertImageToBase64String(from: $0) }
            try encodeContainer.encode(datas, forKey: .image)
        }
        try encodeContainer.encode(id, forKey: .id)
    }
    
    private func convertImageToBase64String (from img: UIImage?) -> String? {
        if let image = img {
            return image.jpegData(compressionQuality: 1)?.base64EncodedString()
        }
        return nil
    }
    
    func type<MetaType>() -> MetaType? {
        if text != nil {
            return Text.self as? MetaType
        }
        if image != nil , image!.isEmpty {
            return UIImage.self as? MetaType
        }
        return nil
    }
    
    var view: some View {
        return Group {
            if let image = image {
                ImageContainerView(store: Store(initialState: ImageContainerViewFeature.State(image: image), reducer: ImageContainerViewFeature()))
            }
    //        retur
    //        if let text = text {
    //                return TextContainerView(store: Store(initialState: TextContainerViewFeature.State(text: "dd"), reducer: TextContainerViewFeature()))
    //        }
            if image == nil && text == nil {
                EmptyView()
            }
        }
        
    }
    
    private struct TextContainerView: View {
        let store: StoreOf<TextContainerViewFeature>
        @Binding var text: String
        
        var body: some View {
            WithViewStore(self.store) { viewStore in
                HStack {
                    TextField(text: $text) {
                        
                    }
                        
                    Spacer()
                }
            }
        }
    }
    
    private struct ImageContainerView: View {

        let store: StoreOf<ImageContainerViewFeature>
        var body: some View {
            WithViewStore(self.store) { viewStore in
                HStack(alignment: .center) {
                    ForEach(viewStore.image, id: \.self) {
                        Image(uiImage: $0)
                            .resizable()
                            .scaledToFit()
                            .frame(width:200)
                    }
                }
                .onTapGesture {
                    viewStore.send(.showPicker(true))
                }
//                .sheet(isPresented: $showPicker) {
//                    ImagePickerView(image: $image, showPicker: $showPicker)
//                }
            }
        }
    }
}
