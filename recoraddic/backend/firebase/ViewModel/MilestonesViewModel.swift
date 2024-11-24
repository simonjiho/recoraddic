//
//  MountainsViewModel.swift
//  recoraddic
//
//  Created by 김지호 on 1/8/25.
//



import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore



@Observable class MountainsViewModel {
    var mountains: [String:Mountain_fb] = [:]
    private var user: User?
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMountains() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        Task {
            do {
                let querySnapshot = try await userData.collection(mountainCollection).getDocuments()
                if !querySnapshot.isEmpty {
                    for queryDocument in querySnapshot.documents {
                        let mountain = try queryDocument.data(as: Mountain_fb.self)
                        guard let mountainId = mountain.id else { continue }
                        await MainActor.run {
                            self.mountains[mountainId] = mountain
                        }
                    }
                    
//                    let mountainNames = self.mountains.values.map({$0.name})
//                    for (_,elm) in self.mountains.enumerated() { // delete temporaily local generated key(from addNewMountain() )
//                        guard let tmpMountainId = elm.key == elm.value.name ? elm.key : nil else { continue }
//                        if mountainNames.count(where: {$0 == tmpMountainId}) > 1 {
//                            self.mountains.removeValue(forKey: tmpMountainId)
//                        }
//                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateAscentData(id mountainId: String, minutes: Minutes, date: YYYYMMDD) {
            if minutes != 0 {
                if self.mountains[mountainId]?.dailyAscent[date] == nil {
                    self.mountains[mountainId]?.dailyAscent[date] = minutes
                    self.mountains[mountainId]?.updateTier()
                    self.mountains[mountainId]?.updateMomentumLevel()
                }
                else {
                    self.mountains[mountainId]?.dailyAscent[date] = minutes
                }
            }
            else {
                self.mountains[mountainId]?.dailyAscent.removeValue(forKey: date)
            }

        

        self.mountains[mountainId]?.dailyAscent[date]? = minutes
    }
    
    func sendRequest_updateMountain(_ mountain: Mountain_fb) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        

//        if let mountainId = mountain.id {
        self.mountains[mountain.id!] = mountain
        do {
            try userData.collection(mountainCollection).document(mountain.id!).setData(from: mountain)
        }
        catch {
            print("Failed to add new dailyMountains. Error Message:")
            print(error.localizedDescription)
        }
//        }
//        else {
//            self.mountains[mountain.id!] = mountain
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                Task {
//                    do {
//                        guard let mountainId = try await userData.collection(mountainCollection).whereField("name", isEqualTo: prevMountain.name).whereField("createdTime", isEqualTo: prevMountain.createdTime).getDocuments().documents.first?.documentID else { return }
//                        try userData.collection(mountainCollection).document(mountainId).setData(from: mountain)
//                    
//                    } catch {
//                        print("Failed to add new dailyMountains. Error Message:")
//                        print(error.localizedDescription)
//                    }
//                }
//            
//            }
//            
//        }

    }
    
    
    func addNewMountain(_ newMountain: Mountain_fb) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        
        if self.mountains[newMountain.id!] == nil {
            self.mountains[newMountain.id!] = newMountain
        }
    
        do {
            try userData.collection(mountainCollection).document(newMountain.id!).setData(from: newMountain)
        }
        catch {
            print("Failed to add new dailyMountains. Error Message:")
            print(error.localizedDescription)
        }
        

    }
    
    func removeDailyData(_ date_str: String, _ mountainId: String) async {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ascentData = db.collection(usersDataCollection).document(uid).collection(mountainCollection).document(mountainId)
        
        do {
            try await ascentData.updateData(["dailyAscent.\(date_str)": FieldValue.delete()])
            
        } catch {
            print("failed to delete dailyAscent: \(error.localizedDescription)")
        }
        
        mountains[mountainId]?.dailyAscent[date_str] = nil
        

                
    }
    
    
    func nameOf(_ mileStoneId: String) -> String {
        return self.mountains[mileStoneId]?.name ?? ""
    }
    
    func tierOf(_ mountainId: String) -> Int {
        return self.mountains[mountainId]?.tier ?? 0
    }
    
}
