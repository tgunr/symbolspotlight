#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 
#include <Foundation/Foundation.h>
#include <stdio.h>
#include <syslog.h>
#import <libsyminfo.h>
#import "extract.h"
#import "pms.h"

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
	    PMLOG(1, @"Null symbol, not doing a thing\n");
	    return;
	}
	NSLog(@"SymbolSpotlight: symbol name: %s arch: %s ordinal: %s\n", SymInfoGetSymbolName(symbol), SymInfoGetSymbolArch(symbol), SymInfoGetSymbolOrdinal(symbol));
}


NSString *
SymInfoAsLine(SymInfoSymbol symbol)
{
	if(symbol == NULL){
	    PMLOG(1, @"Null symbol, not doing a thing\n");
	    return NULL;
	}
	NSString *theString = [[[NSMutableString alloc] initWithCString:SymInfoGetSymbolName(symbol) encoding:NSUTF8StringEncoding] autorelease];
//	theString = [theString stringByAppendingString:@" "];
	return theString;
}


Boolean extract_object_file(void* thisInterface, 
							CFMutableDictionaryRef attributes, 
							CFStringRef contentTypeUTI,
							CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
    
    Boolean success=FALSE;
    FILE * fh = NULL;
    char path[4096];
    SymInfoList nmList;
    SymInfoSymbol * symImports;
    SymInfoSymbol * symExports;
    SymInfoSymbol symbol;
    SymInfoDependencies deps;
	
    NSLog(@"SymbolSpotlight called for: %@", pathToFile);
    if (CFStringHasSuffix(pathToFile, (CFStringRef)@".o") || 
		CFStringHasSuffix(pathToFile, (CFStringRef)@".a") ||
		CFStringHasSuffix(pathToFile, (CFStringRef)@".dylib") ) {
		NSLog(@"SymbolSpotlight processing: %@", pathToFile);
		if (CFStringGetCString(pathToFile, path, 4096, kCFStringEncodingUTF8)) {
			fh = fopen(path, "r");
			if (fh) {
				fclose(fh);
				nmList = SymInfoCreate(path);
				if (nmList) {
					NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					NSMutableArray *exportSymbols = [[NSMutableArray alloc] init];
					NSMutableArray *importSymbols = [[NSMutableArray alloc] init];

					unsigned int symInfoExportCount = SymInfoGetExportCount(nmList);
					unsigned int symInfoImportCount = SymInfoGetImportCount(nmList);
					symExports = SymInfoGetExports(nmList);
					symImports = SymInfoGetImports(nmList);
					uint32_t i;
					char * symName;
					const char * symArch;
					char * symOrdinal;
					for(i = 0; i < symInfoExportCount; i++) {
						symbol = symExports[i];	
						symName = SymInfoGetSymbolName(symbol);
						symArch = SymInfoGetSymbolArch(symbol);
						symOrdinal = SymInfoGetSymbolOrdinal(symbol);
                        if (! [exportSymbols containsObject:SymInfoAsLine(symbol)] ) {
                            [exportSymbols addObject:SymInfoAsLine(symbol)];
                        }
					}
					
					for(i = 0; i < symInfoImportCount; i++) {
						symbol = symImports[i];	
						symName = SymInfoGetSymbolName(symbol);
						symArch = SymInfoGetSymbolArch(symbol);
						symOrdinal = SymInfoGetSymbolOrdinal(symbol);
                        if (! [importSymbols containsObject:SymInfoAsLine(symbol)] ) {
                            [importSymbols addObject:SymInfoAsLine(symbol)];
                        }
					}
					
					deps = SymInfoGetLibraryInfo(nmList);
					unsigned int nSubFrameworks = SymInfoGetSubFrameworkCount(deps);
					char ** subFrameworks = SymInfoGetSubFrameworks(deps);
					unsigned int nSubUmbrellas = SymInfoGetSubUmbrellaCount(deps);
					char ** subUmbrellas = SymInfoGetSubUmbrellas(deps);
					char * subFramework;
					char * subUmbrella;

					for(i = 0; i < nSubFrameworks; i++) {
						subFramework = subFrameworks[i];
					}
					
					for(i = 0; i < nSubUmbrellas; i++) {
						subUmbrella = subUmbrellas[i];
					}
					
					[(NSMutableDictionary *)attributes setObject:(NSString *) pathToFile forKey:@"objectfile_path"];
					[(NSMutableDictionary *)attributes setObject:exportSymbols forKey:@"objectfile_export_symbols"];
					[(NSMutableDictionary *)attributes setObject:importSymbols forKey:@"objectfile_import_symbols"];

					SymInfoFree(nmList);
					[exportSymbols release];
					[importSymbols release];
					[pool release];
					success=TRUE;
				}
			}
		}
	}
	return success;
}
