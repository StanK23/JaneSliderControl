//
//  SliderControl.swift
//  JaneSliderControl
//
//  Created by Barlow Tucker on 5/17/16.
//  Copyright © 2016 Jane. All rights reserved.
//

import UIKit

@IBDesignable open class SliderControl: UIControl {
    //MARK: - Private Variables
    fileprivate let slider: UIView = UIView()
    fileprivate let sliderLabel: UILabel = UILabel()
    fileprivate var sliderWidthConstraint: NSLayoutConstraint!
    fileprivate var sliderImageWidthConstraint: NSLayoutConstraint!
    fileprivate var shouldSlide: Bool = false
    fileprivate let imageView: UIImageView = UIImageView()
    open var currentSection: Int = 1
    //MARK: - Public Variables
    fileprivate(set) open var progress: CGFloat = 0.0
    
    //MARK: - IBInspectable Variables
    @IBInspectable open var sliderColor: UIColor = UIColor.lightGray {
        didSet {
            self.slider.backgroundColor = self.sliderColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable open var sectionCount: Int = 1
    
    @IBInspectable open var textColor: UIColor = UIColor.black {
        didSet {
            self.sliderLabel.textColor = self.textColor
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var cornerRadius: Float = 0 {
        didSet {
            self.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.slider.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var sliderText: String = "" {
        didSet {
            self.sliderLabel.text = sliderText
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var sliderWidth: Float = 50.0 {
        didSet {
            self.sliderWidthConstraint.constant = CGFloat(self.sliderWidth)
            self.sliderImageWidthConstraint.constant = CGFloat(self.sliderWidth)
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var sliderImage: UIImage? = nil {
        didSet {
            self.imageView.image = self.sliderImage
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var sliderImageContentMode: UIViewContentMode = .scaleAspectFit {
        didSet {
            self.imageView.contentMode = self.sliderImageContentMode
            self.setNeedsLayout()
        }
    }
    @IBInspectable open var sliderFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.sliderLabel.font = self.sliderFont
            self.setNeedsLayout()
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        let oneSection: CGFloat = self.bounds.size.width / CGFloat(sectionCount)
        self.sliderWidthConstraint.constant = oneSection
        self.progress = oneSection / self.bounds.size.width
    }
    
    //MARK: - UIControl
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSlider()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSlider()
    }
    
    //MARK: - Private Methods
    fileprivate func addVisualConstraints(_ vertical:String, horizontal:String, view:UIView, toView:UIView) {
        let veritcalConstraints = NSLayoutConstraint.constraints(withVisualFormat: vertical, options: [], metrics: nil, views: ["view":view])
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontal, options: [], metrics: nil, views: ["view":view])
        self.addConstraints(veritcalConstraints)
        self.addConstraints(horizontalConstraints)
    }
    
    fileprivate func setupSlider() {
        //Apply the custom slider styling
        self.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.layer.masksToBounds = true
        
        //Add the slider label and set the constraints that will keep it centered
        self.sliderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.sliderLabel.textAlignment = .center
        self.sliderLabel.textColor = self.textColor
        self.sliderLabel.font = self.sliderFont
        self.addSubview(self.sliderLabel)
        self.addVisualConstraints("V:|[view]|", horizontal: "H:|[view]|", view: self.sliderLabel, toView: self)
        
        //Create Slider
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        self.slider.backgroundColor = self.sliderColor
        self.slider.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.slider.layer.masksToBounds = true
        self.addSubview(self.slider)
        self.addVisualConstraints("V:|[view]|", horizontal: "H:|[view]", view: self.slider, toView: self)
        self.sliderWidthConstraint = NSLayoutConstraint(item: self.slider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(self.sliderWidth))
        self.slider.addConstraint(self.sliderWidthConstraint)
        
        //ImageView for optional slider image
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.slider.addSubview(self.imageView)
        self.imageView.contentMode = self.sliderImageContentMode
        self.imageView.image = self.sliderImage
        self.addVisualConstraints("V:|[view]|", horizontal: "H:[view]|", view:self.imageView, toView: self.slider)
        self.sliderImageWidthConstraint = NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(self.sliderWidth))
        self.imageView.addConstraint(self.sliderImageWidthConstraint)
        
        //Add pan gesture to slide the slider view
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        self.addGestureRecognizer(pan)

    }
    
    //MARK: - Public Methods
    open func reset() {
        self.progress = 0.0
        self.sliderWidthConstraint.constant = CGFloat(self.sliderWidth)
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }
    
    func panGesture(_ recognizer:UIPanGestureRecognizer) {
        let x = recognizer.location(in: self).x
        let padding: CGFloat = 20.0
        let oneSection: CGFloat = self.bounds.size.width / CGFloat(sectionCount)
        switch (recognizer.state) {
        case .began:
            //Only slide if the gestures starts within the slide frame
            self.shouldSlide = x > (self.sliderWidthConstraint.constant - CGFloat(self.sliderWidth)) && x < self.sliderWidthConstraint.constant + padding
            self.sendActions(for: .editingDidBegin)
        case .changed:
            self.sliderWidthConstraint.constant = x
            self.progress = CGFloat(min(x/self.bounds.size.width, 1))
            currentSection = Int(round(x / oneSection))
            if currentSection <= 0 {
                currentSection = 1
            }
            if currentSection > sectionCount {
                currentSection = sectionCount
            }

            self.sendActions(for: .valueChanged)
        case .ended:fallthrough
        case .cancelled:
            guard self.shouldSlide else { return }
            self.shouldSlide = false
            
            let finalX = CGFloat(currentSection) * oneSection
            self.progress = finalX / self.bounds.size.width
            
            self.sliderWidthConstraint.constant = finalX
            self.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            }, completion: { (finished) in
                if #available(iOS 9.0, *) {
                    self.sendActions(for: .primaryActionTriggered)
                }
                
                self.sendActions(for: .editingDidEnd)
                
            })
        default: break
        }
    }
}
