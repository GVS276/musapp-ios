//
//  SQLDataBase.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation
import SQLite3

class SQLDataBase
{
    static let shared = SQLDataBase()
    private let newVersion: Int32 = 1
    
    private var audioDao: DBAudioDao? = nil
    private var db: OpaquePointer?
    
    private init()
    {
        self.db = openDatabase()
        
        self.createDaos()
        self.createTables()
        
        self.handleSchemaUpgrade()
    }
    
    private func handleSchemaUpgrade()
    {
        let version = self.getVersion()
        
        if self.newVersion > version {
            self.upgradeDB(oldVersion: version, newVersion: newVersion)
            self.setVersion(version: self.newVersion)
        }
        
        print("handleSchemaUpgrade: DB version = \(version)")
    }
    
    private func openDatabase() -> OpaquePointer?
    {
        let fileUrl = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil, create: false
        ).appendingPathComponent(DBContracts.DB_NAME)
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open_v2(fileUrl.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK
        {
            print("openDatabase: Can't open DB")
        } else {
            print("openDatabase: DB created successfully")
        }
        
        return db
    }
    
    private func getVersion() -> Int32
    {
        let versionStatementString = "PRAGMA user_version;"
        var versionStatement: OpaquePointer? = nil
        var version: Int32 = -1
        
        if sqlite3_prepare_v2(db, versionStatementString, -1, &versionStatement, nil ) == SQLITE_OK
        {
            if sqlite3_step(versionStatement) == SQLITE_ROW {
                version = sqlite3_column_int(versionStatement, 0)
                print("getVersion: DB version = \(version)")
            } else {
                print("getVersion: no result")
            }
        } else {
            print("getVersion: failed")
        }
        
        sqlite3_finalize(versionStatement)
        return version
    }
    
    private func setVersion(version: Int32)
    {
        let versionStatementString = "PRAGMA user_version=" + String(version)
        var versionStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, versionStatementString, -1, &versionStatement, nil ) == SQLITE_OK
        {
            if sqlite3_step(versionStatement) == SQLITE_DONE {
                print("setVersion: done")
            } else {
                print("setVersion: no result")
            }
        } else {
            print("setVersion: failed")
        }
        
        sqlite3_finalize(versionStatement)
    }
    
    private func createTable(tableName: String, createTableQuery: String)
    {
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("createTable: \(tableName) table created")
            } else {
                print("createTable: \(tableName) not created")
            }
        } else {
            print("createTable: \(tableName) not be prepared")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    fileprivate func upgradeDB(oldVersion: Int32, newVersion: Int32)
    {
        /*if oldVersion < 2 {
            self.executeUpdate(query: DBContracts.AudioEntry.SQL_UPDATE_AUDIO_TIMESTAMP)
        }*/
    }
    
    fileprivate func executeUpdate(query: String) {
        DBUtils.executeRawQuery(dbConnection: self.db!, query: query)
    }
    
    private func createTables()
    {
        self.createTable(tableName: DBContracts.AudioEntry.TABLE_NAME,
                         createTableQuery: DBContracts.AudioEntry.SQL_CREATE_AUDIO)
    }
    
    private func createDaos()
    {
        self.audioDao = DBAudioDao(dbConnection: self.db!)
    }
    
    func getAudioDao() -> DBAudioDao {
        return self.audioDao!
    }
}
