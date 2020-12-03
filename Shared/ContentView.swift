//
//  ContentView.swift
//  Shared
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI

func formatDate(date2format: Date?) -> String {
    let df = DateFormatter()
    df.locale = Locale(identifier: "de-DE")
    df.dateFormat = "E, dd.MM.yyyy, HH:mm"
    return date2format == nil ? "Fehler" : df.string(from: date2format!)
}

struct ContentView: View {
    #if os(iOS)
    @State private var tabSelection = 1
    #elseif os(macOS)
    @State private var sideBarSelection: Int? = 1
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
    
    var body: some View {
        #if os(iOS)
        TabView(selection: $tabSelection) {
            TemperaturenView().tabItem {
                VStack{
                    Image(systemName: "thermometer")
                    Text("Temperaturen")
                }
            }.tag(1)
            PersonenView().tabItem {
                VStack{
                    Image(systemName: "person.3.fill")
                    Text("Personen")
                }
            }.tag(2)
            HealthKitTestView().tabItem {
                VStack{
                    Image(systemName: "waveform.path.ecg")
                    Text("HealthKit")
                }
            }.tag(3)
        }
        #elseif os(macOS)
        NavigationView{
            List{
                NavigationLink(destination: TemperaturenView(), tag: 1, selection: $sideBarSelection) {
                    Label("Temperaturen", systemImage: "thermometer")
                }
                .tag(1)
                
                NavigationLink(destination: PersonenView(), tag: 2, selection: $sideBarSelection) {
                    Label("Personen", systemImage: "person.3.fill")
                }
                .tag(2)
            }
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            .navigationTitle("Temperatur-Tagebuch")
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
