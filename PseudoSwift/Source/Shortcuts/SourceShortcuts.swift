/// Some useful operators to slim down your FunctionStep construction

infix operator ~>
infix operator &&
infix operator ||
prefix operator >

func &&(lhs: String, rhs: String) -> BoolAndPartial {
    return BoolAndPartial(leftVar: lhs, rightVar: rhs)
}

func ||(lhs: String, rhs: String) -> BoolOrPartial {
    return BoolOrPartial(leftVar: lhs, rightVar: rhs)
}

func ~>(lhs: String, rhs: Bool) -> Variable<Bool> {
    return Variable(rhs, name: lhs, isOutput: false)
}

func ~>(lhs: String, rhs: BoolAndPartial) -> BoolAnd {
    return BoolAnd(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
}

func ~>(lhs: String, rhs: BoolOrPartial) -> BoolOr {
    return BoolOr(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
}

prefix func >(lhs: String) -> FunctionOutput {
    return FunctionOutput(name: lhs)
}
