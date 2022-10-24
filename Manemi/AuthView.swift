//
//  AuthView.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/22.
//

import SwiftUI
import ComposableArchitecture
import RxKakaoSDKCommon
import KakaoSDKUser


extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
struct KakaoLoginFeature: ReducerProtocol {

    struct State: Equatable {
        var user: User?
        var isLogin: Bool = false
    }
    
    enum Action {
        case pressLogin
        case loginError(Error?)
        case loginSuccess(User?)
    }

    nonisolated func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .pressLogin:
            return .task {
                let error = try await requestLogin()
                if error == nil {
                    return .loginSuccess(try await user())
                } else {
                    return .loginError(error)
                }
            }
        case .loginError(let error):
            print(error as Any)
            return .none
        case .loginSuccess(let user):
            state.user = user
            state.isLogin = user != nil
            return .none
        }
    }
    
    
    private func user() async throws -> User? {
        await withCheckedContinuation {
            continuation in
            UserApi.shared.me { user, error in
                continuation.resume(returning: user)
            }
        }
    }
    
    private func requestLogin() async throws -> Error? {
        await withCheckedContinuation {
            continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauth, error in
                    continuation.resume(returning: error)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount() { oauth, error in
                    continuation.resume(returning: error)
                }
            }
        }
    }
}

struct AuthView: View {
    
    var store: StoreOf<KakaoLoginFeature>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader {g in
                VStack {
                    Spacer()
                    Text("로그인 해보거라.")
                        .foregroundColor(Color("mainTitleColor"))
                        .opacity(viewStore.isLogin ? 0 : 1)
                    Spacer()
                    if !viewStore.isLogin {
                        Button {
                            viewStore.send(.pressLogin)
                        } label: {
                            Image("kakaoLoginButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                            
                        }
                    } else {
                        Text("로그인 했다 \(viewStore.user?.kakaoAccount?.profile?.nickname ?? "")")
                            .foregroundColor(Color("mainTitleColor"))
                        if let imgURL = viewStore.user?.kakaoAccount?.profile?.profileImageUrl {
                            AsyncImage(url: imgURL)
                        }
                    }
                    Spacer()
                }
                .frame(width: g.size.width, height: g.size.height)
                .background(Color("mainColor"))
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(store: Store(initialState: KakaoLoginFeature.State(), reducer: KakaoLoginFeature()))
    }
}
