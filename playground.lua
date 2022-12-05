local foo = {
	{
		name = "colby",
	},
	{
		name = "michelle",
	},
	foobar = {
		name = "beau",
	},
	"foo",
}

for name, foo in pairs(foo) do
	put({ name, foo })
end
