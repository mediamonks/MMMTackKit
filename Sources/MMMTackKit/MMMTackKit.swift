//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

// TODO: 1) alignment flags
// TODO: 2) equal height/width

// To allow using `>=padding` instead of `.ge(padding)` (and same for `==padding` for symmetry).
// TODO: not sure we are really interested in these.

prefix operator >=
prefix operator ==

public prefix func >= (padding: CGFloat) -> Tack.Padding {
	return .ge(padding)
}

public prefix func == (padding: CGFloat) -> Tack.Padding {
	return .eq(padding)
}

// For something close to `padding@249` (cannot use @ as operator).
// TODO: not sure we are really interested in this.

public func ^(padding: CGFloat, priority: CGFloat) -> Tack.Padding {
	return ._equal(padding, UILayoutPriority(Float(priority)))
}

public func ^(padding: Tack.Padding, priority: CGFloat) -> Tack.Padding {
	switch padding {
	case let ._equal(padding, _):
		return ._equal(padding, UILayoutPriority(Float(priority)))
	case let ._greaterThanOrEqual(padding, _):
		return ._greaterThanOrEqual(padding, UILayoutPriority(Float(priority)))
	case let ._doublePin(padding, _):
		// TODO: allowing this is a bit weird.
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
		pairs: [.init(lhs: .leading(view.superview!), padding: lhs.padding, rhs: .leading(view))],
		trailing: .trailing(view)
	)
}

// [viewA]-(padding)-[viewB]

public func - (lhs: UIView, rhs: Tack.Padding) -> Tack.ViewPadding {
	return .init(view: lhs, padding: rhs)
}

public func - (lhs: UIView, rhs: CGFloat) -> Tack.ViewPadding {
	return .init(view: lhs, padding: ._equal(rhs, .required))
}

public func - (lhs: Tack.ViewPadding, rhs: UIView) -> Tack.Chain {
	return .init(
		pairs: [.init(lhs: .trailing(lhs.view), padding: lhs.padding, rhs: .leading(rhs))],
		trailing: .trailing(rhs)
	)
}

public func - (lhs: Tack.Chain, rhs: Tack.Padding) -> Tack.ChainPadding {
	return .init(chain: lhs, padding: rhs)
}

public func - (lhs: Tack.Chain, rhs: CGFloat) -> Tack.ChainPadding {
	return .init(chain: lhs, padding: ._equal(rhs, .required))
}

public func - (lhs: Tack.ChainPadding, rhs: UIView) -> Tack.Chain {
	return .init(
		pairs: lhs.chain.pairs + [.init(lhs: lhs.chain.trailing, padding: lhs.padding, rhs: .leading(rhs))],
		trailing: .trailing(rhs)
	)
}

// [view]-(padding)-|

public postfix func -| (padding: Tack.Padding) -> Tack.PaddingSuperview {
	return .init(padding: padding)
}

public postfix func -| (padding: CGFloat) -> Tack.PaddingSuperview {
	return .init(padding: .eq(padding))
}

public func - (lhs: UIView, rhs: Tack.PaddingSuperview) -> Tack.Chain {
	return .init(
		pairs: [.init(lhs: .trailing(lhs), padding: rhs.padding, rhs: .trailing(lhs.superview!))],
		trailing: .trailing(lhs.superview!)
	)
}

public func - (chain: Tack.Chain, rhs: Tack.PaddingSuperview) -> Tack.Chain {
	return .init(
		pairs: chain.pairs + [.init(lhs: chain.trailing, padding: rhs.padding, rhs: .trailing(chain.trailing.view.superview!))],
		trailing: .trailing(chain.trailing.view.superview!)
	)
}

public enum Tack {

	public static func H(_ chain: Chain) -> [NSLayoutConstraint] {
		return chain.axis(.horizontal)
	}
	
	public static func V(_ chain: Chain) -> [NSLayoutConstraint] {
		return chain.axis(.vertical)
	}

	public enum Padding {

		public static func eq(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._equal(value, priority)
		}
		/// (To allow using regular floats without casing to UILayoutPriority.)
		public static func eq(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._equal(value, UILayoutPriority(priority))
		}

		public static func ge(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._greaterThanOrEqual(value, priority)
		}
		/// (To allow using regular floats without casing to UILayoutPriority.)
		public static func ge(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._greaterThanOrEqual(value, UILayoutPriority(priority))
		}

		/// This is for what we call a "double-pin" pattern, `-(>=padding,==padding@priority)-`.
		public static func ge2(_ value: CGFloat, _ priority: UILayoutPriority) -> Padding {
			return ._doublePin(value, priority)
		}
		public static func ge2(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._doublePin(value, UILayoutPriority(priority))
		}

		case _equal(CGFloat, UILayoutPriority)
		case _greaterThanOrEqual(CGFloat, UILayoutPriority)
		case _doublePin(CGFloat, UILayoutPriority)

		internal func resolved() -> [(NSLayoutConstraint.Relation, CGFloat, UILayoutPriority)] {
			switch self {
			case let ._equal(value, prio):
				return [(.equal, value, prio)]
			case let ._greaterThanOrEqual(value, prio):
				return [(.greaterThanOrEqual, value, prio)]
			case let ._doublePin(value, prio):
				return [(.greaterThanOrEqual, value, .required), (.equal, value, prio)]
			}
		}
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

	public enum Side {

		case leading(UIView)
		case trailing(UIView)

		var view: UIView {
			switch self {
			case let .leading(view), let .trailing(view):
				return view
			}
		}

		internal func resolved(axis: NSLayoutConstraint.Axis) -> (UIView, NSLayoutConstraint.Attribute) {
			switch axis {
			case .horizontal:
				switch self {
				case let .leading(v):
					return (v, .leading)
				case let .trailing(v):
					return (v, .trailing)
				}
			case .vertical:
				switch self {
				case let .leading(v):
					return (v, .top)
				case let .trailing(v):
					return (v, .bottom)
				}
			}
		}
	}

	public struct Pair {
		let lhs: Side
		let padding: Padding
		let rhs: Side
	}

	public struct Chain {

		let pairs: [Pair]
		let trailing: Side // TODO: use the last view instead

		public func axis(_ axis: NSLayoutConstraint.Axis) -> [NSLayoutConstraint] {
			return pairs.flatMap { pair in
				return pair.padding.resolved().map { padding in
					let lhs = pair.lhs.resolved(axis: axis)
					let rhs = pair.rhs.resolved(axis: axis)
					return NSLayoutConstraint(
						item: rhs.0, attribute: rhs.1,
						relatedBy: padding.0,
						toItem: lhs.0, attribute: lhs.1,
						multiplier: 1, constant: padding.1
					)
				}
			}
		}
	}

	public struct ChainPadding {
		let chain: Chain
		let padding: Padding
	}
}
