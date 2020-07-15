
-- pairs of entry position and value of the AntEnum used for the entry

return {
    --left inside rear
    {
        LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(-0.35, -1.8, 0.20)
        ),
        15 --DPV Passenger
    },
    --right inside rear
    {
        LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0.35, -1.8, 0.20)
        ),
        15 --DPV Passenger
    },
    --left inside front
    {
        LinearTransform(
            Vec3(-1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, -1),
            Vec3(-0.75, -1.8, 1.73)
        ),
        7   --RHIB rear Passenger
    },
    --right inside front
    {
        LinearTransform(
            Vec3(-1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, -1),
            Vec3(0.75, -1.8, 1.73)
        ),
        7  --RHIB rear Passenger
    },
    --left outside front
    {
        LinearTransform(
            Vec3(0, 0, 1),
            Vec3(0, 1, 0),
            Vec3(-1, 0, 0),
            Vec3(-1.03657079, -1.5, -0.40)
        ),
        14  --Z11 side Passenger
    },
    --right outside front
    {
        LinearTransform(
            Vec3(0, 0, -1),
            Vec3(0, 1, 0),
            Vec3(1, 0, 0),
            Vec3(1.03657079, -1.5, -0.40)
        ),
        13  --Z11 side Passenger
    },
    --[[                    --rear seats are a bit too close to eachother to fill both
    --left outside rear
    {
        LinearTransform(
            Vec3(0, 0, 1),
            Vec3(0, 1, 0),
            Vec3(-1, 0, 0),
            Vec3(-1.03657079, -1.5, -0.80)
        ),
        14  --Z11 side Passenger
    },
    --right outside rear
    {
        LinearTransform(
            Vec3(0, 0, -1),
            Vec3(0, 1, 0),
            Vec3(1, 0, 0),
            Vec3(1.03657079, -1.5, -0.80)
        ),
        13  --Z11 side Passenger
    }
    --]]
}



