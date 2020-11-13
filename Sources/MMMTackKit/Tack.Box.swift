//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {

	/// Simplifies management of permanent vs dynamic constraints in `updateContraints()`.
	///
	/// This is another take on the `Box` concept following the older `updateContraints()` pattern we used.
	/// We are evaluating both of them as one or another might feel more natural depending on the use case.
	///
	/// # Usage:
	///
	/// - Add a variable in your view:
	///
	/// ```
	/// private let tackBox = Tack.Box()`
	/// ```
	///
	/// - Get access to the box first ("open" it) in your `updateConstraints()`.
	/// This ensures that previous dynamic constraints will be deactivated (something that's forgotten sometimes)
	/// and the new ones will be activated at once just before leaving `updateConstraints()`.
	///
	/// ```
	/// func updateConstraints() {
	///     super.updateConstraints()
	///     let box = tackBox.open()
	///     // ...
	/// ```
	///
	/// - Start adding permanent constraints, i.e. the ones that don't depend on the dynamic state/style
	/// of your view and thus can be created and activated just once.
	///
	/// ```
	/// box.activateOnce(Tack.constraints(
	///     .H(|-(padding)-viewA)
	/// ))
	/// ```
	///
	/// Note that the code creating them will be executed only the first time `updateConstraints()` is called.
	/// Also note that you can have multiple calls of `activateOnce()`, they all will have effect the first time.
	///
	/// - Add dynamic constraints that might change every time `updateConstraints()` is called:
	///
	/// ```
	/// if !shouldDisplayViewB {
	///     box.activate(Tack.H(viewA-(padding)-|))
	/// } else {
	///     box.activate(Tack.H(viewA-(padding)-viewB-(padding)-|))
	/// }
	/// ```
	///
	/// The dynamic constraints will be activated at once when the `box` accessor goes out of scope.
	///
	/// Note that the calls to `activateOnce()` and `activate()` calls can be freely intermixed.
	public final class Box {

		public init() {}

		private var fillingFirstTime: Bool = true

		/// The dynamic ones, added via `activate` of the accessor.
		private var constraints: [NSLayoutConstraint] = []

		/// The current acessor, only for diagnostics.
		private weak var openBox: OpenBox?

		/// Returns the accessor object through which the constraints should be added and which ensures they
		/// are activated when it goes out of scope.
		///
		/// There must be only one accessor at a time, thus never hold the returned values longer than
		/// your `updateConstraints()` call.
		public func open() -> OpenBox {

			assert(openBox?.closed ?? true, "Did you forget to close the box before?")

			let r = OpenBox(box: self)
			openBox = r

			// Could do this just before the activation of the new constraints collected when the box was open,
			// but doing this here makes it more clear for the user.
			NSLayoutConstraint.deactivate(constraints)
			constraints = []

			return r
		}

		/// Allows to safely add permanent or dynamic constraints into a box.
		public final class OpenBox {

			private let box: Box

			public init(box: Box) {
				self.box = box
			}

			deinit {
				close()
			}

			/// Activates the given constraints only the first time the box is filled in.
			/// (Uses an autoclosure to skip creation of your constraints when accessed later.)
			///
			/// Can be called multiple times and mixed with regular activate() calls.
			///
			/// Note that the user code could use `.once { Tack.activate(...` instead,
			/// but having this as a pair for `activate()` could make the code look consistent.
			public func activateOnce(_ constraints: @autoclosure () -> [NSLayoutConstraint]) {

				guard box.fillingFirstTime else {
					// Already set, skip calling the closure.
					// Note that we could still call it in Debug only to check that the constraints are still the same,
					// i.e. the user code is not misusing the API.
					return
				}

				// Could do this later, when the box is closed, but there would not be any benefits it seems.
				NSLayoutConstraint.activate(constraints())
			}

			/// Activates the given constraints and adds them into the box to automatically deactivate
			/// the next time the box is opened.
			///
			/// (No overload accepting OrientedChain here to keep it consistent with activateOnce() where we cannot
			/// add an overload to keep using autoclosure.)
			public func activate(_ constraints: [NSLayoutConstraint]) {
				// Again, we could activate them all at once when the box is closed,
				// but it seems like this has no benefits and might cause confusion when debugging.
				NSLayoutConstraint.activate(constraints)
				box.constraints.append(contentsOf: constraints)
			}

			fileprivate var closed: Bool = false

			public func close() {

				// Should be safe to call multiple times.
				guard !closed else { return }

				closed = true

				// Sealing it for permanent constraints.
				box.fillingFirstTime = false
			}
		}
	}
}
