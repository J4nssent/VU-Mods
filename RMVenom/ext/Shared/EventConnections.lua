
class "EventConnections"

function EventConnections:Create(source, target, sourceEvent, targetEvent, type)

    local sourceEventSpec = EventSpec()
    sourceEventSpec.id = sourceEvent

    local targetEventSpec = EventSpec()
    targetEventSpec.id = targetEvent

    local EventConnection = EventConnection()
    EventConnection.source = source
    EventConnection.target = target
    EventConnection.sourceEvent = sourceEventSpec
    EventConnection.targetEvent = targetEventSpec
    EventConnection.targetType = type

    return EventConnection
end

return EventConnections()

