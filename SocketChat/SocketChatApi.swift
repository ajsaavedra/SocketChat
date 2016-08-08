import Foundation
import Alamofire

enum Method: String {
    case CheckUser = "checkUser"
    case RegisterUser = "createUser"
}

class SocketChatAPI {
    let baseURLString = "http://localhost:3000/api/";

    func makeCall(username: String, password: String, completionHandler: (NSDictionary?, NSError?) -> ()) {
        checkUser(username, password: password, completionHandler: completionHandler)
    }

    func makeCallToRegister(username: String, password: String,
                            confirmation: String, completionHandler: (NSDictionary?, NSError?) -> ()) {
        registerUser(username, password: password, confirmation: confirmation, completionHandler: completionHandler)
    }

    func checkUser(username: String, password: String, completionHandler: (NSDictionary?, NSError?) -> ()) {
        let url = baseURLString + Method.CheckUser.rawValue
        Alamofire.request(.POST, url,
            parameters: ["username":username, "password": password], encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    completionHandler(value as? NSDictionary, nil)
                case .Failure(let error):
                    completionHandler(nil, error)
                }
        }
    }

    func registerUser(username: String, password: String,
                      confirmation: String, completionHandler: (NSDictionary?, NSError?) -> ()) {
        let url = baseURLString + Method.RegisterUser.rawValue
        Alamofire.request(.POST, url,
            parameters: ["username":username, "password": password, "confirmation": confirmation], encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    completionHandler(value as? NSDictionary, nil)
                case .Failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
}