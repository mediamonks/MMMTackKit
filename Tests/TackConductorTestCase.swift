//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

@testable import MMMTackKit
import UIKit
import XCTest

class TackConductorTestCase: XCTestCase {

	enum State {
		case one, two, three
	}

	private var container: UIView!
	private var viewA: UIView!
	private var viewB: UIView!
	private var viewC: UIView!

	override func setUp() {

		super.setUp()

		container = UIView()

		viewA = UIView()
		container.addSubview(viewA)

		viewB = UIView()
		container.addSubview(viewB)

		viewC = UIView()
		container.addSubview(viewC)
	}

	func testBasics() {
		
		let conductor = Tack.Conductor<State>()
		
		let oneConstraints = Tack.constraints(.H(|-20-viewA))
		let twoConstraints = Tack.constraints(.H(|-40-viewA))
		let threeConstraints = Tack.constraints(.H(|-60-viewA))
		
		conductor[.one] = oneConstraints
		conductor[.two] = twoConstraints
		conductor[.three] = threeConstraints
		
		conductor.activeState = .one
		conductor.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
		
		// Without calling updateConstraints no (de)activation should occur.
		conductor.activeState = .two
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		
		conductor.updateConstraints()
		
		XCTAssertFalse(oneConstraints.allSatisfy { $0.isActive })
		XCTAssert(twoConstraints.allSatisfy { $0.isActive })
		
		conductor.activeStates = [.three, .one]
		conductor.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssert(threeConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .one
		conductor.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .two
		conductor.updateConstraints()
		
		XCTAssertFalse(oneConstraints.allSatisfy { $0.isActive })
		XCTAssert(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
	}
	
	func testMultiple() {
		
		let conductor = Tack.Conductor<State>(activeState: .one)
		
		let aConstraints = Tack.constraints(.H(|-20-viewA))
		let bConstraints = Tack.constraints(.H(|-40-viewA))
		let cConstraints = Tack.constraints(.H(|-60-viewA))
		
		conductor[.one] = aConstraints
		conductor[.two] = bConstraints
		conductor[.three] = cConstraints
		
		conductor.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor[.one] = bConstraints
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .two
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.remove(state: .three)
		conductor.remove(state: .one)
		
		conductor.add(states: [.one, .three], constraints: aConstraints)
		
		conductor.activeState = .one
		conductor.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.add(states: [.two, .three], constraints: cConstraints, bConstraints)
		
		conductor.activeState = .three
		conductor.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .two
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })

		conductor.activeStates = [.one, .two, .three]
		conductor.updateConstraints()
	}
	
	func testStateChanges() {
		
		let conductor = Tack.Conductor<State>(activeState: .one)
		
		let aConstraints = Tack.constraints(.H(|-20-viewA))
		let bConstraints = Tack.constraints(.H(|-40-viewA))
		let cConstraints = Tack.constraints(.H(|-60-viewA))
		
		conductor[.one] = aConstraints
		conductor[.two] = bConstraints
		conductor[.three] = cConstraints
		
		conductor.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .two
		conductor.activeState = .three
		
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .two
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.activeState = .three
		conductor.activeState = .two
		conductor.activeState = .one
		conductor.activeState = .two
		
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		conductor.updateConstraints()
		conductor.updateConstraints()
		conductor.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
	}
}
