/*
 * @Author: bryanthayes
 * @Date:   2016-05-15 11:39:18
 * @Last Modified by:   bryanthayes
 * @Last Modified time: 2016-05-15 11:39:18
 */

import Foundation

public class YSocket{
    
    var addr:String
    var port:Int
    var fd:Int32?
    
    init(){
        self.addr=""
        self.port=0
    }
    
    public init(addr a:String, port p:Int){
        self.addr = a
        self.port = p
    }
}