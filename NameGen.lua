--[[

    NameGen - Syllabic Name Generator by Fesmaster

    This generator works by a simplified version of Wave Function Collapse.

--]]

NameGen = {}

math.randomseed(os.time())

----------------------------------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------------------------------

local CHANCE_ADJUSTMENT = 1
local CHANCE_RANDOM_SYLLABLE = 100
local MAX_SYLLABLES = 5


---Set the chance adjustment setting
---@param val number
function NameGen.SetSyllableChanceAdjustment(val)
    CHANCE_ADJUSTMENT = val
end

---Set the chance (1 in X) of a syllable being completely random
---@param val integer
function NameGen.SetChanceRandomSyllable(val)
    CHANCE_RANDOM_SYLLABLE = val
end

---Set the maximum number of syllables in a word
---@param val integer
function NameGen.SetMaxSyllableCount(val)
    MAX_SYLLABLES = val
end

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------

---Split a string
---@param str string the string to split
---@param delim string bit to split on
---@return string[] parts
local function SplitStr(str, delim)
    local out = {}
    local delimlen = delim:len()
    local iterlen = str:len() -- can't split more than this - there isn't enough space for another delimiter.
    local base = 1
    local i = 1
    while i < iterlen do
        local sub = string.sub(str, i, i+delimlen-1)
        if sub == delim then
            if (i > base) then
                -- perform a split
                local split = string.sub(str, base, i-1)
                if split:len() > 0 then
                    out[#out+1] = split
                end
            end
            base = i+delimlen
            i=i+delimlen -- skip rest of the delimiter
        else
            i=i+1
        end
    end
    local remains = string.sub(str, base, -1)
    if remains ~= delim and remains:len() > 0 then
        out[#out+1] = remains
    end
    return out
end

----------------------------------------------------------------------------------------
-- Dictionaries
----------------------------------------------------------------------------------------

local DictionarySources = {}

local Dictionaries = {}

function NameGen.GetDictionaryList()
    local l = {}
    for dict, _ in pairs(DictionarySources) do
        l[#l+1] = dict
    end
    table.sort(l, function(a, b)
        return a < b
    end)
    return l
end

---Add a Dictionary to the list
---@param path string path to dictionary file
---@param dictName string name of the dictionary
---@param reload boolean? true to reload it immedately. Default: true.
function NameGen.AddDictionarySource(path, dictName, reload)
    if reload == nil then reload = true end
    if DictionarySources[dictName] then
        -- overriding existing dictionary
        NameGen.RemoveDict(dictName)
    end 
    DictionarySources[dictName] = {
        name=dictName,
        path=path
    }
    if reload then
        if not NameGen.ReloadDict(dictName) then
            NameGen.RemoveDict(dictName)
            print("Failed to add dictionary ".. dictName ..". Invalid file: " .. path)
        end
    end
end

function NameGen.RemoveDict(name)
    DictionarySources[name] = nil
    Dictionaries[name] = nil
end

function NameGen.ReloadDict(name)
    local source = DictionarySources[name]
    if source == nil or source.path == nil then return false end
    local words = nil
    xpcall(function()
        words = require(source.path)
    end, function ()
        words = nil
    end
    )
    if words == nil then return false end
    
    -- make all the words lower-case
    for i, word in ipairs(words) do
        words[i] = string.lower(word)
    end

    -- list of all syllables
    ---@type string[]
    local syllables = {}

    -- mapping from a syllable to an entry in the syllables table
    ---@type table<string,integer>
    local mapping = {}

    -- list of syllables that start words
    ---@type string[]
    local starting = {}

    -- chance table. first key is the previous syllable, second is potential current. value is the number of occurances. Nil = 0
    ---@type table<string,table<string,number>>
    local chance_table = {}

    -- list of banned words. these already appeared or were part of the dictionary supplied.
    local banned = {}


    for i, word in ipairs(words) do
        local parts = SplitStr(word, "-")
        starting[#starting+1] = parts[1]
        local prev = nil
        local root = ""
        for j, phonetic in ipairs(parts) do
            root = root .. phonetic
            
            if mapping[phonetic] == nil then
                -- list of syllables
                syllables[#syllables+1] = phonetic
                -- mapping from a syllable to an index
                mapping[phonetic] = #syllables
                -- line in chance table
                chance_table[phonetic] = {}
            end
    
            -- build chance table
            if prev then
                local line = chance_table[prev]
                if line[phonetic] ~= nil then
                    line[phonetic] = line[phonetic] + 1
                else
                    line[phonetic] = 1
                end
            end
    
            -- cache the previous phonetic
            prev = phonetic
        end
    
        -- add the root word to the banned list
        banned[root] = true
    end


    Dictionaries[name] = {
        syllables = syllables,
        starting = starting,
        chance_table = chance_table,
        banned = banned,
    }
    return true
end

----------------------------------------------------------------------------------------
-- Local Data
----------------------------------------------------------------------------------------


---Get the next syllable by chance using a given dictionary
---@param dict string
---@param prev string
---@return string?
local function get_syllable_by_chance(dict, prev)
    local Dict = Dictionaries[dict]
    if Dict == nil then return end
    -- early out if the next syllable is a random one
    if CHANCE_RANDOM_SYLLABLE > 0 and math.random(CHANCE_RANDOM_SYLLABLE) == 1 then
        return Dict.syllables[math.random(#Dict.syllables)]
    end

    local line = Dict.chance_table[prev]
    if line == nil then return nil end
    local chance_list = {}
    for next, chance in pairs(line) do
        local rep = math.ceil(chance ^ CHANCE_ADJUSTMENT)
        for i=1,rep do
            chance_list[#chance_list+1] = next
        end
    end
    -- chance list is built
    -- return a random entry from it
    if #chance_list > 0 then
        return chance_list[math.random(#chance_list)]
    end
    return nil
end

---Get a random word from a dictionary
---@param dict string
---@return string?
function NameGen.GetWord(dict)
    local Dict = Dictionaries[dict]
    if Dict == nil then return end

    local word = ""
    while word == "" or Dict.banned[word] do
        local prev = Dict.starting[math.random(#Dict.starting)]
        word = word .. prev        
        local syl_count = math.random(MAX_SYLLABLES-1)
        for i=1,syl_count do
            local next = get_syllable_by_chance(dict,prev)
            if next then
                word = word .. next
                prev = next
            else
                break
            end
        end
    end
    word = word:gsub("^%l", string.upper)
    return word
end