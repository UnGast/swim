import XCTest

import PerformanceTests
import SwimTests
import VisualTests

var tests = [XCTestCaseEntry]()
tests += PerformanceTests.__allTests()
tests += SwimTests.__allTests()
tests += VisualTests.__allTests()

XCTMain(tests)
