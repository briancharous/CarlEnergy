#import "CPTPlotSpace.h"

#import "CPTMutablePlotRange.h"
#import "CPTPlot.h"
#import "CPTUtilities.h"

NSString *const CPTPlotSpaceCoordinateMappingDidChangeNotification = @"CPTPlotSpaceCoordinateMappingDidChangeNotification";

NSString *const CPTPlotSpaceCoordinateKey   = @"CPTPlotSpaceCoordinateKey";
NSString *const CPTPlotSpaceScrollingKey    = @"CPTPlotSpaceScrollingKey";
NSString *const CPTPlotSpaceDisplacementKey = @"CPTPlotSpaceDisplacementKey";

/// @cond

@interface CPTPlotSpace()

@property (nonatomic, readwrite) BOOL isDragging;

@end

/// @endcond

#pragma mark -

/**
 *  @brief Defines the coordinate system of a plot.
 *
 *  A plot space determines the mapping between data coordinates
 *  and device coordinates in the plot area.
 **/
@implementation CPTPlotSpace

/** @property id<NSCopying, NSCoding, NSObject> identifier
 *  @brief An object used to identify the plot in collections.
 **/
@synthesize identifier;

/** @property BOOL allowsUserInteraction
 *  @brief Determines whether user can interactively change plot range and/or zoom.
 **/
@synthesize allowsUserInteraction;

/** @property BOOL isDragging
 *  @brief Returns @YES when the user is actively dragging the plot space.
 **/
@synthesize isDragging;

/** @property __cpt_weak CPTGraph *graph
 *  @brief The graph of the space.
 **/
@synthesize graph;

/** @property __cpt_weak id<CPTPlotSpaceDelegate> delegate
 *  @brief The plot space delegate.
 **/
@synthesize delegate;

/** @property NSUInteger numberOfCoordinates
 *  @brief The number of coordinate values that determine a point in the plot space.
 **/
@dynamic numberOfCoordinates;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotSpace object.
 *
 *  The initialized object will have the following properties:
 *  - @ref identifier = @nil
 *  - @ref allowsUserInteraction = @NO
 *  - @ref isDragging = @NO
 *  - @ref graph = @nil
 *  - @ref delegate = @nil
 *
 *  @return The initialized object.
 **/
-(instancetype)init
{
    if ( (self = [super init]) ) {
        identifier            = nil;
        allowsUserInteraction = NO;
        isDragging            = NO;
        graph                 = nil;
        delegate              = nil;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    delegate = nil;
    graph    = nil;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeConditionalObject:self.graph forKey:@"CPTPlotSpace.graph"];
    [coder encodeObject:self.identifier forKey:@"CPTPlotSpace.identifier"];
    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;
    if ( [theDelegate conformsToProtocol:@protocol(NSCoding)] ) {
        [coder encodeConditionalObject:theDelegate forKey:@"CPTPlotSpace.delegate"];
    }
    [coder encodeBool:self.allowsUserInteraction forKey:@"CPTPlotSpace.allowsUserInteraction"];

    // No need to archive these properties:
    // isDragging
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
        graph                 = [coder decodeObjectForKey:@"CPTPlotSpace.graph"];
        identifier            = [[coder decodeObjectForKey:@"CPTPlotSpace.identifier"] copy];
        delegate              = [coder decodeObjectForKey:@"CPTPlotSpace.delegate"];
        allowsUserInteraction = [coder decodeBoolForKey:@"CPTPlotSpace.allowsUserInteraction"];

        isDragging = NO;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  If the receiver does not have a @ref delegate,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceDownEvent:atPoint: -plotSpace:shouldHandlePointingDeviceDownEvent:atPoint: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = NO;

    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceDownEvent:atPoint:)] ) {
        handledByDelegate = ![theDelegate plotSpace:self shouldHandlePointingDeviceDownEvent:event atPoint:interactionPoint];
    }
    return handledByDelegate;
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *  If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: -plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = NO;

    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceUpEvent:atPoint:)] ) {
        handledByDelegate = ![theDelegate plotSpace:self shouldHandlePointingDeviceUpEvent:event atPoint:interactionPoint];
    }
    return handledByDelegate;
}

