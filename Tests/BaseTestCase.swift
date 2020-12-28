//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit
import XCTest

class BaseTestCase: XCTestCase {

	internal var container: UIView!
	internal var viewA: UIView!
	internal var viewB: UIView!
	internal var viewC: UIView!

	internal var guideA: UILayoutGuide!
	internal var guideB: UILayoutGuide!
	internal var guideC: UILayoutGuide!

	internal var views: [String: UIView]!
	internal var metrics: [String: CGFloat]!
	internal let padding: CGFloat = 10

	override func setUp() {

		super.setUp()

		container = UIView()

		viewA = UIView()
		container.addSubview(viewA)

		viewB = UIView()
		container.addSubview(viewB)

		viewC = UIView()
		container.addSubview(viewC)

		guideA = UILayoutGuide()
		container.addLayoutGuide(guideA)
		guideB = UILayoutGuide()
		container.addLayoutGuide(guideB)
		guideC = UILayoutGuide()
		container.addLayoutGuide(guideC)

		views = [
			"viewA": viewA, "viewB": viewB, "viewC": viewC,
			"guideA": viewA, "guideB": viewB, "guideC": viewC
		]
		metrics = [ "padding": padding ]
	}

	/// Compares two constraints ignoring their identifiers or active state.
	/// (Note that the standard implementation won't compare flipped constraints.)
	internal func areEqualConstraints(_ a: NSLayoutConstraint, _ b: NSLayoutConstraint) -> Bool {

		func oppositeRelation(_ r: NSLayoutConstraint.Relation) -> NSLayoutConstraint.Relation {
			switch r {
			case .equal:
				return .equal
			case .greaterThanOrEqual:
				return .lessThanOrEqual
			case .lessThanOrEqual:
				return .greaterThanOrEqual
			}
		}

		return
			(a.firstAttribute == b.firstAttribute && a.secondAttribute == b.secondAttribute
				&& a.multiplier == b.multiplier
				&& a.constant == b.constant
				&& a.relation == b.relation
				&& a.priority == b.priority
			)
			||
			(a.firstAttribute == b.secondAttribute && a.secondAttribute == b.firstAttribute
				&& abs(a.multiplier - 1 / b.multiplier) < 1e-6
				&& a.constant == -b.constant
				&& a.relation == oppositeRelation(b.relation)
				&& a.priority == b.priority
			)
		;
	}

	/// Compares two arrays of constraints disregarding the order of elements.
	internal func assertEqualConstraints(_ actual: [NSLayoutConstraint], _ expected: [NSLayoutConstraint], file: StaticString = #filePath, line: UInt = #line) {

		guard actual.count == expected.count else {
			XCTFail("Different nubmer of constraints: \(actual.count) vs \(expected.count) expected", file: file, line: line)
			return
		}

		for c in actual {
			if !expected.contains(where: { areEqualConstraints(c, $0) }) {
				XCTFail("Unexpected contraint: \(c)", file: file, line: line)
				return
			}
		}
		
		for c in expected {
			if !actual.contains(where: { areEqualConstraints(c, $0) }) {
				XCTFail("Missed constraint: \(c)", file: file, line: line)
				return
			}
		}
	}

}
