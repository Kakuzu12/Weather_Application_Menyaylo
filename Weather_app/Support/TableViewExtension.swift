//
//  Created by Егор on 29.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit

extension UITableView {
    
    func beginRefreshing(refreshControl: UIRefreshControl?) {
        guard let refreshControl = refreshControl, refreshControl.isRefreshing else {
            return
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Updating data ...")
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
    
    @objc func endRefreshing(refreshControl: UIRefreshControl?) {
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.endRefreshing()
    }
}

