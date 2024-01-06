//
//  UICellConfigurationState+.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 2023/08/06.
//

import UIKit

extension UICellConfigurationState {
    var item: Item? {
        get { return self[.item] as? Item }
        set { self[.item] = newValue}
    }
}
