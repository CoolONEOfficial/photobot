// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Vapor
import AnyCodable

extension NodeAction.Action {

    enum CodingKeys: String, CodingKey {
        case moveToNode
        case moveToBuilder
        case pop
        case id
        case of
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.moveToNode), try container.decodeNil(forKey: .moveToNode) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .moveToNode)
            let id = try associatedValues.decode(UUID.self, forKey: .id)
            self = .moveToNode(id: id)
            return
        }
        if container.allKeys.contains(.moveToBuilder), try container.decodeNil(forKey: .moveToBuilder) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .moveToBuilder)
            let of = try associatedValues.decode(BuildableType.self, forKey: .of)
            self = .moveToBuilder(of: of)
            return
        }
        if container.allKeys.contains(.pop), try container.decodeNil(forKey: .pop) == false {
            self = .pop
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .moveToNode(id):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .moveToNode)
            try associatedValues.encode(id, forKey: .id)
        case let .moveToBuilder(of):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .moveToBuilder)
            try associatedValues.encode(of, forKey: .of)
        case .pop:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pop)
        }
    }

}
