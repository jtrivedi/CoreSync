# CoreSync

CoreSync is an Objective-C diff/patch framework that supports the [JSONPatch](http://jsonpatch.com) specification.

First, CoreSync can efficiently calculate the difference (the deltas) between two NSDictionary objects (of which can be represented as JSON). This is the `diff` part of CoreSync, which is also known as a [binary log](https://dev.mysql.com/doc/refman/5.0/en/binary-log.html).

The second part of CoreSync is the `patch` functionality. Once the `diff` is calculated, CoreSync can apply each patch transaction to the original dictionary, bringing it up-to-date.

It’s particularly useful for syncing (as the name suggests).

*Note: I’m also working on a fully Swift version of CoreSync. I’m excited about it, but CoreSync leverages a significant amount of Objective-C’s dynamism, which Swift doesn’t provide.*

## How to Get Started

CoreSync is flexible, modular, and lightweight. It’s also extremely easy to use in your projects, and comes with no dependencies.

- [Download CoreSync](https://github.com/jtrivedi/CoreSync/archive/master.zip).
- Try it out by opening the Xcode project and running the tests via the `CoreSyncTests` target. `CoreSyncTests.m` also provides an easy example of how to use the framework.
- Install it in your own project by simply adding the CoreSync folder into your target, and `#import "CoreSync.h"`.

## Contributing

- If you need help, just ask! Email and [Twitter](https://twitter.com/jmtrivedi) both work.
- If you found a bug, or have a feature request, open an issue.
- If you would like to contribute, that’s awesome! Open up a pull request!

Enjoy! :octocat:
