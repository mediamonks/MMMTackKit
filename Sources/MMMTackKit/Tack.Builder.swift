//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2022 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {
	
	@resultBuilder
	/// A resultBuilder that allows you to activate / create chains. This allows you to use conditionals inside your
	/// ``Tack.activate`` or ``Tack.constraints`` block.
	///
	/// **Example**
	/// ```
	///	Tack.activate {
	///		Tack.V(|-(padding)-view)
	///
	///		if keepInBounds {
	///			Tack.V(view-(>=)-(padding)-|)
	///		}
	///
	///		switch alignment {
	///		case .leading:
	///			Tack.H(|-(padding)-view-(>=padding)-|)
	///		case .trailing:
	///			Tack.H(|-(>=padding)-view-(padding)-|)
	///		}
	///	}
	/// ```
	public struct Builder {
		
		public static func buildBlock(_ components: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
			return buildArray(components)
		}
		
		public static func buildOptional(_ component: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
			return component ?? []
		}
		
		public static func buildEither(first component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
			return component
		}
		
		public static func buildEither(second component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
			return component
		}
		
		public static func buildArray(_ components: [[NSLayoutConstraint]]) -> [NSLayoutConstraint] {
			return components.flatMap { $0 }
		}
	}
}
