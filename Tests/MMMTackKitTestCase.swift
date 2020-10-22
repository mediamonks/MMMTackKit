//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import MMMTackKit
import UIKit
import XCTest

class TackKitTestCase: XCTestCase {

	private var container: UIView!
	private var viewA: UIView!
	private var viewB: UIView!

	private var views: [String: UIView]!
	private var metrics: [String: CGFloat]!
	private let padding: CGFloat = 10

	override func setUp() {

		super.setUp()

		container = UIView()
		viewA = UIView()
		container.addSubview(viewA)
		viewB = UIView()
		container.addSubview(viewB)

		views = [ "viewA": viewA, "viewB": viewB ]
		metrics = [ "padding": padding ]
	}

	func assertEqual(_ a: NSLayoutConstraint, _ b: NSLayoutConstraint) {

		if (a.firstItem === b.firstItem && a.secondItem === b.secondItem) {
			XCTAssertEqual(a.firstAttribute.rawValue, b.firstAttribute.rawValue)
			XCTAssertEqual(a.secondAttribute.rawValue, b.secondAttribute.rawValue)
			XCTAssertEqual(a.multiplier, b.multiplier)
			XCTAssertEqual(a.constant, b.constant)
		} else if (a.firstItem === b.secondItem && a.secondItem === b.firstItem) {
			XCTAssertEqual(a.firstAttribute.rawValue, b.secondAttribute.rawValue)
			XCTAssertEqual(a.secondAttribute.rawValue, b.firstAttribute.rawValue)
			XCTAssertEqual(a.multiplier, 1 / b.multiplier)
			XCTAssertEqual(a.constant, -b.constant)
		} else {
			XCTFail("Constraints differ in their items")
		}
	}

	func assertEqualConstraints(_ a: [NSLayoutConstraint], _ b: [NSLayoutConstraint]) {

		if a.count != b.count {
			XCTFail("Number of constraints differs: \(a.count) vs \(b.count)")
			return
		}

		for i in 0..<a.count {
			assertEqual(a[i], b[i])
		}
	}

	private func withTack(_ tack: TackKit.Horizontal) -> [NSLayoutConstraint] {
		return tack.constraints()
	}

	private func withFormat(_ visualFormat: String) -> [NSLayoutConstraint] {
		return NSLayoutConstraint.constraints(
			withVisualFormat: visualFormat,
			options: [], metrics: metrics, views: views
		)
	}

	private let iterations = 10000

	@objc func testVisualLayoutPerformance() {
		self.measure {
			for _ in 1...iterations {
				let _ = withFormat("H:|-(>=padding@700)-[viewA]-(padding)-[viewB]")
			}
		}
	}

	@objc func testTackPerformance() {
		self.measure {
			for _ in 1...iterations {
				let _ = withTack(TackKit.H |-- .ge(padding, 700) --* viewA *-- .eq(padding, 1000) --* viewB )
			}
		}
	}

	func testBasics() {

		// TackKit.H |-- padding --* viewA

		assertEqualConstraints(
			withTack(TackKit.H |-- padding --* viewA),
			withFormat("H:|-(padding)-[viewA]")
		)
		assertEqualConstraints(
			withTack(TackKit.H |-- .eq(padding, 700) --* viewA),
			withFormat("H:|-(padding@700)-[viewA]")
		)
		assertEqualConstraints(
			withTack(TackKit.H |-- .ge(padding, 700) --* viewA),
			withFormat("H:|-(>=padding@700)-[viewA]")
		)

		// TackKit.H viewA *-- padding *-- viewB

		assertEqualConstraints(
			withTack(TackKit.H & viewA *-- .eq(padding, 1000) --* viewB),
			withFormat("H:[viewA]-(padding)-[viewB]")
		)
		assertEqualConstraints(
			withTack(TackKit.H & viewA *-- .ge(padding, 700) --* viewB),
			withFormat("H:[viewA]-(>=padding@700)-[viewB]")
		)

		// TackKit.H viewA *-- padding --|


		// A chain.
		assertEqualConstraints(
			withTack(TackKit.H |-- .ge(padding, 700) --* viewA *-- .eq(padding, 1000) --* viewB ),
			withFormat("H:|-(>=padding@700)-[viewA]-(padding)-[viewB]")
		)
	}
}
