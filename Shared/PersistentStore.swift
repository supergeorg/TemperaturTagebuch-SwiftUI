//
//  PersistentStore.swift
//  TemperaturTagebuch
//
//  Created by Georg Meissner on 21.08.20.
//

import Foundation
import CoreData

final class PersistentStore: ObservableObject {
    static let shared = PersistentStore()
    
    func fetchTemperaturen() -> NSFetchRequest<TemperaturMessung> {
        let request: NSFetchRequest<TemperaturMessung> = TemperaturMessung.fetchRequest()
        let sortDate = NSSortDescriptor(key: "datum", ascending: false)
        request.sortDescriptors = [sortDate]
        return request
    }
    
    func fetchPersonen() -> NSFetchRequest<Person> {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        let sortNachName = NSSortDescriptor(key: "nachname", ascending: true)
        let sortVorName = NSSortDescriptor(key: "vorname", ascending: true)
        request.sortDescriptors = [sortNachName, sortVorName]
        return request
    }
    
    func addPerson(vorname: String, nachname: String) {
        let entityName = "Person"
        let moc = persistentContainer.viewContext
        
        guard let personEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else {return}
        
        let newPerson = NSManagedObject(entity: personEntity, insertInto: moc)
        
        let id = UUID()
        newPerson.setValue(id, forKey: "id")
        newPerson.setValue(vorname, forKey: "vorname")
        newPerson.setValue(nachname, forKey: "nachname")
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func addTemperaturMessung(temperatur: Double, datum: Date, person: Person) {
        let entityName = "TemperaturMessung"
        let moc = persistentContainer.viewContext
        
        guard let temperaturEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else {return}
        
        let newTemp = NSManagedObject(entity: temperaturEntity, insertInto: moc)
        
        let id = UUID()
        newTemp.setValue(id, forKey: "id")
        newTemp.setValue(temperatur, forKey: "temperatur")
        newTemp.setValue(datum, forKey: "datum")
        newTemp.setValue(person, forKey: "person")
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func deletePerson(person: Person) {
        let moc = persistentContainer.viewContext
        moc.delete(person)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func deleteTemperaturMessung(temperaturMessung: TemperaturMessung) {
        let moc = persistentContainer.viewContext
        moc.delete(temperaturMessung)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TemperaturTagebuchModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
