////
////  dataModel.swift
////  recoraddic
////
////  Created by 김지호 on 12/27/24.
////
//
////
//// userDatasViewModel.swift
//// userDatas (iOS)
////
//// Created by Peter Friese on 24.11.22.
//// Copyright © 2021 Google LLC. All rights reserved.
////
//// Licensed under the Apache License, Version 2.0 (the "License");
//// you may not use this file except in compliance with the License.
//// You may obtain a copy of the License at
////
////      http://www.apache.org/licenses/LICENSE-2.0
////
//// Unless required by applicable law or agreed to in writing, software
//// distributed under the License is distributed on an "AS IS" BASIS,
//// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//// See the License for the specific language governing permissions and
//// limitations under the License.
//
import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
////import FirebaseFirestoreSwift
//
//
//@MainActor
@Observable class UserDataViewModel {
    

  var userData = UserData.empty

  @Published private var user: User?
  private var db = Firestore.firestore()
  private var cancellables = Set<AnyCancellable>()
    

  init() {
    registerAuthStateHandler()

    $user
      .compactMap { $0 }
      .sink { user in
        self.userData.id = user.uid
      }
      .store(in: &cancellables)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.fetchuserData()
      }
    }
  }

  func fetchuserData() {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    Task {
      do {
        let querySnapshot = try await db.collection("userDatas").whereField("userId", isEqualTo: uid).limit(to: 1).getDocuments()
        if !querySnapshot.isEmpty {
          if let userData = try querySnapshot.documents.first?.data(as: UserData.self) {
            await MainActor.run {
              self.userData = userData
            }
          }
        }
      }
      catch {
        print(error.localizedDescription)
      }
    }
      
    // 1. updat
  }

  func saveuserData() {
    do {
      if let documentId = userData.id {
        try db.collection("userDatas").document(documentId).setData(from: userData)
      }
      else {
        let documentReference = try db.collection("userDatas").addDocument(from: userData)
        print(userData)
        userData.id = documentReference.documentID
      }
    }
    catch {
      print(error.localizedDescription)
    }
  }
}
