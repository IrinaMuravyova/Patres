//
//  CoreDataManager.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Patres")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
     
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func getPosts() -> [Post] {
        let fetchRequest = NSFetchRequest<PostEntity>(entityName: "PostEntity")
            
        do {
            let postEntity = try mainContext.fetch(fetchRequest)
            
            return postEntity.compactMap {
                Post(from: $0)
            }
        } catch {
            print("Get posts error: \(error)")
            return []
        }
    }
    
    func createPost(with post: Post) {
        let newPostEntity = PostEntity(context: mainContext)
        newPostEntity.id = post.id
        newPostEntity.userPicture = post.userPicture
        newPostEntity.title = post.title
        newPostEntity.text = post.text
        newPostEntity.isLiked = post.isLiked
    }
    
    func update(posts: [Post], context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        
        do {
            let existingPosts = try context.fetch(fetchRequest)
            let existingPostIDs = Set(existingPosts.map { $0.id })
            
            posts.forEach { post in
                if !existingPostIDs.contains(post.id) {
                    createPost(with: post)
                }
            }
            try context.save()
        } catch {
            print("CoreData update error: \(error)")
        }
    }
    
    func deletePosts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PostEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try mainContext.execute(deleteRequest)
            try mainContext.save()
        } catch {
            print("CoreData delete error: \(error)")
        }
    }
    
     func fetchPostEntity(for postId: String) -> PostEntity? {
        let fetchRequest: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", postId)
        
        do {
            let postEntities = try mainContext.fetch(fetchRequest)
            return postEntities.first
        } catch {
            print("Error fetching post entity: \(error)")
            return nil
        }
    }

    func saveImage(_ image: UIImage, for post: Post) {
        if let postEntity = fetchPostEntity(for: post.id) {
            let imageData = image.jpegData(compressionQuality: 1.0)
            postEntity.imageData = imageData
            try? mainContext.save()
        }
    }
    
    func toggleLike(for postId: String) { 
        guard let postEntity = fetchPostEntity(for: postId) else { return }
        
        postEntity.isLiked.toggle()  
        
        do {
            try mainContext.save()
        } catch {
            print("Error saving a like: \(error)")
        }
    }
}

