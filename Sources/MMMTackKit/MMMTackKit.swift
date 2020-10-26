//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

prefix operator |-
postfix operator -|

// |-(padding)-[view]

public prefix func |- (padding: CGFloat) -> TackKit.SuperviewPadding {
	return .init(padding: ._eq(padding, .required))
}

public prefix func |- (padding: TackKit.Padding) -> TackKit.SuperviewPadding {
	return .init(padding: padding)
}

public func - (lhs: TackKit.SuperviewPadding, view: UIView) -> TackKit.Chain {
	return .init(
		pairs: [.init(lhs: .leading(view.superview!), padding: lhs.padding, rhs: .leading(view))],
		trailing: .trailing(view)
	)
}

// [viewA]-(padding)-[viewB]

public func - (lhs: UIView, rhs: TackKit.Padding) -> TackKit.ViewPadding {
	return .init(view: lhs, padding: rhs)
}

public func - (lhs: UIView, rhs: CGFloat) -> TackKit.ViewPadding {
	return .init(view: lhs, padding: ._eq(rhs, .required))
}

public func - (lhs: TackKit.ViewPadding, rhs: UIView) -> TackKit.Chain {
	return .init(
		pairs: [.init(lhs: .trailing(lhs.view), padding: lhs.padding, rhs: .leading(rhs))],
		trailing: .trailing(rhs)
	)
}

public func - (lhs: TackKit.Chain, rhs: TackKit.Padding) -> TackKit.ChainPadding {
	return .init(chain: lhs, padding: rhs)
}

public func - (lhs: TackKit.Chain, rhs: CGFloat) -> TackKit.ChainPadding {
	return .init(chain: lhs, padding: ._eq(rhs, .required))
}

public func - (lhs: TackKit.ChainPadding, rhs: UIView) -> TackKit.Chain {
	return .init(
		pairs: lhs.chain.pairs + [.init(lhs: lhs.chain.trailing, padding: lhs.padding, rhs: .leading(rhs))],
		trailing: .trailing(rhs)
	)
}

// [view]-(padding)-|

public postfix func -| (padding: TackKit.Padding) -> TackKit.PaddingSuperview {
	return .init(padding: padding)
}

public postfix func -| (padding: CGFloat) -> TackKit.PaddingSuperview {
	return .init(padding: .eq(padding))
}

public func - (lhs: UIView, rhs: TackKit.PaddingSuperview) -> TackKit.Chain {
	return .init(
		pairs: [.init(lhs: .trailing(lhs), padding: rhs.padding, rhs: .trailing(lhs.superview!))],
		trailing: .trailing(lhs.superview!)
	)
}

public func - (chain: TackKit.Chain, rhs: TackKit.PaddingSuperview) -> TackKit.Chain {
	return .init(
		pairs: chain.pairs + [.init(lhs: chain.trailing, padding: rhs.padding, rhs: .trailing(chain.trailing.view.superview!))],
		trailing: .trailing(chain.trailing.view.superview!)
	)
}

public enum TackKit {

	public static func H(_ chain: Chain) -> [NSLayoutConstraint] {
		return chain.axis(.horizontal)
	}
	
	public static func V(_ chain: Chain) -> [NSLayoutConstraint] {
		return chain.axis(.vertical)
	}

	public enum Padding {

		public static func eq(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._eq(value, priority)
		}

		public static func ge(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Padding {
			return ._ge(value, priority)
		}

		/// (To allow using regular floats without casing to UILayoutPriority.)
		public static func eq(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._eq(value, UILayoutPriority(priority))
		}

		/// (To allow using regular floats without casing to UILayoutPriority.)
		public static func ge(_ value: CGFloat, _ priority: Float) -> Padding {
			return ._ge(value, UILayoutPriority(priority))
		}

		case _eq(CGFloat, UILayoutPriority)
		case _ge(CGFloat, UILayoutPriority)

		internal func resolved() -> (NSLayoutConstraint.Relation, CGFloat, UILayoutPriority) {
			switch self {
			case let ._eq(value, prio):
				return (.equal, value, prio)
			case let ._ge(value, prio):
				return (.greaterThanOrEqual, value, prio)
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
			return pairs.map { pair in
				let lhs = pair.lhs.resolved(axis: axis)
				let padding = pair.padding.resolved()
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

	public struct ChainPadding {
		let chain: Chain
		let padding: Padding
	}
}
