#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

Boolean processfile(const char *path) {
	CFStringRef thePath;
	Boolean result;
	
	CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(NULL,0,NULL,NULL);
	thePath = CFStringCreateWithCString(NULL,path,kCFStringEncodingUTF8);
	if (CFStringHasSuffix(thePath, (CFStringRef)@".o")) {
		// NSLog(@"File: %@", thePath);
		result = extract(NULL, attributes, (CFStringRef)@"", thePath);
	}
	if (attributes) 
		CFRelease(attributes);
	return result;
}

int main (int argc, const char * argv[]) {
    if (argc < 2)
        return -1;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString * path = [NSString stringWithUTF8String: (const char *)argv[1]];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initWithPath:path];
	if ([fileWrapper isDirectory]) {
        NSDictionary *dirDictionary = [NSDictionary dictionary];
        [fileWrapper initDirectoryWithFileWrappers: dirDictionary];
        NSEnumerator *enumerator = [dirDictionary objectEnumerator];
        NSFileWrapper * aFile;
        while ((aFile = [enumerator nextObject])) {
            processfile([[aFile filename] UTF8String]);
        }
	} else
		processfile(argv[1]);
    [pool release];
	return 0;
}

