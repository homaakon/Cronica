//
//  AcknowledgementsSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct AboutSettings: View {
    @State private var animateEasterEgg = false
    @StateObject private var settings = SettingsStore.shared
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    var body: some View {
        Form {
            Section {
                CenterHorizontalView {
                    VStack {
                        Image("Cronica")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
                            .shadow(radius: 5)
                        Text("Developed by Alexandre Madeira")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.top)
                    }
                }
            }
            Section {
                Button {
                    openUrl("https://www.fiverr.com/akhmad437")
                } label: {
                    InformationalLabel(title: "acknowledgmentsAppIconTitle",
                                       subtitle: "acknowledgmentsAppIconSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl("https://www.themoviedb.org")
                } label: {
                    InformationalLabel(title: "acknowledgmentsContentProviderTitle",
                                       subtitle: "acknowledgmentsContentProviderSubtitle")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl("https://github.com/SDWebImage/SDWebImageSwiftUI")
                } label: {
                    InformationalLabel(title: "acknowledgmentsSDWebImage")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl("https://github.com/AvdLee/Roadmap")
                } label: {
                    InformationalLabel(title: "Roadmap")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                Button {
                    openUrl("https://telemetrydeck.com/")
                } label: {
                    InformationalLabel(title: "TelemetryDeck")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
            } 
            
            Section {
                Button {
                    openUrl("https://github.com/MadeiraAlexandre/Cronica")
                } label: {
                    InformationalLabel(title: "cronicaGitHub")
                }
#if os(macOS)
                .buttonStyle(.link)
#endif
                
            }
            
            Section {
                CenterHorizontalView {
                    Text("Version \(appVersion ?? "")")
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .onLongPressGesture {
                            settings.displayDeveloperSettings.toggle()
                        }
                }
            }
        }
        .navigationTitle("aboutTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
#if os(macOS)
        NSWorkspace.shared.open(url)
#else
        UIApplication.shared.open(url)
#endif
    }
}

struct AboutSettings_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettings()
    }
}