/**
 *  @brief Informs the receiver that the user has moved
 *  @if MacOnly the mouse with the button pressed. @endif
 *  @if iOSOnly their finger while touching the screen. @endif
 *
 *
 *  If the receiver does not have a @ref delegate,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: -plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledByDelegate = NO;

    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint:)] ) {
        handledByDelegate = ![theDelegate plotSpace:self shouldHandlePointingDeviceDraggedEvent:event atPoint:interactionPoint];
    }
    return handledByDelegate;
}

/**
 *  @brief Informs the receiver that tracking of
 *  @if MacOnly mouse moves @endif
 *  @if iOSOnly touches @endif
 *  has been cancelled for any reason.
 *
 *
 *  If the receiver does not have a @ref delegate,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceCancelledEvent: -plotSpace:shouldHandlePointingDeviceCancelledEvent: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    BOOL handledByDelegate = NO;

    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceCancelledEvent:)] ) {
        handledByDelegate = ![theDelegate plotSpace:self shouldHandlePointingDeviceCancelledEvent:event];
    }
    return handledByDelegate;
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

/**
 *  @brief Informs the receiver that the user has moved the scroll wheel.
 *
 *
 *  If the receiver does not have a @ref delegate,
 *  this method always returns @NO. Otherwise, the
 *  @link CPTPlotSpaceDelegate::plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: -plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint: @endlink
 *  delegate method is called. If it returns @NO, this method returns @YES
 *  to indicate that the event has been handled and no further processing should occur.
 *
 *  @param event The OS event.
 *  @param fromPoint The starting coordinates of the interaction.
 *  @param toPoint The ending coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)scrollWheelEvent:(CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    BOOL handledByDelegate = NO;

    id<CPTPlotSpaceDelegate> theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(plotSpace:shouldHandleScrollWheelEvent:fromPoint:toPoint:)] ) {
        handledByDelegate = ![theDelegate plotSpace:self shouldHandleScrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
    }
    return handledByDelegate;
}
#endif

/// @}

@end

#pragma mark -

@implementation CPTPlotSpace(AbstractMethods)

/// @cond

-(NSUInteger)numberOfCoordinates
{
    return 0;
}

/// @endcond

/** @brief Converts a data point to plot area drawing coordinates.
 *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    NSParameterAssert(count == self.numberOfCoordinates);

    return CGPointZero;
}

/** @brief Converts a data point to plot area drawing coordinates.
 *  @param plotPoint A c-style array of data point coordinates (as @double values).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count
{
    NSParameterAssert(count == self.numberOfCoordinates);

    return CGPointZero;
}

/** @brief Converts a point given in plot area drawing coordinates to the data coordinate space.
 *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @param point The drawing coordinates of the data point.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    NSParameterAssert(count == self.numberOfCoordinates);
}

/** @brief Converts a point given in drawing coordinates to the data coordinate space.
 *  @param plotPoint A c-style array of data point coordinates (as @double values).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @param point The drawing coordinates of the data point.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point
{
    NSParameterAssert(count == self.numberOfCoordinates);
}

/** @brief Converts the interaction point of an OS event to plot area drawing coordinates.
 *  @param event The event.
 *  @return The drawing coordinates of the point.
 **/
-(CGPoint)plotAreaViewPointForEvent:(CPTNativeEvent *)event
{
    return CGPointZero;
}

/** @brief Converts the interaction point of an OS event to the data coordinate space.
 *  @param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @param event The event.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event
{
    NSParameterAssert(count == self.numberOfCoordinates);
}

/** @brief Converts the interaction point of an OS event to the data coordinate space.
 *  @param plotPoint A c-style array of data point coordinates (as @double values).
 *  @param count The number of coordinate values in the @par{plotPoint} array.
 *  @param event The event.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event
{
    NSParameterAssert(count == self.numberOfCoordinates);
}

/** @brief Sets the range of values for a given coordinate.
 *  @param newRange The new plot range.
 *  @param coordinate The axis coordinate.
 **/
-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
}

/** @brief Gets the range of values for a given coordinate.
 *  @param coordinate The axis coordinate.
 *  @return The range of values.
 **/
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
    return nil;
}

/** @brief Sets the scale type for a given coordinate.
 *  @param newType The new scale type.
 *  @param coordinate The axis coordinate.
 **/
-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate
{
}

/** @brief Gets the scale type for a given coordinate.
 *  @param coordinate The axis coordinate.
 *  @return The scale type.
 **/
-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate
{
    return CPTScaleTypeLinear;
}

/** @brief Scales the plot ranges so that the plots just fit in the visible space.
 *  @param plots An array of the plots that have to fit in the visible area.
 **/
-(void)scaleToFitPlots:(NSArray *)plots
{
}

/** @brief Scales the plot range for the given coordinate so that the plots just fit in the visible space.
 *  @param plots An array of the plots that have to fit in the visible area.
 *  @param coordinate The axis coordinate.
 **/
-(void)scaleToFitPlots:(NSArray *)plots forCoordinate:(CPTCoordinate)coordinate
{
    if ( plots.count == 0 ) {
        return;
    }

    // Determine union of ranges
    CPTMutablePlotRange *unionRange = nil;
    for ( CPTPlot *plot in plots ) {
        CPTPlotRange *currentRange = [plot plotRangeForCoordinate:coordinate];
        if ( !unionRange ) {
            unionRange = [currentRange mutableCopy];
        }
        [unionRange unionPlotRange:currentRange];
    }

    // Set range
    if ( unionRange ) {
        if ( CPTDecimalEquals( unionRange.length, CPTDecimalFromInteger(0) ) ) {
            [unionRange unionPlotRange:[self plotRangeForCoordinate:coordinate]];
        }
        [self setPlotRange:unionRange forCoordinate:coordinate];
    }
}

/** @brief Zooms the plot space equally in each dimension.
 *  @param interactionScale The scaling factor. One (@num{1}) gives no scaling.
 *  @param interactionPoint The plot area view point about which the scaling occurs.
 **/
-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
}

@end
