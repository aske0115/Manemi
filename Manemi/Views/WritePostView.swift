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
            return false
        }
        var isModifying: Bool = false
        var showPicker: Bool = false
        var newText: String = ""
        var newImage: [UIImage] = []
    }
    
    enum Action: Equatable {
        static func == (lhs: WritePostFeature.Action, rhs: WritePostFeature.Action) -> Bool {
            return false
        }
        
        case addImage
        case beginWrite(String)
        case refreshPost
        case save
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .addImage:
            state.showPicker = true
            return .none
        case .beginWrite(let text):
            state.newText = text
            state.isModifying = true
            return .none
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
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TextField("Enter Post",
                      text: viewStore.binding(get: { $0.newText  },
                                              send: { .beginWrite($0) }))
        }
    }
}

struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView(store:Store(initialState: WritePostFeature.State(), reducer: WritePostFeature()))
    }
}
