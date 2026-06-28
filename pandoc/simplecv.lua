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

function table:keys()
    assert(type(self) == "table")

    local keys = {}
    for key, _ in pairs(self) do
        table.insert(keys, key)
    end
    return keys
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

function is_top_heading(el) return el.t == "Header" and el.level == 1 end

function is_other_heading(el) return el.t == "Header" and el.level ~= 1 end

-- silence Lua Diagnostics
if not pandoc then pandoc = {} end

if FORMAT:match 'latex' then

    -- wrap element in latex command
    function block(name, el)
        assert(type(name) == "string")
        return {
            pandoc.RawBlock("latex", "\\" .. name .. "{"),
            el,
            pandoc.RawBlock("latex", "}")
        }
    end

    function icon(name, is_regular)
        if is_regular then
            return pandoc.RawInline("latex", "\\faIcon[regular]{" .. name .. "}")
        else
            return pandoc.RawInline("latex", "\\faIcon{" .. name .. "}")
        end
    end

    -- insert "content" wrapped in cvmain immediately after cvhints to render side by side in pdf
    function columns(hints, main)
        return {
            pandoc.RawBlock("latex", "\\cvhints{"),
            hints,
            pandoc.RawBlock("latex", "}%\n\\cvmain{"),
            main,
            pandoc.RawBlock("latex", "}")
        }
    end

    function spacing()
        return pandoc.RawBlock("latex", "\\vspace{\\baselineskip}")
    end

    -- TODO move spacing and pdfbookmark to latex document class in simplecv.cls
    function top_heading(el, id)
        local heading = pandoc.utils.stringify(el)
        return {
            spacing(),
            pandoc.RawBlock("latex", "\\pdfbookmark[0]{" .. heading .. "}{name" .. id .. "}"),
            pandoc.RawBlock("latex", "\\cvsection{" .. heading .. "}")
        }
    end

    -- insert cvmain immediately after heading wrapped in cvsection to render side by side in pdf
    function top_heading_with(el, id, main)
        local heading = pandoc.utils.stringify(el)
        return {
            spacing(),
            pandoc.RawBlock("latex", "\\pdfbookmark[0]{" .. heading .. "}{name" .. id .. "}"),
            pandoc.RawBlock("latex", "\\cvsection{" .. heading .. "}%\n\\cvmain{"),
            main,
            pandoc.RawBlock("latex", "}")
        }
    end

    function other_heading(el)
        return {
            pandoc.RawBlock("latex", "\\cvmain{{\\large"),
            el.content,
            pandoc.RawBlock("latex", "}}")
        }
    end
end

if FORMAT:match 'latex' then

    ICONS = {}

    -- support syntax :icon: for inserting fontawesome icons:
    -- * substitute strings :name: with \\faIcon{name}
    -- * substitute strings :regular-name: with \\faIcon[regular]{name}
    function Str(str)
        local text = str.text
        if text:starts_with(":") and text:ends_with(":") and #text > 2 then
            local name = text:sub(2, -2)
            local is_regular = name:starts_with("regular-")
            if is_regular then
                name = name:sub(9, #name)
            end
            ICONS[name] = true
            return icon(name, is_regular)
        end
        return str
    end

    function Pandoc(doc)
        local hblocks = {}
        -- assign dummy element to eliminate nil checks
        local prev = {t = "dummy"}
        for i, el in ipairs(doc.blocks) do
            if is_hint(prev) and (is_content(el) or is_main(el)) then
                table.append(hblocks, columns(prev, el))
            elseif is_top_heading(prev) and is_main(el) then
                table.append(hblocks, top_heading_with(prev, i, el))
            else
                -- first process elements that could possibly
                -- be skipped in previous iteration and not "merged" above
                if is_hint(prev) then
                    table.append(hblocks, block("cvhints", prev))
                elseif is_top_heading(prev) then
                    table.append(hblocks, top_heading(prev, i))
                end

                if is_top_heading(el) or is_hint(el) then
                    -- skip for now to check for possible "merge" with next elem
                    ;
                elseif is_other_heading(el) then
                    -- insert vertical space before headers unless prev is level 1 header
                    -- (additional space is not needed then because
                    -- level 1 header is in different column)
                    if prev.t ~= "Header" and prev.level ~= 1 then
                        table.insert(hblocks, spacing())
                    end
                    table.append(hblocks, other_heading(el))
                elseif is_content(el) then
                    table.append(hblocks, block("cvmain", el))
                elseif is_footer(el) then
                    table.append(hblocks, block("cvfooter", el))
                else
                    table.insert(hblocks, el)
                end
            end
            prev = el
        end
        -- TODO sort to force consistent order
        doc.meta["icons"] = pandoc.MetaList(table.keys(ICONS))
        return pandoc.Pandoc(hblocks, doc.meta)
    end

end
