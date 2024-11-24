//
//  PresetsViewModel.swift
//  recoraddic
//
//  Created by 김지호 on 1/8/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@Observable class PresetsViewModel: ObservableObject {
    var todoPresets: [String:TodoPreset_fb] = [:]
    private var user: User?
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTodoPresets() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        Task {
            do {
                let querySnapshot = try await userData.collection(todoPresetCollection).getDocuments()
                if !querySnapshot.isEmpty {
                    for queryDocument in querySnapshot.documents {
                        let todoPreset = try queryDocument.data(as: TodoPreset_fb.self)
                        guard let todoPresetId = todoPreset.id else { continue }
                        await MainActor.run {
                            self.todoPresets[todoPresetId] = todoPreset
                        }
                    }
                    let contents = self.todoPresets.values.map({$0.content})
                    
//                    for (_,elm) in self.todoPresets.enumerated() { // delete temporaily local generated key(from addNewTodoPreset() )
//                        guard let tmpTodoPresetId = elm.key == elm.value.content ? elm.key : nil else { continue }
//                        if contents.count(where: {$0 == tmpTodoPresetId}) > 1 {
//                            self.todoPresets.removeValue(forKey: tmpTodoPresetId)
//                        }
//                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func addNewTodoPreset(_ content: String) { // local: use content as key for temporarily. Will be replaced into id generated from firestore on later fetch( i.e., fetchTodoPresets() )
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = db.collection(usersDataCollection).document(uid)
        let newTodoPreset = TodoPreset_fb(content: content)
        self.todoPresets[content] = newTodoPreset
        
        do {
            try userData.collection(todoPresetCollection).document(newTodoPreset.id!).setData(from: newTodoPreset)
//            fetchTodoPresets()
        }
        
        catch {
            print("Failed to add new todoPresets. Error Message:")
            print(error.localizedDescription)
        }
    }


}
