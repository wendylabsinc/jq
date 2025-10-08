#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Cjq

/// Errors thrown by the JQ wrapper.
///
/// These map to common failure points when compiling filters, parsing input, or executing jq.
///
/// Example:
/// ```swift
/// do {
///     _ = try JQ.process(filter: "[", input: "{}")
/// } catch let error as JQError {
///     print(error.description)
/// }
/// ```
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

/// A lightweight Swift wrapper around the embedded jq C library.
///
/// Use the static `process` helpers to evaluate jq filters against JSON input.
///
/// Example – basic extraction:
/// ```swift
/// let input = "{" + "\"name\":\"Alice\",\"age\":30" + "}"
/// let out = try JQ.process(filter: ".name", input: input)
/// // out == ["\"Alice\""]
/// ```
///
/// Example – filtering arrays:
/// ```swift
/// let input = "[1,2,3,4,5]"
/// let out = try JQ.process(filter: ".[] | select(. > 3)", input: input)
/// // out == ["4", "5"]
/// ```
public final class JQ: Sendable {

    // MARK: - Internal message capture helpers
    private final class MsgBuffer {
        var messages: [String] = []
    }
    private typealias MsgCB = @convention(c) (UnsafeMutableRawPointer?, jv) -> Void
    // Capture jq error messages without printing to stderr
    private static let errorCB: MsgCB = { ctx, msg in
        let formatted = jq_format_error(msg) // consumes msg
        if jv_get_kind(formatted) == JV_KIND_STRING, let c = jv_string_value(formatted) {
            if let ctx {
                let box = Unmanaged<MsgBuffer>.fromOpaque(ctx).takeUnretainedValue()
                box.messages.append(String(cString: c))
            }
        }
        jv_free(formatted)
    }
    // Silence jq's stderr callback (e.g., from the stderr/1 builtin); store if desired
    private static let stderrCB: MsgCB = { ctx, value in
        // Dump value to string (consumes value)
        let dumped = jv_dump_string(value, 0)
        if jv_get_kind(dumped) == JV_KIND_STRING, let c = jv_string_value(dumped) {
            if let ctx {
                let box = Unmanaged<MsgBuffer>.fromOpaque(ctx).takeUnretainedValue()
                box.messages.append(String(cString: c))
            }
        }
        jv_free(dumped)
    }

    /// Apply a jq filter to a JSON string.
    ///
    /// - Parameters:
    ///   - filter: jq filter expression (e.g., ".foo", ".[] | select(.age > 21)").
    ///   - input: JSON text to process.
    /// - Returns: An array of JSON strings (each element is a single jq output value, encoded as JSON).
    /// - Throws: `JQError` if the filter fails to compile, the input is invalid, or execution fails.
    ///
    /// Example:
    /// ```swift
    /// let json = "{" + "\"nums\":[1,2,3,4]}"
    /// let results = try JQ.process(filter: ".nums[] | select(. % 2 == 0)", input: json)
    /// // results == ["2", "4"]
    /// ```
    public static func process(filter: String, input: String) throws -> [String] {
        // Initialize jq state
        var state = jq_init()
        guard let unwrappedState = state else {
            throw JQError.unexpectedError("Failed to initialize jq state")
        }
        defer { jq_teardown(&state) }

        // Install callbacks to capture errors/stderr into a Swift buffer
        let msgBox = MsgBuffer()
        let boxPtr = Unmanaged.passRetained(msgBox).toOpaque()
        defer { Unmanaged<MsgBuffer>.fromOpaque(boxPtr).release() }
        jq_set_error_cb(unwrappedState, errorCB, boxPtr)
        jq_set_stderr_cb(unwrappedState, stderrCB, boxPtr)

        // Compile the filter
        let compileResult = jq_compile(unwrappedState, filter)
        guard compileResult != 0 else {
            let message = msgBox.messages.last ?? "Failed to compile filter: \(filter)"
            throw JQError.compileError(message)
        }

        // Parse input JSON
        let parseInput = jv_parse(input)
        guard jv_is_valid(parseInput) != 0 else {
            // jv_is_valid does NOT consume, so parseInput is still valid here
            let errorMsg = jvGetErrorMessage(parseInput) ?? "Unknown parsing error"
            // jvGetErrorMessage consumes parseInput, so no jv_free needed
            throw JQError.invalidJSON(errorMsg)
        }

        // Execute the filter
        // jq_start consumes parseInput, so no jv_free needed
        jq_start(unwrappedState, parseInput, 0)

        // Collect results
        var results: [String] = []
        while true {
            let result = jq_next(unwrappedState)
            // jv_is_valid does NOT consume
            guard jv_is_valid(result) != 0 else {
                // Check if it's actually an error or just end of results
                // jv_invalid_has_msg DOES consume, so we need to copy if we want to use result again
                if jv_invalid_has_msg(jv_copy(result)) != 0 {
                    // jvGetErrorMessage consumes its argument
                    let errorMsg = jvGetErrorMessage(result) ?? "Unknown execution error"
                    // result has been consumed by jvGetErrorMessage, no free needed
                    throw JQError.executionError(errorMsg)
                }
                // jv_invalid_has_msg consumed the copy, but result is still valid
                jv_free(result)
                break
            }

            // Convert result to string (jvToString will handle memory correctly)
            if let resultStr = jvToString(result) {
                results.append(resultStr)
            }
            // jvToString passes a copy to jv_dump_string, so result is still owned by us
            jv_free(result)
        }

        return results
    }

