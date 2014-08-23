//
//  HttpController.swift
//  DBFM
//
//  Created by Edward on 14-7-26.
//  Copyright (c) 2014年 Edward. All rights reserved.
//

import UIKit

protocol HttpProtocol{
    func didRecieveResults(results:NSDictionary)
}

class HttpController:NSObject{
    
    var delegate:HttpProtocol?
    
    func onSearch(url:String){
        var nsUrl:NSURL=NSURL(string:url)
        var request:NSURLRequest=NSURLRequest(URL:nsUrl)
        println(url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{(response:NSURLResponse!, data:NSData!, error:NSError!)->Void in
            var jsonResult:NSDictionary=NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
            self.delegate?.didRecieveResults(jsonResult)
            //println("hello")
            })
    }
}
