//
//  MainViewController.m
//  Swipulator4
//
//  Created by Mark Hartnady on 12/02/2014.
//  Copyright (c) 2014 Bilnady Inc. All rights reserved.
//

#import "MainViewController.h"
#import "DDMathParser.h"

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) IBOutlet UILabel *calcDisplay;
@property (strong, nonatomic) IBOutlet UILabel *pos;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation MainViewController

BOOL mustReset = NO;
BOOL leftHanded = NO;
short int startPosX = -1;
short int startPosY = -1;
short int plusSequence = 0;
short int minusSequence = 0;
short int divideSequence = 0;
short int timesSequence = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

/*
 In response to a tap gesture, show the image view appropriately then make it fade out in place.
 */
- (IBAction)showGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
	
	CGPoint location = [recognizer locationInView:self.view];
	[self drawImageForGestureRecognizer:recognizer atPoint:location];
    
    NSLog(@"Tap");
}

- (IBAction)showGestureForPanRecognizer:(UIPanGestureRecognizer *)recognizer {
    
    //middle of keypad = x:160,y:270
    
    NSMutableString* tmp = [[NSMutableString alloc] initWithString:self.calcDisplay.text];
    CGPoint location = [recognizer locationInView:self.view];
    
//    self.pos.text = [[NSString alloc]initWithFormat:@"X:%i/Y:%i",(int)location.x,(int)location.y ];
//    self.pos.center = location;
    
    if ((int) location.y > 137) //make sure to take into account only if pan starts below display
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            startPosX = (short int) location.x;
            minusSequence++;
            
            if ((int) location.x < 161)
            {
                if ((int) location.y > 270)
                {
                    divideSequence++;
                }
                else{
                    timesSequence++;
                }
            } else if ((int) location.y < 270)
            {
                plusSequence++;
            }
        }
    
        if (recognizer.state == UIGestureRecognizerStateChanged)
        {
            //Addition movements
            if (plusSequence==1 && (int) location.y > 270) plusSequence++;
            if (plusSequence==2 && (int) location.x < 160) plusSequence++;
            if (plusSequence==3 && (int) location.x > 160) plusSequence++;
            
            //Multiplication movements
            if (timesSequence==1 && (int) location.y > 270 && (int) location.x > 160) timesSequence++;
            if (timesSequence==2 && (int) location.y > 270 && (int) location.x < 160) timesSequence++;
            if (timesSequence==3 && (int) location.y < 270 && (int) location.x > 160) timesSequence++;
            
            //Division movements
            if (divideSequence==1 && (int) location.x > 160 && location.y < 270) divideSequence++;
            
            //Subtraction movements
            if (minusSequence==1 && (int) location.x < 160 && startPosX > 160) minusSequence++;
            if (minusSequence==1 && (int) location.x > 161 && startPosX < 160) minusSequence++;
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            //append display with correct operator depending on final motion state
            if (plusSequence==4) [tmp appendString:@"+"];
            else if (timesSequence==4) [tmp appendString:@"*"];
            else if (divideSequence==2) [tmp appendString:@"/"];
            else if (minusSequence==2) [tmp appendString:@"-"];
            
            //reset all counters
            timesSequence=0;
            plusSequence=0;
            minusSequence=0;
            divideSequence=0;
            
            //reset debug label
            self.pos.text = @"";
        }
    }
    else //if pan location is within the display then backspace the display
    {
        if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            //remove one character off the end of the display
            tmp = [[NSMutableString alloc]initWithString:[tmp substringToIndex:([tmp length]-1)]];
        }
    }
    
    self.calcDisplay.text = tmp;
    
}

