local function log(...)
	print(...)
end
log("colby", "michelle", "beau")

local person = {
	name = "colby",
	age = 28,
	married = true,
}

for k, v in pairs(person) do
	print(k .. "->" .. tostring(v))
end

local langs = { "rust", "python", "lua" }

for i, v in ipairs(langs) do
	print(i .. "->" .. v)
end
