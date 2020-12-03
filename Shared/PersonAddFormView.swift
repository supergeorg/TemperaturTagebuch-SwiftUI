//
//  PersonAddFormView.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI

struct PersonAddFormView: View {
    @State private var personVorname: String = ""
    @State private var personNachname: String = ""
    //    @Binding var isShown: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        #if os(iOS)
        NavigationView{
            content
        }
        #elseif os(macOS)
        content
        #endif
    }
    
    var content: some View {
        Form {
            Section(header: Text("Persönliche Daten")){
                TextField("Vorname", text: $personVorname)
                TextField("Nachname", text: $personNachname)
            }
        }.padding()
        .navigationTitle("Person hinzufügen")
        .toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Temperatur speichern") {
                    PersistentStore.shared.addPerson(vorname: personVorname, nachname: personNachname)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!(!personVorname.isEmpty || !personNachname.isEmpty))
                .keyboardShortcut(.defaultAction)
            }
        })
    }
}

struct PersonAddFormView_Previews: PreviewProvider {
    static var previews: some View {
        PersonAddFormView()
    }
}
