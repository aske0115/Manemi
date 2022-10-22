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

@MainActor
struct KakaoLoginFeature: ReducerProtocol {
    struct State: Equatable {
        static func == (lhs: KakaoLoginFeature.State, rhs: KakaoLoginFeature.State) -> Bool {
            lhs.user?.id == rhs.user?.id && lhs.isLogin == rhs.isLogin
        }
        
        var user: User?
        var isLogin: Bool = false
    }
    
    enum Action: Equatable {
        static func == (lhs: KakaoLoginFeature.Action, rhs: KakaoLoginFeature.Action) -> Bool {
            true
        }
        
        case pressLogin
        case loginned(Bool)
        case loginError(Error)
        case loginSuccess(User?)
    }
    
    private func user() async throws -> User? {
        await withCheckedContinuation {
            continuation in
            UserApi.shared.me { user, error in
                continuation.resume(returning: user)
            }
        }
    }
    
    private func requestLogin() async throws -> Bool {
        await withCheckedContinuation {
            continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { oauth, error in
                    continuation.resume(returning: oauth != nil)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount() { oauth, error in
                    continuation.resume(returning: oauth != nil)
                }
            }
        }
    }
    
    nonisolated func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .pressLogin:
            return .task {
                .loginned(try await requestLogin())
            }
        case .loginned(let login):
            return .task {
                .loginSuccess(login ? try await user() : nil)
            }
        case .loginError(let error):
            print(error)
            return .none
        case .loginSuccess(let user):
            state.user = user
            state.isLogin = user != nil
            return .none
        }
    }
}

struct AuthView: View {
    
    var store: StoreOf<KakaoLoginFeature>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text(viewStore.isLogin ? viewStore.user?.kakaoAccount?.profile?.nickname ?? "" : "Hello, World!")
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
                    if let imgURL = viewStore.user?.kakaoAccount?.profile?.profileImageUrl {
                        AsyncImage(url: imgURL)
                    }
                }
            }
            
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(store: Store(initialState: KakaoLoginFeature.State(), reducer: KakaoLoginFeature()))
    }
}
