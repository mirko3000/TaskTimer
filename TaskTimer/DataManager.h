//
//  DataManager.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 20.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject


// Persistency objects
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
