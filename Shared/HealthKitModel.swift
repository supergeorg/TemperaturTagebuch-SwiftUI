//
//  HealthKitModel.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import Foundation
#if os(iOS)
import HealthKit

final class HealthKitModel: ObservableObject {
    static let shared = HealthKitModel()
    @Published var healthKitAvailable: Bool = false
    
    var typesToShare : Set<HKSampleType> {
        let bodyTemp = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
        return [bodyTemp]
    }
    
    @Published private(set) var healthStore: HealthKit.HKHealthStore?
    
    init () {
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            print("Healthkit available")
            healthStore = HKHealthStore()
            healthStore?.requestAuthorization(toShare: typesToShare, read: nil, completion: {(success, error) in
                if success {
                    print("Authorisation success")
                } else {
                    print("Authorisation fail")
                }
            })
            self.healthKitAvailable = true
        } else {
            print("No Healthkit available")
        }
    }
    
    public func addBodyTempToHealthKit(temperature : Double, date: Date, completion: @escaping (Error?) -> Swift.Void) {
        
        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            fatalError("Body Temperature Type is no longer available in HealthKit")
        }
        
        let bodyTemperatureUnit:HKUnit = HKUnit.degreeCelsius()
        let bodyTemperatureQuantity = HKQuantity(unit: bodyTemperatureUnit, doubleValue: temperature)
        
        // Location 11 ist auf der Stirn
        let bodyTemperatureSample = HKQuantitySample(type: bodyTemperatureType,
                                                     quantity: bodyTemperatureQuantity,
                                                     start: date,
                                                     end: date, metadata: [HKMetadataKeyBodyTemperatureSensorLocation: 11])
        
        HKHealthStore().save(bodyTemperatureSample) { (success, error) in
            
            if let error = error {
                completion(error)
                print("Error Saving Body Temperature Sample: \(error.localizedDescription)")
            } else {
                completion(nil)
                print("Successfully saved Body Temperature Sample")
            }
        }
    }
}
#endif
