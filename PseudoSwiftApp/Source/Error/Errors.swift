
/// Errors related tto the use of Variables
enum VariableError: Error {
    case VariableProviderNotFound(source: String)
}
