
/// Errors related tto the use of Variables
public enum VariableError: Error {
    case VariableProviderNotFound(source: String)
    case VariableNameNotProvided(variable: String)

}
