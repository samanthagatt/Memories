//
//  MemoryController.swift
//  Memories
//
//  Created by Samantha Gatt on 8/1/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

class MemoryController {
    
    init() {
        loadFromPersistentStore()
    }
    
    var memories: [Memory] = []
    
    // MARK: - Persistence
    
    var memoriesURL: URL? {
        let fm = FileManager.default
        let fileName = "memories.plist"
        
        guard let docDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let memoriesDir = docDir.appendingPathComponent(fileName)
        
        return memoriesDir
    }
    
    func saveToPersistentStore() {
        guard let url = memoriesURL else { return }
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(memories)
            try data.write(to: url)
        } catch  {
            NSLog("Error saving memory data: \(error)")
        }
    }
    
    func loadFromPersistentStore() {
        guard let url = memoriesURL else { return }
        let decoder = PropertyListDecoder()
        
        do {
            let memoriesData = try Data(contentsOf: url)
            let decodedMemories = try decoder.decode([Memory].self, from: memoriesData)
            
            memories = decodedMemories
        } catch {
            NSLog("Error loading memory data: \(error)")
        }
    }
    
    // MARK: - Model Controller Functions
    
    func create(title: String, body: String, imageData: Data) {
        let memory = Memory(title: title, body: body, imageData: imageData)
        memories.append(memory)
        
        saveToPersistentStore()
    }
    
    func update(memory: Memory, title: String, body: String, imageData: Data) {
        guard let index = memories.index(of: memory) else { return }
        let memoryInMemories = memories[index]
        
        if title != memoryInMemories.title {
            memories[index].title = title
        }
        if body != memoryInMemories.body {
            memories[index].body = body
        }
        if imageData != memoryInMemories.imageData {
            memories[index].imageData = imageData
        }
        
        saveToPersistentStore()
    }
    
    func delete(memory: Memory) {
        guard let index = memories.index(of: memory) else { return }
        memories.remove(at: index)
        
        saveToPersistentStore()
    }
}
