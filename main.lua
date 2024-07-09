--[[

    Fesmaster's Name Generator - A powerful, dictionary-based name generator

    (C) 2024 Stephen Kelly
    Licensed under the MIT License.
    See LICENSE for details.

--]]

local JSON_MAX_CHARS_PER_LINE = 160
local JSON_PATH = "./NameGeneratorOut.json"

-- contains a bunch of helpers
local ffi = require("ffi")
require("NameGen")

-- load dictionaries
NameGen.AddDictionarySource("DictGreekMonster", "Greek Monster")
NameGen.AddDictionarySource("DictPlanets", "Planets")
NameGen.AddDictionarySource("DictArabicFemale", "Arabic (Female)")
NameGen.AddDictionarySource("DictArabicMale", "Arabic (Male)")
NameGen.AddDictionarySource("DictCelticFemale", "Celtic (Female)")
NameGen.AddDictionarySource("DictCelticMale", "Celtic (Male)")
NameGen.AddDictionarySource("DictChineseFemale", "Chinese (Female)")
NameGen.AddDictionarySource("DictChineseMale", "Chinese (Male)")
NameGen.AddDictionarySource("DictDragonbornClan", "Dragonborn (Clan)")
NameGen.AddDictionarySource("DictDragonbornFemale", "Dragonborn (Female)")
NameGen.AddDictionarySource("DictDragonbornMale", "Dragonborn (Male)")
NameGen.AddDictionarySource("DictDwarfClan", "Dwarf (Clan)")
NameGen.AddDictionarySource("DictDwarfFemale", "Dwarf (Female)")
NameGen.AddDictionarySource("DictDwarfMale", "Dwarf (Male)")
NameGen.AddDictionarySource("DictEgyptianFemale", "Egyptian (Female)")
NameGen.AddDictionarySource("DictEgyptianMale", "Egyptian (Male)")
NameGen.AddDictionarySource("DictElfFamily", "Elf (Family)")
NameGen.AddDictionarySource("DictElfFemale", "Elf (Female)")
NameGen.AddDictionarySource("DictElfMale", "Elf (Male)")
NameGen.AddDictionarySource("DictEnglishFemale", "English (Female)")
NameGen.AddDictionarySource("DictEnglishMale", "English (Male)")
NameGen.AddDictionarySource("DictFrenchFemale", "French (Female)")
NameGen.AddDictionarySource("DictFrenchMale", "French (Male)")
NameGen.AddDictionarySource("DictGermanFemale", "German (Female)")
NameGen.AddDictionarySource("DictGermanMale", "German (Male)")
NameGen.AddDictionarySource("DictGnomeClan", "Gnome (Clan)")
NameGen.AddDictionarySource("DictGnomeFemale", "Gnome (Female)")
NameGen.AddDictionarySource("DictGnomeMale", "Gnome (Male)")
NameGen.AddDictionarySource("DictGreekFemale", "Greek (Female)")
NameGen.AddDictionarySource("DictGreekMale", "Greek (Male)")
NameGen.AddDictionarySource("DictHalfOrcFemale", "HalfOrc (Female)")
NameGen.AddDictionarySource("DictHalfOrcMale", "HalfOrc (Male)")
NameGen.AddDictionarySource("DictHalflingFamily", "Halfling (Family)")
NameGen.AddDictionarySource("DictHalflingFemale", "Halfling (Female)")
NameGen.AddDictionarySource("DictHalflingMale", "Halfling (Male)")
NameGen.AddDictionarySource("DictIndianFemale", "Indian (Female)")
NameGen.AddDictionarySource("DictIndianMale", "Indian (Male)")
NameGen.AddDictionarySource("DictJapaneseFemale", "Japanese (Female)")
NameGen.AddDictionarySource("DictJapaneseMale", "Japanese (Male)")
NameGen.AddDictionarySource("DictMesoamericanFemale", "Mesoamerican (Female)")
NameGen.AddDictionarySource("DictMesoamericanMale", "Mesoamerican (Male)")
NameGen.AddDictionarySource("DictNigerCongoFemale", "NigerCongo (Female)")
NameGen.AddDictionarySource("DictNigerCongoMale", "NigerCongo (Male)")
NameGen.AddDictionarySource("DictNorseFemale", "Norse (Female)")
NameGen.AddDictionarySource("DictNorseMale", "Norse (Male)")
NameGen.AddDictionarySource("DictPolynesianFemale", "Polynesian (Female)")
NameGen.AddDictionarySource("DictPolynesianMale", "Polynesian (Male)")
NameGen.AddDictionarySource("DictRomanFemale", "Roman (Female)")
NameGen.AddDictionarySource("DictRomanMale", "Roman (Male)")
NameGen.AddDictionarySource("DictSlavicFemale", "Slavic (Female)")
NameGen.AddDictionarySource("DictSlavicMale", "Slavic (Male)")
NameGen.AddDictionarySource("DictSpanishFemale", "Spanish (Female)")
NameGen.AddDictionarySource("DictSpanishMale", "Spanish (Male)")
NameGen.AddDictionarySource("DictTieflingFemale", "Tiefling (Female)")
NameGen.AddDictionarySource("DictTieflingMale", "Tiefling (Male)")

