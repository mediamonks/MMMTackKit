//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {

	/// Align a view to another view / parent (receiver), using a horizontal and vertical alignment policy. The insets will be
	/// applied accordingly. E.g. horizontal alignment `.fill` with insets `(10, 10, 10, 10)` will keep
	/// 10pts 'spacing' around the aligned view. When insets are applied to a `center` alignment, we will offset the
	/// center alignment by the half of `left - right`; e.g. `insets(0, 20, 0, 5) = 7.5px` from center.
	///
	/// - Parameters:
	///   - view: The view to align.
	///   - parent: Where  to align the view to, usually the/a parent.
	///   - horizontally: How to horizontally align the view. Defaults to `.none`.
	///   - vertically: How to vertically align the view. Defaults to `.none`.
	///   - insets: The insets to apply to the alignment.
	public static func align(
		view: UIView,
		to parent: UIView,
		horizontally: HorizontalAlignmentPolicy = .none,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) {
		
		Tack.activate(Tack.constraintsAligning(
			view: view,
			to: parent,
			horizontally: horizontally,
			vertically: vertically,
			insets: insets
		))
	}
	
	/// Align a view to a layout guide, e.g. `view.safeAreaLayoutGuide`, using a horizontal and vertical alignment
	/// policy. For more info look at the `align(view: UIView, to: UIView...` documentation.
	public static func align(
		view: UIView,
		to parent: UILayoutGuide,
		horizontally: HorizontalAlignmentPolicy = .none,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) {
		
		Tack.activate(constraintsAligning(
			view: view,
			to: parent,
			horizontally: horizontally,
			vertically: vertically,
			insets: insets
		))
	}
	
	/// Return the constraints normally applied by `Tack.align()`. For more info, look at that doc-block.
	public static func constraintsAligning(
		view: UIView,
		to parent: UIView,
		horizontally: HorizontalAlignmentPolicy = .none,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) -> [NSLayoutConstraint] {
		
		return _constraintsAligning(view: view, parent: parent, h: horizontally, v: vertically, insets: insets)
	}
	
	/// Return the constraints normally applied by `Tack.align()`. For more info, look at that doc-block.
	public static func constraintsAligning(
		view: UIView,
		to parent: UILayoutGuide,
		horizontally: HorizontalAlignmentPolicy = .none,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) -> [NSLayoutConstraint] {
		
		return _constraintsAligning(view: view, parent: parent, h: horizontally, v: vertically, insets: insets)
	}
	
	/// Return an array with all the constraints for aligning a view, with type erased parent.
	fileprivate static func _constraintsAligning(
		view: UIView,
		parent: Any,
		h: HorizontalAlignmentPolicy,
		v: VerticalAlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		var constraints = [NSLayoutConstraint]()
		
		switch h {
		case .none:
			break
		case .center, .golden:
			constraints = centerConstraints(view: view, parent: parent, policy: h, insets: insets)
		case .fill:
			constraints = fillConstraints(view: view, parent: parent, policy: h, insets: insets)
		case .left, .leading, .right, .trailing:
			constraints = pinConstraints(view: view, parent: parent, policy: h, insets: insets)
		}
		
		switch v {
		case .none:
			break
		case .center, .golden:
			constraints.append(contentsOf:
				centerConstraints(view: view, parent: parent, policy: v, insets: insets)
			)
		case .fill:
			constraints.append(contentsOf:
				fillConstraints(view: view, parent: parent, policy: v, insets: insets)
			)
		case .top, .firstBaseline, .bottom, .lastBaseline:
			constraints.append(contentsOf:
				pinConstraints(view: view, parent: parent, policy: v, insets: insets)
			)
		}
		
		return constraints
	}
	
	/// Return constratins to pin a view to its parent and make sure it stays within bounds.
	private static func pinConstraints(
		view: UIView,
		parent: Any,
		policy: AlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: parent, attribute: policy.attribute(),
				multiplier: 1, constant: policy.inset(from: insets)
			),
			// We want the view to stay in-bounds.
			NSLayoutConstraint(
				item: view, attribute: policy.inverseAttribute(),
				relatedBy: policy.inBoundsRelation(),
				toItem: parent, attribute: policy.inverseAttribute(),
				multiplier: 1, constant: policy.inverseInset(from: insets)
			)
		]
	}
	
	/// Return constraints to fill a view in its parent.
	private static func fillConstraints(
		view: UIView,
		parent: Any,
		policy: AlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: parent, attribute: policy.attribute(),
				multiplier: 1, constant: policy.inset(from: insets)
			),
			NSLayoutConstraint(
				item: view, attribute: policy.inverseAttribute(),
				relatedBy: .equal,
				toItem: parent, attribute: policy.inverseAttribute(),
				multiplier: 1, constant: -policy.inverseInset(from: insets)
			)
		]
	}
	
	/// Return constraints to center a view in it's parent, making sure it's in bounds, handles golden ratio as well.
	private static func centerConstraints(
		view: UIView,
		parent: Any,
		policy: AlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		let leadingAttr: NSLayoutConstraint.Attribute
		let trailingAttr: NSLayoutConstraint.Attribute
		let leadingInset: CGFloat
		let trailingInset: CGFloat
		let multiplier: CGFloat
		
		if case let vertical as VerticalAlignmentPolicy = policy {
			leadingAttr = .top
			leadingInset = insets.top
			trailingAttr = .bottom
			trailingInset = insets.bottom
			
			multiplier = vertical == .golden ? centerMultiplier(ratio: inverseGolden) : 1
		} else if case let horizonal as HorizontalAlignmentPolicy = policy {
			leadingAttr = .left
			leadingInset = insets.left
			trailingAttr = .right
			trailingInset = insets.right
			
			multiplier = horizonal == .golden ? centerMultiplier(ratio: inverseGolden) : 1
		} else {
			preconditionFailure("Policy should be Horizonal or VerticalAlignmentPolicy")
		}
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: parent, attribute: policy.attribute(),
				multiplier: multiplier, constant: policy.inset(from: insets)
			),
			// We want the view to stay in-bounds.
			NSLayoutConstraint(
				item: view, attribute: leadingAttr,
				relatedBy: .greaterThanOrEqual,
				toItem: parent, attribute: leadingAttr,
				multiplier: 1, constant: leadingInset
			),
			NSLayoutConstraint(
				item: view, attribute: trailingAttr,
				relatedBy: .lessThanOrEqual,
				toItem: parent, attribute: trailingAttr,
				multiplier: 1, constant: -trailingInset
			)
		]
	}
	
	/**
	 * Suppose you need to contrain a view so its center divides its container in certain ratio different from 1:1
	 * (e.g. golden section):
	 *
	 *  ┌─────────┐ ◆
	 *  │         │ │
	 *  │         │ │ a
	 *  │┌───────┐│ │
	 * ─│┼ ─ ─ ─ ┼│─◆   ratio = a / b
	 *  │└───────┘│ │
	 *  │         │ │
	 *  │         │ │
	 *  │         │ │ b
	 *  │         │ │
	 *  │         │ │
	 *  │         │ │
	 *  └─────────┘ ◆
	 *
	 * You cannot put this ratio directly into the `multiplier` parameter of the corresponding NSLayoutConstraints relating
	 * the centers of the views, because the `multiplier` would be the ratio between the distance to the center
	 * of the view (`h`) and the distance to the center of the container (`H`) instead:
	 *
	 *   ◆ ┌─────────┐ ◆
	 *   │ │         │ │
	 *   │ │         │ │ a = h
	 * H │ │┌───────┐│ │
	 *   │ │├ ─ ─ ─ ┼│─◆   multiplier = h / H
	 *   │ │└───────┘│ │   ratio = a / b = h / (2 * H - h)
	 *   ◆─│─ ─ ─ ─ ─│ │
	 *     │         │ │
	 *     │         │ │ b = 2 * H - h
	 *     │         │ │
	 *     │         │ │
	 *     │         │ │
	 *     └─────────┘ ◆
	 *
	 * I.e. the `multiplier` is h / H (assuming the view is the first in the definition of the constraint),
	 * but the ratio we are interested would be h / (2 * H - h) if expressed in the distances to centers.
	 *
	 * If you have a desired ratio and want to get a `multiplier`, which when applied, results in the layout dividing
	 * the container in this ratio, then you can use this function as shortcut.
	 *
	 * Detailed calculations:
	 * ratio = h / (2 * H - h)  ==>  2 * H * ratio - h * ratio = h  ==>  2 * H * ratio / h - ratio = 1
	 * ==>  1 + ratio = 2 * H * ratio / h  ==>  (1 + ratio) / (2 * ratio) = H / h
	 * where H / h is the inverse of our `multiplier`, so the actual multiplier is (2 * ratio) / (1 + ratio).
	 */
	
	private static let golden: CGFloat = 1.47093999 * 1.10 // 110% adjusted.
	private static let inverseGolden: CGFloat = 1 / golden
	
	private static func centerMultiplier(ratio: CGFloat) -> CGFloat {
		return (2 * ratio) / (1 + ratio)
	}
}

