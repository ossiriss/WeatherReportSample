//
//  OneLocationTableViewCell.swift
//  WeatherReport
//
//  Created by  Boris Estrin on 25/05/2018.
//  Copyright © 2018  Boris Estrin. All rights reserved.
//

import UIKit

class OneLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationName: UILabel!
    
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    var expanded: Bool {
        set{
            if newValue{
                detailsViewHeightConstraint.priority = UILayoutPriority(rawValue: 250)
            } else{
                detailsViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
            }
        }
        get{
            return Int(detailsViewHeightConstraint.priority.rawValue) > 250
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
