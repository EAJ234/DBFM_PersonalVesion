//
//  ViewController.swift
//  DBFM
//
//  Created by Edward on 14-7-25.
//  Copyright (c) 2014 Edward. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol, ChannelProtocol {
    @IBOutlet var tv : UITableView
    @IBOutlet var iv : UIImageView
    //@IBOutlet var progressView : UIProgressView
    @IBOutlet var playTime : UILabel
    @IBOutlet var tap : UITapGestureRecognizer = nil
    @IBOutlet var btnPlay : UIImageView
    @IBOutlet var pan : UIPanGestureRecognizer = nil
    @IBOutlet var swipe : UISwipeGestureRecognizer = nil
    @IBOutlet var progressSlider : UISlider
    
    
    var eHttp:HttpController = HttpController()  //Http请求
    var tableData:NSArray = NSArray()  //歌曲列表数据
    var channelData:NSArray = NSArray() //频道数据
    var imageCache = Dictionary<String,UIImage>() //缩略图缓存
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController() //播放器
    var timer:NSTimer?
    var songNum:Int = 0//当前播放的歌曲在列表里的序号
    var cycleType:CycleType = CycleType.fullCycle //默认全部循环
    //var player:AVAudioPlayer
    
    //初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        //progressView.progress = 0.0
        progressSlider.value = 0.0
        cycleType=CycleType.fullCycle
        swipe.numberOfTouchesRequired = 1
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        iv.addGestureRecognizer(tap)//添加响应暂停
        iv.addGestureRecognizer(swipe)//添加响应下一首歌
        //player.setCurrentTime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!){
        var channelC:ChannelController = segue.destinationViewController as ChannelController
        channelC.delegate = self
        channelC.channelData = self.channelData
    }
    
    //获取列表条数
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return tableData.count
    }
    
    //接受获取到的新频道信息
    func channelChange(channel_id: NSString){
        let url:NSString = "http://douban.fm/j/mine/playlist?\(channel_id)"
        eHttp.onSearch(url)
    }
    
    //生成歌曲列表信息
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        cell.text = rowData["title"] as NSString //歌曲名称
        cell.detailTextLabel.text = rowData["artist"] as NSString //演唱者
        cell.image = UIImage(named:"detail.jpg") //默认图片
        let url = rowData["picture"] as NSString //图片链接
        let image = self.imageCache[url] as? UIImage //从缓存中获取图片
        if (!image?) {//如果缓存中没有就重新获取图片
            let imageURL:NSURL = NSURL(string:url)
            let request:NSURLRequest = NSURLRequest(URL:imageURL)
            NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error:NSError!) ->Void in
                let img = UIImage(data:data)//获取图片链接对应的图片
                cell.image = img
                self.imageCache[url] = img
                })
        }else {//如果缓存中有就直接从缓存获取
            cell.image = image
        }
        return cell
    }
    
    //切换到点击选定的曲目
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        var rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
         //获取歌曲链接并播放
        var audioURL:NSString = rowData["url"] as NSString
        onSetAudio(audioURL)
        
        //获取图片链接并展示
        let imgURL:NSString = rowData["picture"] as NSString
        onSetImage(imgURL)
    }
    //动画效果
    func tableView(tableview: UITableView, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    //处理获取到到数据到数组
    func didRecieveResults(results:NSDictionary){
//        println("hello")
//        println("==========================")
//        println(results)
        if results["song"]{//歌曲信息
            self.tableData = results["song"] as NSArray
            self.tv.reloadData()
            //播放列表中的第一首歌
            playMusicAndShowImage(0)
            songNum=0
//            //播放列表中的第一首歌
//            let firstSong:NSDictionary = self.tableData[0] as NSDictionary
//            songNum = 1
//            //获取歌曲链接并播放
//            let audioURL:NSString = firstSong["url"] as NSString
//            //println(audioURL)
//            onSetAudio(audioURL)
//            
//            //获取图片链接并展示
//            let imgURL:NSString = firstSong["picture"] as NSString
//            //println(imgURL)
//            onSetImage(imgURL)
            
        } else if results["channels"]{//频道信息
            self.channelData = results["channels"] as NSArray
        }
    }
    
    //
    func playMusicAndShowImage(songNum:Int){
        let songData:NSDictionary = self.tableData[songNum] as NSDictionary
        //获取歌曲链接并播放
        let audioURL:NSString = songData["url"] as NSString
        //println(audioURL)
        onSetAudio(audioURL)
        
        //获取图片链接并展示
        let imgURL:NSString = songData["picture"] as NSString
        //println(imgURL)
        onSetImage(imgURL)
        
    }
    
    //播放对应链接的歌曲
    func onSetAudio(url:NSString){
        timer?.invalidate()
        playTime.text = "00:00"//初始化歌曲时间
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)
        //self.player.init(contentsOfURL: NSURL(string:url), error:nil )
        self.audioPlayer.play()
        sleep(1)//给1秒的时间给播放器缓冲歌曲信息
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector : "updateTime", userInfo: nil, repeats: true)
        //选择其他歌曲开始播放的时候，增加暂停监听
        btnPlay.removeGestureRecognizer(tap)
        iv.addGestureRecognizer(tap)
        btnPlay.hidden = true
    }
    
    //
    func updateTime(){
        //已播放时长
        let currentTime = audioPlayer.currentPlaybackTime
        //总歌曲时长
        let totalTime = audioPlayer.duration
        if (currentTime > 0.0) {
            //显示进度条进度
            let position :CFloat = CFloat(currentTime/totalTime)
            //progressView.setProgress(position, animated: true)
            progressSlider.setValue(position, animated: true)
            
            //显示时长
            let currentSeconds = Int(currentTime)
            let seconds = currentSeconds%60
            let minutes = Int(currentSeconds/60)
            var showTime:NSString = ""
            if (minutes < 10) {
                showTime = "0\(minutes):"
            }else {
                showTime = "\(minutes):"
            }
            
            if (seconds < 10) {
                showTime = "\(showTime)0\(seconds)"
            }else {
                showTime = "\(showTime)\(seconds)"
            }
            playTime.text = showTime
        }
        //如果一首歌播放完成则播放下一首
        if (currentTime >= totalTime) {
            println(totalTime)
            println("当前时长\(currentTime)")
            var nextSongNum:Int = nextSong(cycleType, songNum, tableData.count)
            playMusicAndShowImage(nextSongNum)
            songNum = nextSongNum
            println("songNum is \(songNum)")
        }
        
    }
    
    //展示对应链接到图片到大图
    func onSetImage(url:NSString){
        let image = self.imageCache[url] as? UIImage //从缓存中获取图片
        if (!image?) {//如果缓存中没有就重新获取图片
            let imageURL:NSURL = NSURL(string:url)
            let request:NSURLRequest = NSURLRequest(URL:imageURL)
            NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!, data:NSData!, error:NSError!) ->Void in
                let img = UIImage(data:data)//获取图片链接对应的图片
                self.iv.image = img
                self.imageCache[url] = img
                })
        }else {//如果缓存中有就直接从缓存获取
            self.iv.image = image
        }
    }
    
    //响应点击大图
    @IBAction func onTap(sender : UITapGestureRecognizer) {
        if (sender.view == btnPlay) {
            //暂停时点击
            btnPlay.hidden = true
            audioPlayer.play()
            btnPlay.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        } else if (sender.view == iv) {
            //播放时点击
            btnPlay.hidden = false
            audioPlayer.pause()
            btnPlay.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
        }
    }
    
    //响应滑动
    @IBAction func onPan(sender : UIPanGestureRecognizer) {
        if (sender.view == iv) {
            iv.removeGestureRecognizer(pan)
            println("hello Ed")
            var nextSongNum:Int = nextSong(cycleType, songNum, tableData.count)
            println("nextSongNum is \(nextSongNum)")
            songNum = nextSongNum
            playMusicAndShowImage(nextSongNum)
            iv.addGestureRecognizer(pan)
        }

    }
    
    @IBAction func onSwipe(sender : UISwipeGestureRecognizer) {
        if (sender.view == iv) {
            //iv.removeGestureRecognizer(swipe)
            println("hello Swipe")
            println(sender.direction)
            //if (sender.direction == UISwipeGestureRecognizerDirection.Right){
                var nextSongNum:Int = nextSong(cycleType, songNum, tableData.count)
                println("nextSongNum is \(nextSongNum)")
                songNum = nextSongNum
                playMusicAndShowImage(nextSongNum)}
            //iv.addGestureRecognizer(swipe)
        //}
    }
    @IBAction func sliderMove(sender : UISlider) {
        
     //   player.currentTime = (player.duration)*(sender.value)
    }
}

