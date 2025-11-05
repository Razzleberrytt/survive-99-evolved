local AnalyticsService = game:GetService("AnalyticsService")
local M = M or {}
function M.Funnel(name, fields) pcall(function() AnalyticsService:FireCustomEvent("funnel_"..name, fields or {}) end) end
function M.Economy(action, item, amount) pcall(function() AnalyticsService:FireCustomEvent("eco", {a=action,i=item,v=amount}) end) end
function M.Custom(name, fields) pcall(function() AnalyticsService:FireCustomEvent(name, fields or {}) end) end
function M.PurchaseAttempt(player, key) M.Custom("purchase_attempt", {u=player.UserId, key=key}) end
function M.PurchaseResult(player, key, ok) M.Custom("purchase_result", {u=player.UserId, key=key, ok=ok}) end
function M.SoftGateBlocked(player, reason) M.Custom("soft_gate_blocked", {u=player.UserId, reason=reason}) end
return M
