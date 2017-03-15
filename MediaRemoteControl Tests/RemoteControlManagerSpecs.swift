//
//  RemoteControlManager.swift
//  MediaRemoteControl
//
//  Created by Shady Ghalab on 15/03/2017.
//  Copyright © 2017 Shady Ghalab. All rights reserved.
//

import Foundation
import Quick
import Nimble

class RemoteControlManagerSpecs: QuickSpec {
    
    override func spec() {
        describe("InternetConnection") {
            
            context("when stubbed to be online") {
                it("should report as connected") {
                    InternetConnectionSimulator.stubOnline()
                    expect(InternetConnection.isOnline).to(beTrue())
                }
            }
            
            context("when stubbed to be offline") {
                it("should report as not connected") {
                    InternetConnectionSimulator.stubOffline()
                    expect(InternetConnection.isOnline).to(beFalse())
                }
            }
            
            afterEach {
                InternetConnectionSimulator.unstub()
            }
            
        }
    }
}
