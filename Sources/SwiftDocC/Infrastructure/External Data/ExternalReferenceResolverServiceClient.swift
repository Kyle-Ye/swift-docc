/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

@_predatesConcurrency import Foundation
import SymbolKit

/// A client for performing link resolution requests to a documentation server.
actor ExternalReferenceResolverServiceClient {
    /// The maximum amount of time, in seconds, to await a response from the external reference resolver.
    static let responseTimeout = 5

    /// The documentation server to which link resolution requests should be sent to.
    var server: DocumentationServer

    /// The identifier of the convert request that initiates the reference resolution requests.
    var convertRequestIdentifier: String?

    private var encoder = JSONEncoder()

    init(server: DocumentationServer, convertRequestIdentifier: String?) {
        self.server = server
        self.convertRequestIdentifier = convertRequestIdentifier
    }

    func send<Request: Codable>(_ request: Request) async throws -> Data {
        fatalError()
//        do {
//            let encodedRequest = try encoder.encode(
//                ConvertRequestContextWrapper(
//                    convertRequestIdentifier: convertRequestIdentifier,
//                    payload: request
//                )
//            )
//
//
//
//            let messageData = try self.encoder.encode(message)
//
//            self.server.process(messageData) { responseData in
//                defer { resultGroup.leave() }
//
//                result = self.decodeMessage(responseData).map(\.payload)
//            }
//        } catch {
//            result = .failure(.failedToEncodeRequest(underlyingError: error))
//            resultGroup.leave()
//        } catch let error as Error{
//            logError(error)
//            throw error
//        }
    }

    private func decodeMessage(_ data: Data) throws -> DocumentationServer.Message {
        let message: DocumentationServer.Message
        do {
            message = try JSONDecoder().decode(DocumentationServer.Message.self, from: data)
        } catch {
            throw Error.invalidResponse(underlyingError: error)
        }
        guard message.type == "resolve-reference-response" else {
            throw Error.invalidResponseType(receivedType: message.type.rawValue)
        }
        return message
    }

    private func logError(_ error: Error) {
        switch error {
        case let .failedToEncodeRequest(underlyingError):
            xlog("Unable to encode request for request: \(underlyingError.localizedDescription)")
        case let .invalidResponse(underlyingError):
            xlog("Received invalid response when resolving request: \(underlyingError.localizedDescription)")
        case let .invalidResponseType(receivedType):
            xlog("Received unknown response type when resolving request: '\(receivedType)'")
        case .missingPayload:
            xlog("Received nil payload when resolving request.")
        case .timeout:
            xlog("Timed out when resolving request.")
        case let .receivedErrorFromServer(message):
            xlog("Received error from server when resolving request: \(message)")
        case .unknownError:
            xlog("Unknown error when resolving request.")
        }
    }

    enum Error: Swift.Error {
        case failedToEncodeRequest(underlyingError: Swift.Error)
        case invalidResponse(underlyingError: Swift.Error)
        case invalidResponseType(receivedType: String)
        case missingPayload
        case timeout
        case receivedErrorFromServer(message: String)
        case unknownError
    }
}
