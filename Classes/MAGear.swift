//
//  MAGear.swift
//  MAGearRefreshControl-Demo
//
//  Created by Michaël Azevedo on 20/02/2017.
//  Copyright © 2017 micazeve. All rights reserved.
//

import UIKit

//MARK: - MAGear Class

/// This class represents a gear in the most abstract way, without any graphical code related.
public class MAGear {
    
    //MARK: Instance properties
    
    /// The circle on which two gears effectively mesh, about halfway through the tooth.
    let pitchDiameter:CGFloat
    
    /// Diameter of the gear, measured from the tops of the teeth.
    let outsideDiameter:CGFloat
    
    /// Diameter of the gear, measured at the base of the teeth.
    let insideDiameter:CGFloat
    
    /// The number of teeth per inch of the circumference of the pitch diameter. The diametral pitch of all meshing gears must be the same.
    let diametralPitch:CGFloat
    
    /// Number of teeth of the gear.
    let nbTeeth:UInt
    
    
    //MARK: Init method
    
    /// Init method.
    ///
    /// - parameter radius: of the gear
    /// - parameter nbTeeth: Number of teeth of the gear. Must be greater than 2.
    public init (radius:CGFloat, nbTeeth:UInt) {
        
        assert(nbTeeth > 2)
        
        self.pitchDiameter = 2*radius
        self.diametralPitch = CGFloat(nbTeeth)/pitchDiameter
        self.outsideDiameter = CGFloat((nbTeeth+2))/diametralPitch
        self.insideDiameter = CGFloat((nbTeeth-2))/diametralPitch
        self.nbTeeth = nbTeeth
    }
}
