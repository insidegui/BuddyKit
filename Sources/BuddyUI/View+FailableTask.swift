import SwiftUI

public extension View {
    func failableTask<ID: Equatable>(id: ID, priority: TaskPriority, alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.task(id: id, priority: priority) {
            do {
                try await action()
            } catch {
                alert.wrappedValue = AlertContent(error)
            }
        }
    }

    func failableTask<ID: Equatable>(id: ID, alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.task(id: id) {
            do {
                try await action()
            } catch {
                alert.wrappedValue = AlertContent(error)
            }
        }
    }

    func failableTask(alert: Binding<AlertContent>, action: @escaping @Sendable () async throws -> Void) -> some View {
        self.task {
            do {
                try await action()
            } catch {
                alert.wrappedValue = AlertContent(error)
            }
        }
    }
}
