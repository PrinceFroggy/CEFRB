//
//  WebAPIRequest.swift
//  CEFRB
//
//  Created by Andrew Solesa on 2020-10-17.
//

import Cocoa

class WebApiRequest
{
    var urlBase = ""
    
    var httpMethod = ""
    var httpHeaders: [String: String]?
    var httpBody: Data?
    
    func sendRequest(toUrlPath urlPath: String, completion: @escaping (String, [String : String])->Void)
    {
        let encodedUrlPath = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: "\(urlBase)\(encodedUrlPath!)") else
        {
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        request.allHTTPHeaderFields = httpHeaders
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler:
        { (data, response, error) in
            
            if let error = error
            {
                return
            }
            
            let r = response as! HTTPURLResponse
            
            if (100...199).contains(r.statusCode)
            {
                let results = "Response was interim or informational"

                completion(results, ["":""])
            }
            
            if let data = data, (200...299).contains(r.statusCode)
            {
                let sortableHeaders = r.allHeaderFields as! [String: String]
                
                var results = ""

                do
                {
                    results = String(data: data, encoding: String.Encoding.utf8)!
                }
                catch
                {
                    return
                }
                
                completion(results, sortableHeaders)
            }
            
            if (300...399).contains(r.statusCode)
            {
                let results = "HTTP \(r.statusCode) - Request was redirected"

                completion(results, ["":""])
            }
            
            if (400...499).contains(r.statusCode)
            {
                let results = "HTTP \(r.statusCode) - The request caused an error"

                completion(results, ["":""])
            }
        
            if (500...599).contains(r.statusCode)
            {
                let results = "HTTP \(r.statusCode) - An error on the server happened"

                completion(results, ["":""])
            }
        })
        
        task.resume()
        
    }
}

extension DateFormatter
{
    static let iso8601Full: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
