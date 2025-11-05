-- Simple catalog (IDs are keys). Type: "camp" or "outfit".
return {
  Items = {
    camp_moonlit  = { type="camp",  name="Moonlit Camp",  cost=25 },
    camp_ember    = { type="camp",  name="Ember Camp",    cost=25 },
    outfit_midnight={ type="outfit",name="Midnight Fit",  cost=15 },
    outfit_ashen  = { type="outfit",name="Ashen Fit",     cost=15 },
    camp_bloodmoon= { type="camp",  name="Blood Moon Camp", cost=40 },
    outfit_aurora = { type="outfit",name="Aurora Fit",    cost=20 },
  },
  -- Deterministic daily rotation (pick N per day)
  DailyCount = 4
}
