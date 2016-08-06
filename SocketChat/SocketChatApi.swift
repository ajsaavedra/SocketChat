import Foundation
import Alamofire

enum Method: String {
    case CheckUser = "checkUser"
    case RegisterUser = "registerUser"
}

class SocketChatAPI {
    let baseURLString = "http://localhost:3000/api/";
    
    func makeCall(username: String, password: String, completionHandler: (NSDictionary?, NSError?) -> ()) {
        checkUser(username, password: password, completionHandler: completionHandler)
    }
    
    func checkUser(username: String, password: String, completionHandler: (NSDictionary?, NSError?)->()) {
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
}