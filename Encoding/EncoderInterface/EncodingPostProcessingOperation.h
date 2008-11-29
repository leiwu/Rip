/*
 *  Copyright (C) 2008 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import <Cocoa/Cocoa.h>

// ========================================
// KVC key names for the metadata dictionary
// ========================================
extern NSString * const		kMetadataTitleKey;					// NSString *
extern NSString * const		kMetadataAlbumTitleKey;				// NSString *
extern NSString * const		kMetadataArtistKey;					// NSString *
extern NSString * const		kMetadataAlbumArtistKey;			// NSString *
extern NSString * const		kMetadataGenreKey;					// NSString *
extern NSString * const		kMetadataComposerKey;				// NSString *
extern NSString * const		kMetadataReleaseDateKey;			// NSString *
extern NSString * const		kMetadataCompilationKey;			// NSNumber *
extern NSString * const		kMetadataTrackNumberKey;			// NSNumber *
extern NSString * const		kMetadataTrackTotalKey;				// NSNumber *
extern NSString * const		kMetadataDiscNumberKey;				// NSNumber *
extern NSString * const		kMetadataDiscTotalKey;				// NSNumber *
extern NSString * const		kMetadataLyricsKey;					// NSString *
extern NSString * const		kMetadataCommentKey;				// NSString *
extern NSString * const		kMetadataISRCKey;					// NSString *
extern NSString * const		kMetadataMCNKey;					// NSString *
extern NSString * const		kMetadataMusicBrainzIDKey;			// NSString *

// ========================================
// This value will only be present if inputURL represents a disc image
// ========================================
extern NSString * const		kTrackMetadataArrayKey;				// NSArray * of NSDictionary *

// ========================================
// An NSOperation subclass that defines the interface to be implemented by encoders
// desiring to post-process their output
// ========================================
@interface EncodingPostProcessingOperation : NSOperation
{
@protected
	NSArray *_URLs;
	NSURL *_cueSheetURL;
	NSArray *_metadata;
	NSDictionary *_settings;
	NSError *_error;
}

@property (copy) NSArray * URLs;
@property (copy) NSURL * cueSheetURL;
@property (copy) NSArray * metadata;
@property (copy) NSDictionary * settings;
@property (copy) NSError * error;

// Optional properties
@property (readonly) NSNumber * progress;

@end
