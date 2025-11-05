local PhysicsService = game:GetService("PhysicsService")
local groups = { "Players","Enemies","Placeables","Traps" }
for _, g in ipairs(groups) do pcall(function() PhysicsService:CreateCollisionGroup(g) end) end
PhysicsService:CollisionGroupSetCollidable("Players","Enemies", true)
PhysicsService:CollisionGroupSetCollidable("Players","Placeables", true)
PhysicsService:CollisionGroupSetCollidable("Enemies","Placeables", true)
PhysicsService:CollisionGroupSetCollidable("Traps","Players", false)
