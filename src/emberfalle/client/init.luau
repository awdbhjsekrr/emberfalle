local function init()
	print("Hello world, from client!")
	require(script.guihandler)
end

return {
	init = init,
}
