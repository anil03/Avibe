// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MMSideDrawerTableViewCell.h"

@implementation MMSideDrawerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setAccessoryCheckmarkColor:[UIColor whiteColor]];

        UIView * backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        //Background Color
        UIColor * backgroundColor= [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        [backgroundView setBackgroundColor:backgroundColor];

        [self setBackgroundView:backgroundView];
        
        //Selection Backgroundview
        UIView * selectionBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [selectionBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        UIColor * selectionBackgroundColor;
        if(OSVersionIsAtLeastiOS7()){
            selectionBackgroundColor = [UIColor colorWithRed:102.0/255.0
                                              green:163.0/255.0
                                               blue:210.0/255.0
                                              alpha:1.0];
        }
        else {
            selectionBackgroundColor = [UIColor colorWithRed:77.0/255.0
                                              green:79.0/255.0
                                               blue:80.0/255.0
                                              alpha:1.0];
        }
        [selectionBackgroundView setBackgroundColor:selectionBackgroundColor];
        [self setSelectedBackgroundView:selectionBackgroundView];
        
        //Textlabel
        /*
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setTextColor:[UIColor
                                      colorWithRed:230.0/255.0
                                      green:236.0/255.0
                                      blue:242.0/255.0
                                      alpha:1.0]];
        self.textLabel.frame = CGRectMake(80, 0, 320, 20);
        if(OSVersionIsAtLeastiOS7()== NO){
            [self.textLabel setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
            [self.textLabel setShadowOffset:CGSizeMake(0, 1)];
        }
        */
        
        //Custom label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 320, 30)];
        [_label setBackgroundColor:[UIColor clearColor]];
        //Text Color
        UIColor *textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [_label setTextColor:textColor];
        [self addSubview:_label];
        [self bringSubviewToFront:_label];
        
        //Button
        _button = [[UIButton alloc] initWithFrame:CGRectMake(5, 8, 24, 24)];
//        [button setBackgroundColor:[UIColor redColor]];
        _button.enabled = NO;
        [self addSubview:_button];
    }
    return self;
}

-(void)updateContentForNewContentSize{
    if([[UIFont class] respondsToSelector:@selector(preferredFontForTextStyle:)]){
        [self.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    }
    else {
        [self.textLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    }
}

@end
