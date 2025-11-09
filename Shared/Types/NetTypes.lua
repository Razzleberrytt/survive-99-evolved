-- Minimal type-like specs for payload validation on the server
return {
    ClientToServer = {
        Input_Fire = { weaponId = "string", origin = "Vector3", dir = "Vector3", t = "number" },
        Input_Attack = { weaponId = "string", t = "number" },
        Input_Revive = { targetUserId = "number", t = "number" },
        Menu_RequestPurchase = { productId = "number" },
    },
}