internal protocol Tack_AlignmentPolicy {

	/// Return the attibute for this alignment, so `.left = .left / .top = .top`. Mapping the types basically.
	/// For fill constraints return the 'leading' edge.
	func attribute() -> NSLayoutConstraint.Attribute
	
	/// Return the inverse attribute for this alignment, so `.left = .right / .top = .bottom`.
	/// For fill constraints return the 'trailing' edge.
	func inverseAttribute() -> NSLayoutConstraint.Attribute
	
	/// The relation to keep this view in bounds, e.g. when aligning left, the right (inverse attribute) should be
	/// greaterThanOrEqual.
	func inBoundsRelation() -> NSLayoutConstraint.Relation
	
	/// Return the inset value for this alignment, so `.left = UIEdgeInsets.left`. Fill constraints
	/// return the `.left / .top`.
	func inset(from insets: UIEdgeInsets) -> CGFloat
	
	/// Return the  inverse  inset value for this alignment, so `.top = UIEdgeInsets.bottom`. Fill constraints
	/// return the `.right / .bottom`.
	func inverseInset(from insets: UIEdgeInsets) -> CGFloat
}

extension Tack {

	internal typealias AlignmentPolicy = Tack_AlignmentPolicy
	
	// Not using HorizontalAlignment since we want fill/golden.
	public enum HorizontalAlignmentPolicy: AlignmentPolicy {
		/// Don't align horizontally.
		case none
		/// Fill the view in the receiver.
		case fill
		/// Align the view on the left side of the receiver.
		case left
		/// Align the view on the left side for LTR languages, and on the right for RTL languages.
		case leading
		/// Align the view in the center of the receiver.
		case center
		/// Align the view in the center, using the golden ratio multiplier.
		case golden
		/// Align the view to the right side of the receiver.
		case right
		/// Align the view to the right side for LTR languages, and on the left side for RTL languages.
		case trailing
		
