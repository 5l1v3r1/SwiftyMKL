import XCTest
import BaseMath
@testable import SwiftyMKL

protocol TestProtocol {
  associatedtype T:Vector
  typealias E=T.Element
  var v1:T {get}
  var v2:T {get}
  var rng:RandDistrib {get}
  var z:E {get}
}

class SwiftyMKLTestsVectorPFloat: XCTestCase,TestProtocol {
  typealias T=VectorP<Float>
  override class func setUp() {
    super.setUp()
    IPP.setup()
  }

  let v1:T = [1.0, -2,  3, 0]
  let v2:T = [0.5, 12, -2, 1]
  let rng = RandDistrib()
  let z:E = 0.0
}
class SwiftyMKLTestsArrayFloat: XCTestCase,TestProtocol {
  typealias T=Array<Float>
  override class func setUp() {
    super.setUp()
    IPP.setup()
  }

  let v1:T = [1.0, -2,  3, 0]
  let v2:T = [0.5, 12, -2, 1]
  let rng = RandDistrib()
  let z:E = 0.0
}
class SwiftyMKLTestsVectorPDouble: XCTestCase,TestProtocol {
  typealias T=VectorP<Double>
  override class func setUp() {
    super.setUp()
    IPP.setup()
  }

  let v1:T = [1.0, -2,  3, 0]
  let v2:T = [0.5, 12, -2, 1]
  let rng = RandDistrib()
  let z:E = 0.0
}
class SwiftyMKLTestsArrayDouble: XCTestCase,TestProtocol {
  typealias T=Array<Double>
  override class func setUp() {
    super.setUp()
    IPP.setup()
  }

  let v1:T = [1.0, -2,  3, 0]
  let v2:T = [0.5, 12, -2, 1]
  let rng = RandDistrib()
  let z:E = 0.0
}

extension TestProtocol {
  func testVersion() {
    XCTAssertNotNil(MKL.get_version_string().range(of:"Intel"))
    XCTAssertGreaterThan(IPP.getLibVersion().major, 2012, "IPP Version too old or missing")
  }

  func testSum() {
    let exp = v1.reduce(z, +)
    XCTAssertEqual(v1.sum(), exp)
  }

  func testDot() {
    let exp = zip(v1,v2).map(*).reduce(z, +)
    let r1 = v1.dot(v2)
    XCTAssertEqual(r1, exp)
  }

  func testAbs() {
    let exp = T(v1.map {abs($0)})
    let r1 = v1.abs()
    XCTAssertEqual(r1, exp)
    let r2 = v1.copy()
    v1.abs(r2)
    XCTAssertEqual(r2, exp)
    v1.abs_()
    XCTAssertEqual(v1, exp)
  }

  func testASum() {
    let exp = v1.reduce(z) {$0 + abs($1)}
    XCTAssertEqual(v1.asum(), exp)
    let exp2 = v1.abs().reduce(z, +)
    XCTAssertEqual(v1.asum(), exp2)
  }

  func testAdd() {
    let exp = T(zip(v1,v2).map(+))
    let r1 = v1.add(v2)
    XCTAssertEqual(r1, exp, "add(v2)")
    let r2 = v1.copy()
    v1.add(v2, r2)
    XCTAssertEqual(r2, exp, "add(v2,r2)")
    let r3 = v1 + v2
    XCTAssertEqual(r3, exp, "+")
    let r4 = v1.copy()
    r4.add_(v2)
    XCTAssertEqual(r4, exp, "add_")
    let r5 = v1.copy()
    r5 += v2
    XCTAssertEqual(r5, exp, "+=")
  }

  func testDiv() {
    let v:E = 2.0
    let exp = T(v1.map {$0/v})
    let r1 = v1.div(v)
    XCTAssertEqual(r1, exp)
    let r2 = v1.copy()
    v1.div(v, r2)
    XCTAssertEqual(r2, exp)
    let r3 = v1 / v
    XCTAssertEqual(r3, exp)
    let r4 = v1.copy()
    r4.div_(v)
    XCTAssertEqual(r4, exp)
    let r5 = v1.copy()
    r5 /= v
    XCTAssertEqual(r5, exp)
  }

  func testSubRev() {
    let v:E = 2.0
    let exp = T(v1.map {v-$0})
    let r1 = v1.subRev(v)
    XCTAssertEqual(r1, exp)
    let r2 = v1.copy()
    v1.subRev(v, r2)
    XCTAssertEqual(r2, exp)
    let r3 = v - v1 
    XCTAssertEqual(r3, exp)
    let r4 = v1.copy()
    r4.subRev_(v)
    XCTAssertEqual(r4, exp)
  }


