//
//  DBUtils.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation
import SQLite3

class DBUtils
{
    static func bindInt(opaquePointer: OpaquePointer, value: Int32?, columnIndex: Int32)
    {
        if let value = value {
            sqlite3_bind_int(opaquePointer, columnIndex, value)
        }
    }
    
    static func bindInt64(opaquePointer: OpaquePointer, value: Int64?, columnIndex: Int32)
    {
        if let value = value {
            sqlite3_bind_int64(opaquePointer, columnIndex, value)
        }
    }
    
    static func bindText(opaquePointer: OpaquePointer, value: String?, columnIndex: Int32)
    {
        if let value = value {
            let tempValue = value as NSString
            sqlite3_bind_text(opaquePointer, columnIndex, tempValue.utf8String, -1, nil)
        }
    }
    
    static func getInt32(dbStatement: OpaquePointer, columnIndex: Int32) -> Int32 {
        return sqlite3_column_int(dbStatement, columnIndex)
    }
    
    static func getInt64(dbStatement: OpaquePointer, columnIndex: Int32) -> Int64 {
        return sqlite3_column_int64(dbStatement, columnIndex)
    }
    
    static func getString(dbStatement: OpaquePointer, columnIndex: Int32) -> String
    {
        var value: String
        
        let string = sqlite3_column_text(dbStatement, columnIndex)
        if let string = string {
            value = String(cString: string)
        } else {
            value = ""
        }
        
        return value
    }
    
    static func executeRawQuery(dbConnection: OpaquePointer, query: String)
    {
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("executeRawQuery: success")
            } else {
                print("executeRawQuery: failed")
            }
        } else {
            print("executeRawQuery: failed to prepare")
        }
        
        sqlite3_finalize(statement)
    }
    
    static func executeUpdateQuery(dbConnection: OpaquePointer, query: String)
    {
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &statement, nil) == SQLITE_OK
        {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("executeUpdateQuery: success")
            } else {
                print("executeUpdateQuery: failed")
            }
        } else {
            print("executeUpdateQuery: failed to prepare")
        }
    }
    
    static func executeDeleteQuery(dbConnection: OpaquePointer, query: String)
    {
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &statement, nil) == SQLITE_OK
        {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("executeDeleteQuery: success")
            } else {
                print("executeDeleteQuery: failed")
            }
        } else {
            print("executeDeleteQuery: failed to prepare")
        }
        
        sqlite3_finalize(statement)
    }
}
