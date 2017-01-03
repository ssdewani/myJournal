//
//  Entry.swift
//  MyJournal
//
//  Created by Salim Dewani on 12/24/16.
//  Copyright © 2016 Salim Dewani. All rights reserved.
//

import UIKit

class Entry: NSObject, NSCoding {
    //MARK: Properties
    var feelingToday: String
    var planToday: String
    var affirmToday: String
    var achievedToday: String
    var reflectToday: String
    var planTomorrow: String
    var date: Date
    
    struct PropertyKey {
        static let feelingToday = "feelingToday"
        static let planToday = "planToday"
        static let affirmToday = "affirmToday"
        static let achievedToday = "achievedToday"
        static let reflectToday = "reflectToday"
        static let planTomorrow = "planTomorrow"
        static let date = "date"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("myJournalEntries")
    
    //MARK:Init
    
    init(feelingToday: String, planToday: String, affirmToday: String, achievedToday: String, reflectToday: String, planTomorrow: String, date: Date) {
        self.feelingToday = feelingToday
        self.planToday = planToday
        self.affirmToday = affirmToday
        self.achievedToday = achievedToday
        self.reflectToday = reflectToday
        self.planTomorrow = planTomorrow
        self.date = date
        
    }
    
    //Mark: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(feelingToday, forKey: PropertyKey.feelingToday)
        aCoder.encode(planToday, forKey: PropertyKey.planToday)
        aCoder.encode(affirmToday, forKey: PropertyKey.affirmToday)
        aCoder.encode(achievedToday, forKey: PropertyKey.achievedToday)
        aCoder.encode(reflectToday, forKey: PropertyKey.reflectToday)
        aCoder.encode(planTomorrow, forKey: PropertyKey.planTomorrow)
        aCoder.encode(date, forKey: PropertyKey.date)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let feelingToday = aDecoder.decodeObject(forKey: PropertyKey.feelingToday) as? String
        let planToday = aDecoder.decodeObject(forKey: PropertyKey.planToday) as? String
        let affirmToday = aDecoder.decodeObject(forKey: PropertyKey.affirmToday) as? String
        let achievedToday = aDecoder.decodeObject(forKey: PropertyKey.achievedToday) as? String
        let reflectToday = aDecoder.decodeObject(forKey: PropertyKey.reflectToday) as? String
        let planTomorrow = aDecoder.decodeObject(forKey: PropertyKey.planTomorrow) as? String
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date
        self.init(feelingToday: feelingToday!, planToday: planToday!, affirmToday: affirmToday!, achievedToday: achievedToday!, reflectToday: reflectToday!, planTomorrow: planTomorrow!, date: date!)
    }
    
}
