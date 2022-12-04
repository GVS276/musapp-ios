//
//  DBPlaylistDao.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 03.10.2022.
//

import Foundation
import SQLite3

class DBPlaylistDao
{
    private var dbConnection: OpaquePointer
    
    init(dbConnection: OpaquePointer) {
        self.dbConnection = dbConnection
    }
    
    func insertPlaylist(playlist: PlaylistModel) -> Bool
    {
        var success = false
        let insertStatementString =
                """
                INSERT OR REPLACE INTO \(DBContracts.PlatlistEntry.TABLE_NAME) \
                (\(DBContracts.PlatlistEntry.PLAYLIST_ID), \
                \(DBContracts.PlatlistEntry.PLAYLIST_OWNER_ID), \
                \(DBContracts.PlatlistEntry.PLAYLIST_ACCESS_KEY), \
                \(DBContracts.PlatlistEntry.TITLE), \
                \(DBContracts.PlatlistEntry.DESCRIPTION), \
                \(DBContracts.PlatlistEntry.THUMB), \
                \(DBContracts.PlatlistEntry.COUNT), \
                \(DBContracts.PlatlistEntry.YEAR), \
                \(DBContracts.PlatlistEntry.ORIGINAL), \
                \(DBContracts.PlatlistEntry.TIMESTAMP)) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(dbConnection, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK
        {
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.id, columnIndex: 1)
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.ownerId, columnIndex: 2)
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.accessKey, columnIndex: 3)
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.title, columnIndex: 4)
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.description, columnIndex: 5)
            DBUtils.bindText(opaquePointer: insertStatement!, value: playlist.thumb, columnIndex: 6)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: playlist.count, columnIndex: 7)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: playlist.year, columnIndex: 8)
            DBUtils.bindText(opaquePointer: insertStatement!, value: DBUtils.toJsonFromPlaylistOriginal(original: playlist.original), columnIndex: 9)
            DBUtils.bindInt64(opaquePointer: insertStatement!, value: playlist.timestamp, columnIndex: 10)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                success = true
                print("playlist: successfully inserted")
            } else {
                success = false
                print("playlist: failed to inserted")
            }
        }
        
        sqlite3_finalize(insertStatement)
        return success
    }
    
    func getPlaylists() -> Array<PlaylistModel>?
    {
        let query = "SELECT * from \(DBContracts.PlatlistEntry.TABLE_NAME) ORDER BY \(DBContracts.PlatlistEntry.TIMESTAMP) DESC;"
        let list = getPlaylistsFromQuery(query: query)
        
        return list
    }
    
    private func getPlaylistsFromQuery(query: String) -> Array<PlaylistModel>?
    {
        var list = Array<PlaylistModel>()
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &stmt, nil) == SQLITE_OK
        {
            while sqlite3_step(stmt) == SQLITE_ROW
            {
                let model = getPlaylistFromStatement(stmt: stmt!)
                list.append(model)
            }
        }
        
        sqlite3_finalize(stmt)
        return list
    }
    
    private func getPlaylistFromQuery(query: String) -> PlaylistModel?
    {
        var model: PlaylistModel? = nil
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &stmt, nil) == SQLITE_OK
        {
            if sqlite3_step(stmt) == SQLITE_ROW {
                model = getPlaylistFromStatement(stmt: stmt!)
            }
        }
        
        sqlite3_finalize(stmt)
        return model
    }
    
    private func getPlaylistFromStatement(stmt: OpaquePointer) -> PlaylistModel
    {
        var model = PlaylistModel()
        
        model.id = DBUtils.getString(dbStatement: stmt, columnIndex: 0)
        model.ownerId = DBUtils.getString(dbStatement: stmt, columnIndex: 1)
        model.accessKey = DBUtils.getString(dbStatement: stmt, columnIndex: 2)
        model.title = DBUtils.getString(dbStatement: stmt, columnIndex: 3)
        model.description = DBUtils.getString(dbStatement: stmt, columnIndex: 4)
        model.thumb = DBUtils.getString(dbStatement: stmt, columnIndex: 5)
        model.count = DBUtils.getInt32(dbStatement: stmt, columnIndex: 6)
        model.year = DBUtils.getInt32(dbStatement: stmt, columnIndex: 7)
        
        model.original = DBUtils.fromJsonToPlaylistOriginal(
            json: DBUtils.getString(dbStatement: stmt, columnIndex: 8))
        
        model.timestamp = DBUtils.getInt64(dbStatement: stmt, columnIndex: 9)

        return model
    }
}
