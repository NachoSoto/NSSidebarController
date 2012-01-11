//
//  NSSidebarController.m
//  SidebarController
//
//  Created by Nacho Soto on 1/8/12.
//
//  Copyright 2012 Nacho Soto
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Note: You are NOT required to make the license available from within your
// iOS application. Including it in your project is sufficient.
//
// Attribution is not required, but appreciated :)
//

#import "NSSidebarController.h"

#import "UIViewController+NSSidebarController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    NSSidebarControllerStateNo,
    NSSidebarControllerStateLeft,
    NSSidebarControllerStateRight,
} NSSidebarControllerState;

typedef enum {
    NSSidebarControllerSideLeft,
    NSSidebarControllerSideRight,
} NSSidebarControllerSide;

#define screenWidth() [UIScreen mainScreen].applicationFrame.size.width

#define kMenuWidth 270

#define kAnimationCurve UIViewAnimationOptionCurveEaseInOut
#define kAnimationDuration 0.2

@interface NSSidebarController () 

@property (nonatomic, assign) NSSidebarControllerState currentState;
   
- (void)reveal:(BOOL)show side:(NSSidebarControllerSide)side;
- (void)animateMainViewToPosition:(CGFloat)position revealedView:(UIView *)view callback:(void (^)(BOOL finished))callback;
- (void)animateMainViewToPosition:(CGFloat)position callback:(void (^)(BOOL finished))callback;

@end

@implementation NSSidebarController

@synthesize leftController=_leftController;
@synthesize mainController=_mainController;
@synthesize rightController=_rightController;
@synthesize currentState=_currentState;

- (id)init
{
    if ((self = [super init]))
    {
        _currentState = NSSidebarControllerStateNo;
    }
    
    return self;
}

- (id)initWithMainController:(UIViewController *)mainController
{
    if ((self = [self init]))
    {
        self.mainController = mainController;
    }
    
    return self;
}

- (void)dealloc
{
    _mainController.sidebarController = nil;
    [_mainController release];

    _leftController.sidebarController = nil;
    [_leftController release];
    
    _rightController.sidebarController = nil;
    [_rightController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // TODO: release side controller views if not visible
}

// TODO: setting while visible?
- (void)setMainController:(UIViewController *)mainController
{
    if (_mainController != mainController)
    {
        [_mainController.view removeFromSuperview];
        _mainController.sidebarController = nil;
        [_mainController release];
        
        _mainController = [mainController retain];
        _mainController.sidebarController = self;
    }
}

// TODO: setting while visible?
- (void)setLeftController:(UIViewController *)leftController
{
    if (_leftController != leftController)
    {
        [_leftController.view removeFromSuperview];
        _leftController.sidebarController = nil;
        [_leftController release];
        
        _leftController = [leftController retain];
        _leftController.sidebarController = self;
        
        CGRect originalFrame = _leftController.view.frame;
        _leftController.view.frame = CGRectMake(originalFrame.origin.x, 0, originalFrame.size.width, originalFrame.size.height);
    }
}

- (void)setRightController:(UIViewController *)rightController
{
    if (_rightController != rightController)
    {
        [_rightController.view removeFromSuperview];
        _rightController.sidebarController = nil;
        [_rightController release];
        
        _rightController = [rightController retain];
        _rightController.sidebarController = self;
        
        CGRect originalFrame = _rightController.view.frame;
        _rightController.view.frame = CGRectMake(originalFrame.origin.x, 0, originalFrame.size.width, originalFrame.size.height);
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizesSubviews = YES;
}

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.mainController.view];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
}

// TODO: only supports portrait orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - touches
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.currentState != NSSidebarControllerStateNo)
    {
        CGFloat position = [[touches anyObject] locationInView:self.view].x;
        
        BOOL reset = NO;
        
        if (self.currentState == NSSidebarControllerStateLeft)
        {
            if (position > kMenuWidth)
                reset = YES;
        }
        else
        {
            CGFloat screenWidth = screenWidth();
            
            if (position < screenWidth - kMenuWidth)
                reset = YES;
        }
            
        if (reset)
            self.currentState = NSSidebarControllerStateNo;
    }
}

#pragma mark - view animations
- (CGAffineTransform)baseTransform
{
    CGAffineTransform baseTransform;
    
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            baseTransform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            baseTransform = CGAffineTransformMakeRotation(-M_PI/2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            baseTransform = CGAffineTransformMakeRotation(M_PI/2);
            break;
        default:
            baseTransform = CGAffineTransformMakeRotation(M_PI);
            break;
    }
    
    return baseTransform;
}

