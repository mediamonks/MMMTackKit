//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {

	/// Aligns a view (or a layout guide) relative to another view (or layout guide) using a few simple
	/// alignment policies like "center" or "fill".
	///
	/// Note that the view/guide being aligned does not have to be a child of the target view.
	///
	/// The insets are treated as if they were applied to the bounds of the target container first.
	///
	/// For example, with insets being `(20, 0, 10, 0)`:
	///
	/// 1) a horizontal `.fill` alignment policy  will keep the expected 20pt padding on the left and 10pt
	///    on the right of the view being aligned;
	///
	/// 2) and a horizontal `.center` alignment policy (in addition to not being allowed to be closer than 20/10pt
	///    to the sides of the container) will cause the center of the view being aligned to be shifted by 15pt
	///    (`insets.left - insets.right` / 2), so it is aligned with the center of the inset bounds
	///    of the target container.
	///
	/// - Parameters:
	///   - view: The view (or layout guide) to align.
	///   - another: The view (or layout guide) where to align the `view` to.
	///   - horizontally: How to horizontally align the view.
	///   - vertically: How to vertically align the view. Defaults to `.none`.
	///   - insets: The insets to apply to the alignment.
	public static func align(
		view: Tack.ViewOrLayoutGuide,
		to another: Tack.ViewOrLayoutGuide,
		horizontally: HorizontalAlignmentPolicy,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) {
		Tack.activate(Tack.constraints(
			aligning: view,
			to: another,
			horizontally: horizontally,
			vertically: vertically,
			insets: insets
		))
	}
	
	/// Aligns a view (or a layout guide) relative to another view (or layout guide) using a few simple
	/// alignment policies like "center" or "fill".
	///
	/// Note that the view/guide being aligned does not have to be a child of the target view.
	///
	/// The insets are treated as if they were applied to the bounds of the target container first.
	///
	/// For example, with insets being `(20, 0, 10, 0)`:
	///
	/// 1) a horizontal `.fill` alignment policy  will keep the expected 20pt padding on the left and 10pt
	///    on the right of the view being aligned;
	///
	/// 2) and a horizontal `.center` alignment policy (in addition to not being allowed to be closer than 20/10pt
	///    to the sides of the container) will cause the center of the view being aligned to be shifted by 15pt
	///    (`insets.left - insets.right` / 2), so it is aligned with the center of the inset bounds
	///    of the target container.
	///
	/// - Parameters:
	///   - view: The view (or layout guide) to align.
	///   - another: The view (or layout guide) where to align the `view` to.
	///   - vertically: How to vertically align the view. Defaults to `.none`.
	///   - insets: The insets to apply to the alignment.
	public static func align(
		view: Tack.ViewOrLayoutGuide,
		to another: Tack.ViewOrLayoutGuide,
		vertically: VerticalAlignmentPolicy,
		insets: UIEdgeInsets = .zero
	) {
		Tack.align(view: view, to: another, horizontally: .none, vertically: vertically, insets: insets)
	}

	/// Return the constraints normally applied by `Tack.align()`. For more info, look at that doc-block.
	/// - Returns: An array containing the constraints
	public static func constraints(
		aligning view: Tack.ViewOrLayoutGuide,
		to another: Tack.ViewOrLayoutGuide,
		horizontally: HorizontalAlignmentPolicy,
		vertically: VerticalAlignmentPolicy = .none,
		insets: UIEdgeInsets = .zero
	) -> [NSLayoutConstraint] {
		
		return _constraints(aligning: view, another: another, h: horizontally, v: vertically, insets: insets)
	}

	/// Return the constraints normally applied by `Tack.align()`. For more info, look at that doc-block.
	/// - Returns: An array containing the constraints
	public static func constraints(
		aligning view: Tack.ViewOrLayoutGuide,
		to another: Tack.ViewOrLayoutGuide,
		vertically: VerticalAlignmentPolicy,
		insets: UIEdgeInsets = .zero
	) -> [NSLayoutConstraint] {
		
		return constraints(aligning: view, to: another, horizontally: .none, vertically: vertically, insets: insets)
	}

	/// Return an array with all the constraints for aligning a view, with type erased parent.
	fileprivate static func _constraints(
		aligning view: Any,
		another: Any,
		h: HorizontalAlignmentPolicy,
		v: VerticalAlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		var constraints = [NSLayoutConstraint]()
		
		switch h {
		case .none:
			break
		case .center, .golden:
			constraints = centerConstraints(view: view, another: another, policy: h, insets: insets)
		case .fill:
			constraints = fillConstraints(view: view, another: another, policy: h, insets: insets)
		case .left, .leading, .right, .trailing:
			constraints = pinConstraints(view: view, another: another, policy: h, insets: insets)
		}
		
		switch v {
		case .none:
			break
		case .center, .golden:
			constraints.append(contentsOf:
				centerConstraints(view: view, another: another, policy: v, insets: insets)
			)
		case .fill:
			constraints.append(contentsOf:
				fillConstraints(view: view, another: another, policy: v, insets: insets)
			)
		case .top, .firstBaseline, .bottom, .lastBaseline:
			constraints.append(contentsOf:
				pinConstraints(view: view, another: another, policy: v, insets: insets)
			)
		}
		
		return constraints
	}
	
	/// Return constrains to pin a view to its parent and make sure it stays within bounds.
	private static func pinConstraints(
		view: Any,
		another: Any,
		policy: AlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: another, attribute: policy.attribute(),
				multiplier: 1, constant: policy.inset(from: insets)
			),
			// We want the view to stay in-bounds.
			NSLayoutConstraint(
				item: view, attribute: policy.inverseAttribute(),
				relatedBy: policy.inBoundsRelation(),
				toItem: another, attribute: policy.inverseAttribute(),
				multiplier: 1, constant: policy.inverseInset(from: insets)
			)
		]
	}
	
	/// Return constraints to fill a view in its parent.
	private static func fillConstraints(
		view: Any,
		another: Any,
		policy: AlignmentPolicy,
		insets: UIEdgeInsets
	) -> [NSLayoutConstraint] {
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: another, attribute: policy.attribute(),
				multiplier: 1, constant: policy.inset(from: insets)
			),
			NSLayoutConstraint(
				item: view, attribute: policy.inverseAttribute(),
				relatedBy: .equal,
				toItem: another, attribute: policy.inverseAttribute(),
				multiplier: 1, constant: -policy.inverseInset(from: insets)
			)
		]
	}
	
	/// Return constraints to center a view in it's parent, making sure it's in bounds, handles golden ratio as well.
	private static func centerConstraints(
		view: Any,
		another: Any,
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

		} else if case let horizontal as HorizontalAlignmentPolicy = policy {

			leadingAttr = .left
			leadingInset = insets.left
			trailingAttr = .right
			trailingInset = insets.right
			
			multiplier = horizontal == .golden ? centerMultiplier(ratio: inverseGolden) : 1

		} else {
			preconditionFailure()
		}
		
		return [
			NSLayoutConstraint(
				item: view, attribute: policy.attribute(),
				relatedBy: .equal,
				toItem: another, attribute: policy.attribute(),
				multiplier: multiplier, constant: policy.inset(from: insets)
			),
			// We want the view to stay in-bounds.
			NSLayoutConstraint(
				item: view, attribute: leadingAttr,
				relatedBy: .greaterThanOrEqual,
				toItem: another, attribute: leadingAttr,
				multiplier: 1, constant: leadingInset
			),
			NSLayoutConstraint(
				item: view, attribute: trailingAttr,
				relatedBy: .lessThanOrEqual,
				toItem: another, attribute: trailingAttr,
				multiplier: 1, constant: -trailingInset
			)
		]
	}

	/// Converts a space ratio into a layout constraints `multiplier`.
	///
	/// Suppose you need to constrain a view so its center divides its container in certain ratio different
	/// from 1:1 (e.g. golden section):
	///
	/// ```
	///  ┌─────────┐ ◆
	///  │         │ │
	///  │         │ │ a
	///  │┌───────┐│ │
	/// ─│┼ ─ ─ ─ ┼│─◆   ratio = a / b
	///  │└───────┘│ │
	///  │         │ │
	///  │         │ │
	///  │         │ │ b
	///  │         │ │
	///  │         │ │
	///  │         │ │
	///  └─────────┘ ◆
	/// ```
	///
	/// You cannot put this ratio directly into the `multiplier` parameter of the corresponding
	/// `NSLayoutConstraints` relating the centers of the views, because the `multiplier` would be the ratio
	/// between the distance to the center of the view (`h`) and the distance to the center
	/// of the container (`H`) instead:
	///
	/// ```
	///   ◆ ┌─────────┐ ◆
	///   │ │         │ │
	///   │ │         │ │ a = h
	/// H │ │┌───────┐│ │
	///   │ │├ ─ ─ ─ ┼│─◆   multiplier = h / H
	///   │ │└───────┘│ │   ratio = a / b = h / (2 * H - h)
	///   ◆─│─ ─ ─ ─ ─│ │
	///     │         │ │
	///     │         │ │ b = 2 * H - h
	///     │         │ │
	///     │         │ │
	///     │         │ │
	///     └─────────┘ ◆
	/// ```
	///
	/// I.e. the `multiplier` is `h / H` (assuming the view is the first in the definition of the constraint),
	/// but the ratio we are interested in would be `h / (2 * H - h)` when expressed in the distances to centers.
	///
	/// Calculations:
	/// ```
	/// ratio = h / (2 * H - h)  ==>
	/// 2 * H * ratio - h * ratio = h  ==>
	/// 2 * H * ratio / h - ratio = 1  ==>
	/// 1 + ratio = 2 * H * ratio / h  ==>
	/// (1 + ratio) / (2 * ratio) = H / h
	/// ```
	/// where `H / h` is the inverse of our `multiplier`, so the actual multiplier is `(2 * ratio) / (1 + ratio)`.
	///
	/// - Parameter ratio: In what ratio you would like the container view to be split by the center of the view
	///   being aligned (top to bottom or left to right).
	private static func centerMultiplier(ratio: CGFloat) -> CGFloat {
		return (2 * ratio) / (1 + ratio)
	}

	/// The golden ratio constant, `~1.618`.
	private static let golden: CGFloat = 1.47093999 * 1.10 // 110% adjusted.

	/// The inverse of the golden ratio, `~0.618`.
	private static let inverseGolden: CGFloat = 1 / golden
}

internal protocol Tack_AlignmentPolicy {

	/// Return the attribute for this alignment, so `.left = .left / .top = .top`. Mapping the types basically.
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
