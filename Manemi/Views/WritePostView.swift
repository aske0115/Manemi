//
//  WritePostView.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/27.
//

import SwiftUI
import ComposableArchitecture

struct PostData: Equatable {
    var image: [UIImage]?
    var text: String?
}

struct WritePostFeature: ReducerProtocol {
    struct State: Equatable {
        static func == (lhs: WritePostFeature.State, rhs: WritePostFeature.State) -> Bool {
            return true
        }
        var isModifying: Bool = false
        var showPicker: Bool = false
        var container: [Container] = []
        var newText: String = ""
        var newImage: [UIImage] = []
    }
    
    enum Action: Equatable {
        static func == (lhs: WritePostFeature.Action, rhs: WritePostFeature.Action) -> Bool {
            return true
        }
        
        case loadContainer([Container])
        case addImage
        case beginWrite(String)
        case endWrite(PostData)
        case refreshPost
        case save
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .loadContainer(containers):
            state.container += containers
            return .none
        case .addImage:
            state.showPicker = true
            return .none
        case .beginWrite(let text):
            state.newText = state.newText + text
            state.isModifying = true
            return .none
        case let .endWrite(post):
            if post.text != nil {
                state.newText = post.text!
            }
            if post.image != nil {
                state.newImage + post.image!
            }
            state.isModifying = false
            let container = state.container
            let text = state.newText
            let images = state.newImage
//            container.append(Container(text,images))
            return .task {
                .loadContainer(container + [Container(text,images)])
            }
        case .refreshPost:
            return .task {
                .beginWrite("")
            }
        case .save:
            return .none
        }
    }
}

struct WritePostView: View {
    
    let store: StoreOf<WritePostFeature>
    @Binding var text: String
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.addImage)
                } label: {
                    Image(systemName:"plus")
                        .foregroundColor(.gray.opacity(1))
                }
                TextField("Type Here", text: $text)
            }
//            .sheet(item: viewStore.showPicker) {
//                ImagePickerView(image: viewStore.newImage, showPicker: viewStore.showPicker)
//            }
        }
    }
}

struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView(store:Store(initialState: WritePostFeature.State(), reducer: WritePostFeature()), text: "")
    }
}
