//
//  LibSymbolFinderAppDelegate.h
//  LibSymbolFinder
//
//  Created by Dave Carlton on 08/07/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


@interface LibSymbolFinderAppDelegate : NSObject <NSApplicationDelegate> {

	NSWindow *window;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
- (IBAction)saveAction:sender;

@end

