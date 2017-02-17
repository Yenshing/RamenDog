//
//  RamenPlaceDetailView.swift
//  RamenGo
//
//  Created by Yencheng on 2017/2/16.
//  Copyright © 2017年 GJTeam. All rights reserved.
//

import UIKit

protocol RamenPlaceDetailDelegate: class {
    func dismissDetailViewButton()
    func tapSurveyButton()
}

class RamenPlaceDetailView: UIView {

    weak var delegate : RamenPlaceDetailDelegate?
    @IBOutlet var view: UIView!
    @IBOutlet weak var ramenPlaceTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "RamenPlaceDetailView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    @IBAction func dismiss(_ sender: UIButton) {
        delegate?.dismissDetailViewButton()
    }
    
    @IBAction func survey(_ sender: UIButton) {
        delegate?.tapSurveyButton()
    }
}
