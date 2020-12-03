//
//  HealthKitTestView.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import SwiftUI
#if os(iOS)
struct HealthKitTestView: View {
    @State private var showSuccessfulAlert = false
    let healthKitModel = HealthKitModel.shared
    
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchTemperaturen()) var temperaturen: FetchedResults<TemperaturMessung>
    
    var body: some View {
        List{
            if healthKitModel.healthKitAvailable {Text("HealthKit available")} else {Text("HealthKit not available")}
            ForEach(temperaturen, id:\.id){temperatur in
                Button(action: {
                        healthKitModel.addBodyTempToHealthKit(temperature: temperatur.temperatur,
                                                              date: temperatur.datum ?? Date(),
                                                              completion: {Error in
                                                                if (Error != nil){
                                                                    print ("Error")
                                                                } else {showSuccessfulAlert = true}
                                                              })
                }, label: {
                    HStack{
                        Text(String(format: "%.1f ºC", temperatur.temperatur)).font(.headline)
                        Divider()
                        VStack(alignment: .leading){
                            Text("\(temperatur.person?.vorname ?? "kein Vorname") \(temperatur.person?.nachname ?? "kein Nachname")").font(.body)
                            Text(formatDate(date2format: temperatur.datum)).font(.caption)
                        }
                    }
                }
                ).alert(isPresented: $showSuccessfulAlert) {
                    Alert(title: Text("Nachricht"), message: Text("Temperatur erfolgreich hinzugefügt"), dismissButton: .default(Text("OK!")))
                }
            }
        }
    }
}

struct HealthKitTestView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitTestView()
    }
}
#endif
