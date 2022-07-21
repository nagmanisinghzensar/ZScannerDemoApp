//
//  Bundle+Module.swift
//  ZQRScanner
//
//  Created by Zensar on 12/07/22.
//

import Foundation

#if !SWIFT_PACKAGE
extension Bundle {
    static var module: Bundle = {
        return Bundle(for: ZQRScannerView.self)
    }()
}
#endif
