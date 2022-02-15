//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2022 MediaMonks. All rights reserved.
//

import UIKit

public protocol Tack_Builder_Block {
	func asTackComponents() -> [NSLayoutConstraint]
}

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
	
		public typealias Block = Tack_Builder_Block
		
		public static func buildBlock(_ components: Block...) -> [NSLayoutConstraint] {
			return buildArray(components)
		}
		
		public static func buildOptional(_ component: Block?) -> [NSLayoutConstraint] {
			return component.map { $0.asTackComponents() } ?? []
		}
		
		public static func buildEither(first component: Block) -> [NSLayoutConstraint] {
			return component.asTackComponents()
		}
		
		public static func buildEither(second component: Block) -> [NSLayoutConstraint] {
			return component.asTackComponents()
		}
		
		public static func buildArray(_ components: [Block]) -> [NSLayoutConstraint] {
			return components.flatMap { $0.asTackComponents() }
		}
	}
}

extension Array: Tack.Builder.Block where Element == NSLayoutConstraint {
	
	public func asTackComponents() -> [NSLayoutConstraint] {
		return self
	}
}

extension NSLayoutConstraint: Tack.Builder.Block {
	
	public func asTackComponents() -> [NSLayoutConstraint] {
		return [self]
	}
}
