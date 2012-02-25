//
//  UIViewCarousel.m
//  Miso
//
//  Created by Joshua Wu on 8/29/11.
//  Copyright 2011 Miso. All rights reserved.
//

#import "UIViewCarousel.h"
#import "NSDictionary+Convenience.h"
#import <QuartzCore/QuartzCore.h>

@interface UIViewCarousel ()

- (void)bufferViews;
- (BOOL)viewExistAtIndex:(int)index;
- (void)readjustActiveWebviews;

@end

@implementation UIViewCarousel
@synthesize currentIndex=_currentIndex;
@synthesize enableViewBuffer=_enableViewBuffer;
@synthesize showPageControl=_showPageControl;
@synthesize enableWrap=_enableWrap;
@synthesize bufferSize=_bufferSize;
@synthesize dataSource=_dataSource;
@synthesize carousel=_carousel;
@synthesize pageControl=_pageControl;
@synthesize scrollDelegate=_scrollDelegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _bufferSize = 10;
        _enableViewBuffer = YES;
        _activeViews = [[NSMutableArray array] retain];
        _dequeueList = [[NSMutableDictionary dictionary] retain];
        
        _carousel = [[UIScrollView alloc] initWithFrame:self.bounds];
        _carousel.delegate = self;
        _carousel.pagingEnabled = YES;
        _carousel.directionalLockEnabled = YES;
        _carousel.alwaysBounceVertical = NO;
        _carousel.showsHorizontalScrollIndicator = NO;
        _carousel.alwaysBounceHorizontal = YES;
        _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_carousel];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.hidden = YES;
        [self addSubview:_pageControl];
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.currentIndex = 0;
    }
    
    return self;
}

- (void)dealloc {
    [_activeViews release];
    [_carousel release];
    [_dequeueList release];
    [super dealloc];
}

#pragma mark - Properties


- (void)setCurrentIndex:(int)currentIndex animated:(BOOL)animated {
    [AnalyticsController logEvent:kAnalyticsViewSSItem];

    _currentIndex = currentIndex;
    _pageControl.currentPage = _currentIndex;
    
    [self bufferViews];
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
    
    _carousel.contentOffset = CGPointMake(_carousel.frame.size.width * _currentIndex, 0);
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)setCurrentIndex:(int)currentIndex {
    [self setCurrentIndex:currentIndex animated:YES];
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    if (_showPageControl) {
        _pageControl.hidden = NO;
    } else {
        _carousel.frame = self.bounds;
        _pageControl.hidden = YES;
    }
}

- (void)setEnableViewBuffer:(BOOL)enableViewBuffer {
    _enableViewBuffer = enableViewBuffer;
    
    if (_enableViewBuffer)
        _bufferSize = 10;
    else
        _bufferSize = [_dataSource numberOfViewsInViewCarousel:self];
}

#pragma mark - Public Methods

- (UIView *)activeViewWithTag:(NSInteger)tag {
    for (UIView *view in _activeViews) {
        if (view.tag == tag) {
            return view;
        }
    }
    
    return nil;
}

- (void)reloadData {
    for (UIView *view in _activeViews) {
        NSString *classKey = NSStringFromClass([view class]);
        
        NSMutableArray *dequeueArray = [_dequeueList objectOrNilForKey:classKey];
        if(dequeueArray == nil) {
            dequeueArray = [NSMutableArray array];
            [_dequeueList setObject:dequeueArray forKey:classKey];
        }
        
        [view removeFromSuperview];
        [dequeueArray addObject:view];
    }
    
    [_activeViews removeAllObjects];
    
    _numViews = [_dataSource numberOfViewsInViewCarousel:self];
    _pageControl.numberOfPages = _numViews;
    
    int rootIndex = 0;
    if (_enableWrap) { _numViews += 2; rootIndex = 1;}
    

    _carousel.contentSize = CGSizeMake(_carousel.frame.size.width * _numViews, _carousel.frame.size.height);
    
    [self setCurrentIndex:rootIndex animated:NO];
    
    [self bufferViews];
}

- (id)dequeueReuseableViewWithClass:(id)klass {
    NSString *classKey = NSStringFromClass([klass class]);
    NSMutableArray *dequeueArray = [_dequeueList objectOrNilForKey:classKey];
    if (dequeueArray && [dequeueArray count] > 0) {
        id view = [[[dequeueArray objectAtIndex:0] retain] autorelease];
        [dequeueArray removeObjectAtIndex:0];
        return view;
    } else
        return nil;
}

#pragma mark - Private Methods 

- (void)readjustActiveWebviews {
    NSMutableArray *viewsToRemove = [NSMutableArray array];
    
    for (UIView *view in _activeViews) {
        if (abs(_currentIndex - view.tag) > _bufferSize) {
            [viewsToRemove addObject:view];
            [view removeFromSuperview];
            
            NSString *classKey = NSStringFromClass([view class]);

            NSMutableArray *dequeueArray = [_dequeueList objectOrNilForKey:classKey];
            if(dequeueArray == nil) {
                dequeueArray = [NSMutableArray array];
                [_dequeueList setObject:dequeueArray forKey:classKey];
            }
            
            [dequeueArray addObject:view];
        }
    }
    
    [_activeViews removeObjectsInArray:viewsToRemove];
}

- (BOOL)viewExistAtIndex:(int)index {
    for (UIView *view in _activeViews) {
        if (view.tag == index) {
            return YES;
        }
    }
    
    return NO;
}

- (void)bufferViews {
    [self readjustActiveWebviews];
    
    if ([_dataSource numberOfViewsInViewCarousel:self] == 0) { return; }
    
    for (int i = _currentIndex - _bufferSize; i <= _currentIndex + _bufferSize; i++) {
        if (i < 0 || i >= _numViews || [self viewExistAtIndex:i])
            continue;
        else {
            int askIndex = i;
            
            if (_enableWrap) {
                int tempNumViews = [_dataSource numberOfViewsInViewCarousel:self];
                askIndex = (((i-1)%tempNumViews)+tempNumViews)%tempNumViews;
            }
            
            UIView *view = [_dataSource viewCarousel:self viewAtIndex:askIndex];
            if (view != nil) {
                view.tag = i;
                view.frame = CGRectMake(_carousel.frame.size.width * i, 0, view.frame.size.width, view.frame.size.height);
                [view setNeedsDisplay];
                [_activeViews addObject:view];
                [_carousel addSubview:view];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = round(_carousel.contentOffset.x / _carousel.frame.size.width);
    
    if (index != _currentIndex) {
        _currentIndex = index;
        
        if (_enableWrap) {
            if (_currentIndex == 0) {
                _carousel.contentOffset = CGPointMake(_carousel.contentOffset.x + (_numViews - 2) * _carousel.frame.size.width, _carousel.contentOffset.y);
            } else if (_currentIndex == _numViews - 1) {
                _carousel.contentOffset = CGPointMake(_carousel.contentOffset.x - (_numViews - 2) * _carousel.frame.size.width, _carousel.contentOffset.y);
            }
        }
        
        [self bufferViews];
    }
    
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_scrollDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = round(_carousel.contentOffset.x / _carousel.frame.size.width);
    
    if (_enableWrap) {
        int tempNumViews = [_dataSource numberOfViewsInViewCarousel:self];
        _pageControl.currentPage = (((index-1)%tempNumViews)+tempNumViews)%tempNumViews;
    } else {
        _pageControl.currentPage = index;
    }
    
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_scrollDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

@end