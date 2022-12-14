//
//  PrivacySupportSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct PrivacySupportSetting: View {
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    @State private var showPolicy = false
    var body: some View {
        Section {
            Button {
#if os(macOS)
                NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                showPolicy.toggle()
#endif
            } label: {
                Label("settingsPrivacyPolicy", systemImage: "hand.raised.fingers.spread")
            }
#if os(iOS)
            .fullScreenCover(isPresented: $showPolicy) {
                SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
            }
#elseif os(macOS)
            .buttonStyle(.link)
#endif
            NavigationLink(destination: FeedbackSettingsView()) {
                Label("settingsFeedbackTitle", systemImage: "mail")
            }
            .disabled(disableTelemetry)
            Toggle(isOn: $disableTelemetry) {
                InformationalToggle(title: "settingsDisableTelemetryTitle",
                                    subtitle: "settingsDisableTelemetrySubtitle")
            }
        } header: {
            Label("settingsPrivacySupportTitle", systemImage: "hand.wave")
        }
    }
}

struct PrivacySupportSetting_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySupportSetting()
    }
}
