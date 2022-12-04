//
//  DBContracts.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.08.2022.
//

import Foundation

class DBContracts
{
    static let DB_VERSION = 1
    static let DB_NAME = "musapp_database.sqlit"
    
    class AudioEntry
    {
        static let TABLE_NAME: String = "audio"

        static let AUDIO_ID: String = "audioId"                  // String
        static let AUDIO_OWNER_ID: String = "audioOwnerId"       // String
        static let ARTIST: String = "artist"                     // String
        static let TITLE: String = "title"                       // String
        static let STREAM_URL: String = "streamUrl"              // String
        static let DURATION: String = "duration"                 // Integer
        static let IS_DOWNLOADED: String = "isDownloaded"        // Integer
        static let IS_EXPLICIT: String = "isExplicit"            // Integer
        static let THUMB: String = "thumb"                       // String
        static let ALBUM_ID: String = "albumId"                  // String
        static let ALBUM_TITLE: String = "albumTitle"            // String
        static let ALBUM_OWNER_ID: String = "albumOwnerId"       // String
        static let ALBUM_ACCESS_KEY: String = "albumAccessKey"   // String
        static let ARTISTS: String = "artists"                   // String
        static let TIMESTAMP: String = "timestamp"               // Int64
        
        static let SQL_CREATE_AUDIO: String = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " (" +
        AUDIO_ID + " TEXT PRIMARY KEY," +
        AUDIO_OWNER_ID + " TEXT," +
        ARTIST + " TEXT," +
        TITLE + " TEXT," +
        STREAM_URL + " TEXT," +
        DURATION + " INTEGER," +
        IS_DOWNLOADED + " INTEGER," +
        IS_EXPLICIT + " INTEGER," +
        THUMB + " TEXT," +
        ALBUM_ID + " TEXT," +
        ALBUM_TITLE + " TEXT," +
        ALBUM_OWNER_ID + " TEXT," +
        ALBUM_ACCESS_KEY + " TEXT," +
        ARTISTS + " TEXT," +
        TIMESTAMP + " INTEGER)"
    }
    
    class PlatlistEntry
    {
        static let TABLE_NAME: String = "playlist"

        static let PLAYLIST_ID: String = "playlistId"                  // String
        static let PLAYLIST_OWNER_ID: String = "playlistOwnerId"       // String
        static let PLAYLIST_ACCESS_KEY: String = "playlistAccessKey"   // String
        static let TITLE: String = "title"                             // String
        static let DESCRIPTION: String = "description"                 // String
        static let THUMB: String = "thumb"                             // String
        static let COUNT: String = "count"                             // Integer
        static let YEAR: String = "year"                               // Integer
        static let ORIGINAL: String = "original"                       // String
        static let TIMESTAMP: String = "timestamp"                     // Int64
        
        static let SQL_CREATE_PLAYLIST: String = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " (" +
        PLAYLIST_ID + " TEXT PRIMARY KEY," +
        PLAYLIST_OWNER_ID + " TEXT," +
        PLAYLIST_ACCESS_KEY + " TEXT," +
        TITLE + " TEXT," +
        DESCRIPTION + " TEXT," +
        THUMB + " TEXT," +
        COUNT + " INTEGER," +
        YEAR + " INTEGER," +
        ORIGINAL + " TEXT," +
        TIMESTAMP + " INTEGER)"
    }
}
