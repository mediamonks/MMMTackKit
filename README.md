# MMMTackKit

[![Build](https://github.com/mediamonks/MMMTackKit/workflows/Build/badge.svg)](https://github.com/mediamonks/MMMTackKit/actions?query=workflow%3ABuild)
[![Test](https://github.com/mediamonks/MMMTackKit/workflows/Test/badge.svg)](https://github.com/mediamonks/MMMTackKit/actions?query=workflow%3ATest)

Type-safe replacement for Auto Layout Visual Formatting Language.

(This is a part of `MMMTemple` suite of iOS libraries we use at [MediaMonks](https://www.mediamonks.com/).)

## Installation

Podfile:

```ruby
source 'https://github.com/mediamonks/MMMSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
...
pod 'MMMTackKit'
```

SPM:

```swift
.package(url: "https://github.com/mediamonks/MMMTackKit", .upToNextMajor(from: "0.8.1"))
```

## Why

One of the major downsides of [Visual Formatting Language (VFL)](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html) is that everything is
coded inside string constants, there is no type-safety and expressions get evaluated
at run-time instead of compile-time. A typo will only be noticed when you run
the app.

Tack solves this with by harnessing the power of [custom operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID46) in Swift. The syntax is very similar to VFL to minimise
the learning curve.

A side effect of this is performance, on average Tack is about 2x faster than VFL.

## Usage

Let's look at some pretty standard VFL code from Apple's [documentation](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html).

```swift
NSLayoutConstraint.constraints(
	withVisualFormat: "H:|-50-[purpleBox]-50-|",
	options: [], metrics: [:], views: ["purpleBox": purpleBox]
)
```

This is really easy to convert into type-safe `Tack` code:

```swift
Tack.H(|-50-purpleBox-50-|)

// We prefer to keep the paddings in parentheses to give a bit more visual clarity
// and separation from the views. Especially if your paddings come from a stylesheet.
let p = Stylesheet.shared.paddings

Tack.H(|-(p.L)-purpleBox-(p.L)-|)
```

### A more extensive example

```swift
let views = ["purpleBox": purpleBox, "yellowBox": yellowBox, "pinkBox": pinkBox]

NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
	withVisualFormat: "H:|-(>=50,50@249)-[purpleBox]-(8)-[yellowBox]-(>=20)-|",
	options: [], metrics: [:], views: views
))

NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
	withVisualFormat: "V:|-(20)-[purpleBox]-(>=20)-|",
	options: [], metrics: [:], views: views
))

NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
	withVisualFormat: "V:|-(8)-[yellowBox]-(8)-[pinkBox]-(>=8,8@749)-|",
	options: [.alignAllCenterX], metrics: [:], views: views
))
```

The `Tack` equivalent of this is a lot more concise:

```swift
Tack.activate(
  // The >== operator is a shorthand for '>=50,50@249', what we call a 'double pin',
  // this implies a pin of 249 priority, but the priority of the second pin can
  // be specified.
  .H(|-(>==50)-purpleBox-(8)-yellowBox-(>=20)-|),
  .V(|-(20)-purpleBox-(>=20)-|),
  // We can use the alignAll attribute, this is the equivalent of
  // NSLayoutConstraint.FormatOptions `alignAll` options.
  .V(|-(8)-yellowBox-(8)-pinkBox-(>==8^749)-|, alignAll: .centerX)
)
```

There are a couple of reserved operators, what used to be the priority operator
in VFL `@` is now `^` in `Tack`, so instead of writing `|-(20@249)-[purpleBox]` we
write `|-(20^249)-purpleBox` instead.

The same goes for the brackets around views, in VFL you can specify a views
height / width, this is something that is (not yet) supported in `Tack`. Luckily
this is pretty concise using `widthAnchor` / `heightAnchor`.

Aside from directly activating constraints, we can also grab an array of constrains.
Instead of `Tack.activate()`, use `Tack.constraints()`, this will return all the
generated constraints.

The `activate` / `constraints` method can also take a `@resultBuilder`, this
allows you to write conditional constraints, so you can keep all your constraints
in a single block:

```swift
Tack.activate {
  Tack.V(|-(padding)-view)

  if keepInBounds {
    Tack.V(view-(>=)-(padding)-|)
  }

  switch alignment {
  case .leading:
    Tack.H(|-(padding)-view-(>=padding)-|)
  case .trailing:
    Tack.H(|-(>=padding)-view-(padding)-|)
  }
}
```

Lastly there is built-in support for aligning to the safe-area, instead of
manually having to grab the safeArea guide we can use the `|>-` and `-<|`
operators:

```swift
// This will keep the view 20pts below the top safeArea, and at least in bounds
// on the bottom safeArea.
Tack.V(|>-(20)-view-(>=20)-<|)
```

## Simple alignment

Sometimes you just want to quickly align a view to it's parent, or to another
view. In this case you can use the `Tack.align()` and `Tack.constraints(aligning:..)`
methods, the first will activate the constraints right away, the latter will return
an array of constraints.

```swift
// Simple example, just fill the view horizontally:
Tack.align(
  view: view,
  to: parent,
  horizontally: .fill
)

// More advanced example:
Tack.align(
  // The view to align.
  view: view,

  // Where to align the view to, e.g. parent or some other view.
  to: parent,

  // We pin view.leading to parent.leading, and view.trailing to parent.trailing.
  horizontally: .fill,

  // We pin view.centerY to parent.centerY, but keep the view in bounds by
  // view.top >= parent.top and view.bottom <= parent.bottom.
  vertically: .center,

  // Additional insets, so the view will be inset by 10pts on each edge.
  insets: UIEdgeInsets(
    top: 10,
    left: 10,
    bottom: 10, // Since top and bottom are equal, and we're aligning on center,
                // the view will be perfectly center; however, if bottom would
                // be 0, the view will be 10px offset from center.
    right: 10
  )
)
```

## Tack.Box

Simplifies management of permanent vs dynamic constraints in `updateContraints()`.

This is another take on the `Box` concept following the older `updateContraints()` pattern we used.
(We are evaluating both of them here as one or another might feel more natural depending on the use case.)

### Usage:

- Add a variable into your view:

```swift
private let tackBox = Tack.Box()
```

- In your `updateConstraints()` get access to the box first ("open" it).
This ensures that previous dynamic constraints are deactivated (something that's often forgotten)
and prepares the box to track the new ones:

```swift
func updateConstraints() {
    super.updateConstraints()
    let box = tackBox.open()
    // ...
```

- Start adding permanent constraints, i.e. the ones that don't depend on the dynamic state/style
of your view and thus can be created and activated just once.

```swift
box.activateOnce(Tack.constraints(
    .H(|-(padding)-viewA)
))
```

Note that you can have multiple calls of `activateOnce()`, they will have effect only the first time
each of them is called. (Every call is identified by the code line number, i.e. no 2 calls per line
nor 2 files sharing the same box, please.)

Also note that due to the use of auto-closures this is almost as efficient as if you were using
`if`s with custom flags.

- Add dynamic constraints that might change every time `updateConstraints()` is called:

```swift
if !shouldDisplayViewB {
    box.activate(Tack.H(viewA-(padding)-|))
} else {
    box.activate(Tack.H(viewA-(padding)-viewB-(padding)-|))
}
```

Note that the calls to `activateOnce()` and `activate()` can be freely intermixed,
including the case that was not supported prior to version `0.7` of this library (where it was implicitly
required that all `activateOnce()` calls were made when the box was opened for the first time):

```swift
let box = tackBox.open()
...
if !label.isHidden {
	box.activateOnce(...)
}
```

## Tack.Conductor

The `Conductor` can be used to orchestrate a set of constraints, e.g. between
state changes. The main goal is to avoid unnecessary, and complex / error prone,
if/else chains in `UIView.updateConstraints()`.

You should supply a `Hashable` as generic constraint, this usually ends up being
an `enum State {}`, but could be identifiers or something similar.

Start by adding constraints for a certain state, after that you can safely
set `.activeState` to update the active state. Make sure to call
`setNeedsUpdateConstraints()` after you set a new state.

Finally you should override your `updateConstraints()` method, and call
`conductor.updateConstraints()` to actually activate/de-active the constraints.

### Simple example

```swift
// Store this as a property on your view.
let conductor = Tack.Conductor(activeState: MyState.initialState)

// In your init() call, add the constraints to the conductor.
// On `initialState` viewA is pinned to top with viewB below it.
conductor[.initialState] = Tack.constraints(
    .V(|-(8)-viewA-(8)-viewB-(>=8)-|)
)

// On `secondState` viewB is pinned to bottom with viewA above it.
conductor[.secondState] = Tack.constraints(
    .V(|-(>=8)-viewA-(8)-viewB-(8)-|)
)

// Make sure to override updateConstraints()
override func updateConstraints() {
    super.updateConstraints()
    conductor.updateConstraints()
}

// Somewhere where you update the viewState:
func updateUI() {

    if someCondition {
        conductor.activeState = .secondState
    } else {
        conductor.activeState = .initialState
    }

    setNeedsUpdateConstraints()
}
```

## Ready for liftoff? 🚀

We're always looking for talent. Join one of the fastest-growing rocket ships in
the business. Head over to our [careers page](https://media.monks.com/careers)
for more info!
