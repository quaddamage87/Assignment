//
//  APIClient.swift
//  Assignment
//
//  Created by Martijn Breet on 21/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation

enum HTTPStatusCode: Int {
    
    // Success - 2XX
    case ok = 200
    case created = 201
    case accepted = 202
    
    // Client error - 4XX
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    
    // Server error - 5XX
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    
}

enum APIError: Error {
    case client(reason: String?)
    case decoding(reason: [String: Any]?)
    case network(httpStatusCode: HTTPStatusCode)
    case unexpectedResponseFormat
    case networkUnreachable
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .client(reason: let reason):
            return NSLocalizedString("A client-side error occurred: \(reason ?? "no reason given")", comment: "client error")
        case .decoding(let json):
            return NSLocalizedString("A json decoding error occurred for: \(json?.description ?? "no json given")", comment: "decoding error")
        case .network(let httpStatusCode):
            return NSLocalizedString("A network error occurred with http status code: \(String(httpStatusCode.rawValue) )", comment: "network error")
        case .unexpectedResponseFormat:
            return NSLocalizedString("Received an unexpected API response format", comment: "response format error")
        case .networkUnreachable:
            return NSLocalizedString("No internet connection available", comment: "network unreachable error")
        }
    }
}

enum HTTPRequestMethod: String {
    case delete, get, patch, post, put
}

enum APIResult<T: APIResource> {
    case failure(error: APIError)
    case success(result: T.Response)
}

protocol APIResource {
    associatedtype Response: Codable // API response object, which holds the result
    var path: String { get }
    var httpRequestMethod: HTTPRequestMethod { get }
    var additionalHeaders: [String: String]? { get }    // optional headers
    var httpBody: Data? { get }                         // optional body
    var queryItems: [URLQueryItem]? { get }             // optional query params
}

extension APIResource {
    func buildRequest(withBaseUrl baseUrl: URL?) -> URLRequest? {
        guard let url = buildUrl(withBaseUrl: baseUrl) else {
            NSLog("Couldn't build request for resource: \(String(describing: self))")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpRequestMethod.rawValue
        request.httpBody = httpBody

        additionalHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
    
    func buildUrl(withBaseUrl baseUrl: URL?) -> URL? {
        guard
            let baseUrl = baseUrl,
            var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        else {
            NSLog("Couldn't build url for resource: \(String(describing: self))")
            return nil
        }
        urlComponents.path = baseUrl.path.appending(path)
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
}

protocol APIClient {
    var baseUrlComponents: URLComponents { get }
    
    func fetch<T: APIResource>(with resource: T,
               completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {

    func fetch<T: APIResource>(with resource: T,
    completion: @escaping (APIResult<T>) -> Void) {
        
        // handle bad weather condition: no internet connection
        do {
            let reachability = try! Reachability()
            if reachability.connection == .unavailable {
                completion(.failure(error: APIError.networkUnreachable))
                return
            }
        }
        // handle bad weather condition: invalid resource url
        guard
            let request = resource.buildRequest(withBaseUrl: baseUrlComponents.url)
        else {
            completion(.failure(error: APIError.client(reason: "couldn't construct resource request")))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // handle bad weather condition: unexpected http response
            guard
                let httpResponse = response as? HTTPURLResponse,
                let httpStatusCode = HTTPStatusCode(rawValue: httpResponse.statusCode)
            else {
                completion(.failure(error: APIError.unexpectedResponseFormat))
                return
            }
            // handle bad weather condition: bad http response codes
            guard httpResponse.statusCode == HTTPStatusCode.ok.rawValue else {
                completion(.failure(error: APIError.network(httpStatusCode: httpStatusCode)))
                return
            }
            // handle bad weather condition: json decoding error
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.Response.self, from: data!)
                completion(.success(result: result))
            } catch let error as NSError {
                completion(.failure(error: APIError.decoding(reason: error.userInfo)))
                return
            }
        }
        task.resume()
    }
    
}
