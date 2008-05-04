/*
 *  Copyright (C) 2007 - 2008 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DASession.h>

@class PlugInManager, EncoderManager;

@interface ApplicationDelegate : NSObject
{
@private
	DASessionRef _diskArbitrationSession;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
	NSManagedObjectModel *_managedObjectModel;
	NSManagedObjectContext *_managedObjectContext;
	PlugInManager *_plugInManager;
	EncoderManager *_encoderManager;
}

// File and folder locations
@property (readonly) NSURL * applicationSupportFolderURL;
@property (readonly) NSURL * applicationLogFileURL;

// Core Data
@property (readonly, assign) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (readonly, assign) NSManagedObjectModel * managedObjectModel;
@property (readonly, assign) NSManagedObjectContext * managedObjectContext;

// Managers
@property (readonly, assign) PlugInManager * plugInManager;
@property (readonly, assign) EncoderManager * encoderManager;

// Save changes to the main NSManagedObjectContext
- (IBAction) saveAction:(id)sender;

@end