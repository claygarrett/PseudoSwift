# PseudoSwift
An experimental Swift library that allows you to programmatically create new types and functions at runtime. Write programs with PseudoSwift inside a running Swift app! 

[Note: Still early and very much a WIP] 

## Overview

I thought it'd be an interesting project to be able to programatically define new types and functions at runtime, and attempt to build small programs atop them. PseudoSwift is an exploration of that idea and I'm sure will change quite significantly over time in its design.

I started with a couple of fundamental types: `Variable`, `Function`, and `FunctionStep`. Let's start by seeing what it looks like to build a simple function with these building blocks at compile time:

```
 let makeBeachDecision = Function<Bool> {
    Variable("sharksInWater", false)
    Variable("wavesAreHigh", false)
    Variable("beachIsOpen", true)
    Variable("goingToTheBeach", true)
    "sharksInWater".toggle()
    "beachIsOpen" <~ ("sharksInWater" && "wavesAreHigh")
    If("beachIsOpen",
       Then: ["goingToTheBeach" <~ True()],
       Else: ["goingToTheBeach" <~ False()]
    )
    <<<"goingToTheBeach"
}

let goingToTheBeach = makeBeachDecision(
print(goingToTheBeach) // prints false
```

