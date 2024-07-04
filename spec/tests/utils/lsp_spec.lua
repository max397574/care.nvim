local lsp_utils = require("neocomplete.utils.lsp")

describe("Lsp utils get kind", function()
    it("invalid", function()
        ---@diagnostic disable-next-line: param-type-mismatch
        assert.is.same("", lsp_utils.get_kind_name("99"))
    end)
    it("return correct value", function()
        assert.is.same("Function", lsp_utils.get_kind_name(3))
    end)
end)
