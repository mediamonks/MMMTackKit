//
// MMMTackKit. Part of MMMTemple.
// Copyright (C) 2015-2020 MediaMonks. All rights reserved.
//

import MMMTackKit
import XCTest

class TackBoxTestCase: BaseTestCase {

	func testBasics() {

		// The box is declared as a var in a view (or in a controller if you happen to do layout there).
		let tackBox = Tack.Box()

		// The view (or controller) maintains states/flags/styles affecting the layout.
		// The exact form this state info is maintained in is up to the view. Let's have a simple flag for now.
		var shouldDisplayViewB = false

		// And then the usual updateConstraints() is overridden:
		func updateConstraints() {

			// (With `super.updateConstraints()` of course.)

			// We're getting access to the box first.
			// This ensures that previous dynamic constraints will be deactivated
			// (something that's forgotten sometimes which alone can be the reason to use this helper)
			// and the new ones will be activated at once before leaving updateConstraints().
			let box = tackBox.open()

			// Some of the constraints exist in all the states.
			// (The code creating constraints won't execute the second time, it's an auto-closure here.)
			box.activateOnce(Tack.constraints(
				.H(|-(padding)-viewA)
			))

			// And some depend on flags/states/styles:
			if !shouldDisplayViewB {
				box.activate(Tack.H(viewA-(padding)-|))
			} else {
				box.activate(Tack.H(viewA-(padding)-viewB-(padding)-|))
			}

			// Permanent constraints don't have to be set in a single go either, they are accumulated
			// just like the dynamic ones, so things can be grouped.
			box.activateOnce(Tack.V(|-(padding)-viewA-(padding)-|))

			if shouldDisplayViewB {
				box.activate(Tack.V(|-(padding)-viewB-(padding)-|))
			}
		}

		shouldDisplayViewB = true
		updateConstraints()
		assertEqualConstraints(
			container.constraints,
			Tack.constraints(
				.H(|-(padding)-viewA-(padding)-viewB-(padding)-|),
				.V(|-(padding)-viewA-(padding)-|),
				.V(|-(padding)-viewB-(padding)-|)
			)
		)

		shouldDisplayViewB = false
		updateConstraints()
		assertEqualConstraints(
			container.constraints,
			Tack.constraints(
				.H(|-(padding)-viewA-(padding)-|),
				.V(|-(padding)-viewA-(padding)-|)
			)
		)

		// Btw, it should be safe to close the box manually.
		do {
			let box = tackBox.open()
			box.close()
			// And more than once or when goes out of scope.
			box.close()
		}
		// However opening/closing it will keep only permanent constraints as we have not installed dynamic ones.
		assertEqualConstraints(
			container.constraints,
			Tack.constraints(
				.H(|-(padding)-viewA),
				.V(|-(padding)-viewA-(padding)-|)
			)
		)
	}
}