---Define a new class
---@param table {[any]:any,__init:fun(class:table,...):table} Class definition
---@return table the same as the input. Assign to global variable of class name
Class = function(table)
    -- add the table to the global namespace
    table.__index = table
    local _classmt = {
        __call = function(...)
            local t = table.__init(...)
            setmetatable(t, table)
            return t
        end
    }
    setmetatable(table, _classmt)
    return table
end

---@class IntPtr Pointer to an integer
---@field native lightuserdata
---@field Ptr fun(self:IntPtr):lightuserdata Get a pointer
---@field Get fun(self:IntPtr):integer Get the value
---@field Set fun(self:IntPtr,val:integer):nil Set the value
IntPtr = Class({
    ---Create an IntPtr
    ---@param val integer
    ---@return IntPtr
    __init = function (class, val)
        local retval = {
            native = ffi.new("int[1]")
        }
        retval.native[0] = val
        return retval
    end,

    ---Get a pointer
    ---@param self IntPtr
    ---@return lightuserdata
    Ptr = function (self)
        return self.native
    end,

    ---Get the value
    ---@param self IntPtr
    ---@return integer
    Get = function (self)
        return tonumber(self.native[0])
    end,

    ---Set the value
    ---@param self IntPtr
    ---@param val integer
    Set = function (self, val)
        self.native[0] = val
    end,
})

---@class DynamicStringRef Dynamic-Length string
---@field native lightuserdata
---@field length integer
---@field Ptr fun(self:DynamicStringRef):lightuserdata Get a pointer
---@field Get fun(self:DynamicStringRef):string Get the value
---@field Set fun(self:DynamicStringRef,str:string):bool Set the value. Returns true if it had to realloc the char[]
DynamicStringRef = Class({
    __init=function (class, str, maxlen)
        if maxlen == nil then maxlen = #str+1 end
        local ret = {
            native = ffi.new("char[?]", maxlen),
            length = maxlen,
        }
        ffi.copy(ret.native, str)
        return ret
    end,

    ---Get a pointer
    ---@param self DynamicStringRef
    ---@return lightuserdata
    Ptr = function (self)
        return self.native
    end,

    ---Get the value
    ---@param self DynamicStringRef
    ---@return string
    Get = function (self)
        return ffi.string(self.native)
    end,

    ---Set the value
    ---@param self DynamicStringRef
    ---@param str string
    ---@return bool realloc
    Set = function (self, str)
        if #str < self.length then
            ffi.copy(self.native, str)
            return false
        else
            self.length = #str+1
            self.native = ffi.new("char[?]", self.length)
            ffi.copy(self.native, str)
            return true
        end
    end,

    __tostring = function(self)
        return self:Get()
    end,
})

---@class HeightBuilder A class that helps arranging things vertically
---@field x number
---@field y number
---@field spacing number
---@field Next fun(self:HeightBuilder,width:number,height:number):Rectangle get the next rectangle
HeightBuilder = Class({
    __init = function(class, x, y, spacing)
        local ret = {
            x = x,
            y=y,
            spacing = spacing
        }
        return ret
    end,

    ---Get the next rectangle
    ---@param self HeightBuilder
    ---@param width number
    ---@param height number
    ---@return Rectangle
    Next = function (self, width, height)
        local ret = Rectangle(self.x, self.y, width, height)
        self.y = self.y + height + self.spacing
        return ret
    end,
})

---Create Vector2
---@param x number
---@param y number
---@return Vector2
function Vector2(x,y)
    return rl.new("Vector2", x, y)
end

---Create Rectangle
---@param x number
---@param y number
---@param width number
---@param height number
---@return Rectangle
function Rectangle(x,y,width,height)
    return rl.new("Rectangle", x, y, width, height)
end

---Copy text
---@param text string
function SystemCopy(text)
    local p = io.popen("clip.exe", "w")
    if not p then return end
    p:write(text)
    p:close()
end



rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)

rl.InitWindow(800, 450, "Fesmaster's Name Generator")
rl.SetTargetFPS(60)

-----------------------------------------------------------------------------------
-- GUI Element properties
-----------------------------------------------------------------------------------

