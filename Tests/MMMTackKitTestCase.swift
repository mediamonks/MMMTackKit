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

			XCTAssertEqual(a.firstAttribute, b.firstAttribute)
			XCTAssertEqual(a.secondAttribute, b.secondAttribute)
			XCTAssertEqual(a.multiplier, b.multiplier)

			XCTAssertEqual(a.constant, b.constant)
			XCTAssertEqual(a.relation, b.relation)

		} else if (a.firstItem === b.secondItem && a.secondItem === b.firstItem) {

			XCTAssertEqual(a.firstAttribute, b.secondAttribute)
			XCTAssertEqual(a.secondAttribute, b.firstAttribute)
			XCTAssertEqual(a.multiplier, 1 / b.multiplier)
			XCTAssertEqual(a.constant, -b.constant)

			func opposite(_ r: NSLayoutConstraint.Relation) -> NSLayoutConstraint.Relation {
				switch r {
				case .equal:
					return .equal
				case .greaterThanOrEqual:
					return .lessThanOrEqual
				case .lessThanOrEqual:
					return .greaterThanOrEqual
				}
			}
			XCTAssertEqual(a.relation, opposite(b.relation))

		} else {
			XCTFail("Constraints differ in their items")
		}
	}

	func assertEqualConstraints(_ a: [NSLayoutConstraint], _ b: [NSLayoutConstraint]) {
		XCTAssertEqual(a.count, b.count, "Expected the same number of constraints")
		for i in a.indices {
			assertEqual(a[i], b[i])
		}
	}

	private let iterations = 10000

	@objc func testVisualLayoutPerformance() {
		self.measure {
			for _ in 1...iterations {
				let _ = NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-(>=padding)-[viewA]-(padding)-[viewB]",
					options: [], metrics: metrics, views: views
				)
			}
		}
	}

	@objc func testTackKitPerformance() {
		self.measure {
			for _ in 1...iterations {
				let _ = Tack.H(|-(>=padding)-viewA-padding-viewB)
			}
		}
	}

	// Not really a test, just to check if different combinations compile.
	func testBuilding() {

		print(Tack.H(|-.eq(padding)-viewA))
		print(Tack.H(|-(==padding)-viewA))
		print(Tack.H(|-(padding)-viewA))
		print(Tack.H(|-padding-viewA))

		print(Tack.H(|-.ge(padding)-viewA))
		print(Tack.H(|-(>=padding)-viewA))

		print(Tack.H(viewA-(.eq(padding))-viewB))
		print(Tack.H(viewA-(padding)-viewB))
		print(Tack.H(viewA-padding-viewB))

		print(Tack.H(viewB-(.eq(padding))-|))
		print(Tack.H(viewB-(padding)-|))
		print(Tack.H(viewB-padding-|))
	}

	func testBasics() {
		let axes: [(String, NSLayoutConstraint.Axis)] = [
			("H:", .horizontal),
			("V:", .vertical)
		]
		for axis in axes {

			func check(_ tack: Tack.Chain, _ visualFormat: String) {
				assertEqualConstraints(
					tack.axis(axis.1),
					NSLayoutConstraint.constraints(
						withVisualFormat: "\(axis.0)\(visualFormat)",
						options: [], metrics: metrics, views: views
					)
				)
			}

			// |- padding - viewA
			check(
				(|-padding-viewA),
				"|-(padding)-[viewA]"
			)
			check(
				(|-(.eq(padding, .defaultHigh - 1))-viewA),
				"|-(padding@749)-[viewA]"
			)
			check(
				(|-(padding^749)-viewA),
				"|-(padding@749)-[viewA]"
			)
			check(
				(|-.ge(padding, .defaultHigh - 1)-viewA),
				"|-(>=padding@749)-[viewA]"
			)
			check(
				(|-(>=padding^749)-viewA),
				"|-(>=padding@749)-[viewA]"
			)

			// viewA - padding - viewB
			check(
				(viewA-padding-viewB),
				"[viewA]-(padding)-[viewB]"
			)
			check(
				(viewA-(.eq(padding))-viewB),
				"[viewA]-(padding)-[viewB]"
			)
			check(
				(viewA-(.ge(padding, 749))-viewB),
				"[viewA]-(>=padding@749)-[viewB]"
			)

			// viewA - padding -|
			check(
				(viewA-(.eq(padding))-|),
				"[viewA]-(padding)-|"
			)

			// A chain.
			check(
				(|-(.ge2(padding, 749))-viewA-(>=padding)-viewB-(padding^249)-|),
				"|-(>=padding,padding@749)-[viewA]-(>=padding)-[viewB]-(padding@249)-|"
			)
		}
	}
}
