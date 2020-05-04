//
//  ViewController.swift
//  PseudoSwiftApp
//
//  Created by Clayton Garrett on 4/21/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit
import PseudoSwift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
              
              let sharksInWaterFunction = Function<Bool>( {
                  Var("sharksInWater", false)
                  "sharksInWater".toggle()
                  <<<"sharksInWater"
              }, name: "sharksInWater")
              
              let goingToBeachFunc = Function<Bool> {
                  sharksInWaterFunction
                  Let("wavesAreHigh", false)
                  Var("beachIsOpen", true)
                  Var("goingToTheBeach", true)
                  BoolAnd(varToSet: "beachIsOpen", leftVar: "sharksInWater", rightVar: "wavesAreHigh")
                  If("beachIsOpen",
                     Then: ["goingToTheBeach" <~ True()],
                     Else: ["goingToTheBeach" <~ False()]
                  )
                  Return("goingToTheBeach")
              }
              
              do {
                  let goingToBeach = try goingToBeachFunc()
                  print(goingToBeach)
              } catch {
                  fatalError()
              }
    }


}

