//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import UIKit

extension Tack {

	/// Simplifies management of permanent vs dynamic constraints in `updateContraints()`.
	///
	/// This is another take on the `Box` concept following the older `updateContraints()` pattern we used.
	/// (We are evaluating both of them here as one or another might feel more natural depending on the use case.)
	///
	/// # Usage:
	///
	/// - Add a variable into your view:
	///
	/// ```
	/// private let tackBox = Tack.Box()
	/// ```
	///
	/// - In your `updateConstraints()` get access to the box first ("open" it).
	/// This ensures that previous dynamic constraints are deactivated (something that's often forgotten)
	/// and prepares the box to track the new ones:
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
	/// Note that you can have multiple calls of `activateOnce()`, they will have effect only the first time
	/// each of them is called. (Every call is identified by the code line number, i.e. no 2 calls per line
	/// nor 2 files sharing the same box, please.)
	///
	/// Also note that due to the use of auto-closures this is almost as efficient as if you were using
	/// `if`s with custom flags.
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
	/// Note that the calls to `activateOnce()` and `activate()` can be freely intermixed,
	/// including the case that was not supported prior to version `0.7` of this library (where it was implicitly
	/// required that all `activateOnce()` calls were made when the box was opened for the first time):
	///
	/// ```
	/// let box = tackBox.open()
	/// ...
	/// if !label.isHidden {
	/// 	box.activateOnce(...)
	/// }
	/// ```
	public final class Box {

		public init() {}

		/// The dynamic ones, added via `activate` of the accessor.
		private var constraints: [NSLayoutConstraint] = []

		/// Identifiers (line numbers) of already processed `activateOnce()` calls.
		///
		/// Note that before 0.7 we used a single flag to know if all "once constraints" were installed already.
		/// This would not allow to use `activateOnce()` calls near regular `activate()` guarded by `if`s however,
		/// either separating the related constraints or causing hard to notice bugs.
		///
		/// It should be safe to assume that a box is used from the same source code file and that no more than
		/// one calls per line are made (at least without lecturing on code formatting).
		/// Thus code line numbers should be able to properly identify each call.
		private lazy var linesOfSeenActivateOnceCalls = Set<Int>()

		/// The current accessor, only for diagnostics.
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

			/// Activates the given constraints only once. Uses an auto-closure for efficiency.
			///
			/// The auto-closure allows to skip even creation of your constraints the second time this call
			/// is touched, i.e. you don't have to track if you've added these already nor move their addition
			/// too far (e.g. `init`) from the dynamic constraints added via `activate()`.
			///
			/// Can be called multiple times and mixed with regular activate() calls.
			public func activateOnce(
				_ constraints: @autoclosure () -> [NSLayoutConstraint],
				_ line: Int = #line
			) {

				guard !box.linesOfSeenActivateOnceCalls.contains(line) else {
					// Already set, skip calling the closure.
					// Perhaps we could call the closure in Debug to check that the constraints are still
					// the same as before, i.e. the user code is not misusing the API.
					return
				}

				box.linesOfSeenActivateOnceCalls.insert(line)

				// We could activate these later when closing the box, but there would not be any benefits it seems.
				NSLayoutConstraint.activate(constraints())
			}

			/// Activates the given constraints and adds them into the box to automatically deactivate
			/// the next time the box is opened.
			///
			/// (No overload accepting OrientedChain here to keep it consistent with activateOnce() where we cannot
			/// add an overload due to the use of auto-closures.)
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
			}
		}
	}
}
