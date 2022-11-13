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
    struct State: Equatable {
        static func == (lhs: PostListFeature.State, rhs: PostListFeature.State) -> Bool {
            return false
        }
        var posts: [Post] = []
        var loadingComlete = false
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let database = Database.database().reference().child("posts")
    }
    
    enum Action: Equatable {
        case load
        case loadComlete([Post])
        case loadFailure
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .load:
            state.loadingComlete = false
            return .task {
                let post = try await fetchPost()
                return .loadComlete(post)
            }
        case .loadComlete(let posts):
            state.posts = posts
            state.loadingComlete = true
            return .none
        case .loadFailure:
            return .none
        }
    }
    
    private func fetchPost() async throws -> [Post] {
        await withCheckedContinuation {
            continuation in
            State().database.getData { err, snapshot in
                if let json = snapshot?.value {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
                        do {
                            let post = try JSONDecoder().decode([Post].self, from: jsonData)
                                continuation.resume(returning: post)
                        } catch (let error) {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}


struct PostListView: View {
    let store:StoreOf<PostListFeature>
    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.loadingComlete {
                List(viewStore.state.posts) { post in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(post.post)
                                .foregroundColor(.black)
                                .font(.title)
                                .bold()
                            if let images = post.images {
                                ForEach(images, id: \.self) { url in
                                    AsyncImage(url: URL(string: url)!) { result in
                                        switch result {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            } else {
                HStack{
                    Text("Loading..")
                }
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
}

struct PostListView_Previews: PreviewProvider {
    static var previews: some View {
        PostListView(store:Store(initialState: PostListFeature.State(), reducer: PostListFeature()))
    }
}
