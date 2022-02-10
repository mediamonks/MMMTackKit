//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

@testable import MMMTackKit
import UIKit
import XCTest

internal final class TackBuilderTestCase: BaseTestCase {
	
	public func testBuilding() {
		
		let constaints = Tack.constraints {
			Tack.V(|-(padding)-viewA)
			Tack.H(|-(padding)-viewA)
		}
		
		XCTAssertEqual(constaints.count, 2)
	}
	
	public func testConditionals() {
		
		func build(bool: Bool) -> [NSLayoutConstraint] {
			Tack.constraints {
				Tack.V(|-(padding)-viewA)
				Tack.H(|-(padding)-viewA)
				
				if bool {
					Tack.H(|-(padding)-viewB)
				} else {
					Tack.H(|-(padding)-viewB)
					Tack.V(|-(padding)-viewB)
				}
			}
		}
		
		XCTAssertEqual(build(bool: true).count, 3)
		XCTAssertEqual(build(bool: false).count, 4)
	}
	
	private enum Case {
		case one, two, three
	}
	
	public func testSwitch() {
		
		func build(value: Case) -> [NSLayoutConstraint] {
			Tack.constraints {
				Tack.V(|-(padding)-viewA)
				Tack.H(|-(padding)-viewA)
				
				switch value {
				case .one:
					Tack.H(|-(padding)-viewB)
				case .two:
					Tack.V(|-(padding)-viewB)
					Tack.H(|-(padding)-viewB)
				
				case .three:
					Tack.V(|-(padding)-viewB-(padding)-|)
					Tack.H(|-(padding)-viewB-(padding)-|)
				}
			}
		}
		
		XCTAssertEqual(build(value: .one).count, 3)
		XCTAssertEqual(build(value: .two).count, 4)
		XCTAssertEqual(build(value: .three).count, 6)
	}
	
	public func testAllInOne() {
		
		let value = Case.three
		let bool = false
		let bool2 = false
		
		Tack.activate {
			Tack.V(|-(padding)-viewA)
			Tack.H(|-(padding)-viewA)
			
			if bool {
				Tack.V(viewA-(padding)-|)
			}
			
			if bool2 {
				Tack.V(|-(>=padding)-viewA)
			} else {
				Tack.H(|-(>=padding)-viewA)
				Tack.V(|-(>=padding)-viewA)
			}
			
			switch value {
			case .one:
				Tack.H(|-(padding)-viewB)
			case .two:
				Tack.V(|-(padding)-viewB)
				Tack.H(|-(padding)-viewB)
			
			case .three:
				Tack.V(|-(padding)-viewB-(padding)-|)
				Tack.H(|-(padding)-viewB-(padding)-|)
			}
		}
	}
}
