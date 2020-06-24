/// Some useful operators to slim down your FunctionStep construction

//infix operator <~
//infix operator &&
////infix operator ||
//prefix operator <<<
//
//public func &&(lhs: String, rhs: String) -> BoolAndPartial {
//    return BoolAndPartial(leftVar: lhs, rightVar: rhs)
//}
////
////public func ||(lhs: String, rhs: String) -> BoolOrPartial {
////    return BoolOrPartial(leftVar: lhs, rightVar: rhs)
////}
//
//public func <~(lhs: String, rhs: Bool) -> Variable<Bool> {
//    return Variable(lhs, rhs)
//}
//
//public func <~(lhs: String, rhs: BoolAndPartial) -> BoolAnd {
//    return BoolAnd(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
//}
//
//public func <~(lhs: String, rhs: BoolOrPartial) -> BoolOr {
//    return BoolOr(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
//}
//
//public func <~(lhs: String, rhs: True) -> SetBool {
//    return SetBool(varToSet: lhs, value: true)
//}
//
//public func <~(lhs: String, rhs: False) -> SetBool {
//    return SetBool(varToSet: lhs, value: false)
//}
//
//public prefix func <<<(lhs: String) -> FunctionOutput {
//    return FunctionOutput(name: lhs)
//}
//
//public func Return(_ variableName: String) -> FunctionOutput {
//    return FunctionOutput(name: variableName)
//}