local anchor01 = Vector2(8, 8)
local anchor02 = Vector2(200, 8)

local ScrollView = Rectangle(0, 0, 0, 0)
local ScrollBoundOffset = Vector2(0, 0)

local DictSelect_EditMode = false
local DictSelect_ChoiceIndex = IntPtr(0)

local NameCnt_EditMode = false
local NameCnt_Value = IntPtr(10)

local ParamChanceAdjustment_EditMode = false
local ParamChanceAdjustment_Value = IntPtr(1)

local ParamChanceRandomSyllable_EditMode = false
local ParamChanceRandomSyllable_Value = IntPtr(100)

local ParamMaxSyllables_EditMode = false
local ParamMaxSyllables_Value = IntPtr(5)

local DropdownScrollView = Rectangle(0, 0, 0, 0)
local DropdownScrollBoundOffset = Vector2(0, 0)

local layoutRecs = {
    Rectangle(anchor02.x,      anchor02.y,       392, 344),
    Rectangle(anchor01.x,      anchor01.y + 0,   176, 344),
    Rectangle(anchor01.x + 8,  anchor01.y + 8,   160, 24 ),
    Rectangle(anchor01.x + 8,  anchor01.y + 48,  160, 24 ),
    -- clear and export buttons
    Rectangle(anchor02.x,  anchor01.y,  80, 24 ), --clear
    Rectangle(anchor02.x,  anchor01.y,  120, 24 ), --export
    --Rectangle(anchor01.x + 8,  anchor01.y + 88,  160, 24 ),
    --Rectangle(anchor01.x + 8,  anchor01.y + 128, 160, 24 ),
    --Rectangle(anchor01.x + 8,  anchor01.y + 168, 160, 24 ),
    --Rectangle(anchor01.x + 8,  anchor01.y + 208, 160, 24 ),
    
    Rectangle(anchor01.x + 16, anchor01.y + 304, 144, 24 ),
}

local SettingControlSize = Vector2(160,24)

local DictList = NameGen.GetDictionaryList()

local OutputEntries = {
    
}

local DictOptionsString = ""
for i, name in ipairs(DictList) do
    DictOptionsString = DictOptionsString .. name
    if i < #DictList then
        DictOptionsString = DictOptionsString .. ";"
    end
end

-----------------------------------------------------------------------------------
-- Functional program
-----------------------------------------------------------------------------------


