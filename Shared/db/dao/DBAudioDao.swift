//
//  DBAudioDao.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation
import SQLite3

class DBAudioDao
{
    private var dbConnection: OpaquePointer
    
    init(dbConnection: OpaquePointer) {
        self.dbConnection = dbConnection
    }
    
    func insertAudio(audio: AudioModel) -> Bool
    {
        BaseSemaphore.shared.wait()
        
        var success = false
        let insertStatementString =
                """
                INSERT OR REPLACE INTO \(DBContracts.AudioEntry.TABLE_NAME) \
                (\(DBContracts.AudioEntry.AUDIO_ID), \
                \(DBContracts.AudioEntry.AUDIO_OWNER_ID), \
                \(DBContracts.AudioEntry.ARTIST), \
                \(DBContracts.AudioEntry.TITLE), \
                \(DBContracts.AudioEntry.STREAM_URL), \
                \(DBContracts.AudioEntry.DURATION), \
                \(DBContracts.AudioEntry.IS_DOWNLOADED), \
                \(DBContracts.AudioEntry.IS_EXPLICIT), \
                \(DBContracts.AudioEntry.THUMB), \
                \(DBContracts.AudioEntry.ALBUM_ID), \
                \(DBContracts.AudioEntry.ALBUM_TITLE), \
                \(DBContracts.AudioEntry.ALBUM_OWNER_ID), \
                \(DBContracts.AudioEntry.ALBUM_ACCESS_KEY), \
                \(DBContracts.AudioEntry.ARTISTS), \
                \(DBContracts.AudioEntry.TIMESTAMP)) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
        
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(dbConnection, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK
        {
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.audioId, columnIndex: 1)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.audioOwnerId, columnIndex: 2)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.artist, columnIndex: 3)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.title, columnIndex: 4)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.streamUrl, columnIndex: 5)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.duration, columnIndex: 6)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.isDownloaded ? 1 : 0, columnIndex: 7)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.isExplicit ? 1 : 0, columnIndex: 8)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.thumb, columnIndex: 9)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.albumId, columnIndex: 10)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.albumTitle, columnIndex: 11)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.albumOwnerId, columnIndex: 12)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.albumAccessKey, columnIndex: 13)
            DBUtils.bindText(opaquePointer: insertStatement!, value: DBUtils.toJsonFromArtists(artists: audio.artists), columnIndex: 14)
            DBUtils.bindInt64(opaquePointer: insertStatement!, value: audio.timestamp, columnIndex: 15)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                success = true
                print("audio: successfully inserted")
            } else {
                success = false
                print("audio: failed to inserted")
            }
        }
        
        sqlite3_finalize(insertStatement)
        
        BaseSemaphore.shared.signal()
        return success
    }
    
    func getAllAudio() -> Array<AudioModel>?
    {
        BaseSemaphore.shared.wait()
        
        let query = "SELECT * from \(DBContracts.AudioEntry.TABLE_NAME) ORDER BY \(DBContracts.AudioEntry.TIMESTAMP) DESC;"
        let list = self.getAudioListFromQuery(query: query)
        
        BaseSemaphore.shared.signal()
        return list
    }
    
    func getAudioById(audioId: String) -> AudioModel?
    {
        BaseSemaphore.shared.wait()
        
        let query = "SELECT * from \(DBContracts.AudioEntry.TABLE_NAME) WHERE \(DBContracts.AudioEntry.AUDIO_ID) = '\(audioId)'"
        let model = self.getAudioFromQuery(query: query)
        
        BaseSemaphore.shared.signal()
        return model
    }
    
    func deleteAudioById(audioId: String)
    {
        let query =
        """
        DELETE FROM \(DBContracts.AudioEntry.TABLE_NAME) \
        WHERE \(DBContracts.AudioEntry.AUDIO_ID) = '\(audioId)';
        """
        
        print("deleteAudioById query = \(query)")
        
        DBUtils.executeDeleteQuery(dbConnection: dbConnection, query: query)
    }
    
    func setDownloaded(audioId: String, value: Bool)
    {
        let query =
        """
        UPDATE \(DBContracts.AudioEntry.TABLE_NAME) \
        SET \(DBContracts.AudioEntry.IS_DOWNLOADED) = \(value ? 1 : 0) \
        WHERE \(DBContracts.AudioEntry.AUDIO_ID) = '\(audioId)';
        """
        
        print("setDownloaded query = \(query)")
        
        DBUtils.executeUpdateQuery(dbConnection: dbConnection, query: query)
    }
    
    private func getAudioListFromQuery(query: String) -> Array<AudioModel>?
    {
        var list = Array<AudioModel>()
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &stmt, nil) == SQLITE_OK
        {
            while sqlite3_step(stmt) == SQLITE_ROW
            {
                let model = getAudioFromStatement(stmt: stmt!)
                list.append(model)
            }
        }
        
        sqlite3_finalize(stmt)
        return list
    }
    
    private func getAudioFromQuery(query: String) -> AudioModel?
    {
        var model: AudioModel? = nil
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbConnection, query, -1, &stmt, nil) == SQLITE_OK
        {
            if sqlite3_step(stmt) == SQLITE_ROW {
                model = getAudioFromStatement(stmt: stmt!)
            }
        }
        
        sqlite3_finalize(stmt)
        return model
    }
    
    private func getAudioFromStatement(stmt: OpaquePointer) -> AudioModel
    {
        var model = AudioModel()
        
        model.audioId = DBUtils.getString(dbStatement: stmt, columnIndex: 0)
        model.audioOwnerId = DBUtils.getString(dbStatement: stmt, columnIndex: 1)
        model.artist = DBUtils.getString(dbStatement: stmt, columnIndex: 2)
        model.title = DBUtils.getString(dbStatement: stmt, columnIndex: 3)
        model.streamUrl = DBUtils.getString(dbStatement: stmt, columnIndex: 4)
        model.duration = DBUtils.getInt32(dbStatement: stmt, columnIndex: 5)
        model.isDownloaded = DBUtils.getInt32(dbStatement: stmt, columnIndex: 6) == 1 ? true : false
        model.isExplicit = DBUtils.getInt32(dbStatement: stmt, columnIndex: 7) == 1 ? true : false
        model.thumb = DBUtils.getString(dbStatement: stmt, columnIndex: 8)
        model.albumId = DBUtils.getString(dbStatement: stmt, columnIndex: 9)
        model.albumTitle = DBUtils.getString(dbStatement: stmt, columnIndex: 10)
        model.albumOwnerId = DBUtils.getString(dbStatement: stmt, columnIndex: 11)
        model.albumAccessKey = DBUtils.getString(dbStatement: stmt, columnIndex: 12)
        model.artists = DBUtils.fromJsonToArtists(json: DBUtils.getString(dbStatement: stmt, columnIndex: 13))
        model.timestamp = DBUtils.getInt64(dbStatement: stmt, columnIndex: 14)

        return model
    }
}
