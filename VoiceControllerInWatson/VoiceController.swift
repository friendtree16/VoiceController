//
//  VoiceController.swift
//  VoiceControllerInWatson
//
//  Created by tomoki on 2016/12/04.
//  Copyright © 2016年 friendTree16. All rights reserved.
//

import UIKit
import NaturalLanguageClassifierV1
import SpeechToTextV1

public enum voiceAction: Int {
    case unknow  // 不明
    case next  // 次へ
    case prev  // 前へ
    case error  // エラー
}

public struct UserInfo {
    let nlcUserInfo:NLCUserInfo!
    let sttUserInfo:STTUserInfo!
    
    public init(param_nlcUserInfo:NLCUserInfo!,param_ttsUserInfo:STTUserInfo!) {
        nlcUserInfo = param_nlcUserInfo
        sttUserInfo = param_ttsUserInfo
    }
    
}

public struct NLCUserInfo {
    let userId:String!
    let pass:String!
    let nlcId:String!
    
    public init(param_userId:String! ,param_pass:String!,param_nlcId:String!) {
        userId = param_userId
        pass = param_pass
        nlcId = param_nlcId
    }
}

public struct STTUserInfo {
    let userId:String!
    let pass:String!
    
    public init(param_userId:String! ,param_pass:String!) {
        userId = param_userId
        pass = param_pass
    }
}

public class VoiceController: NSObject {
    
    let userInfo:UserInfo
    
    public init(param_userInfo:UserInfo) {
        userInfo = param_userInfo
    }
    
    public func startControl(wavFile:Data, comletion: @escaping ((_ result:voiceAction,_ error:Error?) -> Void)) {
        let sttUserId = self.userInfo.sttUserInfo.userId
        let sttPassword = self.userInfo.sttUserInfo.pass
        let speechToTextInstans = SpeechToText (username: sttUserId!,password: sttPassword!)
        
        var settings = RecognitionSettings(contentType: .wav)
        settings.interimResults = true
        let failure = { (error: Error) in print(error) }
        speechToTextInstans.recognize(audio: wavFile, settings: settings, failure: failure) {
            results in
            print(results.bestTranscript)
            
            let naturalLanguageClassifier = NaturalLanguageClassifier(username:self.userInfo.nlcUserInfo.userId, password: self.userInfo.nlcUserInfo.pass)
            
            let classifierID = self.userInfo.nlcUserInfo.nlcId
            let text = results.bestTranscript
            let failure = {
                (error: Error) in print(error)
                comletion(voiceAction.error,error)
            }
            naturalLanguageClassifier.classify(text, withClassifierID: classifierID!, failure: failure) {
                classification in
                print(classification)
                var result:voiceAction
                if classification.topClass == "次へ" {
                    result = voiceAction.next
                } else if classification.topClass == "前へ" {
                    result = voiceAction.prev
                } else {
                    result = voiceAction.unknow
                }
                comletion(result,nil)
            }
        }
    }
}
