/*
 *  Copyright (C) 2007 Stephen F. Booth <me@sbooth.org>
 *  All Rights Reserved
 */

#import "CoreAudioEncodeOperation.h"

#include <AudioToolbox/ExtendedAudioFile.h>

#define BUFFER_SIZE 2048u

@interface CoreAudioEncodeOperation ()
@property (copy) NSError * error;
@end

@implementation CoreAudioEncodeOperation

@synthesize inputURL = _inputURL;
@synthesize outputURL = _outputURL;
@synthesize fileType = _fileType;
@synthesize streamDescription = _streamDescription;
@synthesize propertySettings = _propertySettings;
@synthesize error = _error;

- (void) main
{
	NSAssert(nil != self.inputURL, @"self.inputURL may not be nil");
	NSAssert(nil != self.outputURL, @"self.outputURL may not be nil");

	ExtAudioFileRef inputFile = NULL;
	ExtAudioFileRef outputFile = NULL;
	
	// Open the input file for reading
	OSStatus status = ExtAudioFileOpenURL((CFURLRef)self.inputURL, &inputFile);
	if(noErr != status) {
		self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		return;
	}
	
	// Determine the input file's type (should be CDDA)
	AudioStreamBasicDescription inputStreamDescription;
	UInt32 dataSize = sizeof(inputStreamDescription);
	status = ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileDataFormat, &dataSize, &inputStreamDescription);
	if(noErr != status) {
		self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		goto cleanup;
	}
	
	// Determine the input file's channel layout (if any)
	status = ExtAudioFileGetPropertyInfo(inputFile, kExtAudioFileProperty_FileChannelLayout, &dataSize, NULL);
	if(noErr != status) {
		self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		goto cleanup;
	}
	
	__strong AudioChannelLayout *inputChannelLayout = NULL;
	if(dataSize) {
		inputChannelLayout = NSAllocateCollectable(dataSize, 0);
		if(NULL == inputChannelLayout) {
			self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOMEM userInfo:nil];
			goto cleanup;
		}
		
		status = ExtAudioFileGetProperty(inputFile, kExtAudioFileProperty_FileChannelLayout, &dataSize, inputChannelLayout);
		if(noErr != status) {
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
			goto cleanup;
		}
	}
	
	// Create the output file
	AudioStreamBasicDescription streamDescription = self.streamDescription;
	status = ExtAudioFileCreateWithURL((CFURLRef)self.outputURL, self.fileType, &streamDescription, NULL, kAudioFileFlags_EraseFile, &outputFile);
	if(noErr != status) {
		self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		goto cleanup;
	}
	
	// Set the client data format
	status = ExtAudioFileSetProperty(outputFile, kExtAudioFileProperty_ClientDataFormat, sizeof(inputStreamDescription), &inputStreamDescription);
	if(noErr != status) {
		self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
		goto cleanup;
	}
	
	// Set the client channel layout (if any)
	if(inputChannelLayout) {
		status = ExtAudioFileSetProperty(outputFile, kExtAudioFileProperty_ClientChannelLayout, sizeof(*inputChannelLayout), inputChannelLayout);
		if(noErr != status) {
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
			goto cleanup;
		}
	}
	
	// Set the converter properties
	if(self.propertySettings) {
		NSArray *propertySettings = self.propertySettings;
		status = ExtAudioFileSetProperty(outputFile, kExtAudioFileProperty_ConverterConfig, sizeof(propertySettings), &propertySettings);
		if(noErr != status) {
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
			goto cleanup;
		}
	}
	
	// Allocate the conversion buffer
	__strong int8_t *buffer = NSAllocateCollectable(BUFFER_SIZE, 0);
	if(NULL == buffer) {
		self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOMEM userInfo:nil];
		goto cleanup;
	}
	
	AudioBufferList audioBuffer;
	audioBuffer.mNumberBuffers = 1;
	audioBuffer.mBuffers[0].mNumberChannels = inputStreamDescription.mChannelsPerFrame;
	audioBuffer.mBuffers[0].mData = buffer;
	audioBuffer.mBuffers[0].mDataByteSize = BUFFER_SIZE;
	
	// Iteratively read data from the input file and write it to the output file
	for(;;) {
		audioBuffer.mBuffers[0].mDataByteSize = BUFFER_SIZE;
		
		UInt32 frameCount = (audioBuffer.mBuffers[0].mDataByteSize / inputStreamDescription.mBytesPerFrame);
		
		// Read a chunk of input
		status = ExtAudioFileRead(inputFile, &frameCount, &audioBuffer);
		if(noErr != status) {
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
			goto cleanup;
		}
		
		// If no frames were returned, conversion is finished
		if(0 == frameCount)
			break;
		
		// Write the chunk to the output file, converting as required
		status = ExtAudioFileWrite(outputFile, frameCount, &audioBuffer);
		if(noErr != status) {
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
			goto cleanup;
		}
	}
	
	// Cleanup
cleanup:
	if(inputFile) {
		status = ExtAudioFileDispose(inputFile);
		if(noErr != status)
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
	}

	if(outputFile) {
		status = ExtAudioFileDispose(outputFile);
		if(noErr != status)
			self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
	}
}

@end
