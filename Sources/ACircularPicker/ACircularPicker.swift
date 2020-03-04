//
//  ACircularPicker.swift
//
//  Created by Davee on 2018/8/30.
//  Copyright © 2018年 davee. All rights reserved.
//

import UIKit

/// A  circular number picker.
/// 圆形选择器
@IBDesignable public class ACircularPicker: UIControl {
    
    /// The inner padding for scale circle
    let kPadding: CGFloat = 8;
    
    /// The angle to draw first value. Default start from top of circle.
    /// 绘制第一个值的角度。默认从圆的顶部开始
    let kDefaultStartAngle :CGFloat = 270; // CGFloat.pi * 3 / 2;
    
    // MARK: Public Properties
    
    /// The options to draw on the circle.
    /// 所有可供选的值, e.g. [0, 1, 2, ... , 97 ,98 ,100]
    public var options: [String]!;
    
    /// The increment to control which values will be display. e.g. = 5, [0, 5, 10 ... 100] will be display
    /// 控制需要显示的值。 e.g. = 5, 那就是显示[0, 5, 10 ... 100]，其它的将以‘.’代替或者不显示
    public var drawingIncrement: Int = 1;
    
    /// The index of selected value
    /// 当前选中值的下标
    public var selectedIndex: Int = 0 {
        didSet {
            if !isBeingDragged {
                thumbAngle = outAngle(forIndex: selectedIndex);
            } else {
                if selectedIndex != oldValue {
                    notifyValueChanged();
                }
            }
        }
    }
    
    /// Selected value
    /// 当前选中的值
    public var selectedValue: String? {
        guard let hasOptions = options else { return nil }
        return hasOptions[selectedIndex];
    }
    
    /// Drawing a line from center to the thumb if true. Default is true.
    /// 是否绘制连接线（中心点到选项值的连接线）
    @IBInspectable public var drawLineEnable: Bool = true {
        didSet {
            if drawLineEnable != oldValue {
                setNeedsDisplay();
            }
        }
    }
    
