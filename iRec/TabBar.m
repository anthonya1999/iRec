//
//  DownloadTab.m
//  ScreenRecord
//
//  Created by Anthony Agatiello on 10/31/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import "TabBar.h"

@implementation TabBar

- (void)setSelectedImageName:(NSString *)selectedImageName {
    self.selectedImage = [UIImage imageNamed:selectedImageName];
}

@end
