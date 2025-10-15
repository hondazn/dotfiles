local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
-- local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"frontmatter",
		fmt(
			[[
			---
			id: {}
			aliases: [{}]
			tags: [{}]
			title: {}
			description: {}
			---
			]],
			{
				i(1),
				i(2),
				i(3),
				i(4),
				i(5),
			}
		)
	),
}
