//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

// TODO: syntax for equal height/width?

// To allow using `>=padding` instead of `.ge(padding)` (and same for `==padding` for symmetry).

prefix operator >=
prefix operator >==
prefix operator ==

public prefix func >= (padding: CGFloat) -> _Tack.Padding {
	return ._greaterThanOrEqual(padding, .required)
}

/// A "double pin", that is `>==padding^priority` is the same as `">=padding,==padding@priority"` in VFL.
/// Uses `249` aka `.defaultLow - 1` priority by default, so can simply use `>==padding` when need `>==padding^249`.
///
/// The behavior of a double pin is what beginners often expect from a regular `>=padding` constraint.
public prefix func >== (padding: CGFloat) -> _Tack.Padding {
	return ._doublePin(padding, .defaultLow - 1)
}

public prefix func == (padding: CGFloat) -> _Tack.Padding {
	return ._equal(padding, .required)
}

// For something close to `padding@249` (cannot use @ as operator).
// TODO: not sure we are really interested in this.

/// Analogue of `@` in VFL, i.e. using `padding^249` is the same as using `"padding@249"` in VFL.
public func ^(padding: CGFloat, priority: CGFloat) -> _Tack.Padding {
	return ._equal(padding, UILayoutPriority(Float(priority)))
}

/// Analogue of `@` in VFL, i.e. using `padding^249` is the same as using `"padding@249"` in VFL.
public func ^(padding: _Tack.Padding, priority: CGFloat) -> _Tack.Padding {
	switch padding {
	case let ._equal(padding, _):
		return ._equal(padding, UILayoutPriority(Float(priority)))
	case let ._greaterThanOrEqual(padding, _):
		return ._greaterThanOrEqual(padding, UILayoutPriority(Float(priority)))
	case let ._doublePin(padding, _):
		return ._doublePin(padding, UILayoutPriority(Float(priority)))
	}
}

// Superview pins.

prefix operator |-
postfix operator -|

// |-(padding)-[view]

public prefix func |- (padding: CGFloat) -> _Tack.SuperviewPadding {
	return .init(padding: ._equal(padding, .required))
}

public prefix func |- (padding: _Tack.Padding) -> _Tack.SuperviewPadding {
	return .init(padding: padding)
}

public func - (lhs: _Tack.SuperviewPadding, view: UIView) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.leading, .superview, view),
			padding: lhs.padding,
			rhs: .init(.leading, .this, view)
		)],
		last: .init(.trailing, .this, view)
	)
}

// [viewA]-(padding)-[viewB]

public func - (view: UIView, rhs: _Tack.Padding) -> _Tack.ViewPadding {
	return .init(view: view, padding: rhs)
}

public func - (view: UIView, rhs: CGFloat) -> _Tack.ViewPadding {
	return .init(view: view, padding: ._equal(rhs, .required))
}

public func - (lhs: _Tack.ViewPadding, view: UIView) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, lhs.view),
			padding: lhs.padding,
			rhs: .init(.leading, .this, view)
		)],
		last: .init(.trailing, .this, view)
	)
}

public func - (chain: Tack.Chain, padding: _Tack.Padding) -> _Tack.ChainPadding {
	return .init(chain: chain, padding: padding)
}

public func - (chain: Tack.Chain, rhs: CGFloat) -> _Tack.ChainPadding {
	return .init(chain: chain, padding: ._equal(rhs, .required))
}

public func - (lhs: _Tack.ChainPadding, view: UIView) -> Tack.Chain {
	return .init(
		pairs: lhs.chain.pairs + [.init(
			lhs: lhs.chain.last,
			padding: lhs.padding,
			rhs: .init(.leading, .this, view)
		)],
		last: .init(.trailing, .this, view)
	)
}

// [view]-(padding)-|

public postfix func -| (padding: _Tack.Padding) -> _Tack.PaddingSuperview {
	return .init(padding: padding)
}

public postfix func -| (padding: CGFloat) -> _Tack.PaddingSuperview {
	return .init(padding: ._equal(padding, .required))
}

public func - (view: UIView, rhs: _Tack.PaddingSuperview) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, view),
			padding: rhs.padding,
			rhs: .init(.trailing, .superview, view)
		)],
		last: .init(.trailing, .superview, view)
	)
}

public func - (chain: Tack.Chain, rhs: _Tack.PaddingSuperview) -> Tack.Chain {
	return .init(
		pairs: chain.pairs + [.init(
			lhs: chain.last,
			padding: rhs.padding,
			rhs: .init(.trailing, .superview, chain.last.view)
		)],
		last: .init(.trailing, .superview, chain.last.view)
	)
}