- (void)reveal:(BOOL)show side:(NSSidebarControllerSide)side
{    
    __block UIView *revealedView = nil;
    __block UIView *mainView = self.mainController.view;

    CGFloat screenWidth = screenWidth();
    CGFloat positionX;
    
    if (side == NSSidebarControllerSideLeft)
    {
        positionX = 0;
        revealedView = self.leftController.view;
    } 
    else
    {
        positionX = screenWidth - kMenuWidth;
        revealedView = self.rightController.view;
    }
    
    if (show)
    {
        CGRect frame = CGRectMake(positionX, revealedView.frame.origin.y, kMenuWidth, revealedView.frame.size.height);
        CGFloat width = kMenuWidth;
        CGFloat finalPosition = side == NSSidebarControllerSideLeft ? width : -width;
        CGFloat shadowOffset = side == NSSidebarControllerStateLeft ? -1 : 1;
        
        revealedView.frame = frame;
        
        [self.view insertSubview:revealedView belowSubview:mainView];
        
        mainView.layer.shadowOpacity = 1;
        mainView.layer.shadowColor = [UIColor blackColor].CGColor;
        mainView.layer.shadowRadius = 8;
        mainView.layer.shadowOffset = CGSizeMake(shadowOffset, 0);
        
        [self animateMainViewToPosition:finalPosition callback:nil];
    }
    else
    {
        [self animateMainViewToPosition:0 callback:^(BOOL finished) {
            [revealedView removeFromSuperview];
         }];
    }
}

- (void)animateMainViewToPosition:(CGFloat)position callback:(void (^)(BOOL finished))callback
{
    [self animateMainViewToPosition:position revealedView:nil callback:callback];
}

- (void)animateMainViewToPosition:(CGFloat)position revealedView:(UIView *)revealedView callback:(void (^)(BOOL finished))callback
{
    __block UIView *mainView = self.mainController.view;
    
    CGFloat screenWidth = screenWidth();
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0
                        options:kAnimationCurve
                     animations:
     ^{
         // animate the side controller to fit the whole screen
         revealedView.frame = CGRectMake(0, revealedView.frame.origin.y, screenWidth, revealedView.frame.size.height);
         mainView.transform = CGAffineTransformTranslate([self baseTransform], position, 0);
     }  
                     completion:callback];
}

- (void)setCurrentState:(NSSidebarControllerState)revealedState
{
    NSSidebarControllerState currentState = self.currentState;
    
    if (currentState != revealedState) {
        _currentState = revealedState;
        
        switch (currentState)
        {
            case NSSidebarControllerStateNo:
                if (revealedState == NSSidebarControllerStateLeft)
                    [self reveal:YES side:NSSidebarControllerSideLeft];
                else
                    [self reveal:YES side:NSSidebarControllerSideRight];

                break;
            case NSSidebarControllerStateLeft:
                if (revealedState == NSSidebarControllerStateNo)
                    [self reveal:NO side:NSSidebarControllerSideLeft];
                else
                {
                    [self reveal:NO side:NSSidebarControllerSideLeft];
                    [self reveal:YES side:NSSidebarControllerSideRight];
                }
                
                break;
            case NSSidebarControllerStateRight:
                if (revealedState == NSSidebarControllerStateNo)
                    [self reveal:NO side:NSSidebarControllerSideRight];
                else
                {
                    [self reveal:NO side:NSSidebarControllerSideRight];
                    [self reveal:YES side:NSSidebarControllerSideLeft];
                }
                
                break;
            default:
                break;
        }
    }
}

#pragma mark public methods
- (void)showLeftController
{
    self.currentState = NSSidebarControllerStateLeft;
}

- (void)showRightController
{
    self.currentState = NSSidebarControllerStateRight;   
}

- (void)replaceMainController:(UIViewController *)controller
{
    CGFloat screenWidth = screenWidth();
    
    UIView *controllerView = controller.view;
    
    CGFloat temporaryX = 0;
    UIView *revealedView = nil;
    
    if (self.currentState == NSSidebarControllerStateLeft)
    {
        temporaryX = screenWidth;
        revealedView = self.leftController.view;
    }
    else
    {
        temporaryX = -screenWidth;        
        revealedView = self.rightController.view;
    }
    
    [self animateMainViewToPosition:temporaryX
                       revealedView:revealedView
                           callback:
     ^(BOOL finished) {        
         self.mainController = controller;
         [self.view addSubview:controllerView];
         
         controllerView.transform = CGAffineTransformMakeTranslation(temporaryX, 0);
        
         self.currentState = NSSidebarControllerStateNo;
    }];
}

@end