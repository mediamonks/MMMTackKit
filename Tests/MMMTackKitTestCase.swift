//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

@testable import MMMTackKit
import UIKit
import XCTest

class TackKitTestCase: XCTestCase {

	private var container: UIView!
	private var viewA: UIView!
	private var viewB: UIView!
	private var viewC: UIView!

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

		viewC = UIView()
		container.addSubview(viewC)

		views = [ "viewA": viewA, "viewB": viewB, "viewC": viewC ]
		metrics = [ "padding": padding ]
	}

	func assertEqual(_ a: NSLayoutConstraint, _ b: NSLayoutConstraint) {

		if (a.firstItem === b.firstItem && a.secondItem === b.secondItem) {

			XCTAssertEqual(a.firstAttribute, b.firstAttribute)
			XCTAssertEqual(a.secondAttribute, b.secondAttribute)
			XCTAssertEqual(a.multiplier, b.multiplier)

			XCTAssertEqual(a.constant, b.constant)
			XCTAssertEqual(a.relation, b.relation)
			XCTAssertEqual(a.priority, b.priority)

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

			XCTAssertEqual(a.priority, b.priority)

		} else {
			XCTFail("Constraints differ in their items")
		}
	}

	func assertEqualConstraints(_ a: [NSLayoutConstraint], _ b: [NSLayoutConstraint]) {
		guard a.count == b.count else {
			XCTFail("Expected equal number of constraints")
			return
		}
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
				let _ = Tack.H(|-(>=padding)-viewA-(padding)-viewB)
			}
		}
	}

	// Not really a test, just to check if different combinations compile.
	func testBuilding() {

		print(Tack.H(|-(==padding)-viewA))
		print(Tack.H(|-(padding)-viewA))
		print(Tack.H(|-padding-viewA))

		print(Tack.H(|-(>=padding)-viewA))

		print(Tack.H(viewA-(padding)-viewB))
		print(Tack.H(viewA-padding-viewB))

		print(Tack.H(viewB-(padding)-|))
		print(Tack.H(viewB-padding-|))
	}

	func testPostfixSafeArea() {
		assertEqualConstraints(
			Tack.H(viewB-(padding)-<|),
			[.init(
				item: viewB, attribute: .trailing,
				relatedBy: .equal,
				toItem: container.safeAreaLayoutGuide, attribute: .trailing,
				multiplier: 1, constant: -padding
			)]
		)
		assertEqualConstraints(
			Tack.V(viewB-(padding)-<|),
			[.init(
				item: viewB, attribute: .bottom,
				relatedBy: .equal,
				toItem: container.safeAreaLayoutGuide, attribute: .bottom,
				multiplier: 1, constant: -padding
			)]
		)
		assertEqualConstraints(
			Tack.H(viewA-(padding)-viewB-(padding)-<|),
			[
				.init(
					item: viewA, attribute: .trailing,
					relatedBy: .equal,
					toItem: viewB, attribute: .leading,
					multiplier: 1, constant: -padding
				),
				.init(
					item: viewB, attribute: .trailing,
					relatedBy: .equal,
					toItem: container.safeAreaLayoutGuide, attribute: .trailing,
					multiplier: 1, constant: -padding
				)
			]
		)
		assertEqualConstraints(
			Tack.V(viewA-(padding)-viewB-(padding)-<|),
			[
				.init(
					item: viewA, attribute: .bottom,
					relatedBy: .equal,
					toItem: viewB, attribute: .top,
					multiplier: 1, constant: -padding
				),
				.init(
					item: viewB, attribute: .bottom,
					relatedBy: .equal,
					toItem: container.safeAreaLayoutGuide, attribute: .bottom,
					multiplier: 1, constant: -padding
				)
			]
		)
	}
	
	func testPrefixSafeArea() {
		assertEqualConstraints(
			Tack.H(|>-(padding)-viewB),
			[.init(
				item: viewB, attribute: .leading,
				relatedBy: .equal,
				toItem: container.safeAreaLayoutGuide, attribute: .leading,
				multiplier: 1, constant: padding
			)]
		)
		assertEqualConstraints(
			Tack.V(|>-(padding)-viewB),
			[.init(
				item: viewB, attribute: .top,
				relatedBy: .equal,
				toItem: container.safeAreaLayoutGuide, attribute: .top,
				multiplier: 1, constant: padding
			)]
		)
		assertEqualConstraints(
			Tack.H(|>-(padding)-viewA-(padding)-viewB),
			[
				.init(
					item: viewA, attribute: .leading,
					relatedBy: .equal,
					toItem: container.safeAreaLayoutGuide, attribute: .leading,
					multiplier: 1, constant: padding
				),
				.init(
					item: viewA, attribute: .trailing,
					relatedBy: .equal,
					toItem: viewB, attribute: .leading,
					multiplier: 1, constant: -padding
				)
			]
		)
		assertEqualConstraints(
			Tack.V(|>-(padding)-viewA-(padding)-viewB),
			[
				.init(
					item: viewA, attribute: .top,
					relatedBy: .equal,
					toItem: container.safeAreaLayoutGuide, attribute: .top,
					multiplier: 1, constant: padding
				),
				.init(
					item: viewA, attribute: .bottom,
					relatedBy: .equal,
					toItem: viewB, attribute: .top,
					multiplier: 1, constant: -padding
				)
			]
		)
	}

	func testAlignment() {
		assertEqualConstraints(
			Tack.H(|-(padding)-viewA-(padding)-viewB-(padding)-viewC-(padding)-|, alignAll: .centerY),
			NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-(padding)-[viewA]-(padding)-[viewB]-(padding)-[viewC]-(padding)-|",
				options: [.alignAllCenterY],
				metrics: metrics, views: views
			)
		)
	}

	func testBasics() {
		let axes: [(String, NSLayoutConstraint.Axis)] = [
			("H:", .horizontal),
			("V:", .vertical)
		]
		for axis in axes {

			func check(_ tack: Tack.Chain, _ visualFormat: String) {
				assertEqualConstraints(
					tack.resolved(axis.1),
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
				(|-(padding^749)-viewA),
				"|-(padding@749)-[viewA]"
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
				(viewA-(padding)-viewB),
				"[viewA]-(padding)-[viewB]"
			)
			check(
				(viewA-(>=padding^749)-viewB),
				"[viewA]-(>=padding@749)-[viewB]"
			)

			// viewA - padding -|
			check(
				(viewA-(padding)-|),
				"[viewA]-(padding)-|"
			)

			// A chain.
			check(
				|-(>==padding^749)-viewA-(>=padding)-viewB-(padding^249)-|,
				"|-(>=padding,padding@749)-[viewA]-(>=padding)-[viewB]-(padding@249)-|"
			)

			// Double pins.
			check(
				(|-(>==padding^749)-viewA),
				"|-(>=padding,padding@749)-[viewA]"
			)
			check(
				viewA-(>==padding^749)-|,
				"[viewA]-(>=padding,padding@749)-|"
			)
		}
	}
	
	func testAlignmentHelpers() {
		
		// No specification given, should not place any constraints.
		// TODO: maybe should be an illegal combination instead or better have 3 versions of that excluding the one without labels?
		assertEqualConstraints(
			Tack.constraints(aligning: viewA, to: container),
			[]
		)
		
		assertEqualConstraints(
			Tack.constraints(aligning: viewA, to: container, horizontally: .fill),
			[
				NSLayoutConstraint(
					item: viewA, attribute: .left,
					relatedBy: .equal,
					toItem: container, attribute: .left,
					multiplier: 1, constant: 0
				),
				NSLayoutConstraint(
					item: viewA, attribute: .right,
					relatedBy: .equal,
					toItem: container, attribute: .right,
					multiplier: 1, constant: 0
				)
			]
		)
		
		assertEqualConstraints(
			Tack.constraints(aligning: viewA, to: container, vertically: .fill),
			[
				NSLayoutConstraint(
					item: viewA, attribute: .top,
					relatedBy: .equal,
					toItem: container, attribute: .top,
					multiplier: 1, constant: 0
				),
				NSLayoutConstraint(
					item: viewA, attribute: .bottom,
					relatedBy: .equal,
					toItem: container, attribute: .bottom,
					multiplier: 1, constant: 0
				)
			]
		)

		// TODO: maybe it should use leading/trailing instead of left/right?
		
		assertEqualConstraints(
			Tack.constraints(
				aligning: viewA, to: container,
				horizontally: .fill, vertically: .fill,
				insets: .init(top: 30, left: 20, bottom: 10, right: 5)
			),
			[
				NSLayoutConstraint(
					item: viewA, attribute: .left,
					relatedBy: .equal,
					toItem: container, attribute: .left,
					multiplier: 1, constant: 20
				),
				NSLayoutConstraint(
					item: viewA, attribute: .right,
					relatedBy: .equal,
					toItem: container, attribute: .right,
					multiplier: 1, constant: -5
				),
				NSLayoutConstraint(
					item: viewA, attribute: .top,
					relatedBy: .equal,
					toItem: container, attribute: .top,
					multiplier: 1, constant: 30
				),
				NSLayoutConstraint(
					item: viewA, attribute: .bottom,
					relatedBy: .equal,
					toItem: container, attribute: .bottom,
					multiplier: 1, constant: -10
				)
			]
		)
		
		assertEqualConstraints(
			Tack.constraints(
				aligning: viewA, to: container,
				horizontally: .center, vertically: .fill,
				insets: .init(top: 30, left: 20, bottom: 10, right: 5)
			),
			[
				NSLayoutConstraint(
					item: viewA, attribute: .centerX,
					relatedBy: .equal,
					toItem: container, attribute: .centerX,
					multiplier: 1, constant: 7.5
				),
				NSLayoutConstraint(
					item: viewA, attribute: .left,
					relatedBy: .greaterThanOrEqual,
					toItem: container, attribute: .left,
					multiplier: 1, constant: 20
				),
				NSLayoutConstraint(
					item: viewA, attribute: .right,
					relatedBy: .lessThanOrEqual,
					toItem: container, attribute: .right,
					multiplier: 1, constant: -5
				),
				NSLayoutConstraint(
					item: viewA, attribute: .top,
					relatedBy: .equal,
					toItem: container, attribute: .top,
					multiplier: 1, constant: 30
				),
				NSLayoutConstraint(
					item: viewA, attribute: .bottom,
					relatedBy: .equal,
					toItem: container, attribute: .bottom,
					multiplier: 1, constant: -10
				)
			]
		)
	}
}