// Safe area, like in mmm_constraintsWithVisualFormat.

postfix operator -<|

public postfix func -<| (padding: CGFloat) -> _Tack.PaddingSuperviewSafeArea {
	return .init(padding: ._equal(padding, .required))
}

public postfix func -<| (padding: _Tack.Padding) -> _Tack.PaddingSuperviewSafeArea {
	return .init(padding: padding)
}

public func - (view: UIView, rhs: _Tack.PaddingSuperviewSafeArea) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, view),
			padding: rhs.padding,
			rhs: .init(.trailing, .safeAreaOfSuperview,view)
		)],
		last: .init(.trailing, .safeAreaOfSuperview, view)
	)
}

public func - (chain: Tack.Chain, rhs: _Tack.PaddingSuperviewSafeArea) -> Tack.Chain {
	return .init(
		// TODO: make this nicer
		pairs: chain.pairs + [ .init(lhs: chain.last,
			padding: rhs.padding,
			rhs: .init(.trailing, .safeAreaOfSuperview, chain.last.view)
		)],
		last: .init(.trailing, .safeAreaOfSuperview, chain.last.view)
	)
}

prefix operator |>-

public prefix func |>- (padding: CGFloat) -> _Tack.PaddingSuperviewSafeArea {
	return .init(padding: ._equal(padding, .required))
}

public prefix func |>- (padding: _Tack.Padding) -> _Tack.PaddingSuperviewSafeArea {
	return .init(padding: padding)
}

public func - (lhs: _Tack.PaddingSuperviewSafeArea, view: UIView) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.leading, .safeAreaOfSuperview, view),
			padding: lhs.padding,
			rhs: .init(.leading, .this, view)
		)],
		last: .init(.trailing, .this, view)
	)
}

// MARK: -

public enum Tack {

	public static func activate(_ constraints: [NSLayoutConstraint]) {
		NSLayoutConstraint.activate(constraints)
	}

	public static func deactivate(_ constraints: [NSLayoutConstraint]) {
		NSLayoutConstraint.deactivate(constraints)
	}

	public static func activate(_ constraint: NSLayoutConstraint) {
		constraint.isActive = true
	}

	public static func activate(_ chains: Tack.OrientedChain...) {
		NSLayoutConstraint.activate(chains.flatMap { $0.constraints })
	}

	public static func constraints(_ chains: Tack.OrientedChain...) -> [NSLayoutConstraint] {
		chains.flatMap { $0.constraints }
	}

	public static func H(_ chain: Tack.Chain, alignAll alignment: Tack.VerticalAlignment = .none) -> [NSLayoutConstraint] {
		return chain.resolved(.horizontal, alignment: alignment.attribute())
	}
	
	public static func V(_ chain: Tack.Chain, alignAll alignment: Tack.HorizontalAlignment = .none) -> [NSLayoutConstraint] {
		return chain.resolved(.vertical, alignment: alignment.attribute())
	}

	public enum VerticalAlignment {

		case none, top, firstBaseline, centerY, lastBaseline, bottom

