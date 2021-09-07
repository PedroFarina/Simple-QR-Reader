//
//  SimpleQROutputDelegate.swift
//  
//
//  Created by Pedro Farina on 07/09/21.
//

public protocol SimpleQROutputDelegate: AnyObject {
    func viewDidSetup()
    func qrCodeFound(_ value: String)
    func viewWasDismissed()
}
