//
//  LYUitils.swift
//  Instagram-Swift
//
//  Created by LiuY on 2018/1/5.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

import UIKit

class LYUitils: NSObject {
    // 校验Email的合法性
    class func validateEmail(email: String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 校验Web的合法性
    class func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    // 校验手机号的合法性
    class func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
}