		// TODO: use raw value from Attribute
		internal func attribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .none: return .notAnAttribute
			case .top: return .top
			case .firstBaseline: return .firstBaseline
			case .centerY: return .centerY
			case .lastBaseline: return .lastBaseline
			case .bottom: return .bottom
			}
		}
	}

	public enum HorizontalAlignment {

		case none, leading, left, centerX, trailing, right

		internal func attribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .none: return .notAnAttribute
			case .leading: return .leading
			case .left: return .left
			case .centerX: return .centerX
			case .trailing: return .trailing
			case .right: return .right
			}
		}
	}

	public struct OrientedChain {

		internal let constraints: [NSLayoutConstraint]

		public static func H(_ chain: Tack.Chain, alignAll alignment: Tack.VerticalAlignment = .none) -> Self {
			.init(constraints: chain.resolved(.horizontal, alignment: alignment.attribute()))
		}

		public static func V(_ chain: Tack.Chain, alignAll alignment: Tack.HorizontalAlignment = .none) -> Self {
			.init(constraints: chain.resolved(.vertical, alignment: alignment.attribute()))
		}
	}

	public struct Chain {

		let pairs: [_Tack.Pair]
		let last: _Tack.Anchor // TODO: use the last view instead

		internal func resolved(_ axis: NSLayoutConstraint.Axis, alignment: NSLayoutConstraint.Attribute = .notAnAttribute) -> [NSLayoutConstraint] {

			func constraint(_ lhs: _Tack.ResolvedSide, _ rhs: _Tack.ResolvedSide, _ padding: _Tack.ResolvedPadding) -> NSLayoutConstraint {
				let c = NSLayoutConstraint(
					item: rhs.0, attribute: rhs.1,
					relatedBy: padding.0,
					toItem: lhs.0, attribute: lhs.1,
					multiplier: 1, constant: padding.1
				)
				c.priority = padding.2
				return c
			}

			var result: [NSLayoutConstraint] = []
			for pair in pairs {

				let lhs = pair.lhs.resolved(axis: axis)
				let rhs = pair.rhs.resolved(axis: axis)

				switch pair.padding {
				case let ._equal(value, prio):
					result.append(constraint(lhs, rhs, (.equal, value, prio)))
				case let ._greaterThanOrEqual(value, prio):
					result.append(constraint(lhs, rhs, (.greaterThanOrEqual, value, prio)))
				case let ._doublePin(value, prio):
					result.append(constraint(lhs, rhs, (.greaterThanOrEqual, value, .required)))
					result.append(constraint(lhs, rhs, (.equal, value, prio)))
				}
			}

			if alignment != .notAnAttribute {
				var views: [UIView] = []
				for pair in pairs {
					let last = views.last
					if pair.lhs.ref == .this && pair.lhs.view != last {
						views.append(pair.lhs.view)
					}
					if pair.rhs.ref == .this && pair.lhs.view != last {
						views.append(pair.rhs.view)
					}
				}
				var i: Int = 0
				while i < views.count - 1 {
					result.append(.init(
						item: views[i], attribute: alignment,
						relatedBy: .equal,
						toItem: views[i + 1], attribute: alignment,
						multiplier: 1, constant: 0
					))
					i += 1
				}
			}

			return result
		}
	}

}

public enum _Tack {

	internal typealias ResolvedPadding = (NSLayoutConstraint.Relation, CGFloat, UILayoutPriority)

	// TODO: can be a struct eventually, storing already "resolved" array
	public enum Padding {
		case _equal(CGFloat, UILayoutPriority)
		case _greaterThanOrEqual(CGFloat, UILayoutPriority)
		case _doublePin(CGFloat, UILayoutPriority)
	}

	public struct SuperviewPadding {
		let padding: Padding
	}

	public struct ViewPadding {
		let view: UIView
		let padding: Padding
	}

	public struct PaddingSuperview {
		let padding: Padding
	}

	public struct PaddingSuperviewSafeArea {
		let padding: Padding
	}

	internal typealias ResolvedSide = (AnyObject, NSLayoutConstraint.Attribute)

	public enum Side {
		case leading, trailing
	}

	public enum ViewRef {
		case this, superview, safeAreaOfSuperview
	}

	public struct Anchor {

		let side: Side
		let ref: ViewRef
		let view: UIView

		init(_ side: Side, _ ref: ViewRef, _ view: UIView) {
			self.side = side
			self.ref = ref
			self.view = view
		}

		internal func resolved(axis: NSLayoutConstraint.Axis) -> ResolvedSide {

			let r: AnyObject = {
				switch ref {
				case .this:
					return view
				case .superview:
					guard let superview = view.superview else {
						preconditionFailure("Trying to constrain against a superview of a view that does not have one: \(view)")
					}
					return superview
				case .safeAreaOfSuperview:
					guard let superview = view.superview else {
						preconditionFailure("Trying to constrain against safe area of a superview of a view that does not have one: \(view)")
					}
					return superview.safeAreaLayoutGuide
				}
			}()

			let attribute: NSLayoutConstraint.Attribute = {
				switch axis {
				case .horizontal:
					switch side {
					case .leading:
						return .leading
					case .trailing:
						return .trailing
					}
				case .vertical:
					switch side {
					case .leading:
						return .top
					case .trailing:
						return .bottom
					}
				@unknown default:
					preconditionFailure("Got an unknown case as NSLayoutConstraint.Attribute, is there an update available?")
				}
			}()

			return (r, attribute)
		}
	}

	public struct Pair {
		let lhs: Anchor
		let padding: Padding
		let rhs: Anchor
	}

	public struct ChainPadding {
		let chain: Tack.Chain
		let padding: Padding
	}
}