//
//  ManemiApp.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/22.
//

import SwiftUI
import RxKakaoSDKCommon
import ComposableArchitecture

private let appKey = "058fb28645432bd3368da8d3266cd420"
@main
struct ManemiApp: App {
    
    init() {
        RxKakaoSDK.initSDK(appKey: appKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthView(store: Store(initialState: KakaoLoginFeature.State(), reducer: KakaoLoginFeature()))
        }
    }
}