  func testPowx() {
    let exp = T(v1.map {$0.pow(2.0)})
    let r1 = v1.powx(2.0)
    XCTAssertEqual(r1, exp)
    let r2 = v1.copy()
    v1.powx(2.0, r2)
    XCTAssertEqual(r2, exp)
    v1.powx_(2.0)
    XCTAssertEqual(v1, exp)
  }

  func testPow() {
    let exp = T(zip(v1,v2).map({$0.pow($1)}))
    let r1 = v1.pow(v2)
    XCTAssertEqual(r1, exp)
    let r2 = v1.copy()
    v1.pow(v2, r2)
    XCTAssertEqual(r2, exp)
    v1.pow_(v2)
    XCTAssertEqual(v1, exp)
  }

  func testNormDiff_Inf() {
    let exp = zip(v1,v2).map({abs($0-$1)}).reduce(z, {$0.max($1)})
    let r1 = v1.normDiff_Inf(v2)
    XCTAssertEqual(r1, exp)
  }

  func testPackIncrement() {
    let r1 = v1.packIncrement(2, 0, 2)
    XCTAssertEqual(r1.count, 2)
    XCTAssertEqual(r1[0], v1[0])
    XCTAssertEqual(r1[1], v1[2])
  }

  func testPackIndices() {
    let r1 = v1.packIndices([1,2])
    XCTAssertEqual(r1.count, 2)
    XCTAssertEqual(r1[0], v1[1])
    XCTAssertEqual(r1[1], v1[2])
  }

  func testPackMasked() {
    let r1 = v1.packMasked([1,0,0,1])
    XCTAssertEqual(r1.count, 2)
    XCTAssertEqual(r1[0], v1[0])
    XCTAssertEqual(r1[1], v1[3])

    let r2 = v1.packMasked([0,0,0,1])
    XCTAssertEqual(r2.count, 1)
    XCTAssertEqual(r2[0], v1[3])
  }

  func testZero() {
    let r1 = v1.copy()
    XCTAssertEqual(r1, v1)
    r1.zero()
    XCTAssertEqual(r1, v1*z)
  }

  func testSet() {
    let r1 = v1.copy()
    r1.set(2.0)
    XCTAssertEqual(r1, v1*z+2.0)
  }

  func testMove() {
    let r1 = v1.copy()
    v2.move(r1, 2)
    XCTAssertEqual(r1, T([v2[0],v2[1],v1[2],v1[3]]))
    let r2 = v1.copy()
    r2.move(r2, 2, fromIdx:1, toIdx:2)
    XCTAssertEqual(r2, T([v1[0],v1[1],v1[1],v1[2]]))
  }

  func testGaussian() {
    let r1 = rng.gaussian(1000, 5.0, 2.0)
    XCTAssertEqual(r1.count, 1000)
    XCTAssertGreaterThan(r1.mean(), 4)
    XCTAssertLessThan(r1.mean(), 6)
    XCTAssertGreaterThan(r1.stdDev(), 1)
    XCTAssertLessThan(r1.stdDev(), 3)
  }

  func testGaussianMulti1() {
    let r1 = rng.gaussianMulti(1000, [5.0], [2.0]);
    XCTAssertEqual(r1.count, 1000)
    XCTAssertGreaterThan(r1.mean(), 4)
    XCTAssertLessThan(r1.mean(), 6)
    XCTAssertGreaterThan(r1.stdDev(), 1)
    XCTAssertLessThan(r1.stdDev(), 3)
  }

  func testGaussianMulti2() {
    let r1 = rng.gaussianMulti(1000, [5.0,-5.0], [2.0,1.0]);
    XCTAssertEqual(r1.count, 2000)

    let r2 = r1.packIncrement(2, 0, 1000)
    XCTAssertGreaterThan(r2.mean(), 4)
    XCTAssertLessThan(r2.mean(), 6)
    XCTAssertGreaterThan(r2.stdDev(), 1)
    XCTAssertLessThan(r2.stdDev(), 3)

    let r3 = r1.packIncrement(2, 1, 1000)
    XCTAssertGreaterThan(r3.mean(), -6)
    XCTAssertLessThan(r3.mean(), -4)
    XCTAssertLessThan(r3.stdDev(), 2)
  }

}

