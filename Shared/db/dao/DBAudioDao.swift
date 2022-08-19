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
    private var semaphore: DBSemaphore
    
    init(dbConnection: OpaquePointer, semaphore: DBSemaphore) {
        self.dbConnection = dbConnection
        self.semaphore = semaphore
    }
    
    func insertAudio(audio: AudioModel) -> Bool
    {
        semaphore.wait()
        
        var success = false
        let insertStatementString =
                """
                INSERT OR REPLACE INTO \(DBContracts.AudioEntry.TABLE_NAME) \
                (\(DBContracts.AudioEntry.AUDIO_ID), \
                \(DBContracts.AudioEntry.ARTIST), \
                \(DBContracts.AudioEntry.TITLE), \
                \(DBContracts.AudioEntry.STREAM_URL), \
                \(DBContracts.AudioEntry.DOWNLOAD_URL), \
                \(DBContracts.AudioEntry.DURATION), \
                \(DBContracts.AudioEntry.IS_DOWNLOADED), \
                \(DBContracts.AudioEntry.IS_EXPLICIT), \
                \(DBContracts.AudioEntry.THUMB), \
                \(DBContracts.AudioEntry.TIMESTAMP)) \
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
        
        var insertStatement: OpaquePointer? = nil
        if(sqlite3_prepare_v2(dbConnection, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK)
        {
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.audioId, columnIndex: 1)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.artist, columnIndex: 2)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.title, columnIndex: 3)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.streamUrl, columnIndex: 4)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.downloadUrl, columnIndex: 5)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.duration, columnIndex: 6)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.isDownloaded, columnIndex: 7)
            DBUtils.bindInt(opaquePointer: insertStatement!, value: audio.isExplicit ? 1 : 0, columnIndex: 8)
            DBUtils.bindText(opaquePointer: insertStatement!, value: audio.thumb, columnIndex: 9)
            DBUtils.bindInt64(opaquePointer: insertStatement!, value: audio.timestamp, columnIndex: 10)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                success = true
                print("audio: successfully inserted")
            } else {
                success = false
                print("audio: failed to inserted")
            }
        }
        
        semaphore.signal()
        return success
    }
    
    func getAllAudio() -> Array<AudioModel>?
    {
        semaphore.wait()
        
        let query = "SELECT * from \(DBContracts.AudioEntry.TABLE_NAME) ORDER BY \(DBContracts.AudioEntry.TIMESTAMP) DESC;"
        let list = self.getAudioListFromQuery(query: query)
        
        semaphore.signal()
        return list
    }
    
    func getAudioById(audioId: String) -> AudioModel?
    {
        semaphore.wait()
        
        let query = "SELECT * from \(DBContracts.AudioEntry.TABLE_NAME) WHERE \(DBContracts.AudioEntry.AUDIO_ID) = '\(audioId)'"
        let model = self.getAudioFromQuery(query: query)
        
        semaphore.signal()
        return model
    }
    
    func deleteAudioById(audioId: String)
    {
        semaphore.wait()
        
        let query =
        """
        DELETE FROM \(DBContracts.AudioEntry.TABLE_NAME) \
        WHERE \(DBContracts.AudioEntry.AUDIO_ID) = '\(audioId)';
        """
        
        print("deleteAudioById query = \(query)")
        
        DBUtils.executeDeleteQuery(dbConnection: dbConnection, query: query)
        
        semaphore.signal()
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
        model.artist = DBUtils.getString(dbStatement: stmt, columnIndex: 1)
        model.title = DBUtils.getString(dbStatement: stmt, columnIndex: 2)
        model.streamUrl = DBUtils.getString(dbStatement: stmt, columnIndex: 3)
        model.downloadUrl = DBUtils.getString(dbStatement: stmt, columnIndex: 4)
        model.duration = DBUtils.getInt32(dbStatement: stmt, columnIndex: 5)
        model.isDownloaded = DBUtils.getInt32(dbStatement: stmt, columnIndex: 6)
        model.isExplicit = DBUtils.getInt32(dbStatement: stmt, columnIndex: 7) == 1 ? true : false
        model.thumb = DBUtils.getString(dbStatement: stmt, columnIndex: 8)
        model.timestamp = DBUtils.getInt64(dbStatement: stmt, columnIndex: 9)

        return model
    }
}
