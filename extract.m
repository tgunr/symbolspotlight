#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#include <Foundation/Foundation.h>
#include <stdio.h>
#include <syslog.h>
#include "cbt/libsyminfo.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

void
SymInfoPrintSymbol(SymInfoSymbol symbol)
{
	if(symbol == NULL){
	    printf("Null symbol, not doing a thing\n");
	    return;
	}
	NSLog(@"symbol name: %s\n", SymInfoGetSymbolName(symbol));
	NSLog(@"symbol arch: %s\n", SymInfoGetSymbolArch(symbol));
	NSLog(@"symbol ordinal: %s\n", SymInfoGetSymbolOrdinal(symbol));
}


NSString *
SymInfoAsLine(SymInfoSymbol symbol)
{
	if(symbol == NULL){
	    printf("Null symbol, not doing a thing\n");
	    return NULL;
	}
	NSString *theString = [[[NSMutableString alloc] initWithCString:SymInfoGetSymbolName(symbol) encoding:NSUTF8StringEncoding] autorelease];
	theString = [theString stringByAppendingString:@" "];
	return theString;
}


Boolean extract(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
    
	Boolean success=FALSE;
	FILE * fh = NULL;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableString *exportSymbols = [[NSMutableString alloc] init];
	NSMutableString *importSymbols = [[NSMutableString alloc] init];
	SymInfoList nmList;
	char path[4096];
	SymInfoSymbol * symImports;
	SymInfoSymbol * symExports;
	SymInfoDependencies symLibInfo;
	
    if (CFStringHasSuffix(pathToFile, (CFStringRef)@".o") || 
		CFStringHasSuffix(pathToFile, (CFStringRef)@".a") ||
		CFStringHasSuffix(pathToFile, (CFStringRef)@".dylib") ) {
		NSLog(@"LibSpotlight: %@", pathToFile);
		if (CFStringGetCString(pathToFile, path, 4096, kCFStringEncodingUTF8)) {
			fh = fopen(path, "r");
			if (fh) {
				fclose(fh);
				nmList = SymInfoCreate(path);
				if (nmList) {
					unsigned int symInfoExportCount = SymInfoGetExportCount(nmList);
					unsigned int symInfoImportCount = SymInfoGetImportCount(nmList);
					symExports = SymInfoGetExports(nmList);
					symImports = SymInfoGetImports(nmList);
					uint32_t i;
					for(i = 0; i < symInfoExportCount; i++)
						[exportSymbols appendString:SymInfoAsLine(symExports[i])];
					
					for(i = 0; i < symInfoImportCount; i++)
						[importSymbols appendString:SymInfoAsLine(symImports[i])];
					
					symLibInfo = SymInfoGetLibraryInfo(nmList);
					//			char * symInfoName = SymInfoGetSymbolName(symImports);
					//			const char * symInfoArch = SymInfoGetSymbolArch(symImports);
					//			char * symInfoOrdinal = SymInfoGetSymbolOrdinal(symImports);
					[(NSMutableDictionary *)attributes setObject:(NSString *) pathToFile forKey:@"com_polymicrosystems_objectfile_path"];
					[(NSMutableDictionary *)attributes setObject:exportSymbols forKey:@"com_polymicrosystems_objectfile_export_symbols"];
					[(NSMutableDictionary *)attributes setObject:importSymbols forKey:@"com_polymicrosystems_objectfile_import_symbols"];
					[exportSymbols release];
					[importSymbols release];
					success=TRUE;
				}
			}
		}
	}
	[pool release];
	return success;
}