    /// Helper function to convert jv to String
    private static func jvToString(_ value: jv) -> String? {
        // jv_dump_string consumes its argument (it frees it). Pass a copy
        // so the caller still owns `value` and can free it after use.
        let dumped = jv_dump_string(jv_copy(value), 0)

        guard jv_is_valid(dumped) != 0 else {
            jv_free(dumped)
            return nil
        }

        guard jv_get_kind(dumped) == JV_KIND_STRING else {
            jv_free(dumped)
            return nil
        }

        guard let cStr = jv_string_value(dumped) else {
            jv_free(dumped)
            return nil
        }

        let result = String(cString: cStr)
        jv_free(dumped)
        return result
    }

    /// Helper function to extract error message from invalid jv
    /// This function CONSUMES the input jv
    private static func jvGetErrorMessage(_ value: jv) -> String? {
        // jv_invalid_has_msg CONSUMES its argument
        guard jv_invalid_has_msg(jv_copy(value)) != 0 else {
            // has_msg consumed the copy, value is still valid, so free it
            jv_free(value)
            return nil
        }

        // jv_invalid_get_msg CONSUMES its argument
        let msg = jv_invalid_get_msg(value)
        // value has been consumed, don't free it

        // jv_get_kind does NOT consume
        guard jv_get_kind(msg) == JV_KIND_STRING else {
            jv_free(msg)
            return nil
        }

        // jv_string_value does NOT consume
        guard let cStr = jv_string_value(msg) else {
            jv_free(msg)
            return nil
        }

        let result = String(cString: cStr)
        jv_free(msg)
        return result
    }
}

/// Convenience extensions
extension JQ {
    /// Apply a jq filter to JSON `Data` and return outputs as `Data`.
    ///
    /// This is convenience over `process(filter:input:)` when your payloads are binary.
    /// Each returned element is a UTF-8 JSON fragment produced by jq.
    ///
    /// Example:
    /// ```swift
    /// let data = Data("{\"n\":42}".utf8)
    /// let outputs = try JQ.process(filter: ".n", jsonData: data)
    /// // outputs.first -> Data for "42"
    /// ```
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

    /// Apply a jq filter to a Codable input and decode results to a Codable output type.
    ///
    /// - Parameters:
    ///   - filter: jq filter expression.
    ///   - input: Any `Encodable` value that will be encoded to JSON for jq.
    ///   - outputType: The `Decodable` result type for each jq output value.
    /// - Returns: Array of decoded results of type `U`.
    ///
    /// Example:
    /// ```swift
    /// struct Person: Codable { let name: String; let age: Int }
    /// let people = [Person(name: "A", age: 20), Person(name: "B", age: 30)]
    /// let names: [String] = try JQ.process(
    ///     filter: "[.[] | select(.age >= 21) | .name] | .[]",
    ///     input: people,
    ///     outputType: String.self
    /// )
    /// // names == ["B"]
    /// ```
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
