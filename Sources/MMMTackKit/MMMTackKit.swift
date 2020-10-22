//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

infix operator |-- : TackKitPrecedence
infix operator --* : TackKitPrecedence
infix operator *-- : TackKitPrecedence
postfix operator --|

precedencegroup TackKitPrecedence {
	lowerThan: AdditionPrecedence
	associativity: left
}

public enum TackKit {

	public enum Padding {

		case eq(CGFloat, Int)
		case ge(CGFloat, Int)

		func simple() -> (NSLayoutConstraint.Relation, CGFloat, UILayoutPriority)? {
			switch self {
			case let .eq(padding, priority):
				return (.equal, padding, UILayoutPriority(Float(priority)))
			case let .ge(padding, priority):
				return (.greaterThanOrEqual, padding, UILayoutPriority(Float(priority)))
			}
		}
	}

	public enum View {

		case superview
		case view(UIView)

		func resolved(withRight right: UIView) -> (UIView, NSLayoutConstraint.Attribute) {
			switch self {
			case .view(let v):
				return (v, NSLayoutConstraint.Attribute.trailing)
			case .superview:
				return (right.superview!, NSLayoutConstraint.Attribute.leading)
			}
		}
	}

	public struct Context {

		let view: View
		let constraints: [NSLayoutConstraint]

		func copy(withView view: View, appendingConstraints constraints: [NSLayoutConstraint]) -> Context {
			var c = self.constraints
			c.append(contentsOf: constraints)
			return Context(view: view, constraints: c)
		}
	}

	public struct Horizontal {
	
		let context: Context?

		public func constraints() -> [NSLayoutConstraint] {
			return context?.constraints ?? []
		}
	}

	public static let H = Horizontal(context: nil)

	public struct SuperviewRight {
		let padding: Padding
	}
}

public func |-- (lhs: TackKit.Horizontal, padding: CGFloat) -> (TackKit.Horizontal, padding: TackKit.Padding) {
	return (
		TackKit.Horizontal(context: TackKit.Context(view: .superview, constraints: [])),
		padding: .eq(padding, 1000)
	)
}

public func |-- (lhs: TackKit.Horizontal, padding: TackKit.Padding) -> (TackKit.Horizontal, padding: TackKit.Padding) {
	return (
		TackKit.Horizontal(context: TackKit.Context(view: .superview, constraints: [])),
		padding: padding
	)
}

public func & (lhs: TackKit.Horizontal, rhs: UIView) -> TackKit.Horizontal {
	return TackKit.Horizontal(context: TackKit.Context(view: .view(rhs), constraints: []))
}

public func *-- (lhs: TackKit.Horizontal, rhs: TackKit.Padding) -> (TackKit.Horizontal, padding: TackKit.Padding) {
	return (lhs, padding: rhs)
}

public func --* (lhs: (TackKit.Horizontal, padding: TackKit.Padding), rhs: UIView) -> TackKit.Horizontal {

	guard let context = lhs.0.context else {
		preconditionFailure()
	}

	let (view, attr) = context.view.resolved(withRight: rhs)

	if let (relation, padding, priority) = lhs.padding.simple() {

		let c = NSLayoutConstraint(
			item: rhs, attribute: .leading,
			relatedBy: relation,
			toItem: view, attribute: attr,
			multiplier: 1, constant: padding
		)
		c.priority = priority

		return TackKit.Horizontal(context: context.copy(withView: .view(rhs), appendingConstraints: [c]))

	} else {
		preconditionFailure()
	}
}

public postfix func --| (lhs: TackKit.Padding) -> TackKit.SuperviewRight {
	return TackKit.SuperviewRight(padding: lhs)
}
