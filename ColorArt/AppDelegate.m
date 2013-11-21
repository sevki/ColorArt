//
//  AppDelegate.m
//  ColorArt
//
//
// Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//
// Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
//
// - Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// - Neither the name of Panic Inc nor the names of its contributors may be used to endorse or promote works derived from this software without specific prior written permission from Panic Inc.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PANIC INC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "AppDelegate.h"
#import "SLColorArt.h"

@implementation AppDelegate
NSString *css;
NSString *body;
NSString *headers;
NSString *links;
NSString *linksHover;
NSString *texts;
NSString *html;
-(NSString *)getRGBString:(NSColor*)color
{
    return [NSString stringWithFormat:
            @"rgb(%.0f,%.0f,%.0f)",
            color.redComponent*255,
            color.greenComponent*255,
            color.blueComponent*255];
}
-(void)setColor:(NSColor*)color toField:(NSTextField*)field {
    field.textColor = color;
    [field setStringValue:[NSString stringWithFormat:@"colour %@",[self getRGBString:color]]];
}
- (IBAction)chooseImage:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setPrompt:@"Select"];
	[openPanel setAllowedFileTypes:[NSImage imageTypes]];
	
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
	{
		if ( result == NSFileHandlingPanelOKButton )
		{
			NSURL *url = [openPanel URL];
			
			NSImage *image = [[NSImage alloc] initByReferencingURL:url];
			if ( image != nil )
			{
//                [_progress setHidden:NO];
                [_progress startAnimation:nil];
                [[NSOperationQueue new] addOperationWithBlock:^{
                    SLColorArt *colorArt = [[SLColorArt alloc] initWithImage:image scaledSize:NSMakeSize(800., 800.)];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        self.imageView.image = colorArt.scaledImage;
                        self.window.backgroundColor = colorArt.backgroundColor;
                        
                        body =[NSString stringWithFormat:
                               @"body {\r\n\tbackground-color:%@;\r\n}",
                               [self getRGBString:colorArt.backgroundColor]];
                        
                        
                        [self setColor:colorArt.primaryColor toField:self.primaryField];
                        headers =[NSString stringWithFormat:
                                  @"h1, h2, h3, h4 {\r\n\tcolor:%@;\r\n}",
                                  [self getRGBString:colorArt.primaryColor]];
                        
                        [self setColor:colorArt.secondaryColor toField:self.secondaryField];
                        links =[NSString stringWithFormat:
                                @"a {\r\n\tcolor:rgb(%.0f,%.0f,%.0f);\r\n}",
                                colorArt.secondaryColor.redComponent*255,
                                colorArt.secondaryColor.greenComponent*255,
                                colorArt.secondaryColor.blueComponent*255];
                        
                        linksHover =[NSString stringWithFormat:
                                @"a:hover {\r\n\tcolor:rgb(%.0f,%.0f,%.0f);\r\n\ttext-decoration:underline;\r\n}",
                                colorArt.secondaryColor.redComponent*255,
                                colorArt.secondaryColor.greenComponent*255,
                                colorArt.secondaryColor.blueComponent*255];

                        
                        [self setColor:colorArt.detailColor toField:self.detailField];
                        texts =[NSString stringWithFormat:
                                @"body {\r\n\tcolor:rgb(%.0f,%.0f,%.0f);\r\n}",
                                colorArt.detailColor.redComponent*255,
                                colorArt.detailColor.greenComponent*255,
                                colorArt.detailColor.blueComponent*255];

                        
                        self.cssField.textColor = colorArt.detailColor;
                    
                      
                        css =[NSString stringWithFormat:
                                @"%@\r\n%@\r\n%@\r\n%@\r\n%@", body,headers,links, linksHover, texts];
                        
                        html =[NSString stringWithFormat:@"\
                               <!DOCTYPE html>\
                               <html>\
                               <head>\
                               <title></title>\
                               <script src=\"https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js\"></script>\
                               <link rel=\"stylesheet\" type=\"text/css\" href=\"http://jmblog.github.io/color-themes-for-google-code-prettify/css/themes/github.css\">\
                               </head>\
                               <body onload=\"prettyPrint()\">\
                               <style type=\"text/css\">\
                               %@\
                               pre {\
                                background-color:white;\
                               }\
                               </style>\
                               <h1>This is a header</h1>\
                               This is some Text <a href=\"#\">This is a Link</a>. Building on top of Panic's ColorArt too can now quickly prototype CSS files.\
                               <h2>And the css that made this possible</h2>\
                               <pre class=\"prettyprint lang-css\">%@</pre>\
                               </body>\
                               </html>", css,css];
                        [[self.previewPage mainFrame] loadHTMLString:html baseURL:nil];
                        [self.previewPage setHidden:NO];
                        [self.copierButton setHidden:NO];
                        [[self.chooserButton cell] setBackgroundColor:[NSColor redColor]];
                        [[self.copierButton cell] setBackgroundColor:[NSColor redColor]];
//                        [_progress setHidden:YES];
                        [_progress stopAnimation:nil];
                    }];
                }];
			}
		}
	}];
}

- (IBAction)copyPressed:(id)sender {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray     arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString: css forType:NSStringPboardType];
}
@end

