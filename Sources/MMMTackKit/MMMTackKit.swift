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

public prefix func >= (padding: CGFloat) -> Tack.Padding {
	return .ge(padding)
}

/// A "double pin". Specifying `.ge2(priority)` or `>==padding^priority`
/// is the same as the use of `">=padding,==padding@priority"` in VFL.
public prefix func >== (padding: CGFloat) -> Tack.Padding {
	return .ge2(padding, .defaultLow - 1)
}

public prefix func == (padding: CGFloat) -> Tack.Padding {
	return .eq(padding)
}

// For something close to `padding@249` (cannot use @ as operator).
// TODO: not sure we are really interested in this.

/// Analogue of `@` in VFL, i.e. using `padding^249` is the same as using `"padding@249"` in VFL.
public func ^(padding: CGFloat, priority: CGFloat) -> Tack.Padding {
	return ._equal(padding, UILayoutPriority(Float(priority)))
}

/// Analogue of `@` in VFL, i.e. using `padding^249` is the same as using `"padding@249"` in VFL.
public func ^(padding: Tack.Padding, priority: CGFloat) -> Tack.Padding {
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

public prefix func |- (padding: CGFloat) -> Tack.SuperviewPadding {
	return .init(padding: ._equal(padding, .required))
}

public prefix func |- (padding: Tack.Padding) -> Tack.SuperviewPadding {
	return .init(padding: padding)
}

public func - (lhs: Tack.SuperviewPadding, view: UIView) -> Tack.Chain {
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

public func - (view: UIView, rhs: Tack.Padding) -> Tack.ViewPadding {
	return .init(view: view, padding: rhs)
}

public func - (view: UIView, rhs: CGFloat) -> Tack.ViewPadding {
	return .init(view: view, padding: ._equal(rhs, .required))
}

public func - (lhs: Tack.ViewPadding, view: UIView) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, lhs.view),
			padding: lhs.padding,
			rhs: .init(.leading, .this, view)
		)],
		last: .init(.trailing, .this, view)
	)
}

public func - (chain: Tack.Chain, padding: Tack.Padding) -> Tack.ChainPadding {
	return .init(chain: chain, padding: padding)
}

public func - (chain: Tack.Chain, rhs: CGFloat) -> Tack.ChainPadding {
	return .init(chain: chain, padding: ._equal(rhs, .required))
}

public func - (lhs: Tack.ChainPadding, view: UIView) -> Tack.Chain {
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

public postfix func -| (padding: Tack.Padding) -> Tack.PaddingSuperview {
	return .init(padding: padding)
}

public postfix func -| (padding: CGFloat) -> Tack.PaddingSuperview {
	return .init(padding: .eq(padding))
}

public func - (view: UIView, rhs: Tack.PaddingSuperview) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, view),
			padding: rhs.padding,
			rhs: .init(.trailing, .superview, view)
		)],
		last: .init(.trailing, .superview, view)
	)
}

public func - (chain: Tack.Chain, rhs: Tack.PaddingSuperview) -> Tack.Chain {
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

public postfix func -<| (padding: CGFloat) -> Tack.PaddingSuperviewSafeArea {
	return .init(padding: .eq(padding))
}

public postfix func -<| (padding: Tack.Padding) -> Tack.PaddingSuperviewSafeArea {
	return .init(padding: padding)
}

public func - (view: UIView, rhs: Tack.PaddingSuperviewSafeArea) -> Tack.Chain {
	return .init(
		pairs: [.init(
			lhs: .init(.trailing, .this, view),
			padding: rhs.padding,
			rhs: .init(.trailing, .safeAreaOfSuperview,view)
		)],
		last: .init(.trailing, .safeAreaOfSuperview, view)
	)
}

public func - (chain: Tack.Chain, rhs: Tack.PaddingSuperviewSafeArea) -> Tack.Chain {
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

public prefix func |>- (padding: CGFloat) -> Tack.PaddingSuperviewSafeArea {
	return .init(padding: .eq(padding))
}

public prefix func |>- (padding: Tack.Padding) -> Tack.PaddingSuperviewSafeArea {
	return .init(padding: padding)
}

public func - (lhs: Tack.PaddingSuperviewSafeArea, view: UIView) -> Tack.Chain {
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

	public static func activate(_ constraint: NSLayoutConstraint) {
		constraint.isActive = true
	}

	public static func activate(_ chain: OrientedChain) {
		NSLayoutConstraint.activate(chain.constraints)
	}

	public struct OrientedChain {

		internal let constraints: [NSLayoutConstraint]

		public static func H(_ chain: Chain, alignAll alignment: VerticalAlignment = .none) -> Self {
			.init(constraints: chain.resolved(.horizontal, alignment: alignment.attribute()))
		}

		public static func V(_ chain: Chain, alignAll alignment: HorizontalAlignment = .none) -> Self {
			.init(constraints: chain.resolved(.vertical, alignment: alignment.attribute()))
		}
	}

	public enum VerticalAlignment: Int {

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
	
		case none, leading, left, center, trailing, right

		internal func attribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .none: return .notAnAttribute
			case .leading: return .leading
			case .left: return .left
			case .center: return .centerX
			case .trailing: return .trailing
			case .right: return .right
			}
		}
	}

	public static func H(_ chain: Chain, alignAll alignment: VerticalAlignment = .none) -> [NSLayoutConstraint] {
		return chain.resolved(.horizontal, alignment: alignment.attribute())
	}
	
	public static func V(_ chain: Chain, alignAll alignment: HorizontalAlignment = .none) -> [NSLayoutConstraint] {
		return chain.resolved(.vertical, alignment: alignment.attribute())
	}

	internal typealias ResolvedPadding = (NSLayoutConstraint.Relation, CGFloat, UILayoutPriority)

	// TODO: can be a struct eventually, storing already "resolved" array
	public enum Padding {

		public static func eq(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._equal(value, priority)
		}
		/// (To allow using regular floats without casting to UILayoutPriority.)
		public static func eq(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._equal(value, UILayoutPriority(priority))
		}

		public static func ge(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._greaterThanOrEqual(value, priority)
		}
		/// (To allow using regular floats without casting to UILayoutPriority.)
		public static func ge(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._greaterThanOrEqual(value, UILayoutPriority(priority))
		}

		/// A "double pin". Specifying `.ge2(priority)` or `>==padding^priority`
		/// is the same as the use of `">=padding,==padding@priority"` in VFL.
		public static func ge2(_ value: CGFloat, _ priority: UILayoutPriority) -> Padding {
			return ._doublePin(value, priority)
		}
		/// A "double pin". Specifying `.ge2(priority)` or `>==padding^priority`
		/// is the same as the use of `">=padding,==padding@priority"` in VFL.
		public static func ge2(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._doublePin(value, UILayoutPriority(priority))
		}

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

	public struct Chain {

		let pairs: [Pair]
		let last: Anchor // TODO: use the last view instead

		internal func resolved(_ axis: NSLayoutConstraint.Axis, alignment: NSLayoutConstraint.Attribute = .notAnAttribute) -> [NSLayoutConstraint] {

			func constraint(_ lhs: ResolvedSide, _ rhs: ResolvedSide, _ padding: ResolvedPadding) -> NSLayoutConstraint {
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

	public struct ChainPadding {
		let chain: Chain
		let padding: Padding
	}
}
