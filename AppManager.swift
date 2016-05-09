//
//  AppManager.swift
//  TableViewDemo
//
//  Created by surender on 29/01/16.
//  Copyright © 2016 Trigma. All rights reserved.
//

import UIKit
import PKHUD
import SystemConfiguration
import Foundation
import Alamofire



public protocol WebServiceDelegate : NSObjectProtocol
{
     func serverReponse(responseDict: NSDictionary,serviceurl:NSString)
     func failureRsponseError(failureError:NSError)
}

public class AppManager: NSObject {
    
    public var delegate: WebServiceDelegate?
    
    //********* Make Instance Of class ***********//
    
    private struct Constants {
        static let sharedManager = AppManager()
    }
    public class var sharedManager: AppManager {
        return Constants.sharedManager
    }
    
    //************ Check Internet Connectivity **********//
    public class NetWorkReachability
    {
        class func isConnectedToNetwork() -> Bool
        {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
                SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
        }
    }
    
    //********** Get Device UDID **********//
    public class DeviceUDID
    {
        class func GETUDID() -> String{
            let uuid = NSUUID().UUIDString
            return uuid
        }
    }
    
    //******** Check Content is not or not ***********//
    
    public class  getCurrectValue
    {
        class func CheckContentNullORNot(content:(NSString)) -> String
        {
            
            if content .isEqual("null") || content.isEqual("(null)") || content.isEqual("<null>") || content.isEqual("nil") || content.isEqual("") || content.isEqual("<nil>")
            {
                return ""
            }
            else
            {
                return content as String
            }
         }
    }
    
    //************* Activity Indicator **************//
    public func showactivityHub(message:(NSString))
    {
        PKHUD.sharedHUD
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
    }
    
    public func hideHUD()
    {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
    }
    
    
    //************ Set AlertView *********//
    
    public func Showalert(alerttitle:NSString,alertmessage:NSString){
        
        let alert = UIAlertController(title: alerttitle as String, message: alertmessage as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    //********* Check String Empty or not **********//
 
    public func isStringEmpty(strValue:NSString)->Bool
    {
        if strValue .length==0
        {
            return true
        }
        return false
    }
    
    public func isValidEmail(emailText:NSString)->Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(emailText)
    }
    
    public func validate(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(value)
        return result
        
    }
    
    //************ Append Base Url & Api URl ***********//
    
    func createServerPath(requestPath: String) -> String {
        return "\(Header.BASE_URL)\(requestPath)"
    }
    
    
    //************ Web Service method ***********//
    public func postDataOnserver(params:AnyObject,postUrl:NSString)
    {
        let serverpath: String = self.createServerPath(postUrl as String)
        Alamofire.request(.POST, serverpath as String, parameters: params as? [String : AnyObject])
            .responseJSON {
                response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)
                                         // result of response serialization
                if let JSON = response.result.value as? NSDictionary {
                    self.delegate?.serverReponse(JSON, serviceurl: postUrl)
                   // print("JSON: \(JSON)")
                }
                else
                {
                    self.delegate?.failureRsponseError(response.result.error!)
                }
        }
    }
    
    public func FetchDatafromServer(params:AnyObject,postUrl:NSString)
    {
        Alamofire.request(.GET, postUrl as String, parameters: params as? [String : AnyObject])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                let json = response.result.value
                print("JSON: \(json)")
                
                if let JSON = response.result.value as? NSDictionary {
                    self.delegate?.serverReponse(JSON, serviceurl: postUrl)
                    print("JSON: \(JSON)")
                }else
                {
                    self.delegate?.failureRsponseError(response.result.error!)
                }
        }
    }
}

