/// Some useful operators to slim down your FunctionStep construction

infix operator <~
infix operator &&
infix operator ||
prefix operator <<<

func &&(lhs: String, rhs: String) -> BoolAndPartial {
    return BoolAndPartial(leftVar: lhs, rightVar: rhs)
}

func ||(lhs: String, rhs: String) -> BoolOrPartial {
    return BoolOrPartial(leftVar: lhs, rightVar: rhs)
}

func <~(lhs: String, rhs: Bool) -> ValueGettable<Bool> {
    return ValueGettable(lhs, rhs)
}

func <~(lhs: String, rhs: BoolAndPartial) -> BoolAnd {
    return BoolAnd(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
}

func <~(lhs: String, rhs: BoolOrPartial) -> BoolOr {
    return BoolOr(varToSet: lhs, leftVar: rhs.leftVar, rightVar: rhs.rightVar)
}

func <~(lhs: String, rhs: True) -> SetBool {
    return SetBool(varToSet: lhs, value: true)
}

func <~(lhs: String, rhs: False) -> SetBool {
    return SetBool(varToSet: lhs, value: false)
}

prefix func <<<(lhs: String) -> FunctionOutput {
    return FunctionOutput(name: lhs)
}
