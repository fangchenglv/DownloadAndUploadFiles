//
//  ProcessView.m
//  DownloadFile
//
//  Created by lfc on 2019/10/22.
//  Copyright © 2019 lfc. All rights reserved.
//

#import "ProcessView.h"

@implementation ProcessView
- (void)setProcess:(float)process
{
    _process = process;
    [self setTitle:[NSString stringWithFormat:@"%0.2f%%",process * 100 ] forState:UIControlStateNormal];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = MIN(center.x, center.y) -5;
    
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = 2 * M_PI * self.process + startAngle;
    
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    path.lineWidth = 5;
    path.lineCapStyle = kCGLineCapRound;
    
    [[UIColor blueColor]setStroke];
    
    [path stroke];
}


@end
