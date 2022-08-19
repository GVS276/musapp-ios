//
//  DBContracts.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

class DBContracts
{
    public static let DB_VERSION = 1
    public static let DB_NAME = "musapp_database.sqlit"
    
    public class AudioEntry
    {
        public static let TABLE_NAME: String = "audio"

        public static let AUDIO_ID: String = "audioId"                  // String
        public static let ARTIST: String = "artist"                     // String
        public static let TITLE: String = "title"                       // String
        public static let STREAM_URL: String = "streamUrl"              // String
        public static let DOWNLOAD_URL: String = "downloadUrl"          // String
        public static let DURATION: String = "duration"                 // Integer
        public static let IS_DOWNLOADED: String = "isDownloaded"        // Integer
        public static let IS_EXPLICIT: String = "isExplicit"            // Integer
        public static let THUMB: String = "thumb"                       // String
        public static let TIMESTAMP: String = "timestamp"               // Int64
        
        public static let SQL_CREATE_AUDIO: String = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " (" +
        AUDIO_ID + " TEXT PRIMARY KEY," +
        ARTIST + " TEXT," +
        TITLE + " TEXT," +
        STREAM_URL + " TEXT," +
        DOWNLOAD_URL + " TEXT," +
        DURATION + " INTEGER," +
        IS_DOWNLOADED + " INTEGER," +
        IS_EXPLICIT + " INTEGER," +
        THUMB + " TEXT," +
        TIMESTAMP + " INTEGER)"
        
        //public static let SQL_UPDATE_AUDIO_TIMESTAMP: String = "ALTER TABLE " + TABLE_NAME + " ADD COLUMN " + TIMESTAMP + " INTEGER DEFAULT 0";
    }
}
