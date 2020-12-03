//
//  TemperaturenView.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI

struct TemperaturenView: View {
    let store = PersistentStore.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchTemperaturen()) var temperaturen: FetchedResults<TemperaturMessung>
    #if os(iOS)
    @State private var editMode : EditMode = .inactive
    #endif
    
    @State private var showAddTemperatur = false
    
    var body: some View {
        #if os(iOS)
        NavigationView{
            content
                .environment(\.editMode, $editMode)
                .toolbar{
                    ToolbarItemGroup(placement: .automatic) {
                        HStack{
//                            if !temperaturen.isEmpty {EditButton()}
                            if editMode == .inactive {
                                Button(action: {showAddTemperatur = true}, label: {Image(systemName: "text.badge.plus")})
                                    .sheet(isPresented: self.$showAddTemperatur, content: {TemperaturAddFormView().environment(\.managedObjectContext, self.moc)})
                            }
                        }
                    }
                }
        }
        #elseif os(macOS)
        content
            .toolbar{
                ToolbarItem(placement: .automatic) {
                    Button(action: {showAddTemperatur = true}, label: {Image(systemName: "text.badge.plus")})
                        .sheet(isPresented: self.$showAddTemperatur, content: {TemperaturAddFormView().environment(\.managedObjectContext, self.moc)})
                }
            }
        #endif
    }
    
    var content: some View {
        List{
            if temperaturen.isEmpty {
                Text("Noch keine Temperatur eingetragen.").padding()
            }
            ForEach(temperaturen, id:\.id){temperatur in
                HStack{
                    Text(String(format: "%.1f ºC", temperatur.temperatur)).font(.headline)
                    Divider()
                    VStack(alignment: .leading){
                        Text("\(temperatur.person?.vorname ?? "kein Vorname") \(temperatur.person?.nachname ?? "kein Nachname")").font(.body)
                        Text(formatDate(date2format: temperatur.datum)).font(.caption)
                    }
                }
            }
            .onDelete(perform: delete)
            .animation(.default)
        }
        .animation(.default)
        .navigationTitle("Temperaturen")
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            PersistentStore.shared.deleteTemperaturMessung(temperaturMessung: temperaturen[offset])
        }
    }
    
}

struct TemperaturenView_Previews: PreviewProvider {
    static var previews: some View {
        TemperaturenView()
    }
}
