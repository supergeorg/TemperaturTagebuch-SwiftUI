//
//  PersonenView.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI

struct PersonenView: View {
    let store = PersistentStore.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    #if os(iOS)
    @State private var editMode : EditMode = .inactive
    #endif
    
    @State private var showAddPerson = false
    
    var body: some View {
        #if os(iOS)
        NavigationView{
            content
                .environment(\.editMode, $editMode)
                .toolbar{
                    ToolbarItemGroup(placement: .automatic) {
                        HStack{
//                            if !personen.isEmpty {
//                                EditButton()
//                            }
                            if editMode == .inactive {
                                Button(action: {showAddPerson = true}, label: {Image(systemName: "person.crop.circle.fill.badge.plus")})
                                    .sheet(isPresented: self.$showAddPerson, content: {PersonAddFormView().environment(\.managedObjectContext, self.moc)})
                            }
                        }
                    }
                }
        }
        #elseif os(macOS)
        content
            .toolbar{
                ToolbarItem(placement: .automatic) {
                    Button(action: {showAddPerson = true}, label: {Image(systemName: "person.crop.circle.fill.badge.plus")})
                        .sheet(isPresented: self.$showAddPerson, content: {PersonAddFormView().environment(\.managedObjectContext, self.moc)})
                }
            }
        #endif
    }
    
    var content: some View {
        List{
            if personen.isEmpty {
                Text("Noch keine Person eingetragen.").padding()
            }
            ForEach(personen, id:\.id){person in
                Label("\(person.vorname ?? "kein Vorname") \(person.nachname ?? "kein Nachname")", systemImage: "person")
            }
            .onDelete(perform: delete)
            .animation(.default)
        }
        .animation(.default)
        .navigationTitle("Personen")
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            PersistentStore.shared.deletePerson(person: personen[offset])
        }
    }
}

struct PersonenView_Previews: PreviewProvider {
    static var previews: some View {
        PersonenView()
    }
}
