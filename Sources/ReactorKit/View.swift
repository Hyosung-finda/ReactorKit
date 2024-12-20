//
//  View.swift
//  ReactorKit
//
//  Created by Suyeol Jeon on 13/04/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

#if !os(Linux)
import RxSwift
import WeakMapTable

private typealias AnyView = AnyObject
private enum MapTables {
  static let reactor = WeakMapTable<AnyView, Any>()
}

/// A View displays data. A view controller and a cell are treated as a view. The view binds user
/// inputs to the action stream and binds the view states to each UI component. There's no business
/// logic in a view layer. A view just defines how to map the action stream and the state stream.
public protocol View: AnyObject {
  associatedtype Reactor: ReactorKit.Reactor

  /// A dispose bag. It is disposed each time the `reactor` is assigned.
  @MainActor
  var disposeBag: DisposeBag { get set }

  /// A view's reactor. `bind(reactor:)` gets called when the new value is assigned to this property.
  @MainActor
  var reactor: Reactor? { get set }

  /// Creates RxSwift bindings. This method is called each time the `reactor` is assigned.
  ///
  /// Here is a typical implementation example:
  ///
  /// ```
  /// func bind(reactor: MyReactor) {
  ///   // Action
  ///   increaseButton.rx.tap
  ///     .bind(to: Reactor.Action.increase)
  ///     .disposed(by: disposeBag)
  ///
  ///   // State
  ///   reactor.state.map { $0.count }
  ///     .bind(to: countLabel.rx.text)
  ///     .disposed(by: disposeBag)
  /// }
  /// ```
  ///
  /// - warning: It's not recommended to call this method directly.
  @MainActor
  func bind(reactor: Reactor)
}

// MARK: - Default Implementations

extension View {
  @MainActor
  public var reactor: Reactor? {
    get { MapTables.reactor.value(forKey: self) as? Reactor }
    set {
      MapTables.reactor.setValue(newValue, forKey: self)
      disposeBag = DisposeBag()
      if let reactor = newValue {
        bind(reactor: reactor)
      }
    }
  }
}
#endif
