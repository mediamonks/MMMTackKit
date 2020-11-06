//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {
	
	/// The `Box` can be used to orchestrate a set of constraints, e.g. between state changes. The main goal is to avoid
	/// unneccessary, and complex / error prone, if/else chains in `UIView.updateConstraints()`.
	///
	/// You should supply a `Hashable` as generic constraint, this usually ends up being an `enum State {}`, but
	/// could be identifiers or something similar.
	///
	/// Start by adding constraints for a certain state, after that you can safely call `.set(state:)` to update the active
	/// state. Make sure to call `setNeedsUpdateConstraints()` after you set a new state.
	///
	/// Finally you should override your `updateConstraints()` method, and call `Box.updateConstraints()`
	/// to actually activate/deactive the constraints.
	final public class Box<Statable: Hashable> {
		
		private var currentState: Set<Statable>
		private var activatedStates: Set<Statable> = []
		
		private var storage = [Statable: [NSLayoutConstraint]]()
		
		/// Create a new box, passing the current states.
		///
		/// - Parameter states: A set of states to start off with.
		public init(states: Set<Statable> = []) {
			currentState = states
		}

		/// Create a new box, passing the current state.
		///
		/// - Parameter state: State to start off with.
		public convenience init(state: Statable) {
			self.init(states: [state])
		}

		/// Add constraints to the `Box` for a given state.
		public func add(state: Statable, constraints: [NSLayoutConstraint]...) {
			add(constraints: constraints.flatMap { $0 }, state: state)
		}
		
		public subscript(states: Statable...) -> [NSLayoutConstraint] {
			set {
				add(states: Set<Statable>.init(states), constraints: newValue)
			}
			get {
				return states.compactMap { storage[$0] }.flatMap { $0 }
			}
		}
		
		/// Add constraints to the `Box` for a given set of states.
		public func add(states: Set<Statable>, constraints: [NSLayoutConstraint]...) {
			states.forEach { state in
				add(constraints: constraints.flatMap { $0 }, state: state)
			}
		}
		
		private func add(constraints: [NSLayoutConstraint], state: Statable) {
			
			var allConstraints = constraints
			
			if let current = storage[state] {
				// Already have storage for this state, let's add the constraints.
				allConstraints.append(contentsOf: current)
			}
			
			storage[state] = allConstraints
			
			if currentState.contains(state) {
				// We're already presenting this state; let's make sure to activate the new
				// constraints right away.
				Tack.activate(constraints)
			}
		}
		
		/// Remove all constraints from the box for a given state.
		///
		/// - Parameter state: The state to remove the constraints for.
		/// - Throws: Throws a `stateNotFound` error if you try to remove a state that isn't added to the box, and
		/// throws `stateActive` if you try to remove constraints while currently in this state.
		/// - Returns: The constraints known in the box for this state.
		@discardableResult
		public func remove(state: Statable) -> [NSLayoutConstraint] {
			
			guard !currentState.contains(state) else {
				assertionFailure("Removing a state \(state) that's currently active")
				return []
			}
			
			guard let constraints = storage.removeValue(forKey: state) else {
				assertionFailure("Removing a state \(state) that isn't added")
				return []
			}
			
			return constraints
		}
		
		/// Set the current state. Please note you'll have to call `setNeedsUpdateConstraints()` after this.
		/// - Parameter state: The state to activate.
		/// - Throws: Throws a `stateNotFound` error if you try to activate a state that isn't added to the box.
		public func set(state: Statable) {
			set(states: [state])
		}
		
		/// Set the current states. Please note you'll have to call `setNeedsUpdateConstraints()` after this.
		/// - Parameter state: The states to activate.
		/// - Throws: Throws a `stateNotFound` error if you try to activate a state that isn't added to the box.
		public func set(states: Set<Statable>) {
			
			states.forEach { state in
				if !storage.keys.contains(state) {
					assertionFailure("Trying to set current state to \(states) but it isn't added")
				}
			}
			
			currentState = states
		}
		
		/// Call this in your `UIView.updateConstraints()` method.
		public func updateConstraints() {
			
			// Let's deactivate constraints corresponding to the states that don't appear in the new set of states.
			activatedStates.subtracting(currentState)
				.compactMap { storage[$0] } // Could be that the user has removed constraints for those inactive states.
				.forEach { Tack.deactivate($0) }

			// And activate the ones corresponding to the new states skipping previously activated.
			currentState.subtracting(activatedStates).forEach { state in
			
				guard let constraints = storage[state] else {
					assertionFailure("No constraints for state \(state), is this intentional?")
					return
				}
				
				// Only activate constraints that aren't active yet; e.g. when adding the
				// same constraints to multiple states, and activating multiple states.
				Tack.activate(constraints.filter { !$0.isActive })
			}

			activatedStates = currentState
		}
	}
}
