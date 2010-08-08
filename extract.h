/*
 *  extract.h
 *
 *  Created by Dave on 5/10/05.
 *  Copyright 2005 PolyMicro Systems. All rights reserved.
 *
 */

#define kPublicObjectFileString @"public.object-file"

Boolean extract_object_file(void* thisInterface, 
						   CFMutableDictionaryRef attributes, 
						   CFStringRef contentTypeUTI,
						   CFStringRef pathToFile);

