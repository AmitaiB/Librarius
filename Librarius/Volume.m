//
//  Volume.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "Volume.h"
#import "Bookcase.h"
#import "CoverArt.h"
#import "Library.h"

@implementation Volume

// Insert code here to add functionality to your managed object subclass
-(NSString *)isbn {
    return self.isbn13? self.isbn13 : self.isbn10? self.isbn10 : nil;
}



@end
