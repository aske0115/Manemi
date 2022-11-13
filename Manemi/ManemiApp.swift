//
//  ManemiApp.swift
//  Manemi
//
//  Created by GeunHwa Lee on 2022/10/22.
//

import SwiftUI
import RxKakaoSDKCommon
import ComposableArchitecture
import FirebaseCore

private let appKey = "058fb28645432bd3368da8d3266cd420"

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ManemiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        RxKakaoSDK.initSDK(appKey: appKey)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(store: Store(initialState: HomeTabViewFeature.State(), reducer: HomeTabViewFeature()))
        }
    }
}
