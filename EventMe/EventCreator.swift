//
//  EventCreator.swift
//  EventMe
//
//  Created by Charlie Crouse on 12/27/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import Foundation

class EventModel {
    var eventName: String
    var eventDetails: String
    var eventTags: String
    var eventLocation: String
    
    init() {
        eventName = "name"
        eventDetails = "details"
        eventTags = "tags"
        eventLocation = "location"
    }
}

struct EventCreator {
    static var newEvent = EventModel()
    
    func submit() {
        // check to make sure that everything was changed
        print(EventCreator.newEvent.eventName)
        print(EventCreator.newEvent.eventDetails)
        print(EventCreator.newEvent.eventTags)
        print(EventCreator.newEvent.eventLocation)
    }
}