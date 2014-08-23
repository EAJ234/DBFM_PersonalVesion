//
//  ChannelController.swift
//  DBFM
//
//  Created by Edward on 14-7-25.
//  Copyright (c) 2014年 Edward. All rights reserved.
//

import UIKit
import QuartzCore

protocol ChannelProtocol{
    func channelChange(channel_id: NSString)
}

class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tv : UITableView
    var channelData:NSArray = NSArray()
    var delegate:ChannelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //返回的table view条数
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return channelData.count
    
    }
    
    //返回的table view内容
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Channel")
        let rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        cell.text = rowData["name"] as NSString //频道名称
//        cell.detailTextLabel.text = rowData["artist"] as NSString //演唱者
//        cell.image = UIImage(named:"detail.jpg") //默认图片
        return cell
    }

    //动画效果
    func tableView(tableview: UITableView, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            })
    }
    
    //点击表单的某一列
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        //println("Hello World")
        let rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        let channel_id:AnyObject = rowData["channel_id"] as AnyObject
        let channel:NSString = "channel=\(channel_id)"
        delegate?.channelChange(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

