/* 
 Boxer is copyright 2011 Alun Bestor and contributors.
 Boxer is released under the GNU General Public License 2.0. A full copy of this license can be
 found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

#import "BXHUDControls.h"
#import "BXGeometry.h"


#define BXBezelBorderRadius 20.0f


@implementation BXHUDLabel

- (NSString *)themeKey { return @"BXBlueTheme"; }

@end


@implementation BXHUDLevelIndicatorCell
@synthesize indicatorShadow, indicatorColor;

+ (CGFloat) heightForControlSize: (NSControlSize)size
{
    switch (size)
    {
        case NSMiniControlSize:
            return 10.0f;
            
        case NSSmallControlSize:
            return 12.0f;
        
        case NSRegularControlSize:
        default:
            return 14.0f;
    }
}

- (void) dealloc
{
	[self setIndicatorColor: nil], [indicatorColor release];
	[self setIndicatorShadow: nil], [indicatorShadow release];
	
	[super dealloc];
}

- (void) awakeFromNib
{
	if (![self indicatorColor])
	{
		[self setIndicatorColor: [NSColor whiteColor]];
	}
	
	if (![self indicatorShadow])
	{
		NSShadow *theShadow = [[NSShadow alloc] init];
		
		[theShadow setShadowBlurRadius: 3.0f];
		[theShadow setShadowOffset: NSMakeSize(0.0f, -1.0f)];
		
		[self setIndicatorShadow: theShadow];
		[theShadow release];
	}
}

- (void) drawWithFrame: (NSRect)cellFrame
                inView: (NSView *)controlView
{
    //Offset the draw region to give room for our shadow
    //TODO: we should just expand the dirty region of the control view instead
    CGFloat shadowSize  = [[self indicatorShadow] shadowBlurRadius];
    NSSize shadowOffset = [[self indicatorShadow] shadowOffset];
    NSRect shadowClearance  = NSInsetRect(cellFrame, shadowSize, shadowSize);
    shadowClearance.origin.x -= shadowOffset.width;
    shadowClearance.origin.y -= shadowOffset.height;
    
    NSRect indicatorFrame = [self drawingRectForBounds: shadowClearance];
    CGFloat maxHeight = indicatorFrame.size.height;
    CGFloat height = MIN(maxHeight, [[self class] heightForControlSize: [self controlSize]]);
    
    //Center the indicator vertically in the available space
    indicatorFrame.origin.y += (maxHeight - height) / 2.0f;
    indicatorFrame.size.height = height;

    NSRect borderRect       = NSInsetRect(indicatorFrame, 1.0f, 1.0f);
    NSRect levelRect        = NSInsetRect(indicatorFrame, 4.0f, 4.0f);
    
    CGFloat borderRadius    = borderRect.size.height / 2.0f;
    CGFloat levelRadius     = levelRect.size.height / 2.0f;
    
    NSBezierPath *borderPath = [NSBezierPath bezierPathWithRoundedRect: borderRect
                                                               xRadius: borderRadius
                                                               yRadius: borderRadius];
    [borderPath setLineWidth: 2.0f];
    
    
    NSBezierPath *levelPath = [NSBezierPath bezierPathWithRoundedRect: levelRect
                                                              xRadius: levelRadius
                                                              yRadius: levelRadius];
    
    //Work out how full the meter should be, and calculate from that how much of the path to draw
    double level = ([self doubleValue] - [self minValue]) / ([self maxValue] - [self minValue]);
    NSRect levelClip = levelRect;
    levelClip.size.width *= (float)level;
    levelClip = NSIntegralRect(levelClip);
    
    
    [NSGraphicsContext saveGraphicsState];
        [[self indicatorColor] set];
        [[self indicatorShadow] set];
    
        NSUInteger i, numTicks = [self numberOfTickMarks];
        for (i = 1; i < numTicks - 1; i++)
        {
            CGFloat tickPosition = (i / (CGFloat)(numTicks - 1));
            CGFloat xOffset = (levelRect.size.width * tickPosition);
            
            NSRect tickRect = NSMakeRect(levelRect.origin.x + xOffset, levelRect.origin.y, 1.0f, levelRect.size.height);
            tickRect = NSIntegralRect(tickRect);
            tickRect.size.width = 1.0f;
            
            [NSBezierPath fillRect: tickRect];
        }
        
        [borderPath stroke];
        
        [NSBezierPath clipRect: levelClip];
        [levelPath fill];
    [NSGraphicsContext restoreGraphicsState];
}

@end


@implementation BXBezelView

- (void) drawRect: (NSRect)dirtyRect
{
    NSBezierPath *background = [NSBezierPath bezierPathWithRoundedRect: [self bounds]
                                                               xRadius: BXBezelBorderRadius
                                                               yRadius: BXBezelBorderRadius];
    
    NSColor *backgroundColor = [NSColor colorWithCalibratedWhite: 0.0f alpha: 0.5f];
    
    [NSGraphicsContext saveGraphicsState];
        [backgroundColor set];
        [background fill];
    [NSGraphicsContext restoreGraphicsState];
}
@end