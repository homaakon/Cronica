//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var store: SettingsStore
    @State private var showPolicy = false
    @Binding var showSettings: Bool
    @AppStorage("displayDeveloperSettings") private var displayDeveloperSettings = false
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @State private var animateEasterEgg = false
    var body: some View {
        NavigationStack {
            Form {
                // MARK: General Settings
                Section {
                    NavigationLink(destination: BehaviorSetting().environmentObject(store)) {
                        Label("settingsBehaviorTitle", systemImage: "hand.tap")
                    }
                    NavigationLink(destination: AppearanceSetting().environmentObject(store)) {
                        Label("settingsAppearanceTitle", systemImage: "moon.stars")
                    }
                    NavigationLink(destination: SyncSetting()) {
                        Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                    }
                } header: {
                    Label("settingsGeneralTitle", systemImage: "wrench.adjustable")
                }
                PrivacySupportSetting()
                if displayDeveloperSettings {
                    NavigationLink(destination: EmptyView()) {
                        Label("settingsDeveloperOptions", systemImage: "hammer")
                    }
                }
                // MARK: About Settings
                Section {
                    Button {
                        requestReview()
                    } label: {
                        Label("settingsReviewCronica", systemImage: "star.fill")
                    }
                    ShareLink("Share App", item: URL(string: "https://apple.co/3TV9SLP")!)
                    CenterHorizontalView {
                        Text("Made in Brazil 🇧🇷")
                            .onTapGesture {
                                Task {
                                    withAnimation {
                                        self.animateEasterEgg.toggle()
                                    }
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    withAnimation {
                                        self.animateEasterEgg.toggle()
                                    }
                                }
                            }
                            .onLongPressGesture(perform: {
                                displayDeveloperSettings.toggle()
                            })
                            .font(animateEasterEgg ? .title3 : .caption)
                            .foregroundColor(animateEasterEgg ? .green : nil)
                            .animation(.easeInOut, value: animateEasterEgg)
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Done") {
                        showSettings.toggle()
                    }
                })
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    @StateObject private static var settings = SettingsStore()
    @State private static var showSettings = false
    static var previews: some View {
        SettingsView(showSettings: $showSettings)
            .environmentObject(settings)
    }
}



struct BehaviorSetting: View {
    @EnvironmentObject var store: SettingsStore
    @AppStorage("openInYouTube") private var openInYouTube = false
    @AppStorage("markEpisodeWatchedTap") private var markEpisodeWatchedOnTap = false
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.gesture) {
                    ForEach(DoubleTapGesture.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    InformationalToggle(title: "behaviorDoubleTapTitle",
                                        subtitle: "behaviorDoubleTapSubtitle")
                }
                Toggle(isOn: $markEpisodeWatchedOnTap) {
                    InformationalToggle(title: "behaviorEpisodeTitle")
                }
            } header: {
                Label("behaviorGestureTitle", systemImage: "hand.tap")
            }
            Section {
                Toggle(isOn: $openInYouTube) {
                    InformationalToggle(title: "behaviorYouTubeTitle")
                }
            } header: {
                Label("behaviorLinkTitle", systemImage: "link")
            }
        }
        .navigationTitle("behaviorTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

