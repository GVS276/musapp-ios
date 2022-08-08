//
//  UIUtils.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import Foundation

class UIUtils
{
    private static func digitString(_ number: Int) -> String {
        return number == 0 ? "00" : (number / 10 == 0) ? "0\(number)" : String(number)
    }
    
    static func getTimeFromDuration(sec: Int) -> String
    {
        if (sec == 0)
        {
            return "00:00"
        }

        let hours = sec / 3600
        let minutes = sec % 3600 / 60
        let seconds = sec % 60

        if (hours == 0)
        {
            return digitString(minutes) + ":" + digitString(seconds)
        }

        return digitString(hours) + ":" + digitString(minutes) + ":" + digitString(seconds)
    }
}
