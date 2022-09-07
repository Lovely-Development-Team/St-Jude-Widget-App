//
//  IntentHandler.swift
//  Relay FM for St. Jude
//
//  Created by David on 25/08/2021.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        switch intent {
        case is GetMainFundraisingEventIntent:
            return GetFundraisingEventIntentHandler()
        case is GetFundraiserIntent:
            return GetFundraiserIntentHandler()
        case is ConfigurationIntent:
            return ConfigurationIntentHandler()
        case is CampaignLockScreenConfigurationIntent:
            return CampaignConfigurationIntentHandler()
        default:
            return self
        }
    }
    
}
