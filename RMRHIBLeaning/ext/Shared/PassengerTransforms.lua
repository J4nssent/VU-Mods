
-- { entry position, value of the AntEnumeration, { minYaw, maxYaw, minPitch, MaxPitch } }

return {
    {
        LinearTransform(        --1st left
            Vec3(0, 0, 1),
            Vec3(0, 1, 0),
            Vec3(-1, 0, 0),
            Vec3(1.2, 1.2, -2.1)
        ),
        14,
        { -100, 60, -40, 60 }
    },{
        LinearTransform(        --1st right
            Vec3(0, 0, -1),
            Vec3(0, 1, 0),
            Vec3(1, 0, 0),
            Vec3(-1.2, 1.2, -2.1)
        ),
        13,
        { -60, 100, -40, 60 }
    },{
        LinearTransform(        --2nd left
            Vec3(0, 0, 1),
            Vec3(0, 1, 0),
            Vec3(-1, 0, 0),
            Vec3(1.15, 1.25, -0.7)
        ),
        14,
        { -100, 60, -40, 60 }
    },{
        LinearTransform(        --2nd right
            Vec3(0, 0, -1),
            Vec3(0, 1, 0),
            Vec3(1, 0, 0),
            Vec3(-1.15, 1.25, -0.7)
        ),
        13,
        { -60, 100, -40, 60 }
    },{
        LinearTransform(        --3rd left
            Vec3(0, 0, 1),
            Vec3(0, 1, 0),
            Vec3(-1, 0, 0),
            Vec3(1, 1.3, 0.7)
        ),
        14,
        { -100, 60, -40, 60 }
    },{
        LinearTransform(        --3rd right
            Vec3(0, 0, -1),
            Vec3(0, 1, 0),
            Vec3(1, 0, 0),
            Vec3(-1, 1.3, 0.7)
        ),
        13,
        { -60, 100, -40, 60 }
    },
}



