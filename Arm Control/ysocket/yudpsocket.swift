/*
 * @Author: bryanthayes
 * @Date:   2016-05-15 11:39:18
 * @Last Modified by:   bryanthayes
 * @Last Modified time: 2016-05-15 11:39:18
 */

import Foundation

@_silgen_name("yudpsocket_server") func c_yudpsocket_server(host:UnsafePointer<Int8>,port:Int32) -> Int32
@_silgen_name("yudpsocket_recive") func c_yudpsocket_recive(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32
@_silgen_name("yudpsocket_close") func c_yudpsocket_close(fd:Int32) -> Int32
@_silgen_name("yudpsocket_client") func c_yudpsocket_client() -> Int32
@_silgen_name("yudpsocket_get_server_ip") func c_yudpsocket_get_server_ip(host:UnsafePointer<Int8>,ip:UnsafePointer<Int8>) -> Int32
@_silgen_name("yudpsocket_sentto") func c_yudpsocket_sentto(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,ip:UnsafePointer<Int8>,port:Int32) -> Int32
@_silgen_name("enable_broadcast") func c_enable_broadcast(fd:Int32)

public class UDPClient: YSocket {
    public override init(addr a:String,port p:Int){
        super.init()
        let remoteipbuff:[Int8] = [Int8](count:16,repeatedValue:0x0)
        let ret=c_yudpsocket_get_server_ip(a, ip: remoteipbuff)
        if ret==0{
            if let ip=String(CString: remoteipbuff, encoding: NSUTF8StringEncoding){
                self.addr=ip
                self.port=p
                let fd:Int32=c_yudpsocket_client()
                if fd>0{
                    self.fd=fd
                }
            }
        }
    }
    /*
    * send data
    * return success or fail with message
    */
    public func send(data d:[UInt8])->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_yudpsocket_sentto(fd, buff: d, len: Int32(d.count), ip: self.addr,port: Int32(self.port))
            if Int(sendsize)==d.count{
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * send string
    * return success or fail with message
    */
    public func send(str s:String)->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_yudpsocket_sentto(fd, buff: s, len: Int32(strlen(s)), ip: self.addr,port: Int32(self.port))
            if sendsize==Int32(strlen(s)){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * enableBroadcast
    */
    public func enableBroadcast(){
        if let fd:Int32=self.fd{
            c_enable_broadcast(fd)

        }
    }
    /*
    *
    * send nsdata
    */
    public func send(data d:NSData)->(Bool,String){
        if let fd:Int32=self.fd{
            var buff:[UInt8] = [UInt8](count:d.length,repeatedValue:0x0)
            d.getBytes(&buff, length: d.length)
            let sendsize:Int32=c_yudpsocket_sentto(fd, buff: buff, len: Int32(d.length), ip: self.addr,port: Int32(self.port))
            if sendsize==Int32(d.length){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            c_yudpsocket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
    //TODO add multycast and boardcast
}

public class UDPServer:YSocket{
    public override init(addr a:String,port p:Int){
        super.init(addr: a, port: p)
        let fd:Int32 = c_yudpsocket_server(self.addr, port: Int32(self.port))
        if fd>0{
            self.fd=fd
        }
    }
    //TODO add multycast and boardcast
    public func recv(expectlen:Int)->(String,String,Int){
        if let fd:Int32 = self.fd{
            var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
            var remoteipbuff:[Int8] = [Int8](count:16,repeatedValue:0x0)
            var remoteport:Int32=0
            let readLen:Int32=c_yudpsocket_recive(fd, buff: buff, len: Int32(expectlen), ip: &remoteipbuff, port: &remoteport)
            let port:Int=Int(remoteport)
            var addr:String=""
            if let ip=String(CString: remoteipbuff, encoding: NSUTF8StringEncoding){
                addr=ip
            }
            if readLen<=0{
                return ("",addr,port)
            }
            let rs=buff[0...Int(readLen-1)]
            let data:[UInt8] = Array(rs)
            let str = String(bytes: data, encoding: NSUTF8StringEncoding)!
            return (str,addr,port)
        }
        return ("","no ip",0)
    }
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            c_yudpsocket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
}
