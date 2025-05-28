import SwiftUI

public extension View {

    /// Adds a throwing task to perform before this view appears or when a specified value changes.
    /// - Parameters:
    ///   - value: The value to observe for changes.
    ///   - priority: The task priority to use when creating the asynchronous task. The default priority is `userInitiated`.
    ///   - alert: A binding to a custom ``AlertContent`` that will be used to present errors thrown by `action`, or `nil` to attach an `alert` modifier directly to the view.
    ///   - action: A closure that SwiftUI calls as an asynchronous task before the view appears. SwiftUI can automatically cancel the task after the view disappears before the action completes. If the `id` value changes, SwiftUI cancels and restarts the task.
    /// - Returns: A view that runs the specified action asynchronously before the view appears, or restarts the task when the `id` value changes.
    @inlinable func throwingTask<T>(id value: T, priority: TaskPriority = .userInitiated, alert: Binding<AlertContent>? = nil, _ action: @escaping @Sendable () async throws -> ()) -> some View where T : Equatable {
        modifier(ThrowingTaskModifier(value: value, priority: priority, alert: alert, action: action))
    }

    /// Adds a throwing task to perform before this view appears.
    /// - Parameters:
    ///   - priority: The task priority to use when creating the asynchronous task. The default priority is `userInitiated`.
    ///   - alert: A binding to a custom ``AlertContent`` that will be used to present errors thrown by `action`, or `nil` to attach an `alert` modifier directly to the view.
    ///   - action: A closure that SwiftUI calls as an asynchronous task before the view appears. SwiftUI can automatically cancel the task after the view disappears before the action completes.
    /// - Returns: A view that runs the specified action asynchronously before the view appears.
    @inlinable func throwingTask(priority: TaskPriority = .userInitiated, alert: Binding<AlertContent>? = nil, _ action: @escaping @Sendable () async throws -> ()) -> some View {
        modifier(ThrowingTaskModifier(priority: priority, alert: alert, action: action))
    }
}

// MARK: - Implementation

@usableFromInline
struct _ThrowingTaskModifierNoID: Equatable { }

@usableFromInline
struct ThrowingTaskModifier<ID: Equatable>: ViewModifier {

    var value: ID
    var priority: TaskPriority
    @Binding var alert: AlertContent
    @State private var internalAlert = AlertContent()
    var action: @Sendable () async throws -> ()

    private let useExternalAlert: Bool

    @usableFromInline
    init(value: ID, priority: TaskPriority, alert: Binding<AlertContent>?, action: @escaping @Sendable () async throws -> ()) {
        self.value = value
        self.priority = priority
        self.action = action

        if let alert {
            useExternalAlert = true
            self._alert = alert
        } else {
            useExternalAlert = false
            self._alert = .constant(.init())
        }
    }

    @usableFromInline
    func body(content: Content) -> some View {
        Group {
            if value is _ThrowingTaskModifierNoID {
                content.task(priority: priority) { await runAction() }
            } else {
                content.task(id: value, priority: priority) { await runAction() }
            }
        }
        .alert($internalAlert)
    }

    private func runAction() async {
        do {
            try await action()
        } catch {
            if useExternalAlert {
                alert = AlertContent(error)
            } else {
                internalAlert = AlertContent(error)
            }
        }
    }
}

extension ThrowingTaskModifier where ID == _ThrowingTaskModifierNoID {
    @usableFromInline
    init(priority: TaskPriority, alert: Binding<AlertContent>?, action: @escaping @Sendable () async throws -> ()) {
        self.init(value: _ThrowingTaskModifierNoID(), priority: priority, alert: alert, action: action)
    }
}

// MARK: - Deprecated

public extension View {
    @available(*, deprecated, renamed: "throwingTask")
    func failableTask<ID: Equatable>(id: ID, priority: TaskPriority, alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.throwingTask(id: id, priority: priority, alert: alert, action)
    }

    @available(*, deprecated, renamed: "throwingTask")
    func failableTask<ID: Equatable>(id: ID, alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.throwingTask(id: id, alert: alert, action)
    }

    @available(*, deprecated, renamed: "throwingTask")
    func failableTask(alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.throwingTask(alert: alert, action)
    }
}
