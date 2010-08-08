#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

Boolean processFile(NSString *path) {
	Boolean result;
	
	CFMutableDictionaryRef attributes; // = CFDictionaryCreateMutable(NULL,0,NULL,NULL);	
	MDItemRef ref = MDItemCreate(NULL, (CFStringRef)path);
	
	CFArrayRef a = MDItemCopyAttributeNames(ref);
	CFDictionaryRef attributesRef = MDItemCopyAttributes(ref, a);
	attributes = CFDictionaryCreateMutableCopy(NULL, (CFIndex)0,attributesRef);
	
	CFRelease(ref);
	CFRelease(a);
	result = extract_object_file(NULL, attributes, (CFStringRef)@"", (CFStringRef)path);
	if (attributes) 
		CFRelease(attributes);
	return result;
}

void processFolder(NSString * path) {
	BOOL isDir;
	NSString *file;
	NSFileManager * fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:path];
		while ((file = [dirEnumerator nextObject])) {
			file = [path stringByAppendingPathComponent:file];
			//NSLog(@"SymbolFinder testing: %@", file);
			processFolder(file);
		}
	} else
		processFile(path);
}

int main (int argc, const char * argv[]) {
    if (argc < 2)
        return -1;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString * path = [NSString stringWithUTF8String: (const char *)argv[1]];
	processFolder(path);
    [pool release];
	return 0;
}

