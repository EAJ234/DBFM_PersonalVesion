//
//  DataModel.swift
//  DBFM
//
//  Created by Edward on 14-8-3.
//  Copyright (c) 2014年 Edward. All rights reserved.
//

import Foundation

enum CycleType {
    case fullCycle //全部循环
    case singleCycle //单曲循环
    case randomCycle //随机循环
}
//入参分别是循环模式，当前播放的歌曲的序号，当前歌单的总歌曲数目
func nextSong(cycletType: CycleType, songNum: Int, songCount: Int) -> Int{
    var nextSongNum:Int = songNum
    switch cycletType{
    case .fullCycle:
        //全部循环，每次循环下一首歌，直到到达歌单尾部，循环到歌单开始
        if(songNum+1 == songCount){
            nextSongNum = 0
        }else {
            nextSongNum = songNum+1
        }
    case .singleCycle:
        //单曲循环每次获取的歌曲序号相同
        nextSongNum = songNum
    case .randomCycle:
        //随机循环时，直到下一首歌和本首歌不同才返回歌曲序号
        do{
            nextSongNum = Int(arc4random())%songCount
        }while (nextSongNum == songNum)
    }
    println(nextSongNum)
    return nextSongNum
}