		// MARK: - Helper methods
		
		internal func attribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .center, .golden: return .centerX
			case .left: return .left
			case .leading: return .leading
			case .none: return .notAnAttribute
			case .right: return .right
			case .trailing: return .trailing
			case .fill: return .left
			}
		}
		
		internal func inverseAttribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .center, .golden: return .centerX
			case .left: return .right
			case .leading: return .trailing
			case .none: return .notAnAttribute
			case .right: return .left
			case .trailing: return .leading
			case .fill: return .right
			}
		}
		
		internal func inBoundsRelation() -> NSLayoutConstraint.Relation {
			switch self {
			case .center, .golden: return .equal
			case .left, .leading: return .lessThanOrEqual
			case .none: return .equal
			case .right, .trailing: return .greaterThanOrEqual
			case .fill: return .equal
			}
		}
		
		internal func inset(from insets: UIEdgeInsets) -> CGFloat {
			switch self {
			case .center, .golden: return (insets.left - insets.right) * 0.5
			case .leading, .left: return insets.left
			case .trailing, .right: return -insets.right
			case .fill: return insets.left
			case .none: return 0
			}
		}

		internal func inverseInset(from insets: UIEdgeInsets) -> CGFloat {
			switch self {
			case .center, .golden: return (insets.left - insets.right) * 0.5
			case .leading, .left: return -insets.right
			case .trailing, .right: return insets.left
			case .fill: return insets.right
			case .none: return 0
			}
		}
	}
}

extension Tack {

	// Not using HorizontalAlignment since we want fill/golden.
	public enum VerticalAlignmentPolicy: AlignmentPolicy {
		/// Don't align vertically.
		case none
		/// Fill the view in the receiver.
		case fill
		/// Align the view to the top of the receiver.
		case top
		/// Align the view to the first baseline of the receiver.
		case firstBaseline
		/// Align the view in the center of the receiver.
		case center
		/// Align the view in the center, using the golden ratio multiplier.
		case golden
		/// Align the view to the bottom of the receiver.
		case bottom
		/// Align the view to the last baseline of the receiver.
		case lastBaseline
		
		// MARK: - Helper methods
		
		internal func attribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .center, .golden: return .centerY
			case .top: return .top
			case .firstBaseline: return .firstBaseline
			case .none: return .notAnAttribute
			case .bottom: return .bottom
			case .lastBaseline: return .lastBaseline
			case .fill: return .top
			}
		}
		
		internal func inverseAttribute() -> NSLayoutConstraint.Attribute {
			switch self {
			case .center, .golden: return .centerY
			case .top: return .bottom
			case .firstBaseline: return .lastBaseline
			case .none: return .notAnAttribute
			case .bottom: return .top
			case .lastBaseline: return .firstBaseline
			case .fill: return .bottom
			}
		}
		
		internal func inBoundsRelation() -> NSLayoutConstraint.Relation {
			switch self {
			case .center, .golden: return .equal
			case .top, .firstBaseline: return .lessThanOrEqual
			case .none: return .equal
			case .bottom, .lastBaseline: return .greaterThanOrEqual
			case .fill: return .equal
			}
		}
		
		internal func inset(from insets: UIEdgeInsets) -> CGFloat {
			switch self {
			case .center, .golden: return (insets.top - insets.bottom) * 0.5
			case .top, .firstBaseline: return insets.top
			case .bottom, .lastBaseline: return -insets.bottom
			case .fill: return insets.top
			case .none: return 0
			}
		}

		internal func inverseInset(from insets: UIEdgeInsets) -> CGFloat {
			switch self {
			case .center, .golden: return (insets.top - insets.bottom) * 0.5
			case .top, .firstBaseline: return -insets.bottom
			case .bottom, .lastBaseline: return insets.top
			case .fill: return insets.bottom
			case .none: return 0
			}
		}
	}
}
