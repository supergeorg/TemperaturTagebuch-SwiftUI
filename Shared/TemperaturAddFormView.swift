//
//  TemperaturAddFormView.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI

struct TemperaturAddFormView: View {
    @State private var temperatur: Double = 35.0
    @State private var temperaturDatum: Date = Date()
    @State private var temperaturPerson = Person()
    @State private var addToHK: Bool = false
    //    @Binding var isShown: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    #if os(iOS)
    let healthKitModel = HealthKitModel.shared
    #endif
    
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    private func saveTemperatur() {
        PersistentStore.shared.addTemperaturMessung(temperatur: temperatur, datum: temperaturDatum, person: temperaturPerson)
        #if os(iOS)
        if addToHK {
            healthKitModel.addBodyTempToHealthKit(temperature: temperatur, date: temperaturDatum, completion: {Error in
                if (Error != nil){
                    print ("Error")
                }
            })
        }
        #endif
    }
    
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
            Section(header: Text("Temperatur")){
                VStack(alignment:.leading){
                    Stepper("Temperatur: \(String(format: "%.1f", temperatur))ºC", onIncrement: {temperatur = temperatur + 0.1}, onDecrement: {temperatur = temperatur - 0.1})
                    Slider(value: $temperatur, in: 25...45, step: 0.1, minimumValueLabel: Text("25ºC"), maximumValueLabel: Text("45ºC"), label: {Text("Temperatur")})
                }
            }
            Section(header: Text("Datum")){
                DatePicker("Datum", selection: $temperaturDatum)
            }
            Section(header: Text("Person")){
                Picker(selection: $temperaturPerson, label: Text("Person auswählen"), content: {
                    ForEach(personen, id: \.id) {person in
                        Text("\(person.vorname ?? "kein Vorname") \(person.nachname ?? "kein Nachname")").tag(person)
                    }
                }).pickerStyle(SegmentedPickerStyle())
            }
            #if os(iOS)
            Section(header: Text("HealthKit")){
                Toggle("Zu HealthKit hinzufügen", isOn: $addToHK)
            }
            #endif
        }.padding()
        .navigationTitle("Temperatur hinzufügen")
        .toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Temperatur speichern") {
                    saveTemperatur()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!personen.contains(temperaturPerson))
                .keyboardShortcut(.defaultAction)
            }
        })
    }
}

struct TemperaturAddFormView_Previews: PreviewProvider {
    static var previews: some View {
        TemperaturAddFormView()
    }
}