while not rl.WindowShouldClose() do
    local width = rl.GetRenderWidth()
    local height = rl.GetRenderHeight()
    layoutRecs[1].height = height-16
    layoutRecs[1].width = width-8-anchor02.x
    layoutRecs[2].height = height-16
    -- 5 and 6 on the upper right
    layoutRecs[5].x = width - 8 - layoutRecs[5].width
    layoutRecs[6].x = layoutRecs[5].x - 8 - layoutRecs[6].width
    -- last one for generate button
    layoutRecs[#layoutRecs].y = height-40


	rl.BeginDrawing()

	rl.ClearBackground(rl.LIGHTGRAY)
	
    if (DictSelect_EditMode) then 
        --rl.GuiLock() 
    end

    ScrollView = Rectangle(
        layoutRecs[1].x,
        layoutRecs[1].y,
        layoutRecs[1].width - ScrollBoundOffset.x,
        layoutRecs[1].height - ScrollBoundOffset.y
    )
    rl.GuiScrollPanel(
        layoutRecs[1],
        "Generated Names",
        ScrollView,
        rl.ref(ScrollBoundOffset)
    );

    rl.BeginScissorMode(ScrollView.x, ScrollView.y+24, ScrollView.width, layoutRecs[1].height - 38)
        -- build list of names that have been generated...
        -- loop backwards to have the latest first
        local hBuilder = HeightBuilder(anchor02.x + 8 + ScrollBoundOffset.x, anchor02.y + 32 + ScrollBoundOffset.y, 8)
        for i=#OutputEntries,1,-1 do
            local entry = OutputEntries[i]
            if rl.GuiLabelButton(hBuilder:Next(392, 24), entry ) then
                SystemCopy(entry)
                print("Copied text: " .. entry)
            end
        end
    rl.EndScissorMode()
    
    rl.GuiGroupBox(layoutRecs[2], "Control");
    
    local hBuilder = HeightBuilder(layoutRecs[4].x, layoutRecs[4].y, 8)

    rl.GuiLabel(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "Word Count:")
    if (rl.GuiSpinner(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "" , NameCnt_Value:Ptr(), 0, 100, NameCnt_EditMode)) then
        NameCnt_EditMode = not NameCnt_EditMode 
    end

    rl.GuiLabel(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "Syllable Fequency:")
    if (rl.GuiSpinner(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "" , ParamChanceAdjustment_Value:Ptr(), 0, 100, ParamChanceAdjustment_EditMode)) then
        ParamChanceAdjustment_EditMode = not ParamChanceAdjustment_EditMode
        NameGen.SetSyllableChanceAdjustment(ParamChanceAdjustment_Value:Get())
    end

    rl.GuiLabel(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "Random Syllable Chance (1 in x):")
    if (rl.GuiSpinner(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "" , ParamChanceRandomSyllable_Value:Ptr(), 0, 100, ParamChanceRandomSyllable_EditMode)) then
        ParamChanceRandomSyllable_EditMode = not ParamChanceRandomSyllable_EditMode
        NameGen.SetChanceRandomSyllable(ParamChanceRandomSyllable_Value:Get())
    end

    rl.GuiLabel(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "Max Syllables per Word:")
    if (rl.GuiSpinner(hBuilder:Next(SettingControlSize.x, SettingControlSize.y), "" , ParamMaxSyllables_Value:Ptr(), 0, 100, ParamMaxSyllables_EditMode)) then
        ParamMaxSyllables_EditMode = not ParamMaxSyllables_EditMode
        NameGen.SetMaxSyllableCount(ParamMaxSyllables_Value:Get())
    end
    
    if rl.GuiButton(layoutRecs[5], "Clear") then
        print("Clear clikced")
        OutputEntries = {}
    end

    if rl.GuiButton(layoutRecs[6], "Export JSON") then
        print("JSON Export clicked!")

        print("writing to: "..JSON_PATH)

        local f = io.open(JSON_PATH, "w")
        -- JSON_MAX_CHARS_PER_LINE
        if (f) then
            f:write("{\"names\":[\n    ")
            local linewidth = 4

            for i, value in ipairs(OutputEntries) do
                f:write('"'..value..'"')
                linewidth = linewidth + 2 + value:len()

                if i < #OutputEntries then
                    f:write(", ")
                    linewidth = linewidth + 2
                end

                if linewidth > JSON_MAX_CHARS_PER_LINE then
                    f:write("\n    ")
                    linewidth = 4
                end
            end
            f:write("\n]}")
            f:flush()
            f:close()
            print("Write finished!")
        else
            print("ERROR: Write failed to open file!!")
        end
    end
    

    if (rl.GuiButton(layoutRecs[#layoutRecs], "Generate")) then
        print("Generate Pressed!!")
        local dict = DictList[DictSelect_ChoiceIndex:Get() + 1]
        local count = NameCnt_Value:Get()
        for i=1,count do
            local word = NameGen.GetWord(dict)
            if word then
                OutputEntries[#OutputEntries+1] = word
            end
        end
    end
    
    local OldDictSelect_EditMode = DictSelect_EditMode
    local DropdownRect = layoutRecs[3]
    if (OldDictSelect_EditMode) then

        DropdownScrollBase = Rectangle(
            layoutRecs[3].x,
            layoutRecs[3].y,
            layoutRecs[3].width,
            layoutRecs[3].height * 15
        )


        DropdownScrollView = Rectangle(
            DropdownScrollBase.x,
            DropdownScrollBase.y,
            DropdownScrollBase.width - DropdownScrollBoundOffset.x,
            DropdownScrollBase.height - DropdownScrollBoundOffset.y
        )
        rl.GuiScrollPanel(
            DropdownScrollBase,
            "",
            DropdownScrollView,
            rl.ref(DropdownScrollBoundOffset)
        );

        rl.BeginScissorMode(DropdownScrollView.x, DropdownScrollView.y+24, DropdownScrollView.width,DropdownScrollBase.height - 38)
    
        DropdownRect = Rectangle(
            layoutRecs[3].x + DropdownScrollBoundOffset.x,
            layoutRecs[3].y + DropdownScrollBoundOffset.y,
            layoutRecs[3].width,
            layoutRecs[3].height
        )
    else
        DropdownScrollBoundOffset.x = 0
        DropdownScrollBoundOffset.y = 0
    end
    
    --- Must be at the end or everything else draws on top...
    --local r2 = Rectangle(

    --)
    if (rl.GuiDropdownBox(DropdownRect, DictOptionsString, DictSelect_ChoiceIndex:Ptr(), DictSelect_EditMode)) then
        DictSelect_EditMode = not DictSelect_EditMode
    end

    if (OldDictSelect_EditMode) then
        rl.EndScissorMode()
    end

    

    rl.GuiUnlock()
    
	rl.EndDrawing()
end

rl.CloseWindow()


