//
//  HomeView.swift
//  Manemi
//
//  Created by 1101249 on 11/5/22.
//

import SwiftUI
import ComposableArchitecture

struct HomeTabViewFeature : ReducerProtocol {
    struct State: Equatable {
        var selectionIndex: Int = 0
        var oldSelectionIndex: Int = 0
        var showActionSheet: Bool = false
    }
    
    enum Action: Equatable {
        case selectedTabIndex(Int)
        case popActionSheet
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .selectedTabIndex(let index):
            state.selectionIndex = index
            state.oldSelectionIndex = index
            return .none
        case .popActionSheet:
            state.showActionSheet.toggle()
            state.selectionIndex = state.oldSelectionIndex
            return .none
        }
    }
}

struct HomeView: View {
    
    let store: StoreOf<HomeTabViewFeature>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geo in
                ZStack {
                    TabView(selection: viewStore.binding(get: \.selectionIndex, send: HomeTabViewFeature.Action.selectedTabIndex)) {
                        AuthView(store:Store(initialState: KakaoLoginFeature.State(), reducer: KakaoLoginFeature()))
                            .tabItem {
                                Image(systemName: "house")
                                Text("홈")
                            }
                            .tag(0)
                        WritePostView(store: Store(initialState: WritePostFeature.State(), reducer: WritePostFeature()))
                            .tabItem {
                                Image(systemName: "building.2")
                                Text("회사")
                            }
                            .tag(1)
                        
                        Spacer()
                        WritePostView(store: Store(initialState: WritePostFeature.State(), reducer: WritePostFeature()))
                            .tabItem {
                                Image(systemName: "bell")
                                Text("알림")
                            }
                            .tag(2)
                        AuthView(store:Store(initialState: KakaoLoginFeature.State(), reducer: KakaoLoginFeature()))
                            .tabItem {
                                Image(systemName: "ellipsis")
                                Text("마이페이지")
                            }
                            .tag(3)
                    }
                    .onAppear {
                        UITabBar.appearance().barTintColor = .white
                    }
                    .accentColor(.red)
                    .confirmationDialog("포스트올리기", isPresented: viewStore.binding(get: \.showActionSheet, send: HomeTabViewFeature.Action.popActionSheet)) {
                        Button("Delete", role: .destructive) {
                            
                        }
                        Button("Delete2", role: .destructive) {
                           
                        }
                        Button("Delete3", role: .destructive) {
                          
                        }
                        Button("Cancel", role: .cancel) {
     
                        }
                    }
                    Button {
                        viewStore.send(.popActionSheet)
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                    }
                    .padding(.top, geo.size.height - 50)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Store(initialState: HomeTabViewFeature.State(), reducer: HomeTabViewFeature()))
    }
}
