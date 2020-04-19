# PseudoSwift
An experimental Swift library that allows you to programmatically create new types and functions at runtime. Write programs with PseudoSwift inside a running Swift app! 

[Note: Still early and very much a WIP] 

## Overview

I thought it'd be an interesting project to be able to programatically define new types and functions at runtime, and attempt to build small programs atop them. PseudoSwift is an exploration of that idea and I'm sure will change quite significantly over time in its design.

To build up the context of how this will be useful, let's say we want to build a tool in Swift that would allow users to build programs visually. Something like the following example perhaps:

![](https://github.com/claygarrett/PseudoSwift/blob/master/visual-programming-example.png)

We can't create Swift functions that didn't exist compile time. But what if we build our own custom types that acted very much like Swift functions? We could then create instances of those functions at runtime and create, call, and chain them however we like. 

That's what PseudoSwift is made for!

## How it works

I started with a couple of fundamental types that all come together via the `Function` type. Let's start by seeing what it looks like to build a simple function with a few basic building blocks at compile time:

```swift
let goingToBeachFunc = Function<Bool> {
    Var("sharksAreInWater", false)
    Let("wavesAreHigh", false)
    Var("beachIsOpen", true)
    Var("goingToTheBeach", true)
    "sharksAreInWater".toggle()
    "beachIsOpen".set("sharksInWater".and("wavesAreHigh")
    If("beachIsOpen",
       Then: ["goingToTheBeach" <~ True()],
       Else: ["goingToTheBeach" <~ False()]
    )
    Return("goingToTheBeach")
}

let goingToTheBeach = makeBeachDecision()
print(goingToTheBeach) // prints false
```

### The custom `Function` type
 
OK, so what we see here is that we're instantiating a Function which takes a single parameter via a closure. The format of this closure might look a little strange, and for good reason. 

### First Question: How's this all glued together?

The closure isn't returning anything, there's no assignment going on, and none of the lines inside of it are type-dependent on each other. How is this all glued together inside the `Function` class?

#### Function Builders

If you haven't seen the Swift Function Builders [draft proposal](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md), here's a quick recap. It allows you to declare any input parameter to a function as a "Function Builder". A function builder takes each individual in a line of a closure, and adds it to a single array. OK, technically, it converts it to a variadic parameter, but that presents itself as an Array inside your method, so it's essentially one-and-the-same. 

So, if our Function is defined like so:

```
Function<OutputType> { 
   FunctionStep1
   FuncitonStep2
   FunctionStep3
}
```

Then inside the Function initializer, we essentiallyreceive those like this:

```
class Function<T> { 
   init(steps: [FunctionStep) {
   }
}
```

It's really just some syntactic sugar so that you don't have to wrap all of the FunctionSteps yourself in an Array literal. We save the opening and closing brackets [] as well as the comma between each entry. Now, function builders also do allow you to transform the items passed into it before converting them to an array. I'm simply using only the syntactic sugar portion to clean up things at the call site so it looks more like an actual swift `func`. 

### Second Question: How's this callable like a real function?

If `makeBeachDecision` is an instance of a custom type named `Function` how are we able to call it as if it's a function?:

`let goingToTheBeach = makeBeachDecision()`

If you haven't seen the Swift Dynamically Callalble Types Builders [draft proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0216-dynamic-callable.md), here's a quick recap: A class that only has one primary method can delegate that method so that the instance of the class itself can be called like a function. All you need to do is define that single method with the name `callAsFunction` and you get this functionality for free!

