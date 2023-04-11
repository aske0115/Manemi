//
//  IntroView.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/24.
//

import SwiftUI
import ComposableArchitecture

struct IntroFeature: ReducerProtocol {
    struct State: Equatable {
        var isCompleteReadyToHome: Bool = false
        var viewOpacity = 1.00
    }
    
    enum Action: Equatable {
        case loadingComplete
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadingComplete:
            state.isCompleteReadyToHome = true
            state.viewOpacity = 0.000000
            return .none
        }
    }
}


struct IntroView: View {
    let store: StoreOf<IntroFeature>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            if viewStore.isCompleteReadyToHome {
                HomeView(store: Store(initialState: HomeTabViewFeature.State(), reducer: HomeTabViewFeature()))
            } else {
                GeometryReader { g in
                    VStack {
                        Text("Manime")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("mainTitleColor"))
                            .frame(alignment: .center)
                            .padding(.bottom, 30)
                        ProgressView()
                            .scaleEffect(1.2, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
                
                    .opacity(viewStore.viewOpacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            viewStore.send(.loadingComplete, animation: Animation.easeIn(duration: 0.8))
                        }
                    }
                    .frame(width: g.size.width, height: g.size.height)
                    .background(Color("mainColor"))
                
                }
            }
        }
        
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(store: Store(initialState: IntroFeature.State(), reducer: IntroFeature()))
    }
}
