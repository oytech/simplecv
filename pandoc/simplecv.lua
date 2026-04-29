function string:is_empty()
    return self == nil or self == ""
end

function string:starts_with(str)
    return not (string.is_empty(self) or string.is_empty(str)) and self:sub(1, #str) == str
end

function string:ends_with(str)
    return not (string.is_empty(self) or string.is_empty(str)) and self:sub(-#str) == str
end

function table:append(other)
    assert(type(self) == "table" and type(other) == "table")

    for _, val in ipairs(other) do table.insert(self, val) end
end

function table:contains(elem)
    assert(type(self) == "table")

    for _, val in ipairs(self) do
        if val == elem then return true end
    end
    return false
end

function is_fenced_div(el, class)
    return el.t == "Div" and el.classes[1] == class
end

function is_hint(el) return is_fenced_div(el, "hints") end

function is_footer(el) return is_fenced_div(el, "footer") end

function is_main(el) return is_fenced_div(el, "main") end

-- returns true if elem is content that should go into main column
function is_content(el)
    -- TODO probably not complete
    return table.contains({"Para", "BulletList", "OrderedList"}, el.t)
end

function is_top_header(el) return el.t == "Header" and el.level == 1 end

function is_other_header(el) return el.t == "Header" and el.level ~= 1 end

if FORMAT:match 'latex' then

    -- support syntax :icon: for inserting fontawesome icons:
    -- * substitute strings :name: with \\faIcon{name}
    -- * substitute strings :regular-name: with \\faIcon[regular]{name}
    function Str(str)
        local text = str.text
        if text:starts_with(":") and text:ends_with(":") and #text > 2 then
            local emoji = text:sub(2, -2)
            if emoji:starts_with("regular-") then
                emoji = emoji:sub(9, #emoji)
                return pandoc.RawInline("latex", "\\faIcon[regular]{" .. emoji .. "}")
            else
                return pandoc.RawInline("latex", "\\faIcon{" .. emoji .. "}")
            end
        end
        return str
    end

    function Pandoc(doc)
        -- wrap element in latex command
        local function wrap(cmd, el)
            assert(type(cmd) == "string")
            return {
                pandoc.RawBlock("latex", "\\" .. cmd .."{"),
                el,
                pandoc.RawBlock("latex", "}")
            }
        end

        local hblocks = {}
        -- assign dummy element to eliminate nil checks
        local prev = {t = "dummy"}
        for _, el in ipairs(doc.blocks) do
            -- insert "content" wrapped in cvmain immediately after cvhints
            -- to render side by side in pdf
            if is_hint(prev) and is_content(el) then
                table.append(hblocks, {
                    pandoc.RawBlock("latex", "\\cvhints{"),
                    prev,
                    pandoc.RawBlock("latex", "}%\n\\cvmain{"),
                    el,
                    pandoc.RawBlock("latex", "}")
                })
            -- insert cvmain immediately after header wrapped in cvsection
            -- to render side by side in pdf
            elseif is_top_header(prev) and is_main(el) then
                local header = pandoc.utils.stringify(prev)
                table.append(hblocks, {
                    pandoc.RawBlock("latex", "\\vspace{\\baselineskip}"),
                    pandoc.RawBlock("latex", "\\cvsection{" .. header  .."}%\n\\cvmain{"),
                    el,
                    pandoc.RawBlock("latex", "}")
                })
            else
                -- first process elements that could possibly
                -- be skipped in previous iteration and not "merged" above
                if is_hint(prev) then
                    table.append(hblocks, wrap("cvhints", prev))
                elseif is_top_header(prev) then
                    local header = pandoc.utils.stringify(prev)
                    table.append(hblocks, {
                        pandoc.RawBlock("latex", "\\vspace{\\baselineskip}"),
                        pandoc.RawBlock("latex", "\\cvsection{" .. header .."}")
                    })
                end

                if is_top_header(el) or is_hint(el) then
                    -- skip for now to check for possible "merge" with next elem
                    ;
                elseif is_other_header(el) then
                    -- insert vertical space before headers unless prev is level 1 header
                    -- (additional space is not needed then because
                    -- level 1 header is in different column)
                    if prev.t ~= "Header" and prev.level ~= 1 then
                        table.insert(hblocks, pandoc.RawBlock("latex", "\\vspace{\\baselineskip}"))
                    end
                    table.append(hblocks, {
                        pandoc.RawBlock("latex", "\\cvmain{{\\large"),
                        el.content,
                        pandoc.RawBlock("latex", "}}")
                    })
                elseif is_content(el) then
                    table.append(hblocks, wrap("cvmain", el))
                elseif is_footer(el) then
                    table.append(hblocks, wrap("cvfooter", el))
                else
                    table.insert(hblocks, el)
                end
            end
            prev = el
        end
        return pandoc.Pandoc(hblocks, doc.meta)
    end

end