    /// Drawling a point for hidden value if true. Default is false
    /// 是否绘制点来表示隐藏的值
    public var scalePointEnable: Bool = false {
        didSet {
            if scalePointEnable != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    /// The color of scale point (A point for the hidden value).
    /// 刻度点颜色 - 未选中（每个选项相当于一个刻度）
    public var scalePointColor: UIColor = .darkGray;
    
    /// The selected color of scale point
    /// 刻度点颜色 - 选中
    public var scalePointColorSelected: UIColor = .white;
    
    /// The radius of scale point
    /// 刻度点半径
    public var scalePointRadius: CGFloat = 4;
    
    /// The rect of scale point
    public var scalePointRect: CGRect = CGRect.zero;
    
    /// The normal color of scale text
    /// 刻度值文字颜色 - 未选中
    public var scaleTextColor: UIColor = .darkGray;
    
    /// The selected colof of scale text
    /// 刻度值文字颜色 - 选中时
    public var scaleTextColorSelected: UIColor = .white;
    
    /// Font size of scale label. Default 13
    /// 刻度值文字大小。默认13
    public var scaleTextSize: CGFloat = 13;
    
    /// Attributes for scale label
    lazy var scaleLabelAttrs: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: scaleTextSize),
                NSAttributedString.Key.foregroundColor: scaleTextColor];
    }()
    
    /////////////////////////////////////////////////////////////////
    
    /// The color of thumb. Default 0xFF4081
    /// 选择圆圈的颜色
    public var thumbColor: UIColor = UIColor(red:1.00, green:0.25, blue:0.51, alpha:1.00);
    
    /// The size of thumb. Default 32
    /// 选择圆圈的大小
    public var thumbSize: CGFloat = 32;
    
    
    /// Text displayed at the top.
    /// 显示在顶部的文字
    @IBInspectable public var topLabel: String? {
        didSet{
            if topLabel != oldValue {
                setNeedsDisplay();
            }
        }
    }
    
    /// Top margin for top label
    /// 顶部文字的上边距
    public var topLabelMargin: CGFloat = 8;
    
    public var topLabelColor: UIColor = .darkGray
    
    public var topLabelSize: CGFloat = 13
    
    lazy var topLabelAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: topLabelSize),
                NSAttributedString.Key.foregroundColor: topLabelColor];
    }()
    
    
    
    /////////////////////////////////////////////////////////////////
    
    /// Text to display at the bottom.
    /// 显示在底部的文字
    @IBInspectable public var bottomLabel: String? {
        didSet{
            if bottomLabel != oldValue {
                setNeedsDisplay();
            }
        }
    }
    
    /// A block to return a text to display at the bottom.
    /// 底部文字的回调，可以根据不同值返回不同的文字
    public var textForBottom: ((ACircularPicker) -> String)?
    
    /// Bottom margin for bottom label
    /// 底部文字的下边距
    public var bottomLabelMargin: CGFloat = 8;
    
    public var bottomLabelColor: UIColor = .darkGray
    
    public var bottomLabelSize: CGFloat = 13
    
    lazy var bottomLabelAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: bottomLabelSize),
                NSAttributedString.Key.foregroundColor: bottomLabelColor];
    }()
    
    
    /////////////////////////////////////////////////////////////////
    
    
    /// Indicates whether to draw value at center point. Default false
    /// 是否在中心点绘制选中的值
    @IBInspectable public var centerLabelEnable: Bool = false {
        didSet{
            if centerLabelEnable != oldValue {
                setNeedsDisplay();
            }
        }
    }
    
    /// The label to display in center
    @IBInspectable public var centerLabel: String? {
        didSet{
            if centerLabel != oldValue {
                setNeedsDisplay();
            }
        }
    }
    
    /// Return the text to draw at center
    /// 中心点需要绘制的文字
    public var textForCenter: ((ACircularPicker) -> String)?
    
    public var centerLabelColor: UIColor = .darkGray
    
    public var centerLabelSize: CGFloat = 15
    
    /// Attributes for the center label
    lazy var centerLabelAttributes: [NSAttributedString.Key: Any] = {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: centerLabelSize),
                NSAttributedString.Key.foregroundColor: centerLabelColor];
    }()
    
    
    // MARK: Private Properties
    
    /// Circle for drawing scales
    /// 绘制刻度所在的圆
    fileprivate var outCircle: CircleF = CircleF.unit;
    
    /// Circle for drawing thumb
    /// 选择圆圈
    fileprivate var thumbCircle: CircleF = CircleF.unit;
    
    /// Drawing a ellipse thumb if true. Default is false
    /// 是否绘制椭圆
    fileprivate var drawEllipse: Bool = false;
    
    /// The size of options.
    /// 选项数组的大小
    fileprivate var optionsCount: Int {
        guard let hasOptions = options, hasOptions.count > 0 else {
            return 0;
        }
        return hasOptions.count;
    }
    
    /// The angle between two values. e.g. [0, 1, 2, 3], sweepAngle = 90
    /// 每两个选项之间的夹角。例如["0","1","2","3"]有4个选项，它们之间夹角 = 360/4 = 90
    fileprivate var sweepAngle: CGFloat {
        guard optionsCount > 0 else {
            return 0;
        }
        return 360 / CGFloat(optionsCount);
    }
    
    /// The position of thumb on the circle
    /// thumb的位置。以设定坐标为参考系，即 0 时表示圆的最顶端Top
    fileprivate var thumbAngle: CGFloat = 0{
        didSet {
            readjustAngleLoc(angle: &thumbAngle);
            if thumbAngle != oldValue && isBeingDragged {
                updateSelection();
            }
            setNeedsDisplay();
        }
    }
    
    /// Whether the thumb is being dragged
    /// 是否正在拖动
    fileprivate var isBeingDragged: Bool = false;
    
    
    
    // MARK: - UIView+Extension
    
    var width :CGFloat {
        get{
            return self.frame.size.width;
        } set {
            self.frame.size.width = newValue
        }
    }
    var height :CGFloat {
        get {
            return self.frame.size.height;
        } set {
            self.frame.size.height = newValue
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initialize();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initialize();
    }
    
    fileprivate func initialize() {
        self.isUserInteractionEnabled = true;
        // #efeff4
        self.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00);
        
        /// IB中编辑模式
        #if TARGET_INTERFACE_BUILDER
        var labels = [String]();
        for index in 0..<60 {
            labels.append(String(index));
        }
        options = labels;
        self.drawingIncrement = 5;
        #endif
    }
    
    /// 设置选中值
    /// - Parameter value: the value to be selected
    public func preferSelected(value: String) {
        guard let hasOptions = options else { return }
        if let index = hasOptions.firstIndex(of: value) {
            self.selectedIndex = index;
        }
    }
    
    override public func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        guard let hasCtx = ctx else {
            return;
        }
        
        self.layer.cornerRadius = self.height/2;
        self.layer.masksToBounds = true;
        
        outCircle.centerX = self.width / 2;
        outCircle.centerY = self.height / 2;
        outCircle.radius = self.width/2 - kPadding - thumbSize / 2;
        
        if options != nil {
            drawThumb(ctx: hasCtx);
            drawScales(ctx: hasCtx);
            drawLabels(ctx: hasCtx);
        }
    }
    
    fileprivate func drawThumb(ctx: CGContext) {
        thumbColor.set();
        
        var pos: CGPoint!;
        // 设定坐标 -> 默认坐标
        let adjustThumbAngle = thumbAngle + kDefaultStartAngle;
        pos = outCircle.position(angle: adjustThumbAngle);
        
        if drawEllipse {
            let ellipseWidth: CGFloat = 60;
            let ellipseHeight: CGFloat = 22;
            let ox = pos.x - ellipseWidth/2;
            let oy = pos.y - ellipseHeight/2;
            ctx.fillEllipse(in: CGRect(x: ox, y: oy, width: ellipseWidth, height: ellipseHeight));
        } else {
            let ox = pos.x - thumbSize / 2;
            let oy = pos.y - thumbSize / 2;
            
            thumbCircle.center = pos;
            thumbCircle.radius = thumbSize / 2;
            ctx.fillEllipse(in: CGRect(x: ox, y: oy, width: thumbSize, height: thumbSize));
        }
        
        if drawLineEnable {
            /// center point
            ctx.fillEllipse(in: CGRect(x: self.width/2 - 4, y: self.height/2 - 4, width: 8, height: 8));
            ctx.move(to: CGPoint(x: self.width/2, y: self.height/2));
            ctx.addLine(to: pos);
            thumbColor.set();
            ctx.setLineWidth(2);
            ctx.drawPath(using: .stroke);
        }
    }
    
    fileprivate func drawScales(ctx: CGContext) {
        guard let hasOptions = options else {
            return;
        }
        let scaleCount = hasOptions.count;
        for index in 0..<scaleCount {
            let angle = outAngle(forIndex: index) + kDefaultStartAngle;
            let pos = outCircle.position(angle: angle);
            
            if index % self.drawingIncrement == 0 {
                // Draw Label
                if thumbCircle.contains(point: pos) {
                    scaleLabelAttrs[NSAttributedString.Key.foregroundColor] = scaleTextColorSelected;
                } else {
                    scaleLabelAttrs[NSAttributedString.Key.foregroundColor] = scaleTextColor;
                }
                let text = hasOptions[index];
                let textSize = (text as NSString).size(withAttributes: scaleLabelAttrs);
                let ox = pos.x - textSize.width / 2;
                let oy = pos.y - textSize.height / 2;
                let rect = CGRect(x: ox, y: oy, width: textSize.width, height: textSize.height);
                (text as NSString).draw(in: rect, withAttributes: scaleLabelAttrs);
                
            } else { // Draw Scale Point
                if index == selectedIndex {
                    scalePointColorSelected.set();
                    scalePointRect.origin.x = pos.x - scalePointRadius;
                    scalePointRect.origin.y = pos.y - scalePointRadius;
                    scalePointRect.size.width = scalePointRadius;
                    scalePointRect.size.height = scalePointRadius;
                    ctx.fillEllipse(in: scalePointRect);
                } else if self.scalePointEnable {
                    scalePointColor.set();
                    scalePointRect.origin.x = pos.x - scalePointRadius;
                    scalePointRect.origin.y = pos.y - scalePointRadius;
                    scalePointRect.size.width = scalePointRadius;
                    scalePointRect.size.height = scalePointRadius;
                    ctx.fillEllipse(in: scalePointRect);
                }
            }
        }
    }
    
    fileprivate func drawLabels(ctx: CGContext) {
        
        // Draw Top
        if let hasTopLabel = self.topLabel {
            let size = (hasTopLabel as NSString).size(withAttributes: topLabelAttributes);
            let ox: CGFloat = self.width / 2 - size.width/2;
            let oy: CGFloat = kPadding + thumbSize + topLabelMargin;
            (hasTopLabel as NSString).draw(in: CGRect(x: ox, y: oy, width: size.width, height: size.height), withAttributes: topLabelAttributes);
        }
        
        // Draw Bottom Label
        var bottomText: String? = self.bottomLabel;
        if let hasTextForBottom = self.textForBottom {
            bottomText = hasTextForBottom(self);
        }
        if let hasBottomLabel = bottomText {
            let size = (hasBottomLabel as NSString).size(withAttributes: bottomLabelAttributes);
            let ox: CGFloat = self.width/2 - size.width/2;
            let oy = self.height - kPadding - thumbSize - bottomLabelMargin - size.height;
            (hasBottomLabel as NSString).draw(in: CGRect(x: ox, y: oy, width: size.width, height: size.height), withAttributes: bottomLabelAttributes);
        }
        
        // Draw Center Label
        if centerLabelEnable, let hasSelectedValue = selectedValue {
            var textToDraw: String = hasSelectedValue;
            if let hasTextForSelection = self.textForCenter {
                textToDraw = hasTextForSelection(self);
            }
            let size = (textToDraw as NSString).size(withAttributes: centerLabelAttributes);
            let ox: CGFloat = self.width / 2 - size.width / 2;
            let oy: CGFloat = self.height / 2 - size.height / 2;
            (textToDraw as NSString).draw(in: CGRect(x: ox, y: oy, width: size.width, height: size.height), withAttributes: centerLabelAttributes);
        } else if let hasCenterLabel = centerLabel {
            let size = (hasCenterLabel as NSString).size(withAttributes: centerLabelAttributes);
            let ox: CGFloat = self.width / 2 - size.width / 2;
            let oy: CGFloat = self.height / 2 - size.height / 2;
            (hasCenterLabel as NSString).draw(in: CGRect(x: ox, y: oy, width: size.width, height: size.height), withAttributes: centerLabelAttributes);
        }
        
    }
    
    // MARK: - Draw Convenience
    
    fileprivate func outAngle(forIndex index: Int) -> CGFloat {
        let percentage = CGFloat(index) / CGFloat(optionsCount);
        return percentage * 360;
    }
    
    // MARK: - Touch Event
    
    fileprivate var maxRadius: CGFloat {
        return self.width / 2;
    }
    
    fileprivate var minRadius: CGFloat {
        return outCircle.radius - thumbSize/2;
    }
    
    fileprivate var outCircleMaxRadius: CGFloat {
        return outCircle.radius + thumbSize / 2;
    }
    
    fileprivate var outCircleMinRadius: CGFloat {
        return outCircle.radius - thumbSize / 2;
    }
    
    fileprivate func outCircleTouched(point: CGPoint) -> Bool {
        let distance = outCircle.distanceToCenter(point: point);
        return distance > outCircleMinRadius;
        //return distance < outCircleMaxRadius && distance > outCircleMinRadius;
    }
    
    fileprivate func startDragging(point: CGPoint) {
        if isBeingDragged {
            return;
        }
        let distance = outCircle.distanceToCenter(point: point);
        if distance <= maxRadius && distance >= minRadius {
            isBeingDragged = true;
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event);
        if isUserInteractionEnabled == false || isHidden == true || self.alpha <= 0.01 {
            return result;
        }
        
        if !self.point(inside: point, with: event) {
            return result;
        }
        
        for childView in self.subviews {
            let childPoint = self.convert(point, to: childView);
            if (childView.hitTest(childPoint, with: event) != nil) {
                return childView;
            }
        }
        
        return self;
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event);
        let point = touch.location(in: self);
        startDragging(point: point);
        if isBeingDragged {
            updateThumbPos(point: point);
        }
        return result || isBeingDragged;
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.continueTracking(touch, with: event);
        let point = touch.location(in: self);
        startDragging(point: point);
        if isBeingDragged {
            updateThumbPos(point: point);
        }
        return result || isBeingDragged;
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event);
        finishDragging();
    }
    
    override public func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event);
        finishDragging();
    }
    
    fileprivate func updateThumbPos(point: CGPoint) {
        // 默认坐标 -> 设定坐标
        // 0度对应圆上的右端(以xy坐标表示，x>0, y=0)
        // 而绘制value的时候，是从圆的上端(x=0, y>0)开始
        // 所以在根据角度计算对应的选项时，需要加上这个差值
        // 也就是说0度所对应的value不是index=0, -90度对应的才是
        let angle = outCircle.angle(forPoint: point) + 90;
        self.thumbAngle = angle;
    }
    
    /// 结束Touch事件
    fileprivate func finishDragging() {
        self.resignFirstResponder();
        let sweepAngle: CGFloat = self.sweepAngle;
        
        let remain = self.thumbAngle.truncatingRemainder(dividingBy: sweepAngle);
        if remain > sweepAngle/2 {
            self.thumbAngle += (sweepAngle - remain);
        } else {
            self.thumbAngle -= remain;
        }
        isBeingDragged = false;
    }
    
    fileprivate func updateSelection() {
        selectedIndex = checkOutSelection(forAngle: self.thumbAngle);
    }
    
    fileprivate func checkOutSelection(forAngle angle: CGFloat) -> Int {
        // 将角度限制在[0, 360]
        var adjustedAngle = angle;
        readjustAngleLoc(angle: &adjustedAngle);
        
        let fractor = CGFloat(optionsCount) / 360;
        var selection = Int(adjustedAngle * fractor + 0.5);
        if selection >= optionsCount {
            selection = 0;
        }
        return selection;
    }
    
    fileprivate func notifyValueChanged() {
        // ASLog.d("selected index = %d, value = %@", selectedIndex, options[selectedIndex]);
        // SoundEffectManager.playKaka();
        self.sendActions(for: .valueChanged);
    }
    
}
