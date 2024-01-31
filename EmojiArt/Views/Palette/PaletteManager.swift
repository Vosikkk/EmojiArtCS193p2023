//
//  PaletteManager.swift
//  EmojiArt
//
//  Created by Саша Восколович on 01.02.2024.
//

import SwiftUI

struct PaletteManager: View {
    
    let stores: [PaletteStore]
    
    @State private var selectedStore: PaletteStore?
    
    
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                //              Text(store.name) // bad!!
                // this is "bad" because store is not an @ObservedObject in this View
                // instead, pass the store onto another View's @ObservedObject (as below)
                // this is not ACTUALLY a problem for PaletteStore's name var
                // because it's not @Published anyway (and furthermore is a let constant)
                // but be careful of this case where an ObservableObject
                // is passed to a View not via @ObservableObject or @EnvironmentObject
                // (it's passed to PaletteManager via an [PaletteStore])
                PaletteStoreView(store: store)
                    .tag(store)
            }
            
        } content: {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            }
            Text("Choose a store")
        } detail: {
            Text("Choose a palette")
        }
    }
}

struct PaletteStoreView: View {
    @ObservedObject var store: PaletteStore
    
    var body: some View {
        Text(store.name)
    }
}

//#Preview {
//    PaletteManager()
//}
