//
//  JSON.swift
//  JSON
//
//  Created by Swain Molster on 8/2/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

public enum JSON: Codable, Equatable {
    case number(Double)
    case string(String)
    case boolean(Bool)
    case array([JSON])
    case dictionary([String: JSON])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: JSON].self) {
            self = .dictionary(dict)
        } else {
            self = .null
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .number(let double):
            try container.encode(double)
        case .string(let string):
            try container.encode(string)
        case .boolean(let bool):
            try container.encode(bool)
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dict):
            try container.encode(dict)
        case .null:
            try container.encodeNil()
        }
    }
}

extension JSON {
    public subscript(index: Int) -> JSON {
        get {
            guard case .array(let array) = self else { fatalError() }
            return array[index]
        }
        set {
            guard case .array(var array) = self else { return }
            array[index] = newValue
            self = .array(array)
        }
    }
    
    public subscript(key: String) -> JSON? {
        get {
            guard case .dictionary(let dict) = self else { return nil }
            return dict[key]
        }
        set {
            guard case .dictionary(var dict) = self else { return }
            dict[key] = newValue
            self = .dictionary(dict)
        }
    }
    
    public var asNumber: Double? {
        guard case .number(let double) = self else { return nil }
        return double
    }
    
    public var asString: String? {
        guard case .string(let string) = self else { return nil }
        return string
    }
    
    public var asBool: Bool? {
        guard case .boolean(let bool) = self else { return nil }
        return bool
    }
    
    public var isNil: Bool {
        if case .null = self {
            return true
        } else {
            return false
        }
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .dictionary(elements.reduce(into: [String: JSON](), { $0[$1.0] = $1.1 }))
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    private func prettyPrinted(tabLevel: Int) -> String {
        let tabs = String(repeating: "\t", count: tabLevel)
        let tabsPlusOne = String(repeating: "\t", count: tabLevel+1)
        switch self {
        case .number(let double):
            return "\(double)"
        case .string(let string):
            return "\"\(string)\""
        case .boolean(let bool):
            return "\(bool)"
        case .array(let array):
            let list = array.reduce(into: "", { $0.append("\(tabsPlusOne)\($1.prettyPrinted(tabLevel: tabLevel+1)),\n") })
            return "[\n\(list)\(tabs)]"
        case .dictionary(let dict):
            let list = dict.reduce(into: "", { $0.append("\(tabsPlusOne)\"\($1.key)\": \($1.value.prettyPrinted(tabLevel: tabLevel+1)),\n") })
            return "{\n\(list)\(tabs)}"
        case .null:
            return "nil"
        }
    }
    
    public var debugDescription: String {
        return self.prettyPrinted(tabLevel: 0)
    }
    
    public var description: String {
        return self.debugDescription
    }
}
