//
//  NSDictionary+XML.m
//  Tools
//
//  Created by Артем Шиманский on 07.08.15.
//
//

#import "NSDictionary+XML.h"

@interface ASXMLElement : NSObject<NSXMLParserDelegate>
@property (nonatomic, weak) id parent;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableDictionary* children;
@property (nonatomic, strong) NSMutableString* string;
@property (nonatomic, strong) id representedObject;

- (id) initWithName:(NSString*) name attributes:(NSDictionary*) attributes parser:(NSXMLParser *)parser;
- (void) addChild:(ASXMLElement*) child;

@end

@implementation ASXMLElement

- (id) initWithName:(NSString*) name attributes:(NSDictionary*) attributes parser:(NSXMLParser *)parser{
	
	if (self = [super init]) {
		self.children = [NSMutableDictionary new];
		
		[attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			ASXMLElement* child = [[ASXMLElement alloc] initWithName:key attributes:nil parser:nil];
			child.string = [obj mutableCopy];
			[self addChild:child];
		}];
		
		self.parent = parser.delegate;
		self.name = name;
		parser.delegate = self;
		self.string = [NSMutableString new];
	}
	return self;
}

- (void) addChild:(ASXMLElement*) child {
	NSMutableArray* array = self.children[child.name];
	if (!array)
		self.children[child.name] = array = [NSMutableArray new];
	[array addObject:child];
}

- (id) representedObject {
	if (!_representedObject) {
		if (self.children.count == 0)
			_representedObject = self.string;
		else {
			NSMutableDictionary* representedObject = [NSMutableDictionary new];
			[self.children enumerateKeysAndObjectsUsingBlock:^(id key, NSArray* obj, BOOL *stop) {
				if (obj.count == 1)
					representedObject[key] = [[obj lastObject] representedObject];
				else if (obj.count > 1)
					representedObject[key] = [obj valueForKeyPath:@"representedObject"];
			}];
			_representedObject = representedObject;
			if (self.string.length > 0)
				_representedObject[@"_"] = self.string;
		}
	}
	return _representedObject;
}

#pragma mark NSXMLParserDelegate

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	[self addChild:[[ASXMLElement alloc] initWithName:elementName attributes:attributeDict parser:parser]];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	parser.delegate = self.parent;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.string appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	NSString *s = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	[self.string setString:s];
}

@end

@implementation NSDictionary (XML)

+ (instancetype) dictionaryWithXMLData:(NSData*) data {
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	ASXMLElement* root = [[ASXMLElement alloc] initWithName:nil attributes:nil parser:parser];
	if (![parser parse])
		return nil;
	return [root.representedObject isKindOfClass:[NSDictionary class]] ? root.representedObject : nil;
}

@end
