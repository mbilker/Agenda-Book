//
//  GamePickerViewController.h
//  Agenda Book
//
//  Created by Matt Bilker on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSubjectPickerViewController.h"

@class SubjectPickerViewController;

@protocol SubjectPickerViewControllerDelegate <NSObject>
- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)game;
@end

@interface SubjectPickerViewController : UITableViewController <AddSubjectPickerViewControllerDelegate>

@property (nonatomic, weak) id <SubjectPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *subject;

@end