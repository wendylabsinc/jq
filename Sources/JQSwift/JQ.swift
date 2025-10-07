#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Cjq

/// JQ errors
public enum JQError: Error, CustomStringConvertible {
    case compileError(String)
    case executionError(String)
    case invalidJSON(String)
    case unexpectedError(String)

    public var description: String {
        switch self {
        case .compileError(let msg): return "JQ Compile Error: \(msg)"
        case .executionError(let msg): return "JQ Execution Error: \(msg)"
        case .invalidJSON(let msg): return "Invalid JSON: \(msg)"
        case .unexpectedError(let msg): return "Unexpected Error: \(msg)"
        }
    }
}

/// Main JQ wrapper class
public final class JQ: Sendable {

    /// Apply a jq filter to JSON input
    /// - Parameters:
    ///   - filter: The jq filter expression (e.g., ".foo", ".[] | select(.age > 21)")
    ///   - input: JSON string to process
    /// - Returns: Array of JSON strings (one for each output from the filter)
    /// - Throws: JQError if compilation or execution fails
    public static func process(filter: String, input: String) throws -> [String] {
        // Initialize jq state
        var state = jq_init()
        guard let unwrappedState = state else {
            throw JQError.unexpectedError("Failed to initialize jq state")
        }
        defer { jq_teardown(&state) }

        // Compile the filter
        let compileResult = jq_compile(unwrappedState, filter)
        guard compileResult != 0 else {
            throw JQError.compileError("Failed to compile filter: \(filter)")
        }

        // Parse input JSON
        let parseInput = jv_parse(input)
        guard jv_is_valid(parseInput) != 0 else {
            let errorMsg = jvGetErrorMessage(parseInput) ?? "Unknown parsing error"
            jv_free(parseInput)
            throw JQError.invalidJSON(errorMsg)
        }

        // Execute the filter
        jq_start(unwrappedState, parseInput, 0)

        // Collect results
        var results: [String] = []
        while true {
            let result = jq_next(unwrappedState)
            guard jv_is_valid(result) != 0 else {
                // Check if it's actually an error or just end of results
                if jv_invalid_has_msg(jv_copy(result)) != 0 {
                    let errorMsg = jvGetErrorMessage(result) ?? "Unknown execution error"
                    jv_free(result)
                    throw JQError.executionError(errorMsg)
                }
                jv_free(result)
                break
            }

            // Convert result to string
            if let resultStr = jvToString(result) {
                results.append(resultStr)
            }
            jv_free(result)
        }

        return results
    }

    /// Helper function to convert jv to String
    private static func jvToString(_ value: jv) -> String? {
        let dumped = jv_dump_string(value, 0)
        defer { jv_free(dumped) }

        guard jv_get_kind(dumped) == JV_KIND_STRING else {
            return nil
        }

        let cStr = jv_string_value(dumped)
        return cStr.map { String(cString: $0) }
    }

    /// Helper function to extract error message from invalid jv
    private static func jvGetErrorMessage(_ value: jv) -> String? {
        guard jv_invalid_has_msg(jv_copy(value)) != 0 else {
            return nil
        }

        let msg = jv_invalid_get_msg(value)
        defer { jv_free(msg) }

        guard jv_get_kind(msg) == JV_KIND_STRING else {
            return nil
        }

        let cStr = jv_string_value(msg)
        return cStr.map { String(cString: $0) }
    }
}

/// Convenience extensions
extension JQ {
    /// Process JSON data and return as Data
    public static func process(filter: String, jsonData: Data) throws -> [Data] {
        guard let inputStr = String(data: jsonData, encoding: .utf8) else {
            throw JQError.invalidJSON("Input data is not valid UTF-8")
        }

        let results = try process(filter: filter, input: inputStr)
        return try results.map { resultStr in
            guard let data = resultStr.data(using: .utf8) else {
                throw JQError.unexpectedError("Failed to convert result to UTF-8 data")
            }
            return data
        }
    }

    /// Process a JSON object directly (convenience for Codable types)
    public static func process<T: Encodable, U: Decodable>(
        filter: String,
        input: T,
        outputType: U.Type = U.self
    ) throws -> [U] {
        let encoder = JSONEncoder()
        let inputData = try encoder.encode(input)
        guard let inputStr = String(data: inputData, encoding: .utf8) else {
            throw JQError.invalidJSON("Failed to encode input")
        }

        let results = try process(filter: filter, input: inputStr)
        let decoder = JSONDecoder()

        return try results.map { resultStr in
            guard let resultData = resultStr.data(using: .utf8) else {
                throw JQError.unexpectedError("Failed to convert result to data")
            }
            return try decoder.decode(U.self, from: resultData)
        }
    }
}
