         import Foundation
import Alamofire

enum Method: String {
    case CheckUser = "checkUser"
    case RegisterUser = "createUser"
}

class SocketChatAPI {
    let baseURLString = "http://localhost:3000/api/";

    func makeCall(_ username: String, password: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        checkUser(username, password: password, completionHandler: completionHandler)
    }

    func makeCallToRegister(_ username: String, password: String,
                            confirmation: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        registerUser(username, password: password, confirmation: confirmation, completionHandler: completionHandler)
    }

    func checkUser(_ username: String, password: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let url = baseURLString + Method.CheckUser.rawValue
        Alamofire.request(url, method: .post,
            parameters: ["username":username, "password": password], encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                case .failure(let error):
                    completionHandler(nil, error as NSError)
                }
        }
    }

    func registerUser(_ username: String, password: String,
                      confirmation: String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        let url = baseURLString + Method.RegisterUser.rawValue
        Alamofire.request(url, method: .post,
            parameters: ["username":username, "password": password, "confirmation": confirmation], encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                case .failure(let error):
                    completionHandler(nil, error as NSError)
                }
        }
    }
}
