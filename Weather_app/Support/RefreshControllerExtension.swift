//
//  Created by Егор on 29.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    
    func customBeginRefreshing(refreshControl: UIRefreshControl?) {
        guard let refreshControl = refreshControl, refreshControl.isRefreshing else {
            return
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Updating data...", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
    }
    
    @objc func customEndRefreshing(refreshControl: UIRefreshControl?) {
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.endRefreshing()
    }
}
