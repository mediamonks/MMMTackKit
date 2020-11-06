//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

@testable import MMMTackKit
import UIKit
import XCTest

class TackBoxTestCase: XCTestCase {

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
		
		let box = Tack.Box<State>()
		
		let oneConstraints = Tack.constraints(.H(|-20-viewA))
		let twoConstraints = Tack.constraints(.H(|-40-viewA))
		let threeConstraints = Tack.constraints(.H(|-60-viewA))
		
		box[.one] = oneConstraints
		box[.two] = twoConstraints
		box[.three] = threeConstraints
		
		box.set(state: .one)
		box.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
		
		// Without calling updateConstraints no (de)activation should occur.
		box.set(state: .two)
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		
		box.updateConstraints()
		
		XCTAssertFalse(oneConstraints.allSatisfy { $0.isActive })
		XCTAssert(twoConstraints.allSatisfy { $0.isActive })
		
		box.set(states: [.three, .one])
		box.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssert(threeConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .one)
		box.updateConstraints()
		
		XCTAssert(oneConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .two)
		box.updateConstraints()
		
		XCTAssertFalse(oneConstraints.allSatisfy { $0.isActive })
		XCTAssert(twoConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(threeConstraints.allSatisfy { $0.isActive })
	}
	
	func testMultiple() {
		
		let box = Tack.Box<State>(state: .one)
		
		let aConstraints = Tack.constraints(.H(|-20-viewA))
		let bConstraints = Tack.constraints(.H(|-40-viewA))
		let cConstraints = Tack.constraints(.H(|-60-viewA))
		
		box[.one] = aConstraints
		box[.two] = bConstraints
		box[.three] = cConstraints
		
		box.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box[.one] = bConstraints
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .two)
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.remove(state: .three)
		box.remove(state: .one)
		
		box.add(states: [.one, .three], constraints: aConstraints)
		
		box.set(state: .one)
		box.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.add(states: [.two, .three], constraints: cConstraints, bConstraints)
		
		box.set(state: .three)
		box.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .two)
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })

		box.set(states: [.one, .two, .three])
		box.updateConstraints()
	}
	
	func testStateChanges() {
		
		let box = Tack.Box<State>(state: .one)
		
		let aConstraints = Tack.constraints(.H(|-20-viewA))
		let bConstraints = Tack.constraints(.H(|-40-viewA))
		let cConstraints = Tack.constraints(.H(|-60-viewA))
		
		box[.one] = aConstraints
		box[.two] = bConstraints
		box[.three] = cConstraints
		
		box.updateConstraints()
		
		XCTAssert(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .two)
		box.set(state: .three)
		
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(bConstraints.allSatisfy { $0.isActive })
		XCTAssert(cConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .two)
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.set(state: .three)
		box.set(state: .two)
		box.set(state: .one)
		box.set(state: .two)
		
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
		
		box.updateConstraints()
		box.updateConstraints()
		box.updateConstraints()
		
		XCTAssertFalse(aConstraints.allSatisfy { $0.isActive })
		XCTAssert(bConstraints.allSatisfy { $0.isActive })
		XCTAssertFalse(cConstraints.allSatisfy { $0.isActive })
	}
}
