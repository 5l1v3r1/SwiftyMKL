import Foundation

extension Array: BaseVector where Element:SupportsBasicMath {
  public init(_ count:Int) { self.init(repeating:0, count:count) }

  public func copy() -> Array { return (self as NSCopying).copy(with: nil) as! Array }
  public var p:MutPtrT {get {return UnsafeMutablePointer(mutating: self)}}
}

public protocol ComposedStorage {
  associatedtype Storage:MutableCollection where Storage.Index==Int
  typealias Index=Int

  var data:Storage {get set}
  var endIndex:Int {get}
  subscript(i:Int)->Storage.Element {get set}
}
extension ComposedStorage {
  public subscript(i:Int)->Storage.Element { get {return data[i]} set {data[i] = newValue} }
  public var endIndex: Int { return data.count }
}

extension UnsafeMutableBufferPointer: BaseVector,ExpressibleByArrayLiteral where Element:SupportsBasicMath {
  public typealias ArrayLiteralElement=Element

  public init(_ count:Int) {
    let sz = MemoryLayout<Element>.stride
    let raw = UnsafeMutableRawBufferPointer.allocate(byteCount: sz*count, alignment: 64)
    self.init(rebasing: raw.bindMemory(to: Element.self)[0...])
  }
  public init(_ array:Array<Element>) {
    self.init(array.count)
    _ = initialize(from:array)
  }

  public var p:MutPtrT {get {return baseAddress!}}
  public func copy()->UnsafeMutableBufferPointer { return .init(Array(self)) }
}

public class AlignedStorage<T:SupportsBasicMath>: BaseVector, ComposedStorage {
  public typealias Element=T
  public var data:UnsafeMutableBufferPointer<T>

  public required init(_ data: UnsafeMutableBufferPointer<T>) {self.data=data}
  public required convenience init(_ count:Int)      { self.init(UnsafeMutableBufferPointer(count)) }
  public required convenience init(_ array:Array<T>) { self.init(UnsafeMutableBufferPointer(array)) }

  deinit { UnsafeMutableRawBufferPointer(data).deallocate() }

  public var p:MutPtrT {get {return data.p}}
  public func copy()->Self { return .init(data.copy()) }
}

