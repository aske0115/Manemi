//
//  WritePostView.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/27.
//

import SwiftUI
import ComposableArchitecture
import FirebaseStorage

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
        case onEditing(String)
        case refreshPost
        case save
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .addImage:
            state.showPicker = true
            return .none
        case .onEditing(let text):
            state.newText = text
            state.isModifying = true
            return .none
        case .refreshPost:
            return .task {
                .onEditing("")
            }
        case .save:
            return .none
        }
    }
}

struct WritePostView: View {
    @Environment(\.dismiss) private var dismiss
    let store: StoreOf<WritePostFeature>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                TextField("Enter Post",
                              text: viewStore.binding(get: { $0.newText  },
                                                      send: { .onEditing($0) }))
                .navigationBarTitle("글 올리기", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("취소")
                        .foregroundColor(.black)
                }), trailing: Button(action: {
                    
                }, label: {
                    Text("등록")
                        .foregroundColor(.black)
                }))
            }
           
        }
    }
}

struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView(store:Store(initialState: WritePostFeature.State(), reducer: WritePostFeature()))
    }
}