- (void)drawImageForGestureRecognizer:(UIGestureRecognizer *)recognizer atPoint:(CGPoint)centerPoint {
    
    CGPoint location = [recognizer locationInView:self.view];
    
    NSMutableString* tmp = [[NSMutableString alloc] initWithString:self.calcDisplay.text];
    
    if (mustReset) {
        tmp = [[NSMutableString alloc] initWithString:@""];
        mustReset = NO;
    }
    
    NSArray* xLines = [[NSArray alloc]initWithObjects:@32.0,@96.0,@129.0,@193.0,@226.0,@289.0,nil];
    NSArray* yLines = [[NSArray alloc]initWithObjects:@162.0,@224.0,@241.0,@303.0,@319.0,@380.0,@395.0,@459.0, nil];
    
    if (location.x > [[xLines objectAtIndex:0]floatValue] && location.x < [[xLines objectAtIndex:1]floatValue] && location.y > [[yLines objectAtIndex:0]floatValue] && location.y < [[yLines objectAtIndex:1]floatValue])
    {
        [tmp appendString:@"7"];
    } else if (location.x > [[xLines objectAtIndex:2]floatValue] && location.x < [[xLines objectAtIndex:3]floatValue] && location.y > [[yLines objectAtIndex:0]floatValue] && location.y < [[yLines objectAtIndex:1]floatValue])
    {
        [tmp appendString:@"8"];
    } else if (location.x > [[xLines objectAtIndex:4]floatValue] && location.x < [[xLines objectAtIndex:5]floatValue] && location.y > [[yLines objectAtIndex:0]floatValue] && location.y < [[yLines objectAtIndex:1]floatValue])
    {
        [tmp appendString:@"9"];
    } else if (location.x > [[xLines objectAtIndex:0]floatValue] && location.x < [[xLines objectAtIndex:1]floatValue] && location.y > [[yLines objectAtIndex:2]floatValue] && location.y < [[yLines objectAtIndex:3]floatValue])
    {
        [tmp appendString:@"4"];
    } else if (location.x > [[xLines objectAtIndex:2]floatValue] && location.x < [[xLines objectAtIndex:3]floatValue] && location.y > [[yLines objectAtIndex:2]floatValue] && location.y < [[yLines objectAtIndex:3]floatValue])
    {
        [tmp appendString:@"5"];
    } else if (location.x > [[xLines objectAtIndex:4]floatValue] && location.x < [[xLines objectAtIndex:5]floatValue] && location.y > [[yLines objectAtIndex:2]floatValue] && location.y < [[yLines objectAtIndex:3]floatValue])
    {
        [tmp appendString:@"6"];
    } else if (location.x > [[xLines objectAtIndex:0]floatValue] && location.x < [[xLines objectAtIndex:1]floatValue] && location.y > [[yLines objectAtIndex:4]floatValue] && location.y < [[yLines objectAtIndex:5]floatValue])
    {
        [tmp appendString:@"1"];
    } else if (location.x > [[xLines objectAtIndex:2]floatValue] && location.x < [[xLines objectAtIndex:3]floatValue] && location.y > [[yLines objectAtIndex:4]floatValue] && location.y < [[yLines objectAtIndex:5]floatValue])
    {
        [tmp appendString:@"2"];
    } else if (location.x > [[xLines objectAtIndex:4]floatValue] && location.x < [[xLines objectAtIndex:5]floatValue] && location.y > [[yLines objectAtIndex:4]floatValue] && location.y < [[yLines objectAtIndex:5]floatValue])
    {
        [tmp appendString:@"3"];
    } else if (location.x > [[xLines objectAtIndex:2]floatValue] && location.x < [[xLines objectAtIndex:3]floatValue] && location.y > [[yLines objectAtIndex:6]floatValue] && location.y < [[yLines objectAtIndex:7]floatValue])
    {
        [tmp appendString:@"0"];
    } else if ( ( location.x < [[xLines objectAtIndex:1]floatValue] && location.y > [[yLines objectAtIndex:5]floatValue]) || (location.y < 137.0) )
    {
        NSNumber *result = [tmp numberByEvaluatingString];
        [tmp appendString:[[NSMutableString alloc]initWithFormat:@"=%@",result ]];
        mustReset = YES;
    }
    
    self.calcDisplay.text = tmp;
    
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}


@end
