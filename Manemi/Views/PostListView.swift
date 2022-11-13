//
//  PostListView.swift
//  Manemi
//
//  Created by 1101249 on 11/13/22.
//

import SwiftUI
import FirebaseDatabase
import ComposableArchitecture

struct PostListFeature: ReducerProtocol {
    //    @Dependency
    struct State: Equatable {
        static func == (lhs: PostListFeature.State, rhs: PostListFeature.State) -> Bool {
            return lhs.encoder.userInfo.urlQueryItems == rhs.encoder.userInfo.urlQueryItems
        }
        var posts: [Post] = []
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let database = Database.database().reference().child("posts")
    }
    
    enum Action: Equatable {
        case load
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .load:
            return .task {
                
            }
            
            
//            }
//            return .none
        }
    }
}

struct PostListView: View {
    let store:StoreOf<PostListFeature>
    var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.state.posts) { post in
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.post)
                            .font(.title)
                            .bold()
                    }
                }
            }
            .onAppear {
                viewStore.send(.load)
            }
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(store:Store(initialState: PostListFeature.State(), reducer: PostListFeature()))
    }
}
