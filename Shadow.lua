-- Shadow.lua
-- Made by qwerty_nix | UID: 538052
-- Discord: https://discord.gg/QNnCTgAAFE

local ffi = require("ffi")
local bit = require("bit")
local user32 = ffi.load("user32")
local shell32 = ffi.load("shell32")
local kernel32 = ffi.load("kernel32")
local winhttp = ffi.load("WinHttp")
local shlwapi = ffi.load("shlwapi.dll")
local winmm = ffi.load("winmm")
local comdlg32 = ffi.load("comdlg32")

SND_FILENAME = 0x00020000
SND_ASYNC = 0x00000001

ffi.cdef([[
    //Global
    typedef uint32_t DWORD;
    typedef int BOOL;
    typedef void* HANDLE;
    typedef void* HWND;
    typedef unsigned long DWORD;
    typedef unsigned short WORD;

    typedef struct {
        long x;
        long y;
    } POINT;

    typedef struct {
        long left;
        long top;
        long right;
        long bottom;
    } RECT;

    typedef struct Vector {
        float x, y, z;
    } Vector;

    typedef struct QAngle {
        float pitch, yaw, roll;
    } QAngle;

    typedef struct Color {
        float r, g, b, a;
    } Color;

    typedef struct ColorRgb {
        float r, g, b;
    } ColorRgb;

    size_t GlobalSize(void* hMem);
    void* GlobalAlloc(unsigned int uFlags, size_t dwBytes);
    void* GlobalLock(void* hMem);
    int GlobalUnlock(void* hMem);
    int MultiByteToWideChar(unsigned int CodePage, unsigned long dwFlags, const char* lpMultiByteStr, int cbMultiByte, void* lpWideCharStr, int cchWideChar);
    int WideCharToMultiByte(unsigned int CodePage, unsigned long dwFlags, const void* lpWideCharStr, int cchWideChar, char* lpMultiByteStr, int cbMultiByte, const char* lpDefaultChar, int* lpUsedDefaultChar);
    intptr_t ShellExecuteW(void* hwnd, const wchar_t* lpOperation, const wchar_t* lpFile, const wchar_t* lpParameters, const wchar_t* lpDirectory, int nShowCmd);
    void* GetModuleHandleA(const char* lpModuleName);
    void* GetProcAddress(void* hModule, const char* lpProcName);
    void* FindWindowA(const char* lpClassName, const char* lpWindowName);
    void* GetForegroundWindow(void);
    int PlaySoundA(const char* pszSound, void* hmod, DWORD fdwSound);
    int GetClientRect(void* hWnd, RECT* lpRect);

    //File System
    typedef struct {
        DWORD dwLowDateTime;
        DWORD dwHighDateTime;
    } FILETIME;
        
    typedef struct {
        DWORD dwFileAttributes;
        FILETIME ftCreationTime;
        FILETIME ftLastAccessTime;
        FILETIME ftLastWriteTime;
        DWORD nFileSizeHigh;
        DWORD nFileSizeLow;
        DWORD dwReserved0;
        DWORD dwReserved1;
        char cFileName[260];
        char cAlternateFileName[14];
    } WIN32_FIND_DATAA;

    DWORD GetFileAttributesA(const char* lpFileName);
    HANDLE FindFirstFileA(const char* lpFileName, WIN32_FIND_DATAA* lpFindFileData);
    BOOL FindNextFileA(HANDLE hFindFile, WIN32_FIND_DATAA* lpFindFileData);
    BOOL FindClose(HANDLE hFindFile);
    int DeleteFileA(const char* lpFileName);
    int MoveFileA(const char* lpExistingFileName, const char* lpNewFileName);
    int CreateDirectoryA(const char* lpPathName, void* lpSecurityAttributes);
    void* LoadImageA(void* hInst, const char* name, uint32_t type, int cx, int cy, uint32_t fuLoad);
    int ShowWindow(void* hWnd, int nCmdShow);
    void* GetActiveWindow(void);
    BOOL CopyFileA(const char* lpExistingFileName, const char* lpNewFileName, BOOL bFailIfExists);
    int ShellExecuteA(void* hwnd, const char* lpOperation, const char* lpFile, const char* lpParameters, const char* lpDirectory, int nShowCmd);

    //Input
    short GetAsyncKeyState(int vKey);
    int GetCursorPos(POINT* lpPoint);
    int ScreenToClient(void* hWnd, POINT* lpPoint);
    int SetCursorPos(int X, int Y);

    //Clipboard
    int OpenClipboard(void* hWndNewOwner);
    int CloseClipboard(void);
    int EmptyClipboard(void);
    int IsClipboardFormatAvailable(unsigned int format);
    void* GetClipboardData(unsigned int uFormat);
    void* SetClipboardData(unsigned int uFormat, void* hMem);

    //Memory
    typedef struct Thread32Entry {
        uint32_t dwSize;         
        uint32_t cntUsage;       
        uint32_t th32ThreadID;  
        uint32_t th32OwnerProcessID; 
        long tpBasePri;         
        long tpDeltaPri;       
        uint32_t dwFlags;       
    } Thread32Entry;
    
    int CloseHandle(void* handle);
    void* GetCurrentProcess();
    uint32_t ResumeThread(void* thread_handle);
    uint32_t GetCurrentThreadId();
    uint32_t SuspendThread(void* thread_handle);
    uint32_t GetCurrentProcessId();
    void* OpenThread(uint32_t desired_access, int inherit_handle, uint32_t thread_id);
    int Thread32Next(void* snapshot_handle, struct Thread32Entry* thread_entry);
    int Thread32First(void* snapshot_handle, struct Thread32Entry* thread_entry);
    void* CreateToolhelp32Snapshot(uint32_t flags, uint32_t process_id);
    int VirtualProtect(void* lpAddress, size_t dwSize, uint32_t flNewProtect, uint32_t* lpflOldProtect);
    void* VirtualAlloc(void* lpAddress, size_t dwSize, uint32_t flAllocationType, uint32_t flProtect);
    bool VirtualFree(void* lpAddress, size_t dwSize, uint32_t dwFreeType);

    typedef struct LARGE_INTEGER {
        long long QuadPart;   
    } LARGE_INTEGER;
    
    int QueryPerformanceCounter(LARGE_INTEGER* performance_count);
    int QueryPerformanceFrequency(LARGE_INTEGER* frequency);
    uint64_t GetTickCount64(void);
    uint32_t timeGetDevCaps(void* timer_caps, uint32_t size_timer_caps);

    int ReadProcessMemory(void* hProcess, const void* lpBaseAddress, void* lpBuffer, uint64_t nSize, void* lpNumberOfBytesRead);
    int WriteProcessMemory(void* hProcess, void* lpBaseAddress, const void* lpBuffer, uint64_t nSize, void* lpNumberOfBytesWritten);
]])

local Path = {
    Scripts = get_game_directory() .. "/nix/scripts/",
    Lua = get_game_directory() .. "/nix/scripts/Shadow lua/",
    Assets = get_game_directory() .. "/nix/scripts/Shadow lua/Assets/",
    Configs = get_game_directory() .. "/nix/scripts/Shadow lua/Configs/",
    HitSounds = get_game_directory() .. "/nix/scripts/Shadow lua/HitSounds/",
    CS2Sounds = get_game_directory():gsub("\\bin\\win64$", "") .. "/csgo/sounds/",
    Particles = get_game_directory():gsub("\\bin\\win64$", "") .. "/csgo/bin/",
    Models = get_game_directory():gsub("\\bin\\win64$", "") .. "/csgo/characters/",
}

libraries = {}
local original_require = require
local loaded_libraries = {}
function _G.require(library_name)
    if libraries[library_name] then
        if not loaded_libraries[library_name] then
            loaded_libraries[library_name] = libraries[library_name]()
        end
        return loaded_libraries[library_name]
    end
    return original_require(library_name)
end

libraries["library.core.initializate"] = function()
    local init = {}
    local http = require("library.system.http")
    local fs = require("library.system.file_system")
    local cvars = require("library.engine.convars")
    local utils = require("library.core.utils")
    local base64 = require("library.core.base64")
    require("library.core.enum")
    require("library.core.logs")

    local function InternetCheck()
        local Success = false

        http.Get("https://www.google.com/", function(response)
            if response.status == 200 then
                Success = true
            else
                log():SetAllPrefix("Error"):SetPrefixColor(color_t(1, 0, 0, 1)):Send(ALL, PREFIX, "Please, Check Your Internet Connection!")
            end
        end)

        return Success
    end

    if not InternetCheck() then
        error("Error! Please check your internet connection.")
    end

    --directories
    if not fs.FileExists(Path.Lua)then
        fs.CreateDirectory(Path.Lua)
    end
    if not fs.FileExists(Path.Assets)then
        fs.CreateDirectory(Path.Assets)
    end
    if fs.FileExists(Path.HitSounds) then
        fs.CreateDirectory(Path.HitSounds)
    end
    if fs.FileExists(Path.Configs) then
        fs.CreateDirectory(Path.Configs)
    end

    --other
    init.Loaded = false
    init.SteamName = cvars.name:String()
    init.NixwareName = get_user_name()
    init.LuaVersion = "1.0.0"
    init.VersionType = init.NixwareName == "qwerty_nix" and "Beta" or "Stable"
    init.SubscriptionTime = "Never"
    init.SteamAvatar = utils.LoadSteamAvatar()

    --downloading
    local function CheckFileV(file, path)
        return file.path == path and fs.Read(Path.Lua .. "info.txt") ~= init.LuaVersion
    end

    local DownloadingEnd = false
    local files = {
        --fonts
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/PoppinsMedium.ttf?raw=true",
            path = Path.Assets .. "PoppinsMedium.ttf"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/Verdana.ttf?raw=true",
            path = Path.Assets .. "Verdana.ttf"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/Icons.ttf?raw=true",
            path = Path.Assets .. "Icons.ttf"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/WeaponIcons.ttf?raw=true",
            path = Path.Assets .. "WeaponIcons.ttf"
        },

        --particles
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/ash_s1.vpcf_c?raw=true",
            path = Path.Particles .. "ash_s1.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/ash_s2.vpcf_c?raw=true",
            path = Path.Particles .. "ash_s2.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/coins_s.vpcf_c?raw=true",
            path = Path.Particles .. "coins_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/econ_snow.vpcf_c?raw=true",
            path = Path.Particles .. "econ_snow.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/econ_weather_ash.vpcf_c?raw=true",
            path = Path.Particles .. "econ_weather_ash.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/econ_weather_ash_b.vpcf_c?raw=true",
            path = Path.Particles .. "econ_weather_ash_b.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/flowers_s.vpcf_c?raw=true",
            path = Path.Particles .. "flowers_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/lightning_s.vpcf_c?raw=true",
            path = Path.Particles .. "lightning_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/rain_s.vpcf_c?raw=true",
            path = Path.Particles .. "rain_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_blue.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_blue.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_grey.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_grey.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_pink.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_pink.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_purple.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_purple.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_red.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_red.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/sakura_white.vpcf_c?raw=true",
            path = Path.Particles .. "sakura_white.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/snow_s.vpcf_c?raw=true",
            path = Path.Particles .. "snow_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/snow_s1.vpcf_c?raw=true",
            path = Path.Particles .. "snow_s1.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/snow_s2.vpcf_c?raw=true",
            path = Path.Particles .. "snow_s2.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/stars_s.vpcf_c?raw=true",
            path = Path.Particles .. "stars_s.vpcf_c"
        },
        {
            url = "https://github.com/qwertyNIX/Shadow-lua/blob/main/tombstone_s.vpcf_c?raw=true",
            path = Path.Particles .. "tombstone_s.vpcf_c"
        },
    }

    local MissingFiles = {}
    for _, file in ipairs(files) do
        if not fs.FileExists(file.path) then
            table.insert(MissingFiles, file)
        end
    end

    if #MissingFiles > 0 then
        local Pending = #MissingFiles
        local Failed = false

        for _, file in ipairs(MissingFiles) do
            http.Get(file.url, function(Response)
                if Response.status == 200 then
                    local f = io.open(file.path, "wb")
                    if f then
                        f:write(Response.body)
                        f:close()
                        log():Send(CONSOLE, PREFIX, "Downloaded: " .. file.path)
                    end
                else
                    log():SetConsolePrefix("Error"):SetPrefixColor(color_t(1, 0, 0, 1)):Send(CONSOLE, PREFIX, "Failed to Download: " .. file.path)
                    Failed = true
                end
                Pending = Pending - 1

                if Pending == 0 and not Failed then
                    exe_cmd("showconsole")
                    init.Loaded = false
                    Restart("Info")
                end
            end)
        end

        return init 
    end

    --info txt
    fs.DeleteFile(Path.Lua .. "info.txt")
    fs.CreateFile(Path.Lua .. "info.txt")
    fs.Write(Path.Lua .. "info.txt", init.LuaVersion)

    --fonts
    init.SmallFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 12)
    init.StandartFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 16)
    init.SmallBigFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 18)
    init.BigFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 20)
    init.TitleFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 34)

    --icons
    init.SmallIcons = render.setup_font(Path.Assets .. "Icons.ttf", 12)
    init.StandartIcons = render.setup_font(Path.Assets .. "Icons.ttf", 16)
    init.SmallBigIcons = render.setup_font(Path.Assets .. "Icons.ttf", 20)
    init.BigIcons = render.setup_font(Path.Assets .. "Icons.ttf", 22)
    init.TitleIcons = render.setup_font(Path.Assets .. "Icons.ttf", 36)

    init.BombIndicatorFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 13)
    init.BombIndicatorIcons = render.setup_font(Path.Assets .. "WeaponIcons.ttf", 36)
    init.KeybindsFont = render.setup_font(Path.Assets .. "PoppinsMedium.ttf", 14)
    init.GrenadeIcons = render.setup_font(Path.Assets .. "WeaponIcons.ttf", 28)

    init.VerdanaStandart = render.setup_font(Path.Assets .. "Verdana.ttf", 16)

    init.Loaded = true

    return init

end

libraries["library.core.helper"] = function()
    local game_ui = require("library.engine.game_ui")

    ts = tostring
    sf = string.format
    lshift = bit.lshift
    rshift = bit.rshift
    band = bit.band
    schar = string.char
    sbyte = string.byte
    sgsub = string.gsub
    ssub = string.sub
    tc = table.concat
    err = error
    pairs = pairs
    t = true
    f = false

    function exe_cmd(command) engine.execute_client_cmd(command) end
    function say(text) engine.execute_client_cmd("say " .. text) end
    function say_team(text) engine.execute_client_cmd("say_team " .. text) end
    function ternary(a, b, c) if a then return b else return c end end
    function lerp(a, b, t) return a + (b - a) * t end

    function f(t, ...)
        if not t then return end

        if type(t) == "string" and t:find("%%") then
            return sf(t, ...)
        else
            local a = {t, ...}
            for i = 1, #a do
                a[i] = ts(a[i] or "")
            end
            return table.concat(a, " ")
        end
    end

    function bench(fn, ...)
        local Start = os.clock()
        local Result = fn(...)
        local Elapsed = (os.clock() - Start) * 1000
        print(string.format("%.2f ms", elapsed))
        return Result
    end

    function try(fn, ...)
        local Success, Result = pcall(fn, ...)
        if not Success then
            print("Error: " .. tostring(Result))
            return nil
        end
        return Result
    end

    function Restart(Title, Reason)
        local TitleText = (Title and Title ~= "") and Title or "Script Error."
        local Text = Reason and "Restart lua, please.<br>Reason: " .. Reason or "Restart lua, please."
        game_ui.MessageBox(TitleText, Text, true, false, nil, nil, nil)
        unload_script()
    end

end

libraries["library.core.json"] = function()
    local json = {}

    local encode

    local escape_char_map = {
        ["\\"] = "\\",
        ["\""] = "\"",
        ["\b"] = "b",
        ["\f"] = "f",
        ["\n"] = "n",
        ["\r"] = "r",
        ["\t"] = "t"
    }

    local escape_char_map_inv = { ["/"] = "/" }
    for k, v in pairs(escape_char_map) do
        escape_char_map_inv[v] = k
    end

    local function escape_char(c)
        return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
    end

    local function encode_nil(val)
        return "null"
    end

    local function encode_table(val, stack)
        local res = {}
        stack = stack or {}
        -- Circular reference?
        if stack[val] then error("Json Error[1]")  end -- circular reference
        stack[val] = true
        if rawget(val, 1) ~= nil or next(val) == nil then
            -- Treat as array -- check keys are valid and it is not sparse
            local n = 0
            for k in pairs(val) do
                if type(k) ~= "number" then
                    error("Json Error[2]") -- invalid table: mixed or invalid key types
                end
                n = n + 1
            end
            if n ~= #val then
                error("Json Error[3]") -- "invalid table: sparse array"
            end
            -- Encode
            for i, v in ipairs(val) do
                table.insert(res, encode(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        else
            -- Treat as an object
            for k, v in pairs(val) do
                if type(k) ~= "string" and type(k) ~= "number" then
                    error("Json Error[4]") --"invalid table: invalid key type '" .. type(k) .. "'"
                end
                table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
            end
            stack[val] = nil
            return "{" .. table.concat(res, ",") .. "}"
        end
    end

    local function encode_string(val)
        return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
    end

    local function encode_number(val)
        -- Check for NaN, -inf and inf
        if val ~= val or val <= -math.huge or val >= math.huge then
            error("Json Error[4]") -- "unexpected number value '" .. tostring(val) .. "'"
        end
        return string.format("%.14g", val)
    end

    local type_func_map = {
        ["nil"] = encode_nil,
        ["table"] = encode_table,
        ["string"] = encode_string,
        ["number"] = encode_number,
        ["boolean"] = tostring
    }

    encode = function(val, stack)
        local t = type(val)
        local f = type_func_map[t]
        if f then
            return f(val, stack)
        end
        error("unexpected type '" .. t .. "'")
    end

    function json.Stringify(val)
        return (encode(val))
    end

    -- Decode

    local parse

    local function create_set(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[select(i, ...)] = true
        end
        return res
    end

    local space_chars  = create_set(" ", "\t", "\r", "\n")
    local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",", ":")
    local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
    local literals     = create_set("true", "false", "null")
    local literal_map  = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil
    }

    local function next_char(str, idx, set, negate)
        for i = idx, #str do
            if set[str:sub(i, i)] ~= negate then
                return i
            end
        end
        return #str + 1
    end

    local function decode_error(str, idx, msg)
        local line_count = 1
        local col_count = 1
        for i = 1, idx - 1 do
            col_count = col_count + 1
            if str:sub(i, i) == "\n" then
                line_count = line_count + 1
                col_count = 1
            end
        end
        error(string.format("%s at line %d col %d", msg, line_count, col_count)) 
    end

    local function codepoint_to_utf8(n)
        -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
        local f = math.floor
        if n <= 0x7f then
            return string.char(n)
        elseif n <= 0x7ff then
            return string.char(f(n / 64) + 192, n % 64 + 128)
        elseif n <= 0xffff then
            return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
        elseif n <= 0x10ffff then
            return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                f(n % 4096 / 64) + 128, n % 64 + 128)
        end
        error("Json Error[5]") -- string.format("invalid unicode codepoint '%x'", n)
    end

    local function parse_unicode_escape(s)
        local n1 = tonumber(s:sub(1, 4), 16)
        local n2 = tonumber(s:sub(7, 10), 16)
        -- Surrogate pair?
        if n2 then
            return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
        else
            return codepoint_to_utf8(n1)
        end
    end

    local function parse_string(str, i)
        local res = ""
        local j = i + 1
        local k = j
        while j <= #str do
            local x = str:byte(j)
            if x < 32 then
                error("Json Error[6]")
                --decode_error(str, j, "control character in string")
            elseif x == 92 then -- `\`: Escape
                res = res .. str:sub(k, j - 1)
                j = j + 1
                local c = str:sub(j, j)
                if c == "u" then
                    local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                        or str:match("^%x%x%x%x", j + 1)
                        or error("Json Error[7]")
                        --decode_error(str, j - 1, "invalid unicode escape in string")
                    res = res .. parse_unicode_escape(hex)
                    j = j + #hex
                else
                    if not escape_chars[c] then
                        error("Json Error[7]")
                        --decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                    end
                    res = res .. escape_char_map_inv[c]
                end
                k = j + 1
            elseif x == 34 then -- `"`: End of string
                res = res .. str:sub(k, j - 1)
                return res, j + 1
            end
            j = j + 1
        end
        error("Json Error[8]")
        --decode_error(str, i, "expected closing quote for string")
    end

    local function parse_number(str, i)
        local x = next_char(str, i, delim_chars)
        local s = str:sub(i, x - 1)
        local n = tonumber(s)
        if not n then
            error("Json Error[9]")
            --decode_error(str, i, "invalid number '" .. s .. "'")
        end
        return n, x
    end

    local function parse_literal(str, i)
        local x = next_char(str, i, delim_chars)
        local word = str:sub(i, x - 1)
        if not literals[word] then
            error("Json Error[10]")
            --decode_error(str, i, "invalid literal '" .. word .. "'")
        end
        return literal_map[word], x
    end

    local function parse_array(str, i)
        local res = {}
        local n = 1
        i = i + 1
        while 1 do
            local x
            i = next_char(str, i, space_chars, true)
            -- Empty / end of array?
            if str:sub(i, i) == "]" then
                i = i + 1
                break
            end
            -- Read token
            x, i = parse(str, i)
            res[n] = x
            n = n + 1
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "]" then break end
            if chr ~= "," then error("Json Error[11]")  end --decode_error(str, i, "expected ']' or ','")
        end
        return res, i
    end

    local function parse_object(str, i)
        local res = {}
        i = i + 1
        while 1 do
            local key, val
            i = next_char(str, i, space_chars, true)
            -- Empty / end of object?
            if str:sub(i, i) == "}" then
                i = i + 1
                break
            end
            -- Read key
            key, i = parse(str, i)
            -- Read ':' delimiter
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) ~= ":" then
                error("Json Error[12]")
                --decode_error(str, i, "expected ':' after key")
            end
            i = next_char(str, i + 1, space_chars, true)
            -- Read value
            val, i = parse(str, i)
            -- Set
            res[key] = val
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "}" then break end
            if chr ~= "," then error("Json Error[13]")  end --decode_error(str, i, "expected '}' or ','")
        end
        return res, i
    end

    local char_func_map = {
        ['"'] = parse_string,
        ["0"] = parse_number,
        ["1"] = parse_number,
        ["2"] = parse_number,
        ["3"] = parse_number,
        ["4"] = parse_number,
        ["5"] = parse_number,
        ["6"] = parse_number,
        ["7"] = parse_number,
        ["8"] = parse_number,
        ["9"] = parse_number,
        ["-"] = parse_number,
        ["t"] = parse_literal,
        ["f"] = parse_literal,
        ["n"] = parse_literal,
        ["["] = parse_array,
        ["{"] = parse_object
    }

    parse = function(str, idx)
        local chr = str:sub(idx, idx)
        local f = char_func_map[chr]
        if f then
            return f(str, idx)
        end
        error("Json Error[14]")
        --decode_error(str, idx, "unexpected character '" .. chr .. "'")
    end

    function json.Parse(str)
        if type(str) ~= "string" then
            error("Json Error[15]")
            --error("expected argument of type string, got " .. type(str))
        end
        local res, idx = parse(str, next_char(str, 1, space_chars, true))
        idx = next_char(str, idx, space_chars, true)
        if idx <= #str then
            error("Json Error[16]")
            --decode_error(str, idx, "trailing garbage")
        end
        return res
    end

    return json

end

libraries["library.core.base64"] = function()
    local shl, shr, band, bxor = bit.lshift, bit.rshift, bit.band, bit.bxor
    local char, byte, gsub, sub, format, concat, tostring, error, pairs = string.char, string.byte, string.gsub, string.sub, string.format, table.concat, tostring, error, pairs

    local ALPHABET = "zpRVqumeDZLlWTFtkMC04X8bdGPvj5NoBKJnHaxrAYh2761wQyO9fSsI3EUgic+/="
    local DEFAULT_KEY = "Sh4d0wLu4"

    local function XorStr(s, key)
        if not key or key == "" then return s end
        local out, klen = {}, #key
        for i = 1, #s do
            out[i] = char(bxor(byte(s, i), byte(key, (i - 1) % klen + 1)))
        end
        return concat(out)
    end

    local Extract = function(v, from, width)
        return band(shr(v, from), shl(1, width) - 1)
    end

    local function MakeEncoder(alphabet)
        local encoder, decoder = {}, {}
        for i = 1, 65 do
            local chr = byte(sub(alphabet, i, i)) or 32
            if decoder[chr] ~= nil then
                error("Shadow Error[3]: duplicate char in alphabet", 3)
            end
            encoder[i - 1] = chr
            decoder[chr] = i - 1
        end
        return encoder, decoder
    end

    local encoders, decoders = {}, {}

    encoders["shadow"], decoders["shadow"] = MakeEncoder(ALPHABET)
    encoders["base64"], decoders["base64"] = MakeEncoder("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=")
    encoders["base64url"], decoders["base64url"] = MakeEncoder("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")

    local alphabet_mt = {
        __index = function(tbl, key)
            if type(key) == "string" and (key:len() == 64 or key:len() == 65) then
                encoders[key], decoders[key] = MakeEncoder(key)
                return tbl[key]
            end
        end
    }

    setmetatable(encoders, alphabet_mt)
    setmetatable(decoders, alphabet_mt)

    local function BaseEncode(str, encoder)
        encoder = encoders[encoder or "shadow"] or error("ShadowB64 Error[2]", 2)
        str = tostring(str)

        local t, k, n = {}, 1, #str
        local lastn = n % 3
        local cache = {}

        for i = 1, n - lastn, 3 do
            local a, b, c = byte(str, i, i + 2)
            local v = a * 0x10000 + b * 0x100 + c
            local s = cache[v]
            if not s then
                s = char(encoder[Extract(v, 18, 6)], encoder[Extract(v, 12, 6)],
                          encoder[Extract(v, 6, 6)],  encoder[Extract(v, 0, 6)])
                cache[v] = s
            end
            t[k] = s
            k = k + 1
        end

        if lastn == 2 then
            local a, b = byte(str, n - 1, n)
            local v = a * 0x10000 + b * 0x100
            t[k] = char(encoder[Extract(v, 18, 6)], encoder[Extract(v, 12, 6)],
                        encoder[Extract(v, 6, 6)],  encoder[64])
        elseif lastn == 1 then
            local v = byte(str, n) * 0x10000
            t[k] = char(encoder[Extract(v, 18, 6)], encoder[Extract(v, 12, 6)],
                        encoder[64], encoder[64])
        end

        return concat(t)
    end

    local function BaseDecode(b64, decoder)
        decoder = decoders[decoder or "shadow"] or error("Shadow Error[1]", 2)

        local pattern = "[^%w%+%/%=]"
        local s62, s63
        for charcode, b64code in pairs(decoder) do
            if b64code == 62 then s62 = charcode
            elseif b64code == 63 then s63 = charcode end
        end
        if s62 and s63 then
            pattern = format("[^%%w%%%s%%%s%%=]", char(s62), char(s63))
        end

        b64 = gsub(tostring(b64), pattern, "")

        local cache = {}
        local t, k = {}, 1
        local n = #b64
        local padding = sub(b64, -2) == "==" and 2 or sub(b64, -1) == "=" and 1 or 0

        for i = 1, (padding > 0 and n - 4 or n), 4 do
            local a, b, c, d = byte(b64, i, i + 3)
            local v0 = a * 0x1000000 + b * 0x10000 + c * 0x100 + d
            local s = cache[v0]
            if not s then
                local v = decoder[a] * 0x40000 + decoder[b] * 0x1000
                        + decoder[c] * 0x40 + decoder[d]
                s = char(Extract(v, 16, 8), Extract(v, 8, 8), Extract(v, 0, 8))
                cache[v0] = s
            end
            t[k] = s
            k = k + 1
        end

        if padding == 1 then
            local a, b, c = byte(b64, n - 3, n - 1)
            local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40
            t[k] = char(Extract(v, 16, 8), Extract(v, 8, 8))
        elseif padding == 2 then
            local a, b = byte(b64, n - 3, n - 2)
            local v = decoder[a] * 0x40000 + decoder[b] * 0x1000
            t[k] = char(Extract(v, 16, 8))
        end
        return concat(t)
    end

    local function Encode(str, key, alphabet)
        key = key or DEFAULT_KEY
        local xored = XorStr(tostring(str), key)
        return BaseEncode(xored, alphabet or "shadow")
    end

    local function Decode(b64, key, alphabet)
        key = key or DEFAULT_KEY
        local raw = BaseDecode(b64, alphabet or "shadow")
        return XorStr(raw, key)
    end

    local function RawEncode(str, alphabet) 
        return BaseEncode(str, alphabet or "shadow") 
    end

    local function RawDecode(b64, alphabet) 
        return BaseDecode(b64, alphabet or "shadow") 
    end

    return {
        Encode = Encode,   
        Decode = Decode,   
        RawEncode = RawEncode, 
        RawDecode = RawDecode,
        DEFAULT_KEY = DEFAULT_KEY,
        ALPHABET = ALPHABET,
    }

end

libraries["library.core.utils"] = function()
    local DelayedTasks = {}
    local utils = {}

    local fs = require("library.system.file_system")

    local function DelayedTask(Delay, Func, ...)
        local Task = {
            Delay = Delay,
            Func = Func,
            Args = { ... }
        }
        DelayedTasks[#DelayedTasks + 1] = Task
    end

    local CS2Window = ffi.C.FindWindowA(nil, "Counter-Strike 2")
    function utils.IsCS2Foreground()
        return CS2Window ~= nil and ffi.C.GetForegroundWindow() == CS2Window
    end

    function utils.GetCS2Hwnd()
        return CS2Window
    end

    function utils.CreateInterface(ModuleName, InterfaceName)
        local CreateInterfaceFunc = find_export(ModuleName, "CreateInterface")
        local CreateInterface = ffi.cast("void*", CreateInterfaceFunc)

        return (ffi.cast("void*(__cdecl*)(const char*, void*)", CreateInterface)(InterfaceName, nil))
    end

    function utils.ExecuteAfter(Delay, Func, ...)
        DelayedTask(Delay, Func, ...)
    end

    function utils.GetCsgoDirectory()
        local NixDirectory = get_game_directory()
        return NixDirectory .. "\\..\\..\\csgo"
    end

    function utils.GetHitsoundsFiles()
        local SoundsPath = Path.HitSounds
        
        local Files = fs.FindFiles(SoundsPath, "vsnd_c")
        if Files == nil then return {"None"} end

        return Files
    end

    function utils.PlaySound(SoundPath)
        if SoundPath == nil or not SoundPath then return end

        winmm.PlaySoundA(SoundPath, nil, bit.bor(SND_FILENAME, SND_ASYNC))
    end

    function utils.GetSteamId()
        local Controller = entitylist.get_local_player_controller()
        if not Controller then return nil end
        
        if Controller.m_steamID and Controller.m_steamID ~= 0 then
            return tostring(Controller.m_steamID)
        end
        
        return nil
    end

    function utils.LoadSteamAvatar()
        local SteamId = utils.GetSteamId()
        local Scripts = get_game_directory()
        if not SteamId then return end
        
        local AvatarPath = Scripts:gsub("steamapps.*", "") .. "config\\avatarcache\\" .. SteamId .. ".png"
        local AvatarTexture = nil
        
        local File = io.open(AvatarPath, "r")
        if File then
            File:close()
            AvatarTexture = render.setup_texture(AvatarPath)
            if AvatarTexture then return AvatarTexture end
        end
        
        return nil
    end

    local function MurMurHash2(key, len, seed)
        local m = 0x5bd1e995
        local r = 24
        
        local h = bxor(seed, len)
        local data = key
        local pos = 1
        
        while len >= 4 do
            local k = data:byte(pos) or 0
            k = k + ((data:byte(pos+1) or 0) * 0x100)
            k = k + ((data:byte(pos+2) or 0) * 0x10000)
            k = k + ((data:byte(pos+3) or 0) * 0x1000000)
            
            k = band(k * m, 0xFFFFFFFF)
            k = bxor(k, rshift(k, r))
            k = band(k * m, 0xFFFFFFFF)
            
            h = band(h * m, 0xFFFFFFFF)
            h = bxor(h, k)
            
            pos = pos + 4
            len = len - 4
        end
        
        if len >= 3 then h = bxor(h, lshift((data:byte(pos+2) or 0), 16)) end
        if len >= 2 then h = bxor(h, lshift((data:byte(pos+1) or 0), 8)) end
        if len >= 1 then 
            h = bxor(h, data:byte(pos) or 0)
            h = band(h * m, 0xFFFFFFFF)
        end
        
        h = bxor(h, rshift(h, 13))
        h = band(h * m, 0xFFFFFFFF)
        h = bxor(h, rshift(h, 15))
        
        return band(h, 0xFFFFFFFF)
    end

    function utils.MurMurHash2LowerCase2(str, len, seed)
        len = len or #str
        local lower_str = str:lower()
        return MurMurHash2(lower_str, len, seed or 0x31415926)
    end

    return utils

end

libraries["library.core.logs"] = function()
    require("library.system.memory")
    require("library.render.color")

    local Logger = {}
    Logger.__index = Logger

    local FindHudElementPattern = FindPattern("client.dll", "40 53 48 83 EC ? 48 8B 05 ? ? ? ? 48 8B D9 48 85 C0 74 ? 48 89 5C 24", "FindHudElement")
    local SendMessageClientPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 74 24 ? 48 89 7C 24 ? 55 41 56 41 57 48 8D AC 24 ? ? ? ? B8 ? ? ? ? E8 ? ? ? ? 48 2B E0 45 33 FF 41 8B D8", "SendMessageClient")
    local fnFindHudElement = ffi.cast("int64_t(__fastcall*)(const char*)", FindHudElementPattern)
    local fnSendMessageClient = ffi.cast("int64_t(__fastcall*)(int64_t, const char*, unsigned int, uint8_t*)", SendMessageClientPattern)

    local function ChatPrint(text)
        if not text or text == "" then return end
        
        local HudPtr = fnFindHudElement("CCSGO_HudVoiceStatus")
        if not HudPtr or HudPtr == 0 or HudPtr == 32 then return end
        
        fnSendMessageClient(HudPtr - 32, text, 0xFFFFFFFF, ffi.new("uint8_t[2]", 1, 0))
    end

    function Logger.new()
        local self = {
            prefix_color = color_t(0.67, 0.67, 1, 1),
            text_color = color_t(0.825, 0.825, 0.825, 1), 
            prefix_text_chat = "Shadow.lua",
            prefix_text_console = "Shadow",
            color = nil,
            use_prefix = true
        }
        return setmetatable(self, Logger)
    end

    function Logger:SetChatPrefix(text)
        self.prefix_text_chat = text
        return self
    end

    function Logger:SetConsolePrefix(text)
        self.prefix_text_console = text
        return self
    end

    function Logger:SetAllPrefix(text)
        self.prefix_text_chat = text
        self.prefix_text_console = text
        return self
    end

    function Logger:SetPrefixColor(color)
        self.prefix_color = color
        return self
    end

    function Logger:SetTextColor(color)
        self.text_color = color
        return self
    end

    function Logger:Send(...)
        local args = {...}
        local flag = "CONSOLE"
        local color = nil
        local usePrefix = self.use_prefix
        local messageArgs = {}
        local prefixTextChat = self.prefix_text_chat .. " | "
        local prefixTextConsole = "[" .. self.prefix_text_console .. "]"
        local prefixColor = self.prefix_color
        local textColor = self.text_color 

        for i = 1, #args do
            local arg = args[i]
            
            if arg == "CONSOLE" or arg == "CHAT" or arg == "ALL" then
                flag = arg
            elseif arg == "PREFIX" then
                usePrefix = true
            elseif arg == "NOPREFIX" then
                usePrefix = false
            elseif type(arg) == "table" and arg.r and arg.g and arg.b and arg.a then
                color = arg
            else
                table.insert(messageArgs, arg)
            end
        end
        
        local Msg = f(unpack(messageArgs))
        if Msg == "" then return end
        
        local ColorHex = prefixColor:to_hex()
        
        if flag == "CONSOLE" or flag == "ALL" then
            local finalMsg = Msg
            
            local coloredMsg = Msg
            if color then
                coloredMsg = string.format("\a%s%s", color:to_hex(), Msg)
            elseif textColor then
                coloredMsg = string.format("\a%s%s", textColor:to_hex(), Msg)
            end
            
            if usePrefix then
                finalMsg = string.format("\a%s%s\adefault %s", ColorHex, prefixTextConsole, coloredMsg)
            else
                finalMsg = coloredMsg
            end
            
            if finalMsg:find("\a") then
                local DefaultColor = color_t(1, 1, 1, 1)
                local i = 1
                for Segment in string.gmatch(finalMsg, "\a?[^\a]+") do
                    local Sep = (i == select(2, string.gsub(finalMsg, "\a?[^\a]+", ""))) and "" or "\x00"
                    local Hex, Text = Segment:match("^\a(%x%x%x%x%x%x%x%x)(.-)$")
                    
                    if Hex then
                        color_print(Text .. Sep, color_t(string.rgba(Hex)))
                    else
                        local DefaultText = Segment:match("^\adefault(.-)$")
                        color_print((DefaultText or Segment) .. Sep, DefaultColor)
                    end
                    i = i + 1
                end
            else
                color_print(finalMsg, color_t(1, 1, 1, 1))
            end
        end
            
        if flag == "CHAT" or flag == "ALL" then
            local ChatMsg = Msg
            
            if color then
                ChatMsg = ColorHTML(ChatMsg, color)
            elseif textColor then
                ChatMsg = ColorHTML(ChatMsg, textColor)
            end
            
            if usePrefix then
                local ColoredPrefix = ColorHTML(prefixTextChat, prefixColor)
                ChatMsg = ColoredPrefix .. ChatMsg
            end
            
            ChatPrint(ChatMsg)
        end
    end

    function log()
        return Logger.new()
    end

end

libraries["library.core.override"] = function()
    local Cache = {}

    function Override(Name, Value)
        local Data = Cache[Name]

        if not Data then
            Cache[Name] = {
                Overrided = false,
                OldValue = menu[Name],
                Value = Value
            }

            Data = Cache[Name]
        end

        if Value ~= nil then
            if not Cache[Name].Overrided then
                Cache[Name].OldValue = menu[Name]
                Cache[Name].Overrided = true
            end

            if Cache[Name].Value ~= Value then
                menu[Name] = Value
                Cache[Name].Value = Value
            end
        else
            if Cache[Name].Overrided then
                menu[Name] = Cache[Name].OldValue
                Cache[Name].Value = Cache[Name].OldValue
                Cache[Name].Overrided = false
            end
        end
    end

    register_callback("unload", function()
        for Name, Data in pairs(Cache) do
            Override(Name, nil)
        end
    end)

    return Override

end

libraries["library.core.enum"] = function()
    local enums = {}
    local cvars = require("library.engine.convars")

    enums.cvars = {
        FCVAR_NONE = 0,
        FCVAR_UNREGISTERED = bit.lshift(1, 0),
        FCVAR_DEVELOPMENTONLY = bit.lshift(1, 1),
        FCVAR_GAMEDLL = bit.lshift(1, 2),
        FCVAR_CLIENTDLL = bit.lshift(1, 3),
        FCVAR_HIDDEN = bit.lshift(1, 4),
        FCVAR_PROTECTED = bit.lshift(1, 5),
        FCVAR_SPONLY = bit.lshift(1, 6),
        FCVAR_ARCHIVE = bit.lshift(1, 7),
        FCVAR_NOTIFY = bit.lshift(1, 8),
        FCVAR_USERINFO = bit.lshift(1, 9),
        FCVAR_CHEAT = bit.lshift(1, 14),
        FCVAR_PRINTABLEONLY = bit.lshift(1, 10),
        FCVAR_UNLOGGED = bit.lshift(1, 11),
        FCVAR_NEVER_AS_STRING = bit.lshift(1, 12),
        FCVAR_REPLICATED = bit.lshift(1, 13),
        FCVAR_DEMO = bit.lshift(1, 16),
        FCVAR_DONTRECORD = bit.lshift(1, 17),
        FCVAR_RELOAD_MATERIALS = bit.lshift(1, 20),
        FCVAR_RELOAD_TEXTURES = bit.lshift(1, 21),
        FCVAR_NOT_CONNECTED = bit.lshift(1, 22),
        FCVAR_MATERIAL_SYSTEM_THREAD = bit.lshift(1, 23),
        FCVAR_ARCHIVE_XBOX = bit.lshift(1, 24),
        FCVAR_ACCESSIBLE_FROM_THREADS = bit.lshift(1, 25),
        FCVAR_SERVER_CAN_EXECUTE = bit.lshift(1, 28),
        FCVAR_SERVER_CANNOT_QUERY = bit.lshift(1, 29),
        FCVAR_CLIENTCMD_CAN_EXECUTE = bit.lshift(1, 30),
        FCVAR_MATERIAL_THREAD_MASK = bit.bor(
            bit.lshift(1, 20),
            bit.lshift(1, 21),
            bit.lshift(1, 23)
        )
    }

    enums.hitboxes = {
        HITBOX_HEAD = 0,
        HITBOX_NECK = 1,

        HITBOX_PELVIS = 2,
        HITBOX_STOMACH = 3,
        HITBOX_CHEST = 4,
        HITBOX_LOWER_CHEST = 5,
        HITBOX_UPPER_CHEST = 6,

        HITBOX_RIGHT_THIGH = 7,
        HITBOX_LEFT_THIGH = 8,
        HITBOX_RIGHT_CALF = 9,
        HITBOX_LEFT_CALF = 10,
        HITBOX_RIGHT_FOOT = 11,
        HITBOX_LEFT_FOOT = 12,

        HITBOX_RIGHT_HAND = 13,
        HITBOX_LEFT_HAND = 14,
        HITBOX_RIGHT_UPPER_ARM = 15,
        HITBOX_RIGHT_FOREARM = 16,
        HITBOX_LEFT_UPPER_ARM = 17,
        HITBOX_LEFT_FOREARM = 18
    }

    enums.particles = {
        PARTICLE_SETTING_POSITION = 0,
        PARTICLE_SETTING_DENSITY = 2,
        PARTICLE_SETTING_INFO = 3,
        PARTICLE_SETTING_COLOR = 16,
    }

    enums.icons = {
        ICON_LOGO = "A",
        ICON_RAGE = "I",
        ICON_ANTIAIM = "C",
        ICON_LEGIT = "B",
        ICON_VISUALS = "D",
        ICON_USER = "F",
        ICON_GEAR = "E",
        ICON_TIME = "H",
        ICON_FOLDER = "J",
        ICON_FPS = "G",
        ICON_KEYBOARD = "K",
        ICON_SWITCH_OFF = "M",
        ICON_SWITCH_ON = "L",

        ICON_C4 = "j",
        ICON_HE = "d",
        ICON_MOLOTOV = "f",
        ICON_SMOKE = "e",
        ICON_DECOY = "c",
        ICON_FLASH = "c",
    }

    enums.colors = {
        COLOR_RED = color_t(1, 0, 0, 1),
        COLOR_PURPLE = color_t(1, 0, 1, 1),
        COLOR_GREEN = color_t(0, 1, 0, 1),
        COLOR_BLUE = color_t(0, 0, 1, 1),
        COLOR_BLACK = color_t(0, 0, 0, 1),
        COLOR_WHITE = color_t(1, 1, 1, 1),
        COLOR_YELLOW = color_t(1, 1, 0, 1),
        COLOR_ORANGE = color_t(1, 0.5, 0, 1),
        COLOR_PINK = color_t(1, 0, 0.5, 1),
        COLOR_SHADOWLUA = color_t(0.9, 0.5, 0.75, 1),
        COLOR_SHADOWLUA2 = color_t(0.66, 0.5, 0.9, 1)
    }

    enums.default_values = {
        DEF_VALUE_GAMMA = cvars.r_fullscreen_gamma:Float(),
        DEF_VALUE_AA_YAW = menu.ragebot_anti_aim_base_yaw_offset,
        DEF_VALUE_AA = menu.ragebot_anti,
        DEF_VALUE_VM = menu.misc_viewmodel_editor,
        DEF_VALUE_VM_X = menu.misc_viewmodel_editor_x,
        DEF_VALUE_VM_Y = menu.misc_viewmodel_editor_y,
        DEF_VALUE_VM_Z = menu.misc_viewmodel_editor_z,
        DEF_VALUE_VM_FOV = menu.misc_viewmodel_editor_fov,
    }

    enums.team = {
        TEAM_SPECTATE = 1,
        TEAM_T = 2,
        TEAM_CT = 3,
    }

    enums.log = {
        CONSOLE = "CONSOLE",
        CHAT = "CHAT",
        ALL = "ALL",
        PREFIX = "PREFIX",
        NOPREFIX = "NOPREFIX",
    }

    enums.errors = {
        ERR_TABLE_OVERFLOW = "1"
    }

    enums.frame_stages = {
    	FRAME_NET_UPDATE_POSTDATAUPDATE_START = 2,
    	FRAME_NET_UPDATE_POSTDATAUPDATE_END = 3,
    	FRAME_NET_FULL_FRAME_UPDATE_ON_REMOVE = 4,
    	FRAME_RENDER_START = 5,
    	FRAME_RENDER_END = 6,
    	FRAME_NET_UPDATE_END = 7,
    	FRAME_NET_CREATION = 8,
    	FRAME_RESTORE_SERVER_STATE = 9,
    	FRAME_SIMULATE_END = 10
    }

    enums.flt = {
        FLT_MAX = 3.402823466e+38,
        FLT_MIN = -3.402823466e+38,
    }

    enums.user_cmd = {
        IN_ATTACK = bit.lshift(1, 0),
        IN_JUMP = bit.lshift(1, 1),
        IN_DUCK = bit.lshift(1, 2),
        IN_FORWARD = bit.lshift(1, 3),
        IN_BACK = bit.lshift(1, 4),
        IN_USE = bit.lshift(1, 5),
        IN_CANCEL = bit.lshift(1, 6),
        IN_LEFT = bit.lshift(1, 7),
        IN_RIGHT = bit.lshift(1, 8),
        IN_MOVELEFT = bit.lshift(1, 9),
        IN_MOVERIGHT = bit.lshift(1, 10),
        IN_ATTACK2 = bit.lshift(1, 11),
        IN_RUN = bit.lshift(1, 12),
        IN_RELOAD = bit.lshift(1, 13),
        IN_LEFT_ALT = bit.lshift(1, 14),
        IN_RIGHT_ALT = bit.lshift(1, 15),
        IN_SCORE = bit.lshift(1, 16),
        IN_SPEED = bit.lshift(1, 17),
        IN_WALK = bit.lshift(1, 18),
        IN_ZOOM = bit.lshift(1, 19),
        IN_FIRST_WEAPON = bit.lshift(1, 20),
        IN_SECOND_WEAPON = bit.lshift(1, 21),
        IN_BULLRUSH = bit.lshift(1, 22),
        IN_FIRST_GRENADE = bit.lshift(1, 23),
        IN_SECOND_GRENADE = bit.lshift(1, 24),
        IN_MIDDLE_ATTACK = bit.lshift(1, 25),
        IN_USE_OR_RELOAD = bit.lshift(1, 26),
    }

    enums.cheat_removals = {
        REMOVALS_FLASH = bit.lshift(1, 0),
        REMOVALS_SMOKE = bit.lshift(1, 1),
        REMOVALS_VISUAL_RECOIL = bit.lshift(1, 2),
        REMOVALS_SCOPE_BORDERS = bit.lshift(1, 3),
        REMOVALS_ZOOM = bit.lshift(1, 4),
        REMOVALS_SNIPER_CROSSHAIR_CHECK = bit.lshift(1, 5),
        REMOVALS_LOCAL_OVERHEAD_NAME = bit.lshift(1, 6),
        REMOVALS_MODEL_OCCLUSION = bit.lshift(1, 7),
        REMOVALS_FIRSTPERSON_LEGS = bit.lshift(1, 8),
        REMOVALS_SHADOWS = bit.lshift(1, 9),
        REMOVALS_FOG = bit.lshift(1, 10),
        REMOVALS_DECALS = bit.lshift(1, 11),
        REMOVALS_PARTICLES = bit.lshift(1, 12),
        REMOVALS_WATER_EFFECTS = bit.lshift(1, 13),
        REMOVALS_LIGHTING = bit.lshift(1, 14)
    }

    for _, Category in pairs(enums) do
        for Enum, Value in pairs(Category) do
            _G[Enum] = Value
        end
    end

end

libraries["library.lua.configs"] = function()
    local config = {}
    local fs = require("library.system.file_system")
    local json = require("library.core.json")
    local base64 = require("library.core.base64")
    local utils = require("library.core.utils")
    local init = require("library.core.initializate")
    local gui = require("library.render.gui")

    local def_cfg_str = "ShadowLuaLqYEV4W4qyG8VRapquiAVBpTjXZCpXQqLXH8eBuepsikLMMmVRapquiAVBpTVp6MRmiUlMyPjXDuCpDUZkGbVzcMp4DAVkpztV5sq4HAtypdVV6MpSiGLpMmLHAFXMyXzMyeWV50zXquq9MpZQ52ZH4FqQGMt95gquBCtajFRzEXRqWCdpTXty6MCud8DzGMoQEXRqWCdpTXty6MCud8DzGMoQEXRqWCqXH8eBuepsi4lJYiFKy2TSiRDKuejXZCpXQqLXH8eBuepsikLMMmVRp5qmiHDQpPTy62uSQAmKYdZBXMMBYmdu5EFK6bFSjClk52mQuzFsWdFM6kDV5ezXQAeyYptkQ8bBuvvnK5Dz62pSDAeKpRTBadFsD8LpMmjXZCpXQqLXH8eBuepsi4lJYHDkSez4DpLCY/FBMdDa4CLujFTkaduSXvvnK5Dz62zS48tJYHDkSez4DpLCY/FBMdDa4CLRYet95BVXfCvHiudfduCpDUZkGbVz68FsD8LyuvtQMeMBAMlMaeTHk8LXHqlOY0TBamFsD8LyuvtQMeFfWvq9ZmWKE5qqaX5H4djCX5uSWALypXD05xpXj0DyadDV5eRmiytKybZQuvRKZToXH8eBuepsioZOYODkSMpSqPvHcCWBMezMyXzMyeWV5jVsiOLpZMVRZpR4pX5KTXty6MCpDUZkGbVz68FsDCDMYRTn5JVX4zDMYkTBM2lX3AeyGvDQf8bad8DzGMofYEV4W4qyG8VVE5z4jPDyuMt95xRfk8Fpyvt4AFzaqvtyzdjCX5uSWALypXD05JVX4zDMYkTBM2TaiVlku5tzG2uSQAepyzWzz8bBpvvnK5Dz62zS48tJYJFBSVRXi0LMa2zk5zp4kNDy62DzM2tXqzvHiqofYEV4W4qyZMWKY2WaHCFyKvTQSdFsDdFpMzFB5PFfWvqO5vtQk8bBpvvnK5Dz62pSDAVQpeZQ5GFsdNLkZGtzyMRmi+DJYrWz5qzMZTLKMdDzfdMrfNtyG2TzSXuxifFkGztzX2WaHCFyKvTQSdFIHGqOGbtpKMFfWvqOi8PXBdMrfNtyG2TzSXuxifFkGztzX2WaHCFyKvTQSdFIHGqOGbtpKMFfWvqOQ8PXBdMrfNtyG2TzSXuxifFkGztzX2WaHCFyKvTQSdFIHGqOGbtpKMFfWvqOf8PXBdMrfNtyG2TzSXuxifFkGztzX2WaHCFyKvTQSdFIHGqOGbtpKMFfWvq9TvZ4AFXpyXzMyeWV50zXquq9GpDpyvR8iKZMpVtB5kzXQApM62zz6vuu4Atya2zQuzpSKX5H4djCX5uSWALypXD05Iq4WVDyK2pkuMqSfdLppdVRuPFsW4DQXMVp6dFsH8FSjFdfk8LXHqlOY0TBamFIWRtQuvtn5JVX4zDMYkTBM2lX3AeyGvDQS2uSQAeKYdtfAFXpyXeypzZQuPzfWAVyYPTku0usiqLMa2qz5PzaHkvHimofYrz4kVZM60DV5IRS3MZMZeVzuPumifDy6CFBc2LaqPLXjFj4AdMxWCFzu5tkceFsWCFzu5tkceFSWXqOZXZQSmRXquZSjFTkaduSXvvJGMZyy5RajqqOGMZyy5RajqqyZMWKY2WSqVLk5GWKYoFfWvq95vDkyMuxialMu5ZK78bBTGNXH8zzSzquHGLQG2zzSzquHGLQG2TzSXuxiBlkuMDkXXua7Atya2LfAFXBTmouH8zzSzquHGLQG2zzSzquHGLQG2TzSXuxiBlkuMDkXXua7Atya2LHAFXkpvvJGMZyy5RajqqOGMZyy5RajqqyZMWKY2WSqVLk5GWKYoFfWCDRYOFBSdzqTX5JEzDMSMCqkuFMzdZyYpz8SvvJGMZyy5RajqqOGMZyy5RajqqyZMWKY2WSqVLk5GWKYoFfWCDRYUWBXMMBYmdu5rTKyzVX3ktOYrTKyzVX3ktOY0TBamFsj8FppmtBamVsiNDBX2qpSequiPvHi8j4k8TS4VFpyPTp62TS4VFpyPTp62pSDAzMMPZBadFIqsq9yPTQubp4kdtBd8PkEXRqWCdu5rTKyzVX3ktOYrTKyzVX3ktOY0TBamFIf8DBpXt95SZ8i+DKu5WzazRfDqqQGdVRy5ufk8DKGMjXDpXpyXeypzZQuPzfWAeypzZQuPzfWALypXD05EpX3RlMa2qJa2lX30ZMGXZQ5musi4tRYItzMvuKZTTS58jXDqCBKF54QTPaqV4BuR5qkzofYXMBYmdu5mjXDqCBGpoq4qdSBm4BZuNH4zofY0MBYedHpZofYrz4kVZM60DV5rz4kVZM60DV5bpxiSDyK8VRuPzuH4lkuvD4AFzaqvtyzdj06MqqkNDKZeVV6MqqkNDKZeVzcMp4DAVKYGW05cRakNlyMztpY2uSQAVKYmTQSmFsD8LpypDqAFXyERdu5rTKyzVX3ktOYrTKyzVX3ktOY0TBamFIDdDM52mBGkVXW8FpYmVp6dFfKX5Hqpdfk8TS4VFpyPTp62TS4VFpyPTp62zS48tJYstzX8FIHGLpybWKyvuxiqDRYTjXDuXpyXeypzZQuPzfWAeypzZQuPzfWAly52eQ50uyZTLKMdDzfdMxWCFzu5tkceFsWCFzu5tkceFSjClk52eQ50usiqDRYstpYkz4DAeKMkFKSeMBYqdHzdj06MqqkNDKZeVV6MqqkNDKZeVzcMp4DAzpY0DV5eRmitvHiudfk8TS4VFpyPTp62TS4VFpyPTp62zS48tJY3tzceFfWvqQQ8PXHqCpDHLkuzFBG0usiHLkuzFBG0usikLMMmVRMvzfWAtypdVRSRzX3VtSjFRzEXRqWCqXH8zzSzquHGLQG2zzSzquHGLQG2TzSXuxigDyZeVp6MRmi3FkuqZKQ8bx7MlMaeTHMCpXQqLXaCWBMez8SvvJGMZyy5RajqqOGMZyy5RajqqyG8VRTMeXDNDKueVRM5ufMX5KTXty6MCpDHLkuzFBG0usiHLkuzFBG0usikLMMmVRTMeXDNDKueVRM5ufkAtya2qk5mzu4uqO5XTQupuyZToSH8zzSzquHGLQG2zzSzquHGLQG2TzSXuxiiLky8FBGkusigZkGzVp6dFfKX5HWudfk8TS4VFpyPTp62TS4VFpyPTp62zS48tJY/TKu8VX30tOY3FK6zFfWvqQQ8PXHqCpDHLkuzFBG0usiHLkuzFBG0usikLMMmVRTMeXDNDKueVRM5ufkAtypdVRY5RakqvHcwTkaduSXvLKMdDzfdzaqvtyzdTkaduSXvLKMdDzfdzaqvtypYofYrz4kVZM60DV5rz4kVZM60DV5ezXQAzKMGTHAFXMyXzMyeWV5jVsiytKpMWzaGFS7CTXjFdfk8LXHqlOYjFV5Oua4ClyMGVzXvzuXX5HddjCX5uSWAZpE2uBy0z8icFMKqVzTMeMZTouH8eBuepsioZOYyTQcMFIARDkX2tB5kzMZToaH8zka0z8ikLMMmVRa5FszCLME2FQT2DX38lKaMT95oz4aX5H4dj052RX4VlXjFLqYXq4koDQj8P4YuqS4uFzy2tkuWMKyXDzpXZkSmuSHdDajFjXHPXpEevaH8WpYMp4kCLujFjXAqXBGPo4kGdSi4XzMTofDFdaH8mMyXeKM0Tn50zXquq9upWzT2Tu4CZOYSDp65ufkAZpE2uBGXpaQCLRYoTKq8bBpvvJ5XTzS2zS48tJYQZB6oFszCLME2qK6eV4WVqySoVRSPpXDvLMu2tB5kzMZToSH8zka0z8ikLMMmVRyppS7AeppMFV5SufWNtQu2FQT2LfdCtB55TQS2LXHGq9uGTV5yRaqXDppkVzTMeMZTouH8zka0z8ikLMMmVRyppS7AeppMFV5SufWNtQu2FQT2LfdCtB55TQS2LXHGq9uGTV5yRaqXDppkVzXvzuXX5Hjdj0YXzS4ALypXD05EpX3RlMa2qJa2Vu7AzppCZ95oz4aX5H4dj0YXzS4ALypXD05EpX3RlMa2qJa2Vu7AzppCZ95GRSkCvHimofYxpXjCqyZMWKY2ZXHAeppMFV5jVsi3FKpmDkukz8iUZM62uQX0FI4GlM5dTBy2VS4FvHiqofYxpXjCqyZMWKY2ZXHAeppMFV5jVsi3FKpmDkukz8iUZM62uQX0FI4GlM5dTBy2RXi0LXjFd4k8TaqkLCY0TBamFIf8DBpXt95SZ8ioZOYxFBcjqmijLkQ8PXBdMxD8Lyp2TzSXuxiUlM6pWBM2ZbqAZpE2zku0VqkADMYkTHAFXKyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxintKM5ty62uSQARppdWKq8bBuvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAmz5XFBMeFfWCDRYBLKKMMBYmdu5JFK6ppXQqq9avWzadFszvlkyMD05bpxicFMKqVR65uaWvLkd8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq9cptKK2ZSHulyaMDV5eRmiBZMuzFfAFXMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxicFMKqVR65uaWvLkG2DzM2LuHMLku5tBf8bBuvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DApBpGD95IV4D4DppeVp6dFsD8LpypDqAFXkpvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DApBpGD95IV4D4DppeVz6qFIWdDpYmjXZtMaZX5H4PPSqTbkaF54DRdafWXkMvvKk8PXHdMHZX5H4PGX3qXzpeoqjRdXARXzMvvKD8PXBP44SvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVz68FIjvDQD8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq9Zdtpc2pfzAVyYdtpA8bH6XlajFdfdWbkaF54QTGu3u4kKmNuH8WHAFXMyXtajFdfdR4Bpeoq4qdX3mXBGeNuH8TqAFXpERWXH8pkueqXqvtOY3tz6XRmirDpMTTKY2pSDAmypztkSeusiOLKTMWpQ8bad8DzGMofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVVcMqu3CtQG2uBECzXWVqQGdVV6qzX40vHiuGaBdMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2WS4VDKpeDV5yzadClQu2DzM2Du4GtyyzLHAF4kpvvJT5DpSXRqWAmyYmtQy2pSDARKY0VR5Rz4DuZMuMjXZCpXQqLXH8pkueqXqvtOYntpYdzmikLMMmVREvzsi3FKpmDkukz8iqDRYEWKp2Du4GtyyzLHAF4kpvvJT5DpSXRqWAmyYmtQy2zS48tJYOtzc2LfdCtB55TQS2uSQARkSqtzGMRHMX5HkqofYJV4WRlMaeVVcvuaQ0qyZMWKY2Daikq9YRTKYmVXkCqQGdVV6zp4DVvHimdSBdMxdNtQpXty62WSiuDpu2TzSXuxiyDyZ2epEMuHDNLpp2DzM2DX30vHimGaBqCpDKZkGpWBMeFsjdtKakVzcMp4DARKY0VR5Rz4DuZMuMVz6qFIWdDpYmjXZtMaZX5H4PPSqTbkaF54DRdafWXkMvvKk8PXHdMHZX5H4PGX3qXzpeoqjRdXARXzMvvKD8PXBP44SvvJT5DpSXRqWAmyYmtQy2pSDARpYOVR5Rz4DuZMuMjXZCpXQqLXH8pkueqXqvtOYntpYdzmikLMMmVRyvDxi3FKpmDkukz8iqDRYOWKY2ZaQRtB5TjXDu4kpedu5JFK6ppXQqqOZvDkMkFSjClk52uQ5OFIipLk5mFByMFfWvq9TXD05IuaHqtujFdaBqXpyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiKZMpVVR5qquHdDBG2DzM2taidDCYWdnj8bBueouH8pkueqXqvtOY3tz6XRmirDpMTTKY2zS48tJYJFBSVFIieFpyvtM62uSQAuKYvtn5WXxcX5Hkqdfk8WaHqFMMdDV5nRfDvLRYbW05OqXQvlB55TzpzMBAMlMaeTHk8WaHqFMMdDV5nRfDvLRYbW05nVX30vHcCWBMezMyXeKM0Tn50zXquq9M5VVKMzX7Atya2eBuPFIk8DMM0THAFXkpedu5JFK6ppXQqq9avWzadFszvlkyMD050zXquqOXMDM6qzXWVZkTMVR5qquHdDBG2WzY2Daiulyp2pQp5uakeLk5etzG2lX3AeQXMWpyXquXX5KTXty6MCpDalMZMVzcMp4DAVMy2zQSMVsiqDRYHTBSoFIiMLBGMZfAF4QXvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAeppmDpKMpfkNFKp2epKzVXiGtOYbW05OV4DqFzXMDM6vRxiBZkujVVSzVXQNFpyMDqAFzaqvtyzdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52zQSmufzClQu5ZkS2LfzVZMYPDV5eRmi9ZkGzWBGbzMZTo4zqofYxpXjCqyZMWKY2ZXHAeppMFV5jVsiODKM8tQSkFSfdLpz8PXAdMxdNtQpXty62Lui4lMa2zQMXeX4uqyG8VRXvzu4vq9GjWBG0z4ZX5KTXty6MCpDKZkGpWBMeFsjdtKakVz68FIj8DMKXjXZCpXQqLXH8zka0z8ikLMMmVRa5FszCLME2WpK2ZSivDQj8PMW8pKZTou7WPaqTbkaFNfWuGazu4pyXlXjFdHk8uKZTou7RGXBqXzpeoHWmdX3q4pyXLSjFdfdpmMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiUDyuMt95IVuqGLypmVp6MRminq9KvTQSdMBYmdu5JFK6ppXQqqOZvDkMkFSWXqO5MtB5RpXQqvHcCWBMezMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiUDyuMt95IVuqGLypmVp6MRmifFkGztzX2WpZToXH8pkueqXqvtOYntpYdzmikLMMmVVYMRXiplMaeVp6MRmiaLMKvZkf8bx7MlMaeTHMCpXQqLXaCWBMez8SvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAzMYkTBM2ZSB8DKZMD05ezXQAVOu2eB5kzXyX5Hkdj0E5uf48DzG2pz5mRukAly52pz5mRukARMTCTB6zuyZTLKMdDzfdMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2LXi0LMa2qzpXRajCtJYeTBM2Zf4qFpYGVR6BMBYmdu5JFK6ppXQqqOZvDkMkFSjClk52pz5mRukARMTCTB6zusiqDRYQTBGeV4kFvHizdfk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52uQuepXDvLCYEtzyMRmisDKyGjXZCpXQqLXH8pkueqXqvtOYntpYdzmikLMMmVVcvuaQ0q9pCTkSbqqWAlQX2qz5dRfZX5B38W4AFXpEt54QTPaqT4QGmN4fuGfk8pMZToXH8D4AFXpEpNH4qdSBqXBGuoHWqGfk8zyZTou7plHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52zz6vuu4AzQTMDkMXeMZTLKMdDzfdMxdNtQpXty62WSiuDpu2WzY2lSHvDRYyTkEMpfkqvHcCWBMezMyXeKM0Tn50zXquq9upWzT2Tu4CZOYSDp65ufkAtya2eBuPFIk8DMM0THAFXkpedu5JFK6ppXQqq9avWzadFszvlkyMD050zXquqOGbtpKMFIipLk5dWKu2uSQAVM65tBazVXiGqOGqTBSkMBYmNXH8zka0z8ikLMMmVRyppS7AeppMFV5SufWNtQu2DzM2LfdCtB55TQS2LXHGq9uGTqAFXkpvvJ5XTzS2zS48tJYQZB6oFszCLME2qK6eV4WVqySoVRSPpXDvLMq8PkEXRqWCdu5EFK6bFSWXq9GdWBGBpX5X5KTXty6MCpDalMZMVzcMp4DARzpbFV5HzX4jq9MeDzueqmioZOYgZkSmuaH0LCYEFBG2Dufkq9pPWBYdzXMX5KTXty6MCpDalMZMVzcMp4DAzMMPZBadFIqsqySoVVY5zSBVvHcCWBMezMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiHlyYqTn5gqa4uDpMTVp6dFIjulMu5TBGzFsWNTKz8PX7qCpDalMZMVzcMp4DAVMy2zQSMVsi4lJYctky5pSqVDQj8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquqOGbtpKMFIipLk5dWKu2uSQAVkGqTB6zFsD8FpyvjXDqCpDalMZMVzcMp4DAVMy2zQSMVsiqDRYgZkSmuaH0LCYEFBG2DufkvHiudfk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05rpSieLCYgZkSmRuqFqQGMt95Bp4DkLku2eQuPz4TX5JEzDMSMCqkuFMzdZyYpzMQVtBpMVHk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05rpSieLCYgZkSmRuqFqyGqVR6vRuiuvHctjkA8bBpG5qQTPaqTbk5po4zWdaQdMauX5HkdjMA8bBpGNHWqdSBqXzZpoHjRdSQdMa5X5H4PGK4dMxD8Lyp2TzSXuxisZCYHTBSoFfWvqOZ5TyyjMBYmdu5xWBcMFSjClk52qBu2Tu4CZOYet95xpXkNFkd8PXHpCpDalMZMVzcMp4DAVMy2zQSMVsioZOYytka8Ru40vHcCWBMezMyXeKM0Tn50zXquq9M5VVKMzX7AZpE2epEMuHDNLpp2eBuPFIkPLOYytka8Ru40vHcCWBMezMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxi9zpy0FyyeFfWvqOc2ezECuS4VvHizdfk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05QLuHkZzueVz6qFIWdDpYmjXZtMaZX5H4PPSqTbkaF54DRdafWXkMvvKk8PXHdMHZX5H4PGX3qXzpeoqjRdXARXzMvvKD8PXBP44SvvJ5XTzS2pSDAzMMPZBadFIqsvHcCWBMezMyXmKyeZBadusigDyGXt95HRuqFLk52WzY2lu48DzujVRYvRfWVq9S5Z95yzadClQq8PkEXRqWCdu5xWBcMFSjClk52eBaPqXqvq9MSVzpoFIQCLBq8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD05bpxiHZpYzVRSCza44Fzd8PkEXRqWCdu5EFK6bFSjClk52qzMXRxk8LOYet95QzXQ8TXjFdHdpCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFsWoDQu2uBECzXWVtOYeTBM2DXdMLMGzjXDuCpDKZkGpWBMeFsjdtKakVzcMp4DARQ5Mtkakz8iOeOX2WpK2TSfdZyp2qz5dRfZX5B38W4AFXpEt54QTPaqT4QGmN4fuGfk8pMZToXH8D4AFXpEpNH4qdSBqXBGuoHWqGfk8zyZTou7plHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52qMSdRu4Vq9yGDQabqqTX5KTXty6MCpDKZkGpWBMeFsjdtKakVzcMp4DARQ5Mtkakz8iOeOX2WzY2LXivDQuvZ05xpXkNFkd8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD05bpxiKZMpVVR5qquHdDBd8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq95ptQMMqmi+DkXXWpyeFSWXq9umWKc2DaHvDujFZyYpzMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiKZMpVVR5qquHdDBG2DzM2DaipvHiudSBdMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2ZH4vDppzVRuGuuq4FzG2WzY2DqD8FOYnFKyjRf4Vq9uvZy78bHkuFMzdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52qMSdRu4Vq9yGDQabqqWAtya2zzuFzMZToX7pofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRYpRuQCFRYctKKXpfkqqQGdVRM5za4VZMKMjXDmCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIDRDpaMZ95cR4z8lQueVz6qFIWdDpYmjXZtMaZX5H4PPSqTbkaF54DRdafWXkMvvKk8PXHdMHZX5H4PGX3qXzpeoqjRdXARXzMvvKD8PXBP44SvvJT5DpSXRqWAmyYmtQy2zS48tJY9DkSPpXkCq9prz95bpxiHDMYoTn5xpXkNFkd8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD05bpxiSFMadTKy2WqD8lypmDqAFzaqvtyzdj0E5uf48DzG2pz5mRukAly52upYMRaq0LCYBDka5RqTX5KTXty6MCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIDRDpaMZ95Buaq4Lk5eVp6dFsjNLzujjXDqCBXvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAVBpdtQSzFskulMGMDM62uSQAzpyCTKy5RXXX5Hjdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52qMSdRu4VqOumWB6MuHWAtypdVVyTuuXX5Hkdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52qMSdRu4VqOumWB6MuHWAlQX2qz5dRfZX5B38W4AFXpEt54QTPaqT4QGmN4fuGfk8pMZToXH8D4AFXpEpNH4qdSBqXBGuoHWqGfk8zyZTou7plHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52pyYXVXQqvHcCWBMezMyXmKyeZBadusiBDQ5dT95bpxiyDzy5tkc2DfDCDKMkTn5cpSiGtSjFTkaduSXvvJT5DpSXRqWAmyYmtQy2zS48tJYIZK6zRSfAeyKvFzS2ZSivDQ52WpK2ZSivDQj8PMW8pKZTou7WPaqTbkaFNfWuGazu4pyXlXjFdHk8uKZTou7RGXBqXzpeoHWmdX3q4pyXLSjFdfdpmMyXmKyeZBadusiBDQ5dT95bpxifFkGztzX2TSfdZyp2qz5dRfZX5KTXty6MCpDKZkGpWBMeFsjdtKakVzcMp4DApyydt95yzadClQueVp6MRmiOLKTMWpQ8bBuVdu5JFK6ppXQqqOZvDkMkFSjClk52pz5mRukARMTCTB6zusiqLMa2uBECzXWVvHiuofYJV4WRlMaeVVcvuaQ0qyZMWKY2DSqPDMM2DzM2WaqvFMz8PXAPXBpeoq4qdSQV4BKqNSH8pkueqXqvtOYntpYdzmikLMMmVRSWuuiqFk5MVp6dFsd8DzpMjXDWXpyXmKyeZBadusiBDQ5dT95bpxiOTzXvDpSmzMZTLKMdDzfdMxdNtQpXty62WSiuDpu2WzY2DuHqlM5dTn5HRfWVqOXmtz6MufWNDKD8PkEXRqWCdu5JFK6ppXQqqOZvDkMkFSjClk52pzuPzmiqDRYrZyYMRajVZujFdHdpCpDKZkGpWBMeFsjdtKakVzcMp4DARpYOVR5Rz4DuZMuMVp6dFI3Clk52qpY5ufpX5H4dj0E5uf48DzG2pz5mRukALypXD05QRIdAzQTMDMY5zu4Atya2ekSXuxiSDzpmDMq8bKSmoq4dj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52zz6vuu4AzQTMDkMXe8iqDRY3FBGMusi9ZkGzWBGbzMZTo4zdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52zz6vuu4AzQTMDkMXe8iqDRY3FBGMusiHZkcMjXDu4KyXmKyeZBadusiBDQ5dT950zXquq9ZmTBGXzu4ARCGHVz6qFIfdDpYztpE2ZSivDQj8PMW8pKZTou7WPaqTbkaFNfWuGazu4pyXlXjFdHk8uKZTou7RGXBqXzpeoHWmdX3q4pyXLSjFdfdpmMyXzMyeWV50zXquq9GdWBGBpXjAtypdVVyTuuXX5HkdjCX5uSWALypXD05IRuqGmpM0Vp6MRmiyDy6zjXDuCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIkgZMZjZy62uSQAeKMkFKSeMBYmoq4djCX5uSWALypXD05IRuqGmpM0Vp6MRmisDKyGVRXvzuXX5HWdjCX5uSWALypXD05IRuqGmpM0VzuPumifFkGztz48bKZXdu5JFK6ppXQqq9avWzadFszvlkyMD05bpxi9zpy0FyyeMBAMlMaeTK4="

    local cfg_str = "ShadowLuaLqYJV4WRlMaeVRMvpSqvqOXdWKuMuxi4lJY9tQ5VMBAVtBpMofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRcdRfjAlQX2qz5dRfZX5B38W4AFXpEt54QTPaqT4QGmN4fuGfk8pMZToXH8D4AFXpEpNH4qdSBqXBGuoHWqGfk8zyZTou7plHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52pzSzRa4qtOYyTkEMpfMX5KTXty6MCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFsjCFp6MDp62DXdMLMGzVp6dFsWeLMpkjXDu4kpvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAmypztkSeusiOLKTMWpy2uSQARppPDzuzeMZTN44dj0E5uf48DzG2pz5mRukALypXD059ua4GlMuMVRSrTmi4tRYEtzMvquipq9GvtQ5mMBAWvKj8PXBPbzaF54QTPaiRXkXto4qdjkH8bBuvvBj8PXBP4BGeoq4qdSARXBZpoqqdjki8bBpGNkBdj0E5uf48DzG2pz5mRukAly52uk50FIipLk5mFByMMBAVtBpMofYEV4W4qyZMWKY2ZSQ8DJuXTV5eRmi9LMaXLHAFXKyXmKyeZBadusiBDQ5dT950zXquq9TvTV5gqa4utKykTn5eRmiUlkS2uQSPuSHVTXjFGaBdMrfNtyG2TzSXuxifDpMPpQa0FfWCDRYOtzGzMBYVdu5JFK6ppXQqqOZvDkMkFSjClk52uk50FIipLk5mFByMFfWvqOGzWKYzMBYuoq4dj0E5uf48DzG2pz5mRukALypXD05ORSjAzQTMDMY5zu4Atya2uBGkMBYuN44qofYEV4W4qyZMWKY2ZSQ8DJuXTV55RHzAVQpeZQ5GMBYXvaH8eBuepsi4lJYSZKyvFIDRTXjFZyYpzMyXzMyeWV50zXquq9MpZQ52ZH4FqQGMt95EpXHGvHimofYxpXjCqyZMWKY2LXqGFMMdVRaSFSBjq9aMTMy2VS4FvHi8pCT2tpZvvnK5Dz62zS48tJYSZKyvFIDRTCYeTBM2LfkoLkj8P0TzuH4CdzumZBfdqqDRLXazDMSMCqkuFMzdZyYpzMQVtBpMVHk8TaqkLCY0TBamFIf8DBpXt95SZ8ioZOYxFBcjqmijLkQ8P4YJlsifvaH8eBuepsi4lJYiFKy2TSiRDKuejXZzuH4Cdu5EFK6bFSjClk52mQuzFsWdFM6kDV5eRmiKDyaptBf8bBuvvnK5Dz62zS48tJYiFKy2TSiRDKueVp6MRmiHDQpPTfAFXMyXzMyeWV5bpxiaLkTMWBM2Taq0lkj8PMymqXXvvnK5Dz62pSDAez5MDzSmqa4ApyydtOEMzXMX5BumZBfdMrfNtyG2TzSXuxirtKpeTKYRz8iiZMadukSMzmiqDRYBFBXMMBYmou7uofYEV4W4qyG8VVYXzSkdDpaejXZzuH4Cdu5EFK6bFSjClk52zka0zuivDzG2DzM2DfD8FKyzLHAFXpyXzMyeWV50zXquqO5XTzyvRuQqqQGdVREmVXWVZMYPjXDuCpDUZkGbVzpoFIduLMpbWB48bad8DzGMofYEV4W4qySoVRSkzS4ApBpGDfAFzaqvtyzdjCX5uSWAly52zkSGRfdCqOT5TKcGRSkCDRYct05rpSieLXjFTkaduSXvvnK5Dz62pSDAmKyMZzXvzu4vqO5vZQazVXiGvHcCWBMezMyXzMyeWV50zXquqOT5TKcGRSkCDRYxtpyXquHdDJYet95HV4k4ZujFdfk8LXHqlOY0TBamFsdNLkZGtzyMRmiaDQuXZQuvRxiqDRY6WKi8bBpvvnK5Dz62zS48tJYJFBSVRXi0LMa2zk5zp4kNDy62DzM2TaivDujFdfk8LXHqlOYbW05Iq4WVDyK2pkuMqSfdLppdVRuPFsW4DQXMjXZCpXQqLXH8eBuepsikLMMmVR6pufkdDCYJFBSVRXi0LMa2mBG2TSWdtpp2DzM2tKZTouH8eBuepsikLMMmVR6pufkdDCYJFBSVRXi0LMa2mBG2TSWdtpp2DzM2tMZTouH8eBuepsikLMMmVR6pufkdDCYJFBSVRXi0LMa2mBG2TSWdtpp2DzM2tpZTouH8eBuepsikLMMmVR6pufkdDCYJFBSVRXi0LMa2mBG2TSWdtpp2DzM2DaipvHiqofYEV4W4qyZMWKY2Zf4qFpYGVVE5z4jPDyuMt95cRxiHlyYqTn5eRmirZkubFfAFXpyXzMyeWV50zXquq9GpDpyvR8iKZMpVtB5kzXQApM62zz6vuu4Atya2RBaVMBYedu5EFK6bFSjClk52qpSequiPqOT5TKcGRSkCDRYct05rpSieLCYet95xRSQvvHiqofYrz4kVZM60DV5IRS3MZMZeVp6MRmifDy6CFBi8bBuvvJGMZyy5Rajqq9GvtkE5zfWAZM6qVR6vRadNLOYUWBXMMBYXvaH8zzSzquHGLQG2zzSzquHGLQG2WzY2WSqVLk5GWKYoMBAVtBpMofYrz4kVZM60DV5rz4kVZM60DV50zXquqOZXZQSmRXquZOYet95sRfD0Lk52zkakV44qvHieoXfdMxWCFzu5tkceFsWCFzu5tkceFSjClk52pzazz4DPlk5oVp6dFfKX5HjedaQdMxWCFzu5tkceFsWCFzu5tkceFSjClk52pzazz4DPlk5oVp6dFfaX5HdpofYrz4kVZM60DV5rz4kVZM60DV50zXquqOZXZQSmRXquZOYeTBM2DaHCDpuejXZwqqDRLXazDMSMCqkuFMpYofYrz4kVZM60DV5rz4kVZM60DV50zXquqOZXZQSmRXquZOYeTBM2LaqPLXjFdHk8TS4VFpyPTp62TS4VFpyPTp62zS48tJYnWKyMuaf8tKE2FBGqFIWRtQuvtHAFMKZvvJGMZyy5RajqqOGMZyy5RajqqyG8VRXXRH48DRYSqn5cRakNlyMztpYeMBAVtBpMofYrz4kVZM60DV5rz4kVZM60DV50zXquq9KXtMSXRmisVCYctky5pSqVDQ5eVp6dFIkNtQuXtk6MMBYmoq4dj06MqqkNDKZeVV6MqqkNDKZeVzcMp4DAzMMPZBadFIqsq9yPTQubp4kdtBG2WpK2ZSivDQj8PMW8pKZTou7WPaqTbkaFNfWuGazu4pyXlXjFdHk8uKZTou7RGXBqXzpeoHWmdX3q4pyXLSjFdfdpmMyXeypzZQuPzfWAeypzZQuPzfWAly52qk5Gpxi+DKu5WzazRfZX5BumZBfdMxWCFzu5tkceFsWCFzu5tkceFSjClk52qk5Gpxi+DKu5WzazRfDAtya2qk5mzu4uqO5XTQupuyZToS7pofYrz4kVZM60DV5rz4kVZM60DV50zXquq95vtBY2lX30ZMGXZQ5mFfWvqQf8PXQpXpyXeypzZQuPzfWAeypzZQuPzfWALypXD05sRSfXq9yPTQubp4kdtJYet95TMBYmouH8zzSzquHGLQG2zzSzquHGLQG2WzY2LuiktSjFZyYpzMyXeypzZQuPzfWAeypzZQuPzfWALypXD053RSjqqQGdVRYvuakCtJYxWBy5q4TX5HdPGHk8TS4VFpyPTp62TS4VFpyPTp62zS48tJY3tzceFfWvqQf8PXHqCpDHLkuzFBG0usiHLkuzFBG0usikLMMmVRMvzfWAtya2LHAFXkpvvJGMZyy5RajqqOGMZyy5RajqqyZMWKY2LuiktOYeTBM2D4dCDBuejXZwqqDRLCBdj06MqqkNDKZeVV6MqqkNDKZeVzcMp4DAzpY0DV5ezXQAzQpzDySzMBA7Fz5pTHMzuH4CdzumZBSYCpDHLkuzFBG0usiHLkuzFBG0usi4lJY/TKu8VX30tOY3FK6zMBAVtBpMofYrz4kVZM60DV5rz4kVZM60DV50zXquq9EMLBY5Rakqq9a5Dpy2uSQAVKYmTQSmFsD8LpypDqAFXyyXeypzZQuPzfWAeypzZQuPzfWALypXD05/z4HXZM6kDV53V4WVqQGdVpz8bBGmouH8zzSzquHGLQG2zzSzquHGLQG2TzSXuxiiLky8FBGkusigZkGzVp6dFfaX5HkqofYrz4kVZM60DV5rz4kVZM60DV50zXquq9EMLBY5Rakqq9a5Dpy2uS4vq955tkyeMBA7Fz5pTHMzuH4CdzumZBfdqqDRLXazDMSMCqkuFMpYofYrz4kVZM60DV5rz4kVZM60DV5ezXQAzKMGTHAFXMyXzMyeWV5jVsiytKpMWzaGFS7CTXjFdfk8LXHqlOYjFV5Oua4ClyMGVzXvzuXX5HddjCX5uSWAZpE2uBy0z8icFMKqVzTMeMZTouH8eBuepsioZOYyTQcMFIARDkX2tB5kzMZToaH8zka0z8ikLMMmVRyppS7AeppMFV5SufWNtQu2FQT2DX38lKaMT95oz4aX5a5JmV5EDb3JvaH8zka0z8ikLMMmVRyppS7AeppMFV5SufWNtQu2FQT2DX38lKaMT95GRSkCvHieofYxpXjCqyZMWKY2Dq44ZOYHTBSoFIqqtyyeZ95jVsi3FKpmDkukz8iUZM62uQX0FI4GlM5dTBy2VS4FvHi8pCT2teDJmRugeXH8CpDalMZMVzcMp4DARzpbFV5HzX4jq9MeDzueqmioZOYgZkSmuaH0LCYEFBG2Dufkq9pPWBYdzXkADMYkTHAFXKyXeKM0Tn50zXquq9M5VVKMzX7AZpE2uBGXpaQCLRYoTKq8bKDKpOYIqnKcWeqgvaH8zka0z8ikLMMmVRa5FszCLME2FQT2DX38lKaMT95GRSkCvHimofYxpXjCqyZMWKY2ZXHAeppMFV5jVsi3FKpmDkukz8iUZM62uQX0FI4GlM5dTBy2VS4FvHi8pCT2teDJmRugeXH8CpDalMZMVzcMp4DARzpbFV5HzX4jq9MeDzueqmiqDRYEFBG2DuqPlMZMjXDuXzpvvJ5XTzS2zS48tJYQZB6oFszCLME2qK6eV4WVqQGdVR5Rz4DuZMuMVRX5Rxi9DMD8PXHqCpDalMZMVzcMp4DARzpbFV5HzX4jq9MeDzueqmioZOYytka8Ru40vHcCWBMezMyXeKM0Tn50zXquq9upWzT2Tu4CZOYSDp65ufkAZpE2epEMuHDNLpp2eBuPFIkPLOYytka8Ru40vHcCWBMezMyXeKM0Tn50zXquq9M5VVKMzX7Aly52mBGkVXW8FpYmjXZzuH4Cdu5xWBcMFSjClk52qBu2Tu4CZOYet95EVX3ARpMGWBcMMBYmoq4dj0YXzS4ALypXD05SV8irLMpoVp6dFIipLk5mFByMFIfNDJYQtBi8bBuedu5xWBcMFSjClk52qBu2Tu4CZOYet95HzX4jq9YCTM6MqpZTNfzdj0YXzS4ALypXD05SV8irLMpoVp6dFsjNLzujjXDuCpDalMZMVzcMp4DAVMy2zQSMVsiqDRYxWBy5q4TX5HkpofYxpXjCqyZMWKY2ZXHAeppMFV5jVsiODKM8tQSkMBAMlMaeTHk8TaqkLCY0TBamFIqNqOXMTBT2Vu7AzQTMDMY5zu4AzMyPVRyGzsiODKM8tQSkMBAMlMaeTHk8TaqkLCY0TBamFIqNqOXMTBT2pfzAVyYdtpA8bH6XlajFdfdWbkaF54QTGu3u4kKmNuH8WHAFXMyXtajFdfdR4Bpeoq4qdX3mXBGeNuH8TqAFXpERWXH8zka0z8i4lJYEWBGppXQAV0k8PMymqXXvvJ5XTzS2zS48tJYEWBGppXQAV0M2FQT2Lu4MFujFTkaduSXvvJ5XTzS2zS48tJYEWBGppXQAV0M2FQT2TaHkZzq8PkEXRqWCdu5JFK6ppXQqqOZvDkMkFSjClk52uk50FIipLk5mFByMFfWvq9pWDQ5PzX3VvHiudfk8WaHqFMMdDV5nRfDvLRYbW059ua4GlMuMVVympXHvtSjFZyYpzMyXmKyeZBadusigDyGXt95HRuqFLk52WzY2WaHCFOYgDyy5RS3qvHczDMSMCpDUZkGbVzcMp4DAVkpztV5sq4HAtypdVV6MpSiGLpMmLHAFXyyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiKZMpVVR5qquHdDBG2DzM2DaipvHiudSBdMxdNtQpXty62WSiuDpu2WzY2DaQFZM60VRcmzX38Lpp2mB6vRHTX5BumZBfdMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2WaHCFOYgDyy5RS3qqQGdVVZvRSfATqM2jXDuXzpvvJT5DpSXRqWAmyYmtQy2zS48tJY9DkSPpXkCq9prz95bumiHDMYoTn5IRSQdtajFLqY8MBYedHfTPaqTbkazNHkpPSHzCpD8vHiuofYmMBYedHWRdSBqXzpuNHjmGXBzCpDkvHiqoXSZCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFsdNLkZ2epKzVXiGtOYet951RSiPqQfmVqAFXkpedu5JFK6ppXQqqOZvDkMkFSjClk52qpSequiPqOGGtzTMFIWdDpYmVz6qFIWdDpYmjXZtMaZX5H4PPSqTbkaF54DRdafWXkMvvKk8PXHdMHZX5H4PGX3qXzpeoqjRdXARXzMvvKD8PXBP44SvvJT5DpSXRqWAmyYmtQy2zS48tJY9DkSPpXkCq9prz95bpxiHDMYoTn5xpXkNFkd8PMymqXXvvJT5DpSXRqWAmyYmtQy2pSDAVQpeZQ5GFsWPDyEMVR6vRuiuvHczDMSMCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFszCtBGqTB6zV4dCq9YqZQuvRHWAly52uk5mpS4AmpS5Dkyqz4DqDy62mBG2TfzClQuXZQf8bHkuFMzdj0YXzS4ALypXD05EpX3RlMa2qJa2Vu7AeKy0Fyy2RXi0LXjFd4k8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05Hz4DqtppbZQuRz8i3tzu5tzGeFSWXq9T5DM6zuu4utyYPVVc5quBAmku5tQuzVX4qvHczDMSMCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFszCtBGqTB6zV4dCq9YqZQuvRHWAtya2uQuequqGlyz8PXHm4MyXeKM0Tn50zXquq9KXtMSXRmisVCYjFV53zXdVqyKvTQf8bBZvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVz68FIfdLppdVR6jpX3kLkj8PMymqXXvvJ5XTzS2zS48tJYSFn5HzX4jqySoVR5Rz4DuZMuMVRX5Rxi9DMZ2uBGXpaQCLRYGtzyMMBYudu5JFK6ppXQqqOZvDkMkFSWXq9E5tQM2DXdMLMGzDqAFqqDRLXH8pkueqXqvtOY3tz6XRmirDpMTTKY2zS48tJYEtzyMRmifZpMPTzSmFfWCDRYBVRXvzu4vvHiVofYEV4W4qyZMWKY2ZSQ8DJuXTV5ezXQAVM65tn5ERSkCvHiRofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRXvzu4vq9GjWBG0z4DAtypdVR6pufkdDCYBjXDuCpDKZkGpWBMeFsjdtKakVzcMp4DAmyYmtQy2DXdMLMGzDV5bumifDyavD4AFeyDXvHiqoXzTbkaF54QVGXHpbzuVdu5XjXDuCpDuvHiqoX3RXzpeoq4mGXAm4BpVdu50jXDqCB4Ldu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq9KvTQSdFIWolM60TKY2uS4vq9GBVRXvzu4vvHiVofYJV4WRlMaeVVcvuaQ0qyZMWKY2WSiuDpu2uBECzXWVtOYeTBM2DXdMLMGzjXDuCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIfdLppdVR6jpX3kLk52DzSdFIWRtQuvtn5IWpZToXH8pkueqXqvtOYntpYdzmikLMMmVRcmzX38Lpp2un6HFSWXq9KvtQ5zRfdAeKMkFKSeMBAVtBpMofYJV4WRlMaeVRMvpSqvqOXdWKuMuxi4lJYQFK6XpaQCq9KvTQSdFIqGZMB8PkEXRqWCdu52VzXMquuX5B38WKSzVuiuvHi8DKcMuHkFqy65LfAdMaQRlkTMDM65RSEX5ajuoXBPXpZvvKGmTBazzXMX5ajmdSARCkumd44VjSBzbBTz5HqVjM4dMxdNtQpXty62Lui4lMa2zQMXeX4uqyG8VV6bRfzCq9YRTKYdp4aX5BumZBfdMxdNtQpXty62WSiuDpu2WzY2Duiyq9YRTKYmVXkCvHczDMSMCpDUZkGbVz68FIWvlM6BWBi8bHkuFMzdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52zz6vuu4AzQTMDkMXe8iqDRYStkuGp4kNDy62zpKMzXMX5HkpofYJV4WRlMaeVVcvuaQ0qyZMWKY2Ta4PDQTXty62uS4vqO5MtB5RzMZTuyTXty6MCud8DzGMoQEXRqWCqXH8pkueqXqvtOY3tz6XRmirDpMTTKY2zS48tJYrWz5qz8i3FKpmtQaTFfWvq9a5tkSeFIkNtQuXtk6MMBYmNXH8pkueqXqvtOYntpYdzmikLMMmVRyvDxi3FKpmDkukz8iqDRYUTBamFIWuZkGqjXDqCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFsW4DQXMVR5Rz4Dvlky2DzM2LuHGLkG2zzuFzMZTo4Wdj0E5uf48DzG2pz5mRukAly52zkSGRfd8Dzd8PkEXRqWCdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquqOGbtpKMFIipLk5dWKu2uSQARQ5XTQuMRHkAeyyFTHAFXQpvvJT5DpSXRqWAmyYmtQy2zS48tJYQtRE2LfdCtB55TQS2uSQARKMmVRYdq4DuTXjFdafqXpyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiHlyYqTn5gqa4uDpMTVp6dFIqqtppbZ95xp4kNDSjFdfk8WaHqFMMdDV5nRfDvLRY0TBamFsjNDKu2DzM2TfkuLM60ZQz8bBuGNXH8pkueqXqvtOY3tz6XRmirDpMTTKY2zS48tJYrWz5qz8i3FKpmtQaTFfWCDRYBWKY0z4kAzpyPTK78bx7VtBpMoyymqXXvFz5pTHMzuH4CqXH8pkueqXqvtOY3tz6XRmirDpMTTKY2zS48tJYrWz5qz8i3FKpmtQaTFSWeq9GvtQ5mMBAWvKj8PXBPbzaF54QTPaiRXkXto4qdjkH8bBuvvBj8PXBP4BGeoq4qdSARXBZpoqqdjki8bBpGNkBdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSWXq9u3FBcjqqTX5KTXty6MCpDKZkGpWBMeFsjdtKakVzcMp4DARpYOVR5Rz4DuZMuMVp6dFId8tJYIDkueupZTo44qdfk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05QLuHkZzueVp6dFsD8LpypDqAFXkpedu5JFK6ppXQqqOZvDkMkFSjClk52uQ5OFIipLk5mFByMFfWvq96MWKY2ZaQRtB5TjXDGXkpedu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq9u3FBcjqqWAtya2R05gzadqLkq8PXQqCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIkgZMZjZy62pfzAVyYdtpA8bH6XlajFdfdWbkaF54QTGu3u4kKmNuH8WHAFXMyXtajFdfdR4Bpeoq4qdX3mXBGeNuH8TqAFXpERWXH8pkueqXqvtOYntpYdzmi4lJYOZBMdpHDNLySzjXZCpXQqLXH8pkueqXqvtOY3tz6XRmirDpMTTKY2pSDApppXtyyjFIDdDQGzVRp5qmiOLKTMWpQ8bHkuFMzdj0E5uf48DzG2pz5mRukAly52pzuPzpZTFz5pTHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52zzpvqmiOLKTMWpyeMBAVtBpMofYJV4WRlMaeVVcvuaQ0qyG8VRy5uSqXDpp2zQ5eqmirtKYbTK6eVX3kvHcCWBMezMyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxiHZpYzVRSCza44FzG2DzSdFI4MLKpbZfAFXMyXmKyeZBadusiBDQ5dT95bpxiOTzXvDpSmzMZTFz5pTHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52qMSdRu4Vq9yGDQabqqTX5BumZBfdMxdNtQpXty62WSiuDpu2TzSXuxiOTzXvDpSmz8iqDRYJWBMpzMZT5q4dj0E5uf48DzG2pz5mRukAly52uzaGRXuX5KTXty6MCpDKZkGpWBMeFIQdlyMdVVKdp4HCtJY0TBamFIDRDpaMZ95cR4z8lQueVz68FIkulkZ2ukudRpZTFz5pTHk8WaHqFMMdDV5nRfDvLRY0TBamFIj8DMKXVp6dFsd8DzpMjXDmCBZeoq4qdSBz4QGtofDdj0E5uf48DzG2eQ5bpXQAepaXLBSmFSjClk52qMSdRu4Vq9yGDQabqqWAly52uyYXqsiBZkujtpSzFIkdFzd8PMymqXXvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAVBpdtQSzFIHPtpMbZy62uSQAeyyFTHAFXMERdu5JFK6ppXQqq9avWzadFszvlkyMD050zXquq95ptQMMqmi+DkXXWpyeFfWvq9a5TkSzVXfCvHimofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRYpRuQCFRYctKKXpfkqqyGqVR6vRuiuvHctjkA8bBpG5qQTPaqTbk5po4zWdaQdMauX5HkdjMA8bBpGNHWqdSBqXzZpoHjRdSQdMa5X5H4PGK4dMxdNtQpXty62WSiuDpu2WzY2WSiuDpu2uBECzXWVtSjFZyYpzMyXmKyeZBadusigDyGXt95HRuqFLk52WzY2ZH4vDppzVVympXWCtBd8PMymqXXvvJT5DpSXRqWAmyYmtQy2zS48tJYntpYdzmiOLKTMWpyeFfWvq9uMtM65qqaX5HqqofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRYpRuQCFRYBDkabz4DqqQGdVVc5zqkovHiqoXfdMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2ZH4vDppzVVympXWCtBG2DzM2LuHMLku5tBf8bBZvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAVBpdtQSzFskulMGMDM62uS4vqOuTDQf8bBuvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAVBpdtQSzFskulMGMDM62pfzAVyYdtpA8bH6XlajFdfdWbkaF54QTGu3u4kKmNuH8WHAFXMyXtajFdfdR4Bpeoq4qdX3mXBGeNuH8TqAFXpERWXH8pkueqXqvtOY3tz6XRmirDpMTTKY2pSDAmz5XFBMeMBAMlMaeTHk8WaHqFMMdDV5nRfDvLRY0TBamFI7NDpa2uBECzXWVtOYeTBM2DXdMLMGzjXDu4pyXmKyeZBadusigDyGXt95HRuqFLk52TzSXuxintKM5ty62uSQARppdWKq8bBuvvJT5DpSXRqWAzpYbWBM2TuQ8TMpmVzcMp4DAmz5XFBMeFfWCDRYBLKKMMBYmdu5EFK6bFSjClk52qzMXRxk8LOYeTBM2WqHeLXjFdHk8WaHqFMMdDV53RSW8DRYHtQaTz4DAly52mMSGumifZk5btQSeMBAVtBpMofYJV4WRlMaeVVcvuaQ0qyZMWKY2Daikq9YRTKYmVXkCqyGqVR6vRuiuvHctjkA8bBpG5qQTPaqTbk5po4zWdaQdMauX5HkdjMA8bBpGNHWqdSBqXzZpoHjRdSQdMa5X5H4PGK4dMxdNtQpXty62Lui4lMa2zQMXeX4uqyZMWKY2lH4PtRYIFKYbRu4qqQGdVVc5zqkovHiuofYJV4WRlMaeVRMvpSqvqOXdWKuMuxikLMMmVRZpR4zAVyymWzMMusiqDRY3FBEMquHPLXjFdHk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05+qXfeq9G5Dk6dz4WAtya2zkakV44qvHiudfk8WaHqFMMdDV53RSW8DRYHtQaTz4DALypXD05+qXfeq9G5Dk6dz4WAlQX2qz5dRfZX5B38W4AFXpEt54QTPaqT4QGmN4fuGfk8pMZToXH8D4AFXpEpNH4qdSBqXBGuoHWqGfk8zyZTou7plK4="

    fs.CreateFile(Path.Configs .. "/Rage.cfg")
    fs.Write(Path.Configs .. "/Rage.cfg", cfg_str)

    local ConfigPath = Path.Configs
    local PREFIX = "ShadowLua"

    local function collect_widgets_from_group(group, widgets, path)
        if not group then return end
        
        for _, cb in ipairs(group.checkboxes or {}) do
            local id = path .. "cb_" .. (cb.label:gsub("[^%w_]", "_"))
            widgets[id] = cb
            if cb.gear_group then
                collect_widgets_from_group(cb.gear_group, widgets, path .. "gear_" .. (cb.label:gsub("[^%w_]", "_")) .. "_")
            end
        end
        
        for _, sl in ipairs(group.sliders or {}) do
            local id = path .. "sl_" .. (sl.label:gsub("[^%w_]", "_"))
            widgets[id] = sl
            if sl.gear_group then
                collect_widgets_from_group(sl.gear_group, widgets, path .. "gear_" .. (sl.label:gsub("[^%w_]", "_")) .. "_")
            end
        end
        
        for _, sel in ipairs(group.selectables or {}) do
            local id = path .. "sel_" .. (sel.label:gsub("[^%w_]", "_"))
            widgets[id] = sel
            if sel.gear_group then
                collect_widgets_from_group(sel.gear_group, widgets, path .. "gear_" .. (sel.label:gsub("[^%w_]", "_")) .. "_")
            end
        end
        
        for _, lbl in ipairs(group.labels or {}) do
            if lbl.gear_group then
                collect_widgets_from_group(lbl.gear_group, widgets, path .. "gear_" .. (lbl.label:gsub("[^%w_]", "_")) .. "_")
            end
        end
        
        for _, hk in ipairs(group.hotkeys or {}) do
            local id = path .. "hk_" .. (hk.label:gsub("[^%w_]", "_"))
            widgets[id] = hk
        end
        
        for _, cp in ipairs(group.color_pickers or {}) do
            local id = path .. "cp_" .. (cp.label:gsub("[^%w_]", "_"))
            widgets[id] = cp
        end
        
        for _, inp in ipairs(group.inputs or {}) do
            local id = path .. "inp_" .. (inp.label:gsub("[^%w_]", "_"))
            widgets[id] = inp
        end
        
        for _, sub_group in ipairs(group.groups or {}) do
            collect_widgets_from_group(sub_group, widgets, path)
        end
    end

    local function collect_all_widgets()
        local widgets = {}
        local all_windows = gui.get_all_windows()
        
        for _, window in ipairs(all_windows) do
            for _, group in ipairs(window.groups or {}) do
                collect_widgets_from_group(group, widgets, "")
                
                for _, tab in ipairs(group.tabs or {}) do
                    local tab_path = tab.name:gsub("[^%w_]", "_") .. "_"
                    
                    for _, sub_group in ipairs(tab.groups or {}) do
                        collect_widgets_from_group(sub_group, widgets, tab_path)
                    end
                    
                    for _, subtab in ipairs(tab.subtabs or {}) do
                        local sub_path = tab_path .. (subtab.name:gsub("[^%w_]", "_")) .. "_"
                        for _, sub_group in ipairs(subtab.groups or {}) do
                            collect_widgets_from_group(sub_group, widgets, sub_path)
                        end
                    end
                end
            end
        end
        
        return widgets
    end

    function config.GetList()
        if not fs.FileExists(ConfigPath) then
            fs.CreateDirectory(ConfigPath)
            return {}
        end
        
        local files = fs.FindFiles(ConfigPath, "cfg")
        local list = {}
        if files then
            for _, file in ipairs(files) do
                local name = file:gsub("%.cfg$", "")
                if name ~= "" then
                    table.insert(list, name)
                end
            end
        end
        table.sort(list)
        return list
    end

    function config.Delete(name)
        if not name or name == "" then return false end
        local filepath = ConfigPath .. name .. ".cfg"

        

        os.remove(filepath)
        return true
    end

    function config.Save(name)
        if not name or name == "" then return false end
        
        name = name:gsub("[^%w_%-%s]", "")
        if name == "" then return false end
        
        if not fs.FileExists(ConfigPath) then
            fs.CreateDirectory(ConfigPath)
        end
        
        local data = {}
        local widgets = collect_all_widgets()
        
        data.__meta = {
            author = ((author ~= nil or author ~= "") and init.NixwareName) or "Unknown",
            created = os.date("%Y-%m-%d %H:%M:%S"),
            luaversion = init.LuaVersion,
        }
        
        for id, widget in pairs(widgets) do
            if widget.Get then
                local val = widget:Get()
                local t = type(val)
                
                if t == "boolean" or t == "number" or t == "string" then
                    data[id] = val
                elseif t == "userdata" and val.r then
                    data[id] = {r = val.r, g = val.g, b = val.b, a = val.a}
                elseif t == "table" then
                    if widget.selected and type(widget.selected) == "table" then
                        data[id] = widget.selected
                    else
                        local copy = {}
                        for k, v in pairs(val) do
                            if type(v) ~= "function" then
                                copy[k] = v
                            end
                        end
                        data[id] = copy
                    end
                end
            end
            
            if widget.GetKey then
                local key_data = widget:GetKey()
                if key_data then
                    data[id .. "_key"] = key_data.key
                    data[id .. "_mode"] = key_data.mode
                end
            end
        end
        
        if next(data) == nil then
            return false
        end
        
        local json_str = json.Stringify(data)
        if not json_str then return false end
        
        local encoded = base64.Encode(json_str)
        
        local filepath = ConfigPath .. name .. ".cfg"
        local f = io.open(filepath, "wb")
        if not f then return false end
        f:write(PREFIX .. encoded)
        f:close()
        
        return true
    end

    local function LoadByStr(str, name_for_log)
        if not str or str == "" then
            return false
        end

        local label = name_for_log or "<string>"

        local encoded
        if str:sub(1, #PREFIX) == PREFIX then
            encoded = str:sub(#PREFIX + 1)
        else
            encoded = str
        end

        local json_str = base64.Decode(encoded)
        if not json_str then
            log():SetConsolePrefix("Error"):SetPrefixColor(color_t(255, 0, 0, 255)):Send(CONSOLE, PREFIX, "Decode failed: " .. label)
            return false
        end

        local data = json.Parse(json_str)
        if not data then
            log():SetConsolePrefix("Error"):SetPrefixColor(color_t(255, 0, 0, 255)):Send(CONSOLE, PREFIX, "Parse failed: " .. label)
            return false
        end

        local widgets = collect_all_widgets()

        for key, value in pairs(data) do
            if key ~= "__meta" then
                local widget = widgets[key]

                if widget then
                    if widget.type == "selectable" and widget.Set then
                        if widget.multi then
                            if type(value) == "table" then
                                for i = 1, #widget.items do
                                    widget.selected[i] = value[i] or false
                                end
                                local selected_items = {}
                                for i, selected in ipairs(widget.selected) do
                                    if selected and widget.items[i] then
                                        table.insert(selected_items, widget.items[i])
                                    end
                                end
                                widget.value = selected_items
                            end
                        else
                            if type(value) == "number" and value >= 1 and value <= #widget.items then
                                widget:Set(value)
                            end
                        end
                    elseif widget.Set then
                        if type(value) == "table" and value.r then
                            widget:Set(color_t(value.r, value.g, value.b, value.a))
                        else
                            pcall(widget.Set, widget, value)
                        end
                    end
                end

                if key:match("_key$") then
                    local widget_name = key:gsub("_key$", "")
                    local w = widgets[widget_name]
                    if w and w.SetKey then
                        pcall(w.SetKey, w, value)
                    end
                end

                if key:match("_mode$") then
                    local widget_name = key:gsub("_mode$", "")
                    local w = widgets[widget_name]
                    if w and w.SetMode then
                        pcall(w.SetMode, w, value)
                    end
                end
            end
        end

        return true
    end

    local last_time = os.clock()
    function config.Load(name)
        if not name or name == "" then return false end

        local filepath = ConfigPath .. name .. ".cfg"

        local f = io.open(filepath, "rb")
        if not f then
            log():SetConsolePrefix("Error"):SetPrefixColor(color_t(255, 0, 0, 255)):Send(CONSOLE, PREFIX, "Not found: " .. name)
            return false
        end

        local content = f:read("*a")
        f:close()

        if not content or content == "" then
            return false
        end

        return LoadByStr(content, name)
    end

    function config.ResetSettings()
        LoadByStr(def_cfg_str)
    end

    function config.GetInfo(name)
        if not name or name == "" then return nil end
        
        local filepath = ConfigPath .. name .. ".cfg"
        local f = io.open(filepath, "rb")
        if not f then return nil end
        
        local content = f:read("*a")
        f:close()
        
        if not content or content == "" then return nil end
        
        local encoded = content:sub(1, #PREFIX) == PREFIX 
            and content:sub(#PREFIX + 1) 
            or content
        
        local json_str = base64.Decode(encoded)
        if not json_str then return nil end
        
        local data = json.Parse(json_str)
        if not data or not data.__meta then return nil end
        
        return data.__meta
    end

    return config

end

libraries["library.system.http"] = function()
    local http = {}

    ffi.cdef([[
        typedef void* HINTERNET;
        typedef unsigned long DWORD;
        typedef int BOOL;

        HINTERNET WinHttpOpen(const wchar_t* userAgent, DWORD accessType, const wchar_t* proxyName, const wchar_t* proxyBypass, DWORD flags);
        HINTERNET WinHttpConnect(HINTERNET session, const wchar_t* serverName, unsigned short serverPort, DWORD reserved);
        HINTERNET WinHttpOpenRequest(HINTERNET connect, const wchar_t* verb, const wchar_t* objectName, const wchar_t* version, const wchar_t* referrer, const wchar_t** acceptTypes, DWORD flags);
        BOOL WinHttpSendRequest(HINTERNET request, const wchar_t* headers, DWORD headersLength, void* optional, DWORD optionalLength, DWORD totalLength, DWORD context);
        BOOL WinHttpReceiveResponse(HINTERNET request, void* reserved);
        BOOL WinHttpQueryHeaders(HINTERNET request, DWORD infoLevel, const wchar_t* name, void* buffer, DWORD* bufferLength, DWORD* index);
        BOOL WinHttpReadData(HINTERNET request, void* buffer, DWORD bytesToRead, DWORD* bytesRead);
        BOOL WinHttpCloseHandle(HINTERNET handle);
        DWORD GetLastError();
    ]])

    local HTTP_PORT = 80
    local HTTPS_PORT = 443
    local WINHTTP_FLAG_SECURE = 0x00800000
    local WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0
    local WINHTTP_QUERY_STATUS_CODE = 19
    local WINHTTP_QUERY_FLAG_NUMBER = 0x20000000

    local function string_to_wstring(str)
        if not str then return nil end
        local len = #str
        local wstr = ffi.new("wchar_t[?]", len + 1)
        for i = 1, len do
            wstr[i - 1] = string.byte(str, i)
        end
        wstr[len] = 0
        return wstr
    end

    local function table_to_headers(headers)
        if not headers then return nil end
        local result = {}
        for key, value in pairs(headers) do
            table.insert(result, key .. ": " .. value)
        end
        return table.concat(result, "\r\n")
    end

    local function close_handles(...)
        for i = 1, select("#", ...) do
            local handle = select(i, ...)
            if handle ~= nil and handle ~= ffi.cast("HINTERNET", 0) then
                winhttp.WinHttpCloseHandle(handle)
            end
        end
    end

    local function get_status_code(request)
        local status_code = ffi.new("DWORD[1]", 0)
        local buffer_size = ffi.new("DWORD[1]", ffi.sizeof("DWORD"))
        buffer_size[0] = ffi.sizeof("DWORD")
        
        local flags = bit.bor(WINHTTP_QUERY_STATUS_CODE, WINHTTP_QUERY_FLAG_NUMBER)
        
        if winhttp.WinHttpQueryHeaders(request, flags, nil, status_code, buffer_size, nil) ~= 0 then
            return status_code[0], nil
        else
            return -1, "WinHttpQueryHeaders failed. Error: " .. tostring(ffi.C.GetLastError())
        end
    end

    local function read_response_data(request)
        local buffer_size = 8192
        local buffer = ffi.new("uint8_t[?]", buffer_size)
        local chunks = {}
        
        while true do
            local bytes_read = ffi.new("DWORD[1]", 0)
            if winhttp.WinHttpReadData(request, buffer, buffer_size, bytes_read) == 0 then
                break
            end
            if bytes_read[0] == 0 then
                break
            end
            table.insert(chunks, ffi.string(buffer, bytes_read[0]))
        end
        
        return table.concat(chunks)
    end

    local function parse_url(url)
        local parsed = {}
        local protocol, host, path = url:match("^([hH][tT][tT][pP][sS]?)://([^/]+)(.*)$")
        
        if not protocol then
            protocol, host, path = "http", url, "/"
        end
        
        parsed.https = protocol:lower() == "https"
        
        local hostname, port = host:match("^(.-):(%d+)$")
        if hostname then
            parsed.host = hostname
            parsed.port = tonumber(port)
        else
            parsed.host = host
            parsed.port = nil
        end
        
        parsed.path = (path and #path > 0 and path) or "/"
        
        return parsed
    end

    local function perform_request(method, host, options, callback)
        local path = options.path or "/"
        local is_https = options.https or false
        local port = options.port or (is_https and HTTPS_PORT or HTTP_PORT)
        local headers = options.headers
        local body = options.body or ""
        local user_agent = options.user_agent or "LuaHTTP/1.0"
        
        local final_port = port
        local flags = is_https and WINHTTP_FLAG_SECURE or 0
        
        local session = winhttp.WinHttpOpen(string_to_wstring(user_agent), WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, nil, nil, 0)
        
        if session == nil or session == ffi.cast("HINTERNET", 0) then
            return callback({
                status = 0,
                body = "WinHttpOpen failed: " .. tostring(ffi.C.GetLastError())
            })
        end

        local connection = winhttp.WinHttpConnect(session, string_to_wstring(host), final_port, 0)
        
        if connection == nil or connection == ffi.cast("HINTERNET", 0) then
            close_handles(session)
            return callback({
                status = 0,
                body = "WinHttpConnect failed: " .. tostring(ffi.C.GetLastError())
            })
        end

        local request = winhttp.WinHttpOpenRequest(connection, string_to_wstring(method), string_to_wstring(path), nil, nil, nil, flags)
        
        if request == nil or request == ffi.cast("HINTERNET", 0) then
            close_handles(connection, session)
            return callback({
                status = 0,
                body = "WinHttpOpenRequest failed: " .. tostring(ffi.C.GetLastError())
            })
        end

        local headers_wstr
        local headers_len = 0
        
        if headers then
            local headers_str = table_to_headers(headers)
            headers_wstr = string_to_wstring(headers_str)
            headers_len = #headers_str
        end

        local body_data
        local body_len = #body
        
        if body_len > 0 then
            body_data = ffi.new("char[?]", body_len + 1)
            ffi.copy(body_data, body, body_len)
        end

        if winhttp.WinHttpSendRequest(request, headers_wstr, headers_len, body_data, body_len, body_len, 0) == 0 then
            close_handles(request, connection, session)
            return callback({
                status = 0,
                body = "WinHttpSendRequest failed: " .. tostring(ffi.C.GetLastError())
            })
        end

        if winhttp.WinHttpReceiveResponse(request, nil) == 0 then
            close_handles(request, connection, session)
            return callback({
                status = 0,
                body = "WinHttpReceiveResponse failed: " .. tostring(ffi.C.GetLastError())
            })
        end

        local status_code, status_error = get_status_code(request)
        local response_body = read_response_data(request)
        
        close_handles(request, connection, session)

        if status_error then
            response_body = "Status Query Error: " .. status_error .. "\n\n" .. response_body
            callback({
                status = -1,
                body = response_body
            })
        else
            callback({
                status = status_code,
                body = response_body
            })
        end
    end

    function http.Request(method, url, options, callback)
        if callback == nil and type(options) == "function" then
            callback = options
            options = {}
        end
        
        method = string.upper(method or "GET")
        options = options or {}
        
        local host
        
        if url:match("://") then
            local parsed = parse_url(url)
            host = parsed.host
            options.path = options.path or parsed.path
            options.https = options.https or parsed.https
            options.port = options.port or parsed.port
        else
            host = url
        end
        
        if not host then
            return callback({
                status = 0,
                body = "Invalid or missing host/URL."
            })
        end
        
        if (method == "POST" or method == "PUT") and not options.body then
            options.body = ""
        elseif method == "GET" or method == "DELETE" then
            options.body = ""
        end
        
        perform_request(method, host, options, callback)
    end

    function http.Get(url, options, callback)
        return http.Request("GET", url, options, callback)
    end

    function http.Post(url, options, callback)
        return http.Request("POST", url, options, callback)
    end

    function http.Put(url, options, callback)
        return http.Request("PUT", url, options, callback)
    end

    function http.Delete(url, options, callback)
        return http.Request("DELETE", url, options, callback)
    end

    return http

end

libraries["library.system.input"] = function()
    local utils = require("library.core.utils")
    local input = {}
    local PrevKeys = {}
    local KeyCodes = {
        VK_A = 0x41,
        VK_B = 0x42,
        VK_C = 0x43,
        VK_D = 0x44,
        VK_E = 0x45,
        VK_F = 0x46,
        VK_G = 0x47,
        VK_H = 0x48,
        VK_I = 0x49,
        VK_J = 0x4A,
        VK_K = 0x4B,
        VK_L = 0x4C,
        VK_M = 0x4D,
        VK_N = 0x4E,
        VK_O = 0x4F,
        VK_P = 0x50,
        VK_Q = 0x51,
        VK_R = 0x52,
        VK_S = 0x53,
        VK_T = 0x54,
        VK_U = 0x55,
        VK_V = 0x56,
        VK_W = 0x57,
        VK_X = 0x58,
        VK_Y = 0x59,
        VK_Z = 0x5A,
        
        VK_0 = 0x30,
        VK_1 = 0x31,
        VK_2 = 0x32,
        VK_3 = 0x33,
        VK_4 = 0x34,
        VK_5 = 0x35,
        VK_6 = 0x36,
        VK_7 = 0x37,
        VK_8 = 0x38,
        VK_9 = 0x39,
        
        VK_F1 = 0x70,
        VK_F2 = 0x71,
        VK_F3 = 0x72,
        VK_F4 = 0x73,
        VK_F5 = 0x74,
        VK_F6 = 0x75,
        VK_F7 = 0x76,
        VK_F8 = 0x77,
        VK_F9 = 0x78,
        VK_F10 = 0x79,
        VK_F11 = 0x7A,
        VK_F12 = 0x7B,

        VK_LBUTTON = 0x01,  
        VK_RBUTTON = 0x02,  
        VK_MBUTTON = 0x04,   
        VK_XBUTTON1 = 0x05,  
        VK_XBUTTON2 = 0x06,   
        
        VK_NUMPAD0 = 0x60,
        VK_NUMPAD1 = 0x61,
        VK_NUMPAD2 = 0x62,
        VK_NUMPAD3 = 0x63,
        VK_NUMPAD4 = 0x64,
        VK_NUMPAD5 = 0x65,
        VK_NUMPAD6 = 0x66,
        VK_NUMPAD7 = 0x67,
        VK_NUMPAD8 = 0x68,
        VK_NUMPAD9 = 0x69,
        VK_MULTIPLY = 0x6A,
        VK_ADD = 0x6B,
        VK_SEPARATOR = 0x6C,
        VK_SUBTRACT = 0x6D,
        VK_DECIMAL = 0x6E,
        VK_DIVIDE = 0x6F,
        
        VK_BACK = 0x08,
        VK_TAB = 0x09,
        VK_CLEAR = 0x0C,
        VK_RETURN = 0x0D,
        VK_SHIFT = 0x10,
        VK_CONTROL = 0x11,
        VK_MENU = 0x12,    
        VK_PAUSE = 0x13,
        VK_CAPITAL = 0x14,
        VK_ESCAPE = 0x1B,
        VK_SPACE = 0x20,
        VK_PRIOR = 0x21,      
        VK_NEXT = 0x22,    
        VK_END = 0x23,
        VK_HOME = 0x24,
        VK_LEFT = 0x25,
        VK_UP = 0x26,
        VK_RIGHT = 0x27,
        VK_DOWN = 0x28,
        VK_SELECT = 0x29,
        VK_PRINT = 0x2A,
        VK_EXECUTE = 0x2B,
        VK_SNAPSHOT = 0x2C,  
        VK_INSERT = 0x2D,
        VK_DELETE = 0x2E,
        VK_HELP = 0x2F,
        
        VK_LWIN = 0x5B,
        VK_RWIN = 0x5C,
        VK_APPS = 0x5D,
        
        VK_SLEEP = 0x5F,
        VK_NUMLOCK = 0x90,
        VK_SCROLL = 0x91,
        
        VK_LSHIFT = 0xA0,
        VK_RSHIFT = 0xA1,
        VK_LCONTROL = 0xA2,
        VK_RCONTROL = 0xA3,
        VK_LMENU = 0xA4,
        VK_RMENU = 0xA5,
        
        VK_BROWSER_BACK = 0xA6,
        VK_BROWSER_FORWARD = 0xA7,
        VK_BROWSER_REFRESH = 0xA8,
        VK_BROWSER_STOP = 0xA9,
        VK_BROWSER_SEARCH = 0xAA,
        VK_BROWSER_FAVORITES = 0xAB,
        VK_BROWSER_HOME = 0xAC,
        VK_VOLUME_MUTE = 0xAD,
        VK_VOLUME_DOWN = 0xAE,
        VK_VOLUME_UP = 0xAF,
        VK_MEDIA_NEXT_TRACK = 0xB0,
        VK_MEDIA_PREV_TRACK = 0xB1,
        VK_MEDIA_STOP = 0xB2,
        VK_MEDIA_PLAY_PAUSE = 0xB3,
        VK_LAUNCH_MAIL = 0xB4,
        VK_LAUNCH_MEDIA_SELECT = 0xB5,
        VK_LAUNCH_APP1 = 0xB6,
        VK_LAUNCH_APP2 = 0xB7,
        
        VK_OEM_1 = 0xBA,       -- ;:
        VK_OEM_PLUS = 0xBB,    -- =+
        VK_OEM_COMMA = 0xBC,   -- ,<
        VK_OEM_MINUS = 0xBD,   -- -_
        VK_OEM_PERIOD = 0xBE,  -- .>
        VK_OEM_2 = 0xBF,       -- /?
        VK_OEM_3 = 0xC0,       -- `~
        VK_OEM_4 = 0xDB,       -- [{
        VK_OEM_5 = 0xDC,       -- \|
        VK_OEM_6 = 0xDD,       -- ]}
        VK_OEM_7 = 0xDE,       -- '"
    }

    local KeyNames = {
        [0x41] = "A", 
        [0x42] = "B", 
        [0x43] = "C", 
        [0x44] = "D", 
        [0x45] = "E",
        [0x46] = "F", 
        [0x47] = "G", 
        [0x48] = "H", 
        [0x49] = "I", 
        [0x4A] = "J",
        [0x4B] = "K", 
        [0x4C] = "L", 
        [0x4D] = "M", 
        [0x4E] = "N", 
        [0x4F] = "O",
        [0x50] = "P", 
        [0x51] = "Q", 
        [0x52] = "R", 
        [0x53] = "S", 
        [0x54] = "T",
        [0x55] = "U", 
        [0x56] = "V", 
        [0x57] = "W", 
        [0x58] = "X", 
        [0x59] = "Y",
        [0x5A] = "Z", 

        [0x30] = "0", 
        [0x31] = "1", 
        [0x32] = "2", 
        [0x33] = "3",
        [0x34] = "4", 
        [0x35] = "5", 
        [0x36] = "6", 
        [0x37] = "7", 
        [0x38] = "8",
        [0x39] = "9", 

        [0x70] = "F1", 
        [0x71] = "F2", 
        [0x72] = "F3", 
        [0x73] = "F4",
        [0x74] = "F5", 
        [0x75] = "F6", 
        [0x76] = "F7", 
        [0x77] = "F8", 
        [0x78] = "F9",
        [0x79] = "F10", 
        [0x7A] = "F11", 
        [0x7B] = "F12", 
        
        [0x01] = "LMB", 
        [0x02] = "RMB",
        [0x04] = "MMB", 
        [0x08] = "Backspace", 
        [0x09] = "Tab", 
        [0x0D] = "Enter",
        [0x10] = "Shift", 
        [0x11] = "Ctrl", 
        [0x12] = "Alt", 
        [0x1B] = "Esc",
        [0x20] = "Space", 
        [0x21] = "PgUp", 
        [0x22] = "PgDn", 
        [0x23] = "End",
        [0x24] = "Home", 
        [0x25] = "Left", 
        [0x26] = "Up", 
        [0x27] = "Right", 
        [0x28] = "Down",
        [0x2D] = "Ins", 
        [0x2E] = "Del",

        [0x05] = "M4",
        [0x06] = "M5", 
        [0x60] = "N0", 
        [0x61] = "N1", 
        [0x62] = "N2", 
        [0x63] = "N3",
        [0x64] = "N4", 
        [0x65] = "N5", 
        [0x66] = "N6", 
        [0x67] = "N7",
        [0x68] = "N8", 
        [0x69] = "N9",
        [0x6A] = "N*", 
        [0x6B] = "N+", 
        [0x6C] = "N,", 
        [0x6D] = "N-",
        [0x6E] = "N.", 
        [0x6F] = "N/",
        [0xA0] = "LS", 
        [0xA1] = "RS",    
        [0xA2] = "LC",
        [0xA3] = "RC",   
        [0xA4] = "LA",
        [0xA5] = "RA",  
        [0x90] = "NL",  
        [0x91] = "SC",   
    }

    function input.IsKeyPressed(key)
        local KeyCode = KeyCodes[key]
        return bit.band(ffi.C.GetAsyncKeyState(KeyCode), 0x8000) ~= 0
    end

    function input.IsKeyClicked(Key)
        local KeyPressed = input.IsKeyPressed(Key)
        local KeyClick = KeyPressed and not PrevKeys[Key]

        PrevKeys[Key] = KeyPressed

        return KeyClick
    end

    function input.GetMousePos()
        local Point = ffi.new("POINT[1]")
        user32.GetCursorPos(Point)
        user32.ScreenToClient(utils.GetCS2Hwnd(), Point)
        return vec2_t(Point[0].x, Point[0].y)
    end

    function input.WASDPressed()
        return input.IsKeyPressed(VK_W) or input.IsKeyPressed(VK_A) or input.IsKeyPressed(VK_S) or input.IsKeyPressed(VK_D)
    end

    function input.GetKeyName(KeyCode)
        return KeyNames[KeyCode] or "?"
    end

    function input.GetKeyCode(KeyName)
        for Code, Name in pairs(KeyNames) do
            if Name == KeyName then return Code end
        end
        return 0
    end

    for i, _ in pairs(KeyCodes) do
        _G[i] = i
    end

    return input

end

libraries["library.system.file_system"] = function()
    local file_system = {}

    function file_system.CreateDirectory(path)
        return ffi.C.CreateDirectoryA(path, nil)
    end

    function file_system.CreateFile(Path)
        local File, Error = io.open(Path, "wb")

        if not File then
            error("Error Creating File: " .. (Error or "Unknown"))
            return false
        end

        File:close()
        return true
    end

    function file_system.FileExists(path)
        local attr = ffi.C.GetFileAttributesA(path)
        return attr ~= 0xFFFFFFFF
    end

    function file_system.DeleteFile(path)
        return ffi.C.DeleteFileA(path) ~= 0
    end

    function file_system.MoveFile(old_path, new_path)
        return ffi.C.MoveFileA(old_path, new_path) ~= 0
    end

    function file_system.CopyFile(source_path, dest_path, overwrite)
        local overwrite = overwrite or false
        local fail_if_exists = overwrite and 0 or 1
        
        return ffi.C.CopyFileA(source_path, dest_path, fail_if_exists) ~= 0
    end

    function file_system.OpenFolder(Path)
        local Result = shell32.ShellExecuteA(nil, "open", Path, nil, nil, 1)
        return Result > 32
    end

    function file_system.FindFiles(directory, extension)
        local files = {}
        local search_path = directory .. "*." .. extension
        local find_data = ffi.new("WIN32_FIND_DATAA[1]")
        
        local handle = ffi.C.FindFirstFileA(search_path, find_data)
        if handle == ffi.cast("HANDLE", -1) then
            return nil
        end
        
        repeat
            local filename = ffi.string(find_data[0].cFileName)
            if filename ~= "." and filename ~= ".." then
                table.insert(files, filename)
            end
        until ffi.C.FindNextFileA(handle, find_data) == 0
        
        ffi.C.FindClose(handle)
        
        return files
    end

    function file_system.Write(Path, Text)
        local File, Error = io.open(Path, "wb")

        if not File then
            error("Error Writing File: " .. (Error or "Unknown"))
            return false
        end

        File:write(Text)
        File:close()

        return true
    end

    function file_system.Read(Path)
        local File, Error = io.open(Path, "rb")

        if not File then
            error("Error Reading File: " .. (Error or "Unknown"))
            return nil
        end

        local FileContent = File:read("*a")
        File:close()

        return FileContent
    end

    function file_system.RecursiveScanDirectory(Path, FileType)
        local FoundFiles = {}
        local FolderName = Path:match("([^\\/]+)[\\/]?$") or Path
        local BasePath = Path:gsub("[\\/]+$", "")
        
        local function RecursiveScan(CurrentPath)
            local SearchPath = CurrentPath .. "\\*"
            local FindData = ffi.new("WIN32_FIND_DATAA[1]")
            local Handle = ffi.C.FindFirstFileA(SearchPath, FindData)
            if Handle == ffi.cast("HANDLE", -1) then return end
            
            repeat
                local FileName = ffi.string(FindData[0].cFileName)
                if FileName ~= "." and FileName ~= ".." then
                    local FullPath = CurrentPath .. "\\" .. FileName
                    local attributes = ffi.C.GetFileAttributesA(FullPath)
                    
                    if bit.band(attributes, 0x10) ~= 0 then
                        RecursiveScan(FullPath)
                    elseif FileName:match("%." .. FileType .. "$") then
                        local RelativePath = FullPath:match(".*[\\/](" .. FolderName .. "[\\/].*)")

                        if RelativePath then
                            RelativePath = RelativePath:gsub("\\", "/")
                            table.insert(FoundFiles, RelativePath)
                        else
                            RelativePath = FullPath:sub(#BasePath + 2)
                            RelativePath = RelativePath:gsub("\\", "/")
                            table.insert(FoundFiles, RelativePath)
                        end
                    end
                end
            until ffi.C.FindNextFileA(Handle, FindData) == 0
            
            ffi.C.FindClose(Handle)
        end
        
        RecursiveScan(Path)
        return FoundFiles
    end

    function file_system.PrintTable(Table)
        if not Table or #Table == 0 then return end

        for i, Value in ipairs(Table) do
            print(string.format("%s", tostring(Value)))
        end
    end

    return file_system

end

libraries["library.system.clipboard"] = function()
    local clipboard = {}

    local CF_UNICODETEXT = 13 
    local GMEM_MOVEABLE = 2  
    local CP_UTF8 = 65001 

    function clipboard.CopyToClipboard(Text)
        if not Text then
            return false, "nil text"
        end

        local TextLength = #Text
        local UnicodeLength = ffi.C.MultiByteToWideChar(CP_UTF8, 0, Text, TextLength, nil, 0)
        
        if UnicodeLength == 0 then
            return false, "MultiByteToWideChar failed"
        end

        local UnicodeBuffer = ffi.new("uint16_t[?]", UnicodeLength + 1)
        
        if ffi.C.MultiByteToWideChar(CP_UTF8, 0, Text, TextLength, UnicodeBuffer, UnicodeLength) == 0 then
            return false, "MultiByteToWideChar convert failed"
        end
        
        UnicodeBuffer[UnicodeLength] = 0

        local MemorySize = (UnicodeLength + 1) * 2
        local GlobalMemory = ffi.C.GlobalAlloc(GMEM_MOVEABLE, MemorySize)
        
        if GlobalMemory == nil then
            return false, "GlobalAlloc failed"
        end

        local LockedMemory = ffi.C.GlobalLock(GlobalMemory)
        
        if LockedMemory == nil then
            return false, "GlobalLock failed"
        end
        
        ffi.copy(LockedMemory, UnicodeBuffer, MemorySize)
        ffi.C.GlobalUnlock(GlobalMemory)

        if ffi.C.OpenClipboard(nil) == 0 then
            return false, "OpenClipboard failed"
        end
        
        ffi.C.EmptyClipboard()
        
        if ffi.C.SetClipboardData(CF_UNICODETEXT, GlobalMemory) == nil then
            ffi.C.CloseClipboard()
            return false, "SetClipboardData failed"
        end
        
        ffi.C.CloseClipboard()
        return true
    end

    function clipboard.GetFromClipboard()
        if ffi.C.IsClipboardFormatAvailable(CF_UNICODETEXT) == 0 then
            return nil, "no unicode text available"
        end

        if ffi.C.OpenClipboard(nil) == 0 then
            return nil, "OpenClipboard failed"
        end

        local ClipboardData = ffi.C.GetClipboardData(CF_UNICODETEXT)
        
        if ClipboardData == nil then
            ffi.C.CloseClipboard()
            return nil, "GetClipboardData failed"
        end

        local LockedData = ffi.C.GlobalLock(ClipboardData)
        
        if LockedData == nil then
            ffi.C.CloseClipboard()
            return nil, "GlobalLock failed"
        end

        local DataSize = tonumber(ffi.C.GlobalSize(ClipboardData)) or 0
        local MaxChars = math.floor(DataSize / 2)
        
        local StringData = ffi.cast("const uint16_t*", LockedData)
        local StringLength = 0
        
        for i = 0, MaxChars - 1 do
            if StringData[i] == 0 then
                StringLength = i
                break
            end
        end
        
        if StringLength == 0 and MaxChars > 0 then
            StringLength = MaxChars
        end

        local UTF8Length = ffi.C.WideCharToMultiByte(CP_UTF8, 0, LockedData, StringLength, nil, 0, nil, nil)
        
        if UTF8Length == 0 then
            ffi.C.GlobalUnlock(ClipboardData)
            ffi.C.CloseClipboard()
            return nil, "WideCharToMultiByte failed"
        end

        local UTF8Buffer = ffi.new("char[?]", UTF8Length + 1)
        local ConvertedLength = ffi.C.WideCharToMultiByte(CP_UTF8, 0, LockedData, StringLength, UTF8Buffer, UTF8Length, nil, nil)
        
        ffi.C.GlobalUnlock(ClipboardData)
        ffi.C.CloseClipboard()
        
        if ConvertedLength == 0 then
            return nil, "WideCharToMultiByte convert failed"
        end

        return ffi.string(UTF8Buffer, ConvertedLength)
    end

    return clipboard

end

libraries["library.system.detour"] = function()
    require("library.system.memory")

    local Detour = {}
    local Hooks = {}

    local DetourMt = {}
    DetourMt.__index = DetourMt

    function DetourMt:Apply()
        if self.active then return true end
        if not MemWrite(self.target, self.patch, self.size) then return false end

        self.active = true

        return true
    end

    function DetourMt:Restore()
        if not self.active then return true end
        if not MemWrite(self.target, self.backup, self.size) then return false end

        self.active = false

        return true
    end

    function DetourMt:Remove()
        self:Restore()

        for i = #Hooks, 1, -1 do
            if Hooks[i] == self then
                table.remove(Hooks, i)
                break
            end
        end
    end

    function Detour.Create(target, destination, size)
        size = size or 14
        assert(size >= 14, "[Detour] Detour size must be at least 14 bytes")

        local t_addr = ffi.cast("uint8_t*", target)
        local d_addr = ffi.cast("uintptr_t", destination)
        local backup = MemRead(t_addr, size)
        local patch = ffi.new("uint8_t[?]", size)

        for i = 0, size - 1 do
            patch[i] = 0x90
        end

        patch[0] = 0xFF
        patch[1] = 0x25
        patch[2] = 0x00
        patch[3] = 0x00
        patch[4] = 0x00
        patch[5] = 0x00
        ffi.cast("uintptr_t*", patch + 6)[0] = d_addr

        local instance = setmetatable({
            target = t_addr,
            destination = d_addr,
            size = size,
            backup = backup,
            patch = patch,
            active = false
        }, DetourMt)

        table.insert(Hooks, instance)
        return instance
    end

    function Detour.RestoreAll()
        for i = #Hooks, 1, -1 do
            Hooks[i]:Restore()
        end
    end

    register_callback("unload", function()
        Detour.RestoreAll()
    end)

    return Detour

end

libraries["library.system.hooks"] = function()
    local null_ptr = ffi.cast("void*", 0)
    local invalid_ptr = ffi.cast("void*", -1)
    local HookList = {}
    local ThreadList = {}

    local function CreateThreadObject(ThreadId)
        local ThreadHandle = ffi.C.OpenThread(2, 0, ThreadId)
        
        if ThreadHandle == null_ptr or ThreadHandle == invalid_ptr then return false end
        
        return setmetatable({
            handle = nil,
            Id = nil,
            isValid = true,
            isSuspended = false,
            Id = ThreadId,
            Handle = ThreadHandle
        }, {
            __index = {
                Suspend = function(ThreadObj)
                    if ThreadObj.isSuspended or not ThreadObj.isValid then return false end
                    
                    if ffi.C.SuspendThread(ThreadObj.Handle) ~= -1 then
                        ThreadObj.isSuspended = true
                        return true
                    end
                    
                    return false
                end,
                Resume = function(ThreadObj)
                    if not ThreadObj.isSuspended or not ThreadObj.isValid then return false end
                    
                    if ffi.C.ResumeThread(ThreadObj.Handle) ~= -1 then
                        ThreadObj.isSuspended = false
                        return true
                    end
                    
                    return false
                end,
                Close = function(ThreadObj)
                    if not ThreadObj.isValid then return end
                    
                    ThreadObj:Resume()
                    ThreadObj.isValid = false
                    ffi.C.CloseHandle(ThreadObj.Handle)
                end
            }
        })
    end

    local function SuspendAllThreads()
        ThreadList = {}
        
        local Snapshot = ffi.C.CreateToolhelp32Snapshot(4, 0)
        if Snapshot == invalid_ptr then return false end
        
        local ThreadEntry = ffi.new("struct Thread32Entry[1]")
        ThreadEntry[0].dwSize = ffi.sizeof("struct Thread32Entry")
        
        if ffi.C.Thread32First(Snapshot, ThreadEntry) == 0 then
            ffi.C.CloseHandle(Snapshot)
            return false
        end
        
        local CurrentThreadId = ffi.C.GetCurrentThreadId()
        local CurrentProcessId = ffi.C.GetCurrentProcessId()
        
        while ffi.C.Thread32Next(Snapshot, ThreadEntry) > 0 do
            if ThreadEntry[0].dwSize >= 20 and ThreadEntry[0].th32OwnerProcessID == CurrentProcessId and ThreadEntry[0].th32ThreadID ~= CurrentThreadId then
                local ThreadObj = CreateThreadObject(ThreadEntry[0].th32ThreadID)
                
                if not ThreadObj then
                    for _, Thread in pairs(ThreadList) do
                        Thread:Close()
                    end
                    
                    ThreadList = {}
                    ffi.C.CloseHandle(Snapshot)
                    return false
                end
                
                table.insert(ThreadList, ThreadObj)
            end
        end
        
        ffi.C.CloseHandle(Snapshot)
        return true
    end

    local function SuspendThread()
        if not SuspendAllThreads() then return false end
        
        for _, ThreadObj in pairs(ThreadList) do
            ThreadObj:Suspend()
        end
        
        return true
    end

    local function ResumeThreads()
        for _, ThreadObj in pairs(ThreadList) do
            ThreadObj:Resume()
            ThreadObj:Close()
        end
    end

    local function CreateHook(Target, DetourFunc, ReturnType)
        assert(type(DetourFunc) == "function", "[Hooks] Error: Invalid Detour Function")
        assert(type(Target) == "cdata" or type(Target) == "userdata" or type(Target) == "number" or type(Target) == "function", "[Hooks] Error: Invalid Target Function")
        
        if not SuspendThread() then
            ResumeThreads()
            print("create_hook: failed suspend threads")
            return false
        end
        
        local BackupBytes = ffi.new("uint8_t[14]")
        local TargetPtr = ffi.cast(ReturnType, Target)
        local HookBytes = ffi.new("uint8_t[14]", {255, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        
        local HookObj = {
            ProcessHandle = nil,
            OldProtect = nil,
            isValid = true,
            BackupData = nil,
            isAttached = false,
            TargetAddr = nil,
            BackupData = BackupBytes,
            TargetAddr = TargetPtr,
            OldProtect = ffi.new("uint32_t[1]"),
            ProcessHandle = ffi.C.GetCurrentProcess()
        }
        
        ffi.copy(BackupBytes, TargetPtr, ffi.sizeof(BackupBytes))
        
        ffi.cast("uintptr_t*", HookBytes + 6)[0] = ffi.cast("uintptr_t", ffi.cast(ReturnType, function(...)
            local success, result = pcall(DetourFunc, HookObj, ...)
            
            if not success then
                HookObj:Remove()
                print(("[hooks]: unexception runtime error -> %s"):format(result))
                return TargetPtr(...)
            end
            
            return result
        end))
        
        HookObj.__index = setmetatable(HookObj, {
            __call = function(HookObj, ...)
                if not HookObj.isValid then
                    return nil
                end
                
                HookObj:Detach()
                
                local success, result = pcall(HookObj.TargetAddr, ...)
                
                if not success then
                    HookObj.isValid = false
                    print(("[Hooks]: Error -> %s"):format(result))
                    return nil
                end
                
                HookObj:Attach()
                return result
            end,
            __index = {
                Attach = function(HookObj)
                    if HookObj.isAttached or not HookObj.isValid then return false end
                    
                    HookObj.isAttached = true
                    ffi.C.VirtualProtect(HookObj.TargetAddr, ffi.sizeof(BackupBytes), 64, HookObj.OldProtect)
                    ffi.copy(HookObj.TargetAddr, HookBytes, ffi.sizeof(BackupBytes))
                    ffi.C.VirtualProtect(HookObj.TargetAddr, ffi.sizeof(BackupBytes), HookObj.OldProtect[0], HookObj.OldProtect)
                    return true
                end,
                Detach = function(HookObj)
                    if not HookObj.isAttached or not HookObj.isValid then
                        return false
                    end
                    
                    HookObj.isAttached = false
                    ffi.C.VirtualProtect(HookObj.TargetAddr, ffi.sizeof(BackupBytes), 64, HookObj.OldProtect)
                    ffi.copy(HookObj.TargetAddr, HookObj.BackupData, ffi.sizeof(BackupBytes))
                    ffi.C.VirtualProtect(HookObj.TargetAddr, ffi.sizeof(BackupBytes), HookObj.OldProtect[0], HookObj.OldProtect)
                    return true
                end,
                Remove = function(HookObj)
                    if not HookObj.isValid then
                        return false
                    end
                    
                    SuspendThread()
                    HookObj:Detach()
                    ResumeThreads()
                    HookObj.isValid = false
                end
            }
        })
        
        HookObj:Attach()
        table.insert(HookList, HookObj)
        ResumeThreads()
        
        return HookObj
    end

    register_callback("unload", function()
        for _, Hook in pairs(HookList) do
            Hook:Remove()
        end
    end)

    local Hooks = {
        CreateHook = CreateHook,
        SuspendThread = SuspendThread,
        ResumeThreads = ResumeThreads,
    }

    return Hooks

end

libraries["library.system.memory"] = function()
    function Absolute(Address, Offset, ExtraOffset)
        Address = ffi.cast("uintptr_t", Address)
        Address = Address + (Offset or 1)
        Address = Address + ffi.cast("int32_t*", Address)[0] + ffi.sizeof("int32_t")
        Address = Address + (ExtraOffset or 0)

        return Address
    end

    function Relative(Address, Offset, ExtraOffset)
        Address = ffi.cast("uint8_t*", Address)
        Offset = Offset or 0
        ExtraOffset = ExtraOffset or 0
        
        local BasePtr = Address + Offset
        local Rel = ffi.cast("int32_t*", BasePtr)[0]
        local Result = BasePtr + 4 + Rel + ExtraOffset

        return Result
    end

    function FindExport(Module, Export, ErrorName)
        local ExportAddr = assert(find_export(Module, Export), ErrorName .. " Outdated")
        if not ExportAddr then return nil end
        
        return ExportAddr
    end

    function FindPattern(PatternModule, Pattern, ErrorName)
        local PatternAddr = assert(find_pattern(PatternModule, Pattern), ErrorName .. " Outdated")
        if not PatternAddr then return nil end

        if ffi.cast("void*", PatternAddr) == ffi.cast("void*", 0) then return nil end

        local Result = ffi.cast("uintptr_t", PatternAddr)
        if not Result then return nil end
        
        return Result
    end

    function FindAbsolute(Module, Pattern, ErrorName, Offset, ExtraOffset)
        local Addr = FindPattern(Module, Pattern, ErrorName)
        if not Addr then return nil end

        Offset = Offset or 1
        ExtraOffset = ExtraOffset or 0
        
        local Result = Addr + Offset
        Result = Result + ffi.cast("int32_t*", Result)[0] + ffi.sizeof("int32_t")
        Result = Result + ExtraOffset
        if not Result then return nil end

        return Result
    end

    function FindRelative(Module, Pattern, ErrorName, Offset, ExtraOffset)
        local Addr = FindPattern(Module, Pattern, ErrorName)
        if not Addr then return nil end
        
        Offset = Offset or 0
        ExtraOffset = ExtraOffset or 0
        
        local BasePtr = ffi.cast("uint8_t*", Addr) + Offset
        local Relative = ffi.cast("int32_t*", BasePtr)[0]
        local Result = BasePtr + 4 + Relative + ExtraOffset
        if not Result then return nil end
        
        return Result
    end

    function GetVFunc(Object, Index)
        if not Object then return nil end

        local VtablePTR = ffi.cast("void***", Object)[0]
        if not VtablePTR then return nil end

        local Result = VtablePTR[Index]
        if not Result then return nil end

        return Result
    end

    function CallVFunc(Object, Signature, Index, ...)
        local Function = GetVFunc(Object, Index)
        if not Function then return nil end

        local FunctionPTR = ffi.cast(Signature, Function)
        if not FunctionPTR then return nil end

        return FunctionPTR(Object, ...)
    end

    function CallVFunc(Object, Signature, Index, ...)
        local Function = GetVFunc(Object, Index)
        if not Function then return nil end

        local FunctionPTR = ffi.cast(Signature, Function)
        if not FunctionPTR then return nil end

        return FunctionPTR(Object, ...)
    end

    function CallVFunc2(Object, Index, ...)
        local Function = GetVFunc(Object, Index)
        if not Function then return nil end

        return ffi.cast("void*(__thiscall*)(void*, ...)", Function)(Object, ...)
    end

    function MemProtect(Address, Size, NewProtect)
        local Addr = ffi.cast("void*", Address)
        local prev = ffi.new("uint32_t[1]")

        if ffi.C.VirtualProtect(Addr, Size, NewProtect, prev) ~= 0 then
            return prev[0] > 0 and prev[0] or 0x20
        end

        return nil
    end

    function MemWrite(Address, Data, Size)
        local Addr = ffi.cast("uint8_t*", Address)
        local len = Size
        local src = Data

        if type(Data) == "table" then
            len = len or #Data
            src = ffi.new("uint8_t[?]", len, Data)
        elseif type(Data) == "string" then
            len = len or #Data
        elseif type(Data) == "cdata" and not len then
            len = ffi.sizeof(Data)
        end

        local prev = MemProtect(Addr, len, 0x40)
        if not prev then return false end

        ffi.copy(Addr, src, len)
        MemProtect(Addr, len, prev)

        return true
    end

    function MemRead(Address, Size)
        local Addr = ffi.cast("uint8_t*", Address)
        local buf = ffi.new("uint8_t[?]", Size)
        ffi.copy(buf, Addr, Size)
        return buf
    end

    function MemAlloc(Size, Protect, AllocType)
        local ptr = ffi.C.VirtualAlloc(nil, Size, AllocType or 0x3000, Protect or 0x40)
        if ptr == nil or ffi.cast("uintptr_t", ptr) == 0 then return nil end

        return ffi.cast("uint8_t*", ptr)
    end

    function MemFree(Address, Size, ft)
        if not Address or ffi.cast("uintptr_t", Address) == 0 then return false end

        return ffi.C.VirtualFree(ffi.cast("void*", Address), Size or 0, ft or 0x8000)
    end

    function MemRip(Address, Offset, InstSize)
        local Addr = ffi.cast("uint8_t*", Address)
        local Rel = ffi.cast("int32_t*", Addr + (Offset or 1))[0]
        return Addr + (InstSize or 5) + Rel
    end

end

libraries["library.render.render"] = function()
    require("library.render.color")

    function render.ShadowText(text, font, pos, color, color2)
        if not text or not font or not pos or not color or not color2 then return end

        render.Text(text, font, vec2_t(pos.x + 1.5, pos.y + 1.5), color2)
        render.Text(text, font, pos, color)
    end

    local GradientOutlineText = {}
    function render.GradientOutlineText(text, font, pos, mainColor, color1, color2, thickness, speed)
        thickness = thickness or 1
        speed = speed or 1.0
        
        local id = tostring(font) .. "_" .. text .. "_" .. tostring(pos.x) .. "_" .. tostring(pos.y)
        
        if not GradientOutlineText[id] then
            GradientOutlineText[id] = {
                angle = 0,
                speed = speed
            }
        end
        
        local anim = GradientOutlineText[id]
        anim.angle = anim.angle + (1/60) * anim.speed
        if anim.angle > 1 then
            anim.angle = anim.angle - 1
        end
        
        local points = {}
        for step = 0, 63 do 
            local angle = (step / 64) * math.pi * 2
            local dx = math.cos(angle) * thickness
            local dy = math.sin(angle) * thickness
            
            local progress = (angle / (math.pi * 2) + anim.angle)
            progress = progress - math.floor(progress) 
            
            local r = color1.r + (color2.r - color1.r) * progress
            local g = color1.g + (color2.g - color1.g) * progress
            local b = color1.b + (color2.b - color1.b) * progress
            local a = color1.a + (color2.a - color1.a) * progress
            
            render.text(text, font, vec2_t(pos.x + dx, pos.y + dy), color_t(r, g, b, a))
        end
        
        render.text(text, font, pos, mainColor)
    end

    local GradientTextTimer = 0
    local CharWidthCache = {}
    function render.GradientText(Text, Font, Pos, Color1, Color2, AlphaMult, Speed)
        GradientTextTimer = GradientTextTimer + render.frame_time()
        
        local Offset = 0
        local Len = #Text
        local CacheKey = Font and tostring(Font)
        
        for i = 1, Len do
            local Char = Text:sub(i, i)
            local Wave = (math.sin(GradientTextTimer * Speed + (i * 0.3)) + 1) / 2
            local Color = LerpColor(Color1, Color2, Wave)
            Color = color_t(Color.r, Color.g, Color.b, Color.a * AlphaMult)
            render.text(Char, Font, vec2_t(Pos.x + Offset, Pos.y), Color)
            
            local CharKey = CacheKey .. Char
            if not CharWidthCache[CharKey] then
                CharWidthCache[CharKey] = render.calc_text_size(Char, Font).x
            end
            Offset = Offset + CharWidthCache[CharKey]
        end
    end

    function render.Bone(StartPos, EndPos, Color)
        if not StartPos or not EndPos or not Color then return end

        render.line(StartPos, EndPos, Color, 1)
    end

    function render.RectGlow(Pos, Size, Rounding, Thickness, GlowSize, Color, GlowAlpha, Alpha)
        local FinalColor = color_t(Color.r, Color.g, Color.b, Color.a * (Alpha or 1))
        if FinalColor.a <= 0 then return end
        
        for i = GlowSize, 1, -1 do
            local Fade = (1 - (i / GlowSize)) ^ 1.5
            local GlowValue = GlowAlpha * Fade * FinalColor.a
            if GlowValue > 0 then
                local offset = i
                render.rect(vec2_t(Pos.x - offset, Pos.y - offset), vec2_t(Pos.x + Size.x + offset, Pos.y + Size.y + offset), color_t(FinalColor.r, FinalColor.g, FinalColor.b, GlowValue), Rounding, Thickness)
            end
        end
    end

    function render.CircleGlow(Pos, Radius, Thickness, GlowSize, Color, GlowAlpha, Alpha)
        local FinalColor = color_t(Color.r, Color.g, Color.b, Color.a * (Alpha or 1))
        if FinalColor.a <= 0 then return end
        
        local Segments = math.max(32, Radius * 2)
        
        for i = GlowSize, 1, -1 do
            local Fade = (1 - (i / GlowSize)) ^ 1.5
            local GlowValue = GlowAlpha * Fade * FinalColor.a
            if GlowValue > 0 then
                render.circle(Pos, Radius + i, Segments, color_t(FinalColor.r, FinalColor.g, FinalColor.b, GlowValue), Thickness)
            end
        end
    end

    function render.TextGlow(Text, Font, Pos, GlowSize, Color, GlowAlpha, Alpha)
        local FinalColor = color_t(Color.r, Color.g, Color.b, Color.a * (Alpha or 1))
        if FinalColor.a <= 0 then return end
        
        for i = GlowSize, 1, -1 do
            local Fade = (1 - (i / GlowSize)) ^ 1.5
            local GlowValue = GlowAlpha * Fade * FinalColor.a
            if GlowValue > 0 then
                local GlowColor = color_t(FinalColor.r, FinalColor.g, FinalColor.b, GlowValue)
                for _, Offset in ipairs({{-1, 0}, {1, 0}, {0, -1}, {0, 1}}) do
                    render.text(Text, Font, vec2_t(Pos.x + Offset[1] * i, Pos.y + Offset[2] * i), GlowColor)
                end
            end
        end
        
        render.text(Text, Font, Pos, FinalColor)
    end

    function render.SegmentedLine(world_start, world_end, color, glow_color, size, segment_length)
        local direction = vec3_t(
            world_end.x - world_start.x,
            world_end.y - world_start.y,
            world_end.z - world_start.z
        )
        local total_length = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)
        if total_length <= 0 then return end
        
        direction.x = direction.x / total_length
        direction.y = direction.y / total_length
        direction.z = direction.z / total_length
        
        local num_segments = math.ceil(total_length / segment_length)
        local actual_segment_length = total_length / num_segments
        
        for i = 0, num_segments - 1 do
            local seg_start = vec3_t(
                world_start.x + direction.x * (i * actual_segment_length),
                world_start.y + direction.y * (i * actual_segment_length),
                world_start.z + direction.z * (i * actual_segment_length)
            )
            local seg_end = vec3_t(
                world_start.x + direction.x * ((i + 1) * actual_segment_length),
                world_start.y + direction.y * ((i + 1) * actual_segment_length),
                world_start.z + direction.z * ((i + 1) * actual_segment_length)
            )
            
            local screen_start = render.world_to_screen(seg_start)
            local screen_end = render.world_to_screen(seg_end)
            
            if screen_start and screen_end then
                render.line(screen_start, screen_end, color, size)
                
                if glow_color then
                    render.line(screen_start + vec2_t(1, 1), screen_end + vec2_t(1, 1), color_t(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.3), size)
                    render.line(screen_start + vec2_t(-1, -1), screen_end + vec2_t(-1, -1), color_t(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.3), size)
                end
            end
        end
    end

end

libraries["library.render.color"] = function()
    function string.rgba(hex)
        hex = hex:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        local a = (tonumber(hex:sub(7, 8), 16) or 255) / 255
        return r, g, b, a
    end

    function color_t.unpack(color_t)
        return color_t.r, color_t.g, color_t.b, color_t.a
    end

    function color_t.to_hex(color_t)
        return string.format("%02x%02x%02x%02x", color_t.r * 255, color_t.g * 255, color_t.b * 255, color_t.a * 255)
    end

    function get_gradient(color1, color2, progress)
        local r = color1.r + (color2.r - color1.r) * progress
        local g = color1.g + (color2.g - color1.g) * progress
        local b = color1.b + (color2.b - color1.b) * progress
        local a = color1.a + (color2.a - color1.a) * progress
        return color_t(r, g, b, a)
    end

    function color_t.hsv_to_rgb(color_t)
        local i = math.floor(color_t * 6)
        local f = color_t * 6 - i
        local p = 0
        local q = 1 - f
        local t = f
        
        i = i % 6
        if i == 0 then return 1, t, p
        elseif i == 1 then return q, 1, p
        elseif i == 2 then return p, 1, t
        elseif i == 3 then return p, q, 1
        elseif i == 4 then return t, p, 1
        else return 1, p, q end
    end

    function rgb_to_hsv(color_t)
        local r, g, b = color_t.r, color_t.g, color_t.b
        local max_val = math.max(r, g, b)
        local min_val = math.min(r, g, b)
        local delta = max_val - min_val
        local h = 0
        
        if delta ~= 0 then
            if max_val == r then
                h = (g - b) / delta % 6
            elseif max_val == g then
                h = (b - r) / delta + 2
            else
                h = (r - g) / delta + 4
            end
            h = h / 6
        end
        
        local s = (max_val == 0) and 0 or (delta / max_val)
        local v = max_val
        
        return h, s, v
    end

    function LerpColor(c1, c2, t)
        t = math.min(1, math.max(0, t))
        return color_t(
            c1.r + (c2.r - c1.r) * t,
            c1.g + (c2.g - c1.g) * t,
            c1.b + (c2.b - c1.b) * t,
            c1.a + (c2.a - c1.a) * t
        )
    end

    function ColorHTML(text, clr)
        return string.format('<font color="#%02X%02X%02X">%s</font>', 
            math.min(255, math.floor(clr.r * 255)),
            math.min(255, math.floor(clr.g * 255)),
            math.min(255, math.floor(clr.b * 255)),
            text
        )
    end

end

libraries["library.render.vector"] = function()
    local vector = getmetatable(vec2_t(0, 0))

    function vector.__lt(vector_a, vector_b)
        return vector_a.x < vector_b.x and vector_a.y < vector_b.y
    end

    function vector.__le(vector_a, vector_b)
        return vector_a.x <= vector_b.x and vector_a.y <= vector_b.y
    end

    function vec3_t.lerp(a, b, t)
        return vec3_t(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)
    end

    function vec3_t.angle_to(from_vector, to_vector)
        local direction_vector = to_vector - from_vector
        local direction_length = direction_vector:length()
        local pitch_deg = -math.deg(math.asin(direction_vector.z / direction_length))
        local clamped_pitch = clamp(pitch_deg, -89, 89)
        local yaw_deg = normalize_yaw(math.deg(math.atan2(direction_vector.y, direction_vector.x)))

        return angle_t(clamped_pitch, yaw_deg, 0)
    end

    return function(...)
        local vec_t = select("#", ...)

        if vec_t == 2 then
            return vec2_t(...)
        elseif vec_t == 3 then
            return vec3_t(...)
        elseif vec_t == 4 then
            return vec4_t(...)
        end
    end

end

libraries["library.render.gui"] = function()
    local input = require("library.system.input")
    local events = require("library.engine.events")
    local anim = require("library.render.animation")
    local fonts = require("library.core.initializate")
    local utils = require("library.core.utils")
    local clipboard = require("library.system.clipboard")

    local add_gear_button
    local active_gear_popup = nil
    local gear_blocking = false
    local last_mouse_left = false

    local gui = {}
    local all_windows = {}
    local dragging_window = nil
    local any_interactive_hovered = false
    local active_slider = nil
    local active_checkbox = nil
    local active_selectable = nil
    local hotkey_widgets = {}
    local pending_hotkey_popups = {}

    local accent_color = color_t(0.8, 0.8, 0.8, 1)

    function gui.accent_color(color)
        if color then accent_color = color return end 
        return accent_color
    end

    local function get_text_width(font, text)
        local size = render.calc_text_size(text, font)
        if size then return size.x end
        return #text * 8
    end

    local function get_slider_display_value(slider)
        local display_val = slider.value
        if slider.increment and slider.increment > 0 then
            local inv = 1 / slider.increment
            display_val = math.floor(display_val * inv + 0.5) / inv
        end
        if slider.custom_formats and slider.custom_formats[display_val] then
            return slider.custom_formats[display_val]
        end
        return string.format(slider.format, display_val)
    end

    local function is_blocked_by_gear_popup(element)
        if not active_gear_popup or not active_gear_popup.gear_opened then return false end
        if element and element.parent == active_gear_popup.gear_group then return false end
        return true
    end

    local function force_close_gear_popup()
        if active_gear_popup then
            if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
            active_gear_popup.gear_opened = false
            active_gear_popup.gear_progress = 0
            active_gear_popup = nil
            gear_blocking = false
        end
    end

    function GetKeyName(key_code)
        local key_names = {
            [0x01] = "LMB", [0x02] = "RMB", [0x04] = "MMB",
            [0x08] = "Backspace", [0x09] = "Tab", [0x0D] = "Enter",
            [0x10] = "Shift", [0x11] = "Ctrl", [0x12] = "Alt",
            [0x1B] = "Esc", [0x20] = "Space", [0x21] = "PgUp",
            [0x22] = "PgDn", [0x23] = "End", [0x24] = "Home",
            [0x25] = "Left", [0x26] = "Up", [0x27] = "Right",
            [0x28] = "Down", [0x2D] = "Ins", [0x2E] = "Del",
            [0x30] = "0", [0x31] = "1", [0x32] = "2", [0x33] = "3",
            [0x34] = "4", [0x35] = "5", [0x36] = "6", [0x37] = "7",
            [0x38] = "8", [0x39] = "9",
            [0x41] = "A", [0x42] = "B", [0x43] = "C", [0x44] = "D",
            [0x45] = "E", [0x46] = "F", [0x47] = "G", [0x48] = "H",
            [0x49] = "I", [0x4A] = "J", [0x4B] = "K", [0x4C] = "L",
            [0x4D] = "M", [0x4E] = "N", [0x4F] = "O", [0x50] = "P",
            [0x51] = "Q", [0x52] = "R", [0x53] = "S", [0x54] = "T",
            [0x55] = "U", [0x56] = "V", [0x57] = "W", [0x58] = "X",
            [0x59] = "Y", [0x5A] = "Z",
            [0x60] = "N0", [0x61] = "N1", [0x62] = "N2", [0x63] = "N3",
            [0x64] = "N4", [0x65] = "N5", [0x66] = "N6", [0x67] = "N7",
            [0x68] = "N8", [0x69] = "N9",
            [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
            [0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
            [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
            [0x90] = "NumLk", [0x91] = "ScrlLk"
        }
        return key_names[key_code] or tostring(key_code)
    end

    local function update_all_hotkeys()
        for i = #hotkey_widgets, 1, -1 do
            local hotkey = hotkey_widgets[i]
            if not hotkey then
                table.remove(hotkey_widgets, i)
                goto continue
            end
            
            local key = hotkey.key or 0
            local old_active = hotkey.active
            
            if hotkey.mode == 1 then
                hotkey.active = true
            elseif hotkey.mode == 2 then
                if key ~= 0 then
                    hotkey.active = input.IsKeyPressed(key)
                else
                    hotkey.active = false
                end
            elseif hotkey.mode == 3 then
                if key ~= 0 then
                    if input.IsKeyClicked(key) then
                        hotkey.toggle_state = not hotkey.toggle_state
                        hotkey.active = hotkey.toggle_state
                    end
                else
                    hotkey.active = false
                end
            end
            
            if hotkey.callback and old_active ~= hotkey.active then
                hotkey.callback(hotkey.active, hotkey)
            end
            
            ::continue::
        end
    end

    local function is_hovering(rect, mouse_pos)
        return mouse_pos.x >= rect.x and mouse_pos.x <= rect.x + rect.w and
                mouse_pos.y >= rect.y and mouse_pos.y <= rect.y + rect.h
    end

    local function get_checkbox_bounds(checkbox, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        local text_width = get_text_width(fonts.StandartFont, checkbox.label)
        return {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + checkbox.y,
                w = text_width,
                h = checkbox.height
            },
            toggle = {
                x = parent_pos.x + parent_size_x - parent_right_padding - checkbox.width,
                y = parent_pos.y + checkbox.y + (checkbox.height - checkbox.toggle_height) / 2 + 2,
                w = checkbox.width,
                h = checkbox.toggle_height
            }
        }
    end

    local function get_slider_bounds(slider, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        local text_width = get_text_width(fonts.StandartFont, slider.label)
        local val_text = get_slider_display_value(slider)
        local val_width = get_text_width(fonts.StandartFont, val_text)
        local val_x = parent_pos.x + parent_size_x - parent_right_padding - slider.slider_width - val_width - 8
        local slider_x = val_x + val_width + 8
        local slider_end_x = parent_pos.x + parent_size_x - parent_right_padding
        
        return {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + slider.y,
                w = text_width,
                h = slider.height
            },
            val_x = val_x,
            slider_x = slider_x,
            slider_end_x = slider_end_x,
            slider_zone = {
                x = slider_x,
                y = parent_pos.y + slider.y + (slider.height - 10) / 2 + 2 - 10,
                w = slider_end_x - slider_x,
                h = 30
            }
        }
    end

    local function get_selectable_bounds(selectable, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        local text_width = get_text_width(fonts.StandartFont, selectable.label)
        return {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + selectable.y,
                w = text_width,
                h = selectable.height
            },
            button = {
                x = parent_pos.x + parent_size_x - parent_right_padding - selectable.button_width,
                y = parent_pos.y + selectable.y + (selectable.height - 20) / 2,
                w = selectable.button_width,
                h = 20
            }
        }
    end

    local function get_dropdown_bounds(sel, button_x, button_y)
        local max_item_width = 0
        for _, item in ipairs(sel.items) do
            local item_width = get_text_width(fonts.StandartFont, item)
            if item_width > max_item_width then
                max_item_width = item_width
            end
        end
        local dropdown_width = max_item_width + 30
        local dropdown_x = button_x
        local dropdown_y = button_y + 22
        local items_height = #sel.items * 22
        local max_height = 1000 
        
        return {
            x = dropdown_x,
            y = dropdown_y,
            w = dropdown_width,
            h = math.min(items_height, max_height),
            button_x = button_x,
            button_y = button_y,
            button_w = sel.button_width,
            button_h = 20
        }
    end

    local function get_hotkey_bounds(hotkey, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        local text_width = get_text_width(fonts.StandartFont, hotkey.label)
        local hotkey_width = hotkey.current_button_width or 50
        return {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + hotkey.y,
                w = text_width,
                h = hotkey.height
            },
            button = {
                x = parent_pos.x + parent_size_x - parent_right_padding - hotkey_width,
                y = parent_pos.y + hotkey.y + (hotkey.height - 22) / 2 + 1,  
                w = hotkey_width,
                h = 22  
            }
        }
    end

    local function get_key_popup_bounds(hotkey, button_bounds)
        local popup_width = 120
        local popup_height = 40
        local popup_x = button_bounds.x + button_bounds.w + 5
        local popup_y = button_bounds.y
        
        local screen_size = render.screen_size()
        if popup_x + popup_width > screen_size.x - 10 then
            popup_x = button_bounds.x - popup_width - 5
        end
        
        return {
            x = popup_x,
            y = popup_y,
            w = popup_width,
            h = popup_height
        }
    end

    local function get_mode_popup_bounds(hotkey, button_bounds)
        local mode_names = hotkey.mode_names or {"Always", "Hold", "Toggle"}
        local max_width = 0
        for _, name in ipairs(mode_names) do
            local w = get_text_width(fonts.StandartFont, name)
            if w > max_width then max_width = w end
        end
        local popup_width = max_width + 30
        local popup_x = button_bounds.x + button_bounds.w + 5
        local popup_y = button_bounds.y
        
        local screen_size = render.screen_size()
        if popup_x + popup_width > screen_size.x - 10 then
            popup_x = button_bounds.x - popup_width - 5
        end
        
        if popup_y + #mode_names * 24 > screen_size.y - 10 then
            popup_y = screen_size.y - #mode_names * 24 - 10
        end
        
        return {
            x = popup_x,
            y = popup_y,
            w = popup_width,
            h = #mode_names * 24,
            mode_names = mode_names
        }
    end

    local function get_color_picker_bounds(picker, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        local text_width = get_text_width(fonts.StandartFont, picker.label)
        return {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + picker.y,
                w = text_width,
                h = picker.height
            }
        }
    end

    local function is_input_blocked()
        if active_selectable ~= nil and active_selectable.opened then
            return true
        end
        
        for _, hotkey in ipairs(hotkey_widgets) do
            if hotkey.mode_popup_opened then
                return true
            end
        end
        
        return false
    end

    local function is_position_blocked_by_pinned_window(pos_x, pos_y, exclude_window)
        for _, win in ipairs(all_windows) do
            if win ~= exclude_window and win.is_pinned and win.is_open and win.window_fade_progress > 0.5 then
                if pos_x >= win.pos.x and pos_x <= win.pos.x + win.size.x and 
                    pos_y >= win.pos.y and pos_y <= win.pos.y + win.size.y then 
                    return true, win 
                end
            end
        end
        return false, nil
    end

    local function is_gear_blocked_by_pinned_window(gear_popup)
        if not gear_popup or not gear_popup.gear_popup_bounds then return false end
        
        local bounds = gear_popup.gear_popup_bounds
        for _, win in ipairs(all_windows) do
            if win.is_pinned and win.is_open and win.window_fade_progress > 0.5 then
                if not (bounds.x + bounds.w <= win.pos.x or bounds.x >= win.pos.x + win.size.x or 
                        bounds.y + bounds.h <= win.pos.y or bounds.y >= win.pos.y + win.size.y) then 
                    return true, win 
                end
            end
        end
        return false, nil
    end

    local function close_selectable_on_outside_click(mouse_pos, mouse_clicked, current_sel, button_x, button_y)
        if not mouse_clicked then return false end
        
        local bounds = get_dropdown_bounds(current_sel, button_x, button_y)
        local is_over_dropdown = is_hovering(bounds, mouse_pos)
        local is_over_button = is_hovering({x = bounds.button_x, y = bounds.button_y, w = bounds.button_w, h = bounds.button_h}, mouse_pos)
        
        if not is_over_dropdown and not is_over_button then
            if active_gear_popup and active_gear_popup.gear_opened then
                if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
                active_gear_popup.gear_opened = false
                active_gear_popup = nil
                gear_blocking = false
            end
            
            if current_sel.opened then
                if current_sel.dropdown_anim then current_sel.dropdown_anim:stop() end
                current_sel.dropdown_anim = anim.animate_to(current_sel, "dropdown_height_progress", current_sel.dropdown_height_progress or 1, 0, 0.2, "cubic_out")
                current_sel.dropdown_anim.on_complete = function()
                    current_sel.opened = false
                    if active_selectable == current_sel then
                        active_selectable = nil
                    end
                end
                current_sel.dropdown_anim:start()
            end

            for _, win in ipairs(all_windows) do
                for _, group in ipairs(win.groups or {}) do
                    for _, sel in ipairs(group.selectables or {}) do
                        sel.click_processed = false
                    end
                    for _, cp in ipairs(group.color_pickers or {}) do
                        if cp.opened then
                            if cp.dropdown_anim then cp.dropdown_anim:stop() end
                            cp.opened = false
                            cp.dropdown_height_progress = 0
                        end
                    end
                end
            end
            
            if active_selectable and active_selectable.type == "color_picker" then
                active_selectable = nil
            end

            return true
        end
        return false
    end

    local function get_element_value(element, index)
        if element.type == "checkbox" then
            return element.value
        elseif element.type == "slider" then
            return element.value
        elseif element.type == "selectable" then
            if element.multi then
                if index then
                    return element.selected[index] or false
                else
                    local result = {}
                    for i = 1, #element.items do
                        result[i] = element.selected[i] or false
                    end
                    return result
                end
            else
                if index then
                    return element.selected[index] or false
                else
                    for i = 1, #element.items do
                        if element.selected[i] then
                            return i
                        end
                    end
                    return 1 
                end
            end
        else
            return nil
        end
    end

    local function update_checkbox(cb, mouse_pos, mouse_left, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not cb.visible then return end
        if cb.disabled then 
            cb.text_hovered = false
            cb.hovered = false
            return 
        end
        if is_blocked_by_gear_popup(cb) then return end
        local bounds = get_checkbox_bounds(cb, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        
        cb.text_hovered = is_hovering(bounds.text, mouse_pos)
        cb.hovered = cb.text_hovered or is_hovering(bounds.toggle, mouse_pos)
        
        if cb.hovered then any_interactive_hovered = true end
        if can_interact and cb.hovered and mouse_left and not active_slider and not active_checkbox and not is_input_blocked() then active_checkbox = cb end
    end

    local function update_slider(sl, mouse_pos, mouse_left, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not sl.visible then return end
        if is_blocked_by_gear_popup(sl) then return end
        
        local is_in_gear_popup = false
        local gear_popup_parent = nil
        if sl.parent and sl.parent.parent then
            local current = sl.parent
            while current do
                if current.gear_opened ~= nil then
                    is_in_gear_popup = true
                    gear_popup_parent = current
                    break
                end
                current = current.parent
            end
        end
        
        local bounds = get_slider_bounds(sl, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        
        sl.text_hovered = is_hovering(bounds.text, mouse_pos)
        local slider_hover = is_hovering(bounds.slider_zone, mouse_pos)
        
        if slider_hover then
            any_interactive_hovered = true
        end
        
        sl.hovered = sl.text_hovered or slider_hover
        
        if can_interact and slider_hover and not sl.dragging and mouse_left and not active_slider and not active_checkbox and not is_input_blocked() then
            sl.dragging = true
            active_slider = sl
            local t = (math.max(bounds.slider_x, math.min(bounds.slider_end_x, mouse_pos.x)) - bounds.slider_x) / (bounds.slider_end_x - bounds.slider_x)
            local new_val = sl.min + t * (sl.max - sl.min)
            if sl.increment and sl.increment > 0 then
                local inv = 1 / sl.increment
                new_val = math.floor(new_val * inv + 0.5) / inv
            end
            new_val = math.max(sl.min, math.min(sl.max, new_val))
            
            if sl.value_anim then sl.value_anim:stop() end
            local start_value = sl.value
            sl.target_value = new_val
            sl.animating = true
            sl.value_anim = anim.animate_to(sl, "value", start_value, new_val, 0.15, "cubic_out")
            sl.value_anim.on_complete = function() sl.animating = false end
            sl.value_anim:start()
        end
        
        if sl.dragging then
            local t = (math.max(bounds.slider_x, math.min(bounds.slider_end_x, mouse_pos.x)) - bounds.slider_x) / (bounds.slider_end_x - bounds.slider_x)
            local new_val = sl.min + t * (sl.max - sl.min)
            if sl.increment and sl.increment > 0 then
                local inv = 1 / sl.increment
                new_val = math.floor(new_val * inv + 0.5) / inv
            end
            new_val = math.max(sl.min, math.min(sl.max, new_val))
            if new_val ~= sl.target_value then
                if sl.value_anim then sl.value_anim:stop() end
                local start_value = sl.value
                sl.target_value = new_val
                sl.animating = true
                sl.value_anim = anim.animate_to(sl, "value", start_value, new_val, 0.15, "cubic_out")
                sl.value_anim.on_complete = function() sl.animating = false end
                sl.value_anim:start()
            end
            
            if not mouse_left then
                sl.dragging = false
                active_slider = nil
            end
        end
    end

    local function handle_dropdown_item_click(sel, item_index, mouse_left)
        if sel.multi then
            sel.selected[item_index] = not sel.selected[item_index]
            local selected_items = {}
            for j = 1, #sel.items do
                if sel.selected[j] then
                    table.insert(selected_items, sel.items[j])
                end
            end
            sel.value = selected_items
        else
            for j = 1, #sel.items do
                sel.selected[j] = (j == item_index)
            end
            sel.value = item_index 
        end
    end

    local function update_selectable(sel, mouse_pos, mouse_clicked, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not sel.visible then return end
        if is_blocked_by_gear_popup(sel) then return end
        local bounds = get_selectable_bounds(sel, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        
        sel.text_hovered = is_hovering(bounds.text, mouse_pos)
        local button_hover = is_hovering(bounds.button, mouse_pos)
        
        if button_hover then any_interactive_hovered = true end
        
        if sel.opened and mouse_clicked and not sel.click_processed then
            local over_gear_popup = false
            if active_gear_popup and active_gear_popup.gear_opened and active_gear_popup.gear_popup_bounds then
                over_gear_popup = is_hovering(active_gear_popup.gear_popup_bounds, mouse_pos)
            end
            
            local is_in_gear = false
            local current = sel
            while current do
                if current == active_gear_popup then is_in_gear = true break end
                current = current.parent
            end
            
            if not over_gear_popup and not is_in_gear then
                local closed = close_selectable_on_outside_click(mouse_pos, mouse_clicked, sel, bounds.button.x, bounds.button.y)
                if closed then sel.click_processed = true end
            elseif is_in_gear then
                local closed = close_selectable_on_outside_click(mouse_pos, mouse_clicked, sel, bounds.button.x, bounds.button.y)
                if closed then sel.click_processed = true end
            end
        end

        local can_interact_with_this = not is_input_blocked() or (sel == active_selectable)
        
        if can_interact_with_this and button_hover and mouse_clicked and not active_slider and not active_checkbox then
            if not sel.click_processed then
                sel.click_processed = true
                if sel.opened then
                    if sel.dropdown_anim then sel.dropdown_anim:stop() end
                    sel.dropdown_anim = anim.animate_to(sel, "dropdown_height_progress", sel.dropdown_height_progress or 1, 0, 0.2, "cubic_out")
                    sel.dropdown_anim.on_complete = function()
                        sel.opened = false
                        if sel == active_selectable then
                            active_selectable = nil
                        end
                    end
                    sel.dropdown_anim:start()
                else
                    for _, other_sel in ipairs(sel.parent.selectables) do
                        if other_sel ~= sel and other_sel.opened then
                            other_sel.opened = false
                            other_sel.dropdown_height_progress = 0
                            if other_sel.dropdown_anim then other_sel.dropdown_anim:stop() end
                        end
                    end
                    if sel.parent.parent and sel.parent.parent.selectables then
                        for _, other_sel in ipairs(sel.parent.parent.selectables) do
                            if other_sel ~= sel and other_sel.opened then
                                other_sel.opened = false
                                other_sel.dropdown_height_progress = 0
                                if other_sel.dropdown_anim then other_sel.dropdown_anim:stop() end
                            end
                        end
                    end
                    sel.opened = true
                    active_selectable = sel
                    if sel.dropdown_anim then sel.dropdown_anim:stop() end
                    sel.dropdown_height_progress = sel.dropdown_height_progress or 0
                    sel.dropdown_anim = anim.animate_to(sel, "dropdown_height_progress", sel.dropdown_height_progress, 1, 0.25, "cubic_out")
                    sel.dropdown_anim:start()
                end
            end
        elseif not mouse_clicked then
            sel.click_processed = false
        end
        
        if sel.opened and sel == active_selectable then
            local dropdown_x = bounds.button.x
            local dropdown_y = bounds.button.y + 22
            
            local max_item_width = 0
            for _, item in ipairs(sel.items) do
                local item_width = get_text_width(fonts.StandartFont, item)
                if item_width > max_item_width then
                    max_item_width = item_width
                end
            end
            local dropdown_width = max_item_width + 30
            local current_dropdown_height = math.min(#sel.items * 22, 1000) * (sel.dropdown_height_progress or 0)
            
            if current_dropdown_height > 0 then
                local dropdown_bounds = {x = dropdown_x, y = dropdown_y, w = dropdown_width, h = current_dropdown_height}
                if is_hovering(dropdown_bounds, mouse_pos) then any_interactive_hovered = true end
                
                sel.hovered_index = nil
                
                for i, item in ipairs(sel.items) do
                    local item_y = dropdown_y + (i - 1) * 22
                    if item_y >= dropdown_y and item_y + 20 <= dropdown_y + current_dropdown_height then
                        local item_rect = {x = dropdown_x + 2, y = item_y, w = dropdown_width - 4, h = 17}
                        if is_hovering(item_rect, mouse_pos) then
                            any_interactive_hovered = true
                            sel.hovered_index = i
                            if mouse_clicked and not active_slider and not active_checkbox and not sel.click_processed then
                                sel.click_processed = true
                                handle_dropdown_item_click(sel, i, mouse_clicked)
                            end
                        end
                    end
                end
            end
        end
    end

    local function update_button(btn, mouse_pos, mouse_left, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not btn.visible then return end
        if is_blocked_by_gear_popup(btn) then return end
        if btn.disabled then return end
        
        local button_width = btn.width or (parent_size_x - parent_left_padding - parent_right_padding)
        local button_x = parent_pos.x + parent_left_padding
        local button_y = parent_pos.y + btn.y
        local button_h = btn.height or 24
        
        local button_rect = {
            x = button_x,
            y = button_y,
            w = button_width,
            h = button_h
        }
        
        local is_button_hovered = is_hovering(button_rect, mouse_pos)
        
        if is_button_hovered then
            any_interactive_hovered = true
        end
        
        btn.hovered = is_button_hovered
        
        if can_interact and is_button_hovered and mouse_left and not active_slider and not active_checkbox and not is_input_blocked() then
            if not btn.click_processed then
                btn.click_processed = true
                btn.is_holding = true
                
                if btn.press_anim then btn.press_anim:stop() end
                
                btn.press_anim = anim.animate_to(btn, "pct", btn.pct or 0, 1, 0.1, "cubic_out")
                btn.press_anim.on_complete = function()
                    btn.press_anim = nil
                    if not btn.is_holding then
                        btn.press_anim = anim.animate_to(btn, "pct", 1, 0, 0.125, "cubic_in")
                        btn.press_anim:start()
                    end
                end
                btn.press_anim:start()
                
                if btn.callback then
                    btn.callback(btn)
                end
            end
        elseif not mouse_left then
            if btn.is_holding then
                btn.is_holding = false
                
                if btn.press_anim == nil and btn.pct >= 0.99 then
                    btn.press_anim = anim.animate_to(btn, "pct", 1, 0, 0.125, "cubic_in")
                    btn.press_anim:start()
                end
            end
            btn.click_processed = false
        end
    end

    local function update_color_picker(picker, mouse_pos, mouse_left, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not picker.visible then return end
        if is_blocked_by_gear_popup(picker) then return end
        
        local bounds = get_color_picker_bounds(picker, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        
        picker.text_hovered = is_hovering(bounds.text, mouse_pos)
        
        if picker.text_hovered then any_interactive_hovered = true end
        if not picker.preview_bounds then return end
        
        local preview_hover = is_hovering(picker.preview_bounds, mouse_pos)
        if preview_hover then any_interactive_hovered = true end
        
        if can_interact and not is_input_blocked() and not active_slider and not active_checkbox then
            if preview_hover and mouse_left and not picker.opened then
                if active_selectable and active_selectable ~= picker then
                    if active_selectable.opened then
                        if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                        active_selectable.opened = false
                        active_selectable.dropdown_height_progress = 0
                    end
                    active_selectable = nil
                end
                
                picker.opened = true
                active_selectable = picker
                if picker.dropdown_anim then picker.dropdown_anim:stop() end
                picker.dropdown_height_progress = picker.dropdown_height_progress or 0
                picker.dropdown_anim = anim.animate_to(picker, "dropdown_height_progress", picker.dropdown_height_progress, 1, 0.25, "cubic_out")
                picker.dropdown_anim:start()
            end
        end
        
        if picker.opened and picker == active_selectable and picker.picker_bounds then
            local changed = false
            
            if mouse_left then
                if not picker.dragging_picker and not picker.dragging_hue and not picker.dragging_alpha then
                    local in_picker = picker.picker_bounds and 
                        mouse_pos.x >= picker.picker_bounds.x and mouse_pos.x <= picker.picker_bounds.x + picker.picker_bounds.w and
                        mouse_pos.y >= picker.picker_bounds.y and mouse_pos.y <= picker.picker_bounds.y + picker.picker_bounds.h
                    
                    local in_hue = picker.hue_bounds and
                        mouse_pos.x >= picker.hue_bounds.x and mouse_pos.x <= picker.hue_bounds.x + picker.hue_bounds.w and
                        mouse_pos.y >= picker.hue_bounds.y and mouse_pos.y <= picker.hue_bounds.y + picker.hue_bounds.h
                    
                    local in_alpha = picker.show_alpha and picker.alpha_bounds and
                        mouse_pos.x >= picker.alpha_bounds.x and mouse_pos.x <= picker.alpha_bounds.x + picker.alpha_bounds.w and
                        mouse_pos.y >= picker.alpha_bounds.y and mouse_pos.y <= picker.alpha_bounds.y + picker.alpha_bounds.h
                    
                    if in_picker then
                        picker.dragging_picker = true
                    elseif in_hue then
                        picker.dragging_hue = true
                    elseif in_alpha then
                        picker.dragging_alpha = true
                    end
                end
            end

            if picker.copy_bounds then
                local over_copy = mouse_pos.x >= picker.copy_bounds.x and mouse_pos.x <= picker.copy_bounds.x + picker.copy_bounds.w and
                                mouse_pos.y >= picker.copy_bounds.y and mouse_pos.y <= picker.copy_bounds.y + picker.copy_bounds.h
                
                if over_copy and mouse_left then
                    if not picker.copy_clicked then
                        picker.copy_clicked = true
                        picker.copy_press = true
                        clipboard.CopyToClipboard(picker:Hex())
                    end
                else
                    if picker.copy_clicked then
                        picker.copy_clicked = false
                        picker.copy_press = false
                    end
                end
            end

            if picker.paste_bounds then
                local over_paste = mouse_pos.x >= picker.paste_bounds.x and mouse_pos.x <= picker.paste_bounds.x + picker.paste_bounds.w and
                                mouse_pos.y >= picker.paste_bounds.y and mouse_pos.y <= picker.paste_bounds.y + picker.paste_bounds.h
                
                if over_paste and mouse_left then
                    if not picker.paste_clicked then
                        picker.paste_clicked = true
                        picker.paste_press = true
                        
                        local clipboard_text = clipboard.GetFromClipboard()
                        if clipboard_text then
                            local hex = clipboard_text:gsub("#", "")
                            if #hex == 6 or #hex == 8 then
                                local r = tonumber(hex:sub(1, 2), 16) / 255 or 0
                                local g = tonumber(hex:sub(3, 4), 16) / 255 or 0
                                local b = tonumber(hex:sub(5, 6), 16) / 255 or 0
                                local a = #hex == 8 and (tonumber(hex:sub(7, 8), 16) / 255) or 1
                                
                                local new_color = color_t(r, g, b, a)
                                picker:Set(new_color)
                            end
                        end
                    end
                else
                    if picker.paste_clicked then
                        picker.paste_clicked = false
                        picker.paste_press = false
                    end
                end
            end
            
            if picker.dragging_picker then
                local clamped_x = math.max(picker.picker_bounds.x, math.min(picker.picker_bounds.x + picker.picker_bounds.w, mouse_pos.x))
                local clamped_y = math.max(picker.picker_bounds.y, math.min(picker.picker_bounds.y + picker.picker_bounds.h, mouse_pos.y))
                local s = (clamped_x - picker.picker_bounds.x) / picker.picker_bounds.w
                local v = 1 - ((clamped_y - picker.picker_bounds.y) / picker.picker_bounds.h)
                picker.hsv[2] = math.max(0, math.min(1, s))
                picker.hsv[3] = math.max(0, math.min(1, v))
                changed = true
            end
            
            if picker.dragging_hue then
                local clamped_y = math.max(picker.hue_bounds.y, math.min(picker.hue_bounds.y + picker.hue_bounds.h, mouse_pos.y))
                local hue = (clamped_y - picker.hue_bounds.y) / picker.hue_bounds.h
                picker.hsv[1] = math.max(0, math.min(1, hue))
                changed = true
            end
            
            if picker.show_alpha and picker.dragging_alpha and picker.alpha_bounds then
                local clamped_y = math.max(picker.alpha_bounds.y, math.min(picker.alpha_bounds.y + picker.alpha_bounds.h, mouse_pos.y))
                local alpha = (clamped_y - picker.alpha_bounds.y) / picker.alpha_bounds.h
                picker.value.a = math.max(0, math.min(1, alpha))
                changed = true
            end
            
            if not mouse_left then
                picker.dragging_picker = false
                picker.dragging_hue = false
                picker.dragging_alpha = false
            end
            
            if changed then
                local new_color = picker:hsv_to_rgb(picker.hsv)
                new_color.a = picker.value.a
                picker.value = new_color
                can_interact = false
                any_interactive_hovered = true
            end
            
            if not picker.dragging_picker and not picker.dragging_hue and not picker.dragging_alpha then
                if picker.popup_bounds then
                    local over_popup = mouse_pos.x >= picker.popup_bounds.x and mouse_pos.x <= picker.popup_bounds.x + picker.popup_bounds.w and
                                    mouse_pos.y >= picker.popup_bounds.y and mouse_pos.y <= picker.popup_bounds.y + picker.popup_bounds.h
                    local over_preview = is_hovering(picker.preview_bounds, mouse_pos)
                    
                    local over_gear_popup = false
                    if active_gear_popup and active_gear_popup.gear_opened and active_gear_popup.gear_popup_bounds then
                        over_gear_popup = mouse_pos.x >= active_gear_popup.gear_popup_bounds.x and 
                                        mouse_pos.x <= active_gear_popup.gear_popup_bounds.x + active_gear_popup.gear_popup_bounds.w and
                                        mouse_pos.y >= active_gear_popup.gear_popup_bounds.y and 
                                        mouse_pos.y <= active_gear_popup.gear_popup_bounds.y + active_gear_popup.gear_popup_bounds.h
                    end
                    
                    if not over_popup and not over_preview and not over_gear_popup and mouse_left then
                        if picker.dropdown_anim then picker.dropdown_anim:stop() end
                        picker.dropdown_anim = anim.animate_to(picker, "dropdown_height_progress", picker.dropdown_height_progress or 1, 0, 0.2, "cubic_out")
                        picker.dropdown_anim.on_complete = function()
                            picker.opened = false
                            if active_selectable == picker then
                                active_selectable = nil
                            end
                            picker.popup_bounds = nil
                            picker.picker_bounds = nil
                            picker.hue_bounds = nil
                            picker.alpha_bounds = nil
                        end
                        picker.dropdown_anim:start()
                    end
                end
            end
        end
    end

    local function update_input(inp, mouse_pos, mouse_left, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, x_off)
        if not inp.visible then return end
        if is_blocked_by_gear_popup(inp) then return end
        local text_width = get_text_width(fonts.StandartFont, inp.label)
        local text_bounds = {
            x = parent_pos.x + parent_left_padding,
            y = parent_pos.y + inp.y,
            w = text_width,
            h = inp.height
        }
        inp.text_hovered = is_hovering(text_bounds, mouse_pos)
        
        if inp.text_hovered then any_interactive_hovered = true end

        local label_width = 100
        local input_width = inp.width
        local input_x = x_off and parent_pos.x + parent_left_padding + label_width + 5 + x_off or parent_pos.x + parent_left_padding + label_width + 5
        local input_y = parent_pos.y + inp.y + (inp.height - 20) / 2
        
        local input_bounds = {
            x = input_x,
            y = input_y,
            w = input_width,
            h = 20
        }
        
        local over_input = is_hovering(input_bounds, mouse_pos)
        if over_input then any_interactive_hovered = true end
        
        if can_interact and not is_input_blocked() and not active_slider and not active_checkbox then
            if over_input and mouse_left and not inp.interacting then
                if active_selectable and active_selectable ~= inp then
                    if active_selectable.opened then
                        if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                        active_selectable.opened = false
                    end
                    active_selectable = nil
                end
                inp.interacting = true
                active_selectable = inp
                inp.repeat_timer = 0
                inp.last_key = nil
            elseif not over_input and mouse_left and inp.interacting then
                inp.interacting = false
                if active_selectable == inp then
                    active_selectable = nil
                end
            end
        end
        
        if inp.interacting then
            if mouse_left and not over_input then
                inp.interacting = false
                if active_selectable == inp then
                    active_selectable = nil
                end
            end
            
            local changed = false
            
            local function add_char(char)
                inp.value = inp.value:sub(1, inp.cursor_pos - 1) .. char .. inp.value:sub(inp.cursor_pos)
                inp.cursor_pos = inp.cursor_pos + 1
                changed = true
            end
            
            local function add_text(text)
                inp.value = inp.value:sub(1, inp.cursor_pos - 1) .. text .. inp.value:sub(inp.cursor_pos)
                inp.cursor_pos = inp.cursor_pos + #text
                changed = true
            end
            
            local function backspace()
                if inp.cursor_pos > 1 then
                    inp.value = inp.value:sub(1, inp.cursor_pos - 2) .. inp.value:sub(inp.cursor_pos)
                    inp.cursor_pos = inp.cursor_pos - 1
                    changed = true
                end
            end
            
            local function delete_char()
                if inp.cursor_pos <= #inp.value then
                    inp.value = inp.value:sub(1, inp.cursor_pos - 1) .. inp.value:sub(inp.cursor_pos + 1)
                    changed = true
                end
            end
            
            if input.IsKeyPressed(VK_LCONTROL) or input.IsKeyPressed(VK_RCONTROL) then
                if input.IsKeyClicked(VK_V) then
                    local clipboard_text = clipboard.GetFromClipboard()
                    if clipboard_text and clipboard_text ~= "" then
                        local max_length = inp.max_length or 256
                        local remaining = max_length - #inp.value
                        if remaining > 0 and #clipboard_text > remaining then
                            clipboard_text = clipboard_text:sub(1, remaining)
                        end
                        add_text(clipboard_text)
                    end
                end
            end
            
            local current_time = os.clock()
            if not inp.last_key_time then
                inp.last_key_time = current_time
                inp.last_key = nil
                inp.repeat_delay = 0.5
                inp.repeat_interval = 0.03
            end
            
            local keys = {
                {VK_A, "A"}, {VK_B, "B"}, {VK_C, "C"}, {VK_D, "D"}, {VK_E, "E"},
                {VK_F, "F"}, {VK_G, "G"}, {VK_H, "H"}, {VK_I, "I"}, {VK_J, "J"},
                {VK_K, "K"}, {VK_L, "L"}, {VK_M, "M"}, {VK_N, "N"}, {VK_O, "O"},
                {VK_P, "P"}, {VK_Q, "Q"}, {VK_R, "R"}, {VK_S, "S"}, {VK_T, "T"},
                {VK_U, "U"}, {VK_V, "V"}, {VK_W, "W"}, {VK_X, "X"}, {VK_Y, "Y"}, {VK_Z, "Z"},
                {VK_0, "0"}, {VK_1, "1"}, {VK_2, "2"}, {VK_3, "3"}, {VK_4, "4"},
                {VK_5, "5"}, {VK_6, "6"}, {VK_7, "7"}, {VK_8, "8"}, {VK_9, "9"}
            }
            
            for _, key_info in ipairs(keys) do
                local key_code = key_info[1]
                local char = key_info[2]
                
                if input.IsKeyPressed(key_code) then
                    if not inp.last_key or inp.last_key ~= key_code then
                        local final_char = char
                        if key_code >= VK_A and key_code <= VK_Z and not input.IsKeyPressed(VK_SHIFT) then final_char = string.lower(char) end
                        add_char(final_char)
                        inp.last_key = key_code
                        inp.last_key_time = current_time
                        inp.repeat_state = false
                    elseif inp.last_key == key_code and not inp.repeat_state and current_time - inp.last_key_time > inp.repeat_delay then
                        inp.repeat_state = true
                        inp.last_key_time = current_time
                        local final_char = char
                        if key_code >= VK_A and key_code <= VK_Z and not input.IsKeyPressed(VK_SHIFT) then
                            final_char = string.lower(char)
                        end
                        add_char(final_char)
                    elseif inp.last_key == key_code and inp.repeat_state and current_time - inp.last_key_time > inp.repeat_interval then
                        inp.last_key_time = current_time
                        local final_char = char
                        if key_code >= VK_A and key_code <= VK_Z and not input.IsKeyPressed(VK_SHIFT) then
                            final_char = string.lower(char)
                        end
                        add_char(final_char)
                    end
                    break
                end
            end
            
            if not changed and input.IsKeyPressed(VK_SPACE) then
                if not inp.last_key or inp.last_key ~= VK_SPACE then
                    add_char(" ")
                    inp.last_key = VK_SPACE
                    inp.last_key_time = current_time
                    inp.repeat_state = false
                elseif inp.last_key == VK_SPACE and not inp.repeat_state and current_time - inp.last_key_time > inp.repeat_delay then
                    inp.repeat_state = true
                    inp.last_key_time = current_time
                    add_char(" ")
                elseif inp.last_key == VK_SPACE and inp.repeat_state and current_time - inp.last_key_time > inp.repeat_interval then
                    inp.last_key_time = current_time
                    add_char(" ")
                end
            end
            
            if not changed and input.IsKeyPressed(VK_BACK) then
                if not inp.last_key or inp.last_key ~= VK_BACK then
                    backspace()
                    inp.last_key = VK_BACK
                    inp.last_key_time = current_time
                    inp.repeat_state = false
                elseif inp.last_key == VK_BACK and not inp.repeat_state and current_time - inp.last_key_time > inp.repeat_delay then
                    inp.repeat_state = true
                    inp.last_key_time = current_time
                    backspace()
                elseif inp.last_key == VK_BACK and inp.repeat_state and current_time - inp.last_key_time > inp.repeat_interval then
                    inp.last_key_time = current_time
                    backspace()
                end
            end
            
            if not changed and input.IsKeyPressed(VK_DELETE) then
                if not inp.last_key or inp.last_key ~= VK_DELETE then
                    delete_char()
                    inp.last_key = VK_DELETE
                    inp.last_key_time = current_time
                    inp.repeat_state = false
                elseif inp.last_key == VK_DELETE and not inp.repeat_state and current_time - inp.last_key_time > inp.repeat_delay then
                    inp.repeat_state = true
                    inp.last_key_time = current_time
                    delete_char()
                elseif inp.last_key == VK_DELETE and inp.repeat_state and current_time - inp.last_key_time > inp.repeat_interval then
                    inp.last_key_time = current_time
                    delete_char()
                end
            end
            
            if not changed and input.IsKeyClicked(VK_LEFT) and inp.cursor_pos > 1 then
                inp.cursor_pos = inp.cursor_pos - 1
                changed = true
                inp.last_key = nil
            elseif not changed and input.IsKeyClicked(VK_RIGHT) and inp.cursor_pos <= #inp.value then
                inp.cursor_pos = inp.cursor_pos + 1
                changed = true
                inp.last_key = nil
            end
            
            if not changed and input.IsKeyClicked(VK_RETURN) then
                inp.interacting = false
                if active_selectable == inp then
                    active_selectable = nil
                end
                changed = true
            elseif not changed and input.IsKeyClicked(VK_ESCAPE) then
                inp.interacting = false
                if active_selectable == inp then
                    active_selectable = nil
                end
                changed = true
            end
            
            if not input.IsKeyPressed(VK_BACK) and not input.IsKeyPressed(VK_DELETE) and not input.IsKeyPressed(VK_SPACE) then
                local any_key_pressed = false
                for _, key_info in ipairs(keys) do
                    if input.IsKeyPressed(key_info[1]) then
                        any_key_pressed = true
                        break
                    end
                end
                if not any_key_pressed then
                    inp.last_key = nil
                    inp.repeat_state = false
                end
            end
            
            if changed then
                local text_before_cursor = inp.value:sub(1, inp.cursor_pos - 1)
                local before_width = get_text_width(fonts.StandartFont, text_before_cursor)
                local full_width = get_text_width(fonts.StandartFont, inp.value)
                local max_visible_width = input_width - 8
                
                if max_visible_width < before_width - inp.scroll_offset then
                    inp.scroll_offset = before_width - max_visible_width
                end
                if before_width - inp.scroll_offset < 0 then
                    inp.scroll_offset = before_width
                end
                if max_visible_width > full_width - inp.scroll_offset then
                    inp.scroll_offset = math.max(0, full_width - max_visible_width)
                end
                inp.scroll_offset = math.max(0, inp.scroll_offset)
            end
        end
        
        inp.input_bounds = input_bounds
    end

    local function update_hotkey(hotkey, mouse_pos, mouse_left, mouse_right, can_interact, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        if not hotkey.visible then return end
        if is_blocked_by_gear_popup(hotkey) then return end
        
        local key_display = hotkey.waiting_for_key and "..." or (hotkey.key == 0 and "N/A" or GetKeyName(hotkey.key))
        local target_text_width = get_text_width(fonts.StandartFont, key_display)
        local target_button_width = target_text_width + 16
        
        if not hotkey.anim_button_width then
            hotkey.anim_button_width = hotkey.current_button_width or target_button_width
        end
        
        local diff = target_button_width - hotkey.anim_button_width
        if math.abs(diff) > 0.5 then
            hotkey.anim_button_width = hotkey.anim_button_width + diff * 0.3
        else
            hotkey.anim_button_width = target_button_width
        end
        
        hotkey.current_button_width = hotkey.anim_button_width
        
        local bounds = get_hotkey_bounds(hotkey, parent_pos, parent_left_padding, parent_right_padding, parent_size_x)
        bounds.button.w = hotkey.current_button_width
        bounds.button.x = parent_pos.x + parent_size_x - parent_right_padding - hotkey.current_button_width
        
        hotkey.text_hovered = is_hovering(bounds.text, mouse_pos)
        local button_hover = is_hovering(bounds.button, mouse_pos)
        
        if button_hover then any_interactive_hovered = true end
        
        hotkey.hovered = (hotkey.text_hovered or button_hover) and not hotkey.mode_popup_opened
        
        if hotkey.mode_popup_opened then
            local popup_bounds = get_mode_popup_bounds(hotkey, bounds.button)
            local current_progress = hotkey.mode_popup_progress or 1
            local current_height = popup_bounds.h * current_progress
            
            local in_popup = false
            if current_height > 0 then
                in_popup = mouse_pos.x >= popup_bounds.x and mouse_pos.x <= popup_bounds.x + popup_bounds.w and
                            mouse_pos.y >= popup_bounds.y and mouse_pos.y <= popup_bounds.y + current_height
            end
            
            local in_button = button_hover
            local in_text = hotkey.text_hovered
            
            if mouse_left and not in_popup and not in_button and not in_text then
                if hotkey.mode_popup_anim then hotkey.mode_popup_anim:stop() end
                hotkey.mode_popup_anim = anim.animate_to(hotkey, "mode_popup_progress", hotkey.mode_popup_progress or 1, 0, 0.2, "cubic_out")
                hotkey.mode_popup_anim.on_complete = function()
                    hotkey.mode_popup_opened = false
                    hotkey.mode_popup_anim = nil
                end
                hotkey.mode_popup_anim:start()
                hotkey.mode_click_processed = true
            end
        end
        
        if can_interact and button_hover and mouse_left and not active_slider and not active_checkbox and not is_input_blocked() then
            if not hotkey.click_processed then
                hotkey.click_processed = true
                
                if hotkey.mode_popup_opened then
                    if hotkey.mode_popup_anim then hotkey.mode_popup_anim:stop() end
                    hotkey.mode_popup_anim = anim.animate_to(hotkey, "mode_popup_progress", hotkey.mode_popup_progress or 1, 0, 0.2, "cubic_out")
                    hotkey.mode_popup_anim.on_complete = function()
                        hotkey.mode_popup_opened = false
                        hotkey.mode_popup_anim = nil
                    end
                    hotkey.mode_popup_anim:start()
                end
                
                hotkey.waiting_for_key = true
                hotkey.ignore_current_click = true
            end
        end
        
        if can_interact and button_hover and mouse_right and not active_slider and not active_checkbox and not is_input_blocked() then
            if not hotkey.mode_click_processed then
                hotkey.mode_click_processed = true
                
                if hotkey.mode_popup_opened then
                    if hotkey.mode_popup_anim then hotkey.mode_popup_anim:stop() end
                    hotkey.mode_popup_anim = anim.animate_to(hotkey, "mode_popup_progress", hotkey.mode_popup_progress or 1, 0, 0.2, "cubic_out")
                    hotkey.mode_popup_anim.on_complete = function()
                        hotkey.mode_popup_opened = false
                        hotkey.mode_popup_anim = nil
                    end
                    hotkey.mode_popup_anim:start()
                else
                    if active_selectable and active_selectable ~= hotkey then
                        if active_selectable.opened then
                            if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                            active_selectable.opened = false
                        end
                        active_selectable = nil
                    end
                    
                    if active_gear_popup and active_gear_popup.gear_opened then
                        if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
                        active_gear_popup.gear_opened = false
                        active_gear_popup.gear_progress = 0
                        active_gear_popup = nil
                        gear_blocking = false
                    end
                    
                    hotkey.mode_popup_opened = true
                    if hotkey.mode_popup_anim then hotkey.mode_popup_anim:stop() end
                    hotkey.mode_popup_progress = hotkey.mode_popup_progress or 0
                    hotkey.mode_popup_anim = anim.animate_to(hotkey, "mode_popup_progress", hotkey.mode_popup_progress, 1, 0.25, "cubic_out")
                    hotkey.mode_popup_anim:start()
                end
            end
        elseif not mouse_left and not mouse_right then
            hotkey.click_processed = false
            if not hotkey.mode_popup_opened then hotkey.mode_click_processed = false end
        end
        
        if hotkey.waiting_for_key then
            if hotkey.ignore_current_click and not mouse_left then hotkey.ignore_current_click = false end
            
            if not hotkey.ignore_current_click then
                local is_over_button = is_hovering(bounds.button, mouse_pos)
                local is_over_text = is_hovering(bounds.text, mouse_pos)
                
                if mouse_left and not is_over_button and not is_over_text then
                    hotkey.waiting_for_key = false
                    hotkey.ignore_current_click = false
                    return
                end
            end
            
            local key_pressed = false
            local selected_key = nil
            
            local all_keys = {
                VK_MBUTTON, VK_XBUTTON1, VK_XBUTTON2,
                VK_BACK, VK_TAB, VK_CLEAR, VK_RETURN, VK_SHIFT, VK_CONTROL, VK_MENU,
                VK_PAUSE, VK_CAPITAL, VK_ESCAPE, VK_SPACE, VK_PRIOR, VK_NEXT,
                VK_END, VK_HOME, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN, VK_SELECT,
                VK_PRINT, VK_EXECUTE, VK_SNAPSHOT, VK_INSERT, VK_DELETE, VK_HELP,
                VK_0, VK_1, VK_2, VK_3, VK_4, VK_5, VK_6, VK_7, VK_8, VK_9,
                VK_A, VK_B, VK_C, VK_D, VK_E, VK_F, VK_G, VK_H, VK_I, VK_J,
                VK_K, VK_L, VK_M, VK_N, VK_O, VK_P, VK_Q, VK_R, VK_S, VK_T,
                VK_U, VK_V, VK_W, VK_X, VK_Y, VK_Z,
                VK_LWIN, VK_RWIN, VK_APPS, VK_SLEEP, VK_NUMPAD0, VK_NUMPAD1,
                VK_NUMPAD2, VK_NUMPAD3, VK_NUMPAD4, VK_NUMPAD5, VK_NUMPAD6,
                VK_NUMPAD7, VK_NUMPAD8, VK_NUMPAD9, VK_MULTIPLY, VK_ADD,
                VK_SEPARATOR, VK_SUBTRACT, VK_DECIMAL, VK_DIVIDE, VK_F1, VK_F2,
                VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10, VK_F11, VK_F12,
                VK_NUMLOCK, VK_SCROLL, VK_LSHIFT, VK_RSHIFT, VK_LCONTROL, VK_RCONTROL,
                VK_LMENU, VK_RMENU
            }
            
            if hotkey.ignore_current_click then return end
            
            if input.IsKeyClicked(VK_RETURN) then
                hotkey.waiting_for_key = false
                hotkey.ignore_current_click = false
                hotkey.anim_button_width = nil 
                return
            end
            
            if input.IsKeyClicked(VK_ESCAPE) then
                hotkey.key = 0
                hotkey.waiting_for_key = false
                hotkey.ignore_current_click = false
                
                hotkey.anim_button_width = nil
                hotkey.current_button_width = nil
                
                if hotkey.mode == 1 then
                    hotkey.active = true
                elseif hotkey.mode == 2 then
                    hotkey.active = false  
                elseif hotkey.mode == 3 then
                    hotkey.toggle_state = false
                    hotkey.active = false
                end
                
                if hotkey.callback then
                    hotkey.callback(hotkey.active, hotkey)
                end
                
                return
            end
            
            for _, key_code in ipairs(all_keys) do
                if input.IsKeyClicked(key_code) then
                    key_pressed = true
                    selected_key = key_code
                    break
                end
            end
            
            if key_pressed then
                hotkey.key = selected_key
                if hotkey.mode == 1 then
                    hotkey.active = true
                elseif hotkey.mode == 2 then
                    hotkey.active = input.IsKeyPressed(hotkey.key)
                elseif hotkey.mode == 3 then
                    hotkey.toggle_state = false
                    hotkey.active = false
                end
                
                hotkey.anim_button_width = nil
                hotkey.waiting_for_key = false
                hotkey.ignore_current_click = false
                
                if hotkey.callback then
                    hotkey.callback(hotkey.active, hotkey)
                end
            end
        end
        
        if hotkey.mode_popup_opened and hotkey.mode_popup_progress and hotkey.mode_popup_progress > 0 then
            local popup_bounds = get_mode_popup_bounds(hotkey, bounds.button)
            local current_progress = hotkey.mode_popup_progress
            local current_height = popup_bounds.h * current_progress
            
            for i, mode_name in ipairs(popup_bounds.mode_names) do
                local item_y = popup_bounds.y + (i - 1) * 24
                if item_y >= popup_bounds.y and item_y + 22 <= popup_bounds.y + current_height then
                    local item_rect = {
                        x = popup_bounds.x + 5,
                        y = item_y,
                        w = popup_bounds.w - 10,
                        h = 22
                    }
                    if is_hovering(item_rect, mouse_pos) then
                        any_interactive_hovered = true
                        hotkey.hovered_mode_index = i
                        if mouse_left then
                            local real_mode = 1
                            local display_count = 0
                            for m = 1, 3 do
                                if hotkey.available_modes[m] then
                                    display_count = display_count + 1
                                    if display_count == i then
                                        real_mode = m
                                        break
                                    end
                                end
                            end
                            hotkey.mode = real_mode
                            
                            if hotkey.mode == 1 then
                                hotkey.active = true
                                hotkey.toggle_state = false
                            elseif hotkey.mode == 2 then
                                hotkey.active = (hotkey.key ~= 0) and input.IsKeyPressed(hotkey.key) or false
                                hotkey.toggle_state = false
                            elseif hotkey.mode == 3 then
                                hotkey.toggle_state = false
                                hotkey.active = false
                            end
                            
                            if hotkey.callback then
                                hotkey.callback(hotkey.active, hotkey)
                            end
                            
                            if hotkey.mode_popup_anim then hotkey.mode_popup_anim:stop() end
                            hotkey.mode_popup_anim = anim.animate_to(hotkey, "mode_popup_progress", hotkey.mode_popup_progress or 1, 0, 0.2, "cubic_out")
                            hotkey.mode_popup_anim.on_complete = function()
                                hotkey.mode_popup_opened = false
                                hotkey.mode_popup_anim = nil
                            end
                            hotkey.mode_popup_anim:start()
                        end
                    end
                end
            end
        end
    end

    local function draw_checkbox(checkbox, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not checkbox.visible then return end

        local fade_alpha = alpha * (checkbox.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local disabled_mult = checkbox.disabled and 0.55 or 1.0
        
        local text_y = parent_pos.y + checkbox.y + (checkbox.height / 2) - 6
        local text_color = checkbox.text_hovered and color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha) 
                            or color_t(0.9 * disabled_mult, 0.9 * disabled_mult, 0.9 * disabled_mult, 0.9 * fade_alpha)
        render.text(checkbox.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), text_color)
        
        local toggle_x = parent_pos.x + parent_size_x - parent_right_padding - checkbox.width
        local toggle_y = parent_pos.y + checkbox.y + (checkbox.height - checkbox.toggle_height) / 2 + 2
        
        local toggle_progress = checkbox.toggle_progress or 0
        local off_color = color_t(0.3, 0.3, 0.3, 0.8 * fade_alpha)
        local on_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha)
        local bg_color = LerpColor(off_color, on_color, toggle_progress)
        
        render.rect_filled(vec2_t(toggle_x, toggle_y), vec2_t(toggle_x + checkbox.width, toggle_y + checkbox.toggle_height), bg_color, checkbox.toggle_height / 2)
        
        local knob_pos = vec2_t(toggle_x + checkbox.knob_x, toggle_y + 2)
        render.rect_filled(knob_pos, vec2_t(knob_pos.x + checkbox.knob_radius*2, knob_pos.y + checkbox.knob_radius*2), color_t(1, 1, 1, 0.95 * fade_alpha), checkbox.knob_radius)

        if checkbox.hasSettingsGear then
            local gear_x = parent_pos.x + parent_size_x - parent_right_padding - checkbox.width - 20
            local gear_y = parent_pos.y + checkbox.y + (checkbox.height - 14) / 2 + 2
            add_gear_button(checkbox, gear_x, gear_y, alpha)
        end
    end

    local function draw_slider(slider, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not slider.visible then return end

        local fade_alpha = alpha * (slider.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local text_y = parent_pos.y + slider.y + (slider.height / 2) - 6
        render.text(slider.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha))
        
        local val_text = get_slider_display_value(slider)
        local val_width = get_text_width(fonts.StandartFont, val_text)
        local val_x = parent_pos.x + parent_size_x - parent_right_padding - slider.slider_width - val_width - 8
        render.text(val_text, fonts.StandartFont, vec2_t(val_x, text_y), color_t(0.8, 0.8, 0.8, 0.9 * fade_alpha))
        
        local slider_x = val_x + val_width + 8
        local slider_y = parent_pos.y + slider.y + (slider.height - 10) / 2 + 2
        local slider_end_x = parent_pos.x + parent_size_x - parent_right_padding
        
        render.rect_filled(vec2_t(slider_x, slider_y), vec2_t(slider_end_x, slider_y + 10), color_t(0.2, 0.2, 0.2, 0.9 * fade_alpha), 5)
        
        local t = (slider.value - slider.min) / (slider.max - slider.min)
        local fill_width = t * (slider_end_x - slider_x)
        if fill_width > 0 then
            render.rect_filled(vec2_t(slider_x, slider_y), vec2_t(slider_x + fill_width, slider_y + 10), color_t(accent_color.r, accent_color.g, accent_color.b, 0.8 * fade_alpha), 5)
        end

        if slider.hasSettingsGear then
            local gear_x = parent_pos.x + parent_size_x - parent_right_padding - slider.slider_width - 45
            local gear_y = parent_pos.y + slider.y + (slider.height - 14) / 2 + 2
            add_gear_button(slider, gear_x, gear_y, alpha)
        end
    end

    local function draw_selectable_button(selectable, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not selectable.visible then return end

        local fade_alpha = alpha * (selectable.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local text_y = parent_pos.y + selectable.y + (selectable.height / 2) - 6
        local text_color
        if selectable.text_hovered then
            text_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha)
        else
            text_color = color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
        end
        render.text(selectable.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), text_color)
        
        local button_x = parent_pos.x + parent_size_x - parent_right_padding - selectable.button_width
        local button_y = parent_pos.y + selectable.y + (selectable.height - 20) / 2
        render.rect_filled(vec2_t(button_x, button_y + 2), vec2_t(button_x + selectable.button_width, button_y + 22), color_t(0.2, 0.2, 0.2, 0.9 * fade_alpha), 4)
        
        local display_text = ""
        if selectable.multi then
            local selected_items = {}
            for i, selected in ipairs(selectable.selected) do
                if selected then table.insert(selected_items, selectable.items[i]) end
            end
            if #selected_items == 0 then
                display_text = "None"
            elseif #selected_items == 1 then
                display_text = selected_items[1]
            else
                display_text = #selected_items .. " selected"
            end
        else
            local selected_index = selectable.value
            if type(selected_index) == "number" and selected_index >= 1 and selected_index <= #selectable.items then
                display_text = selectable.items[selected_index]
            else
                display_text = "None"
            end
        end
        
        local text_width = get_text_width(fonts.StandartFont, display_text)
        local max_text_width = selectable.button_width - 20
        if text_width > max_text_width then
            local ellipsis = "..."
            local max_chars = math.floor((max_text_width - get_text_width(fonts.StandartFont, ellipsis)) / 6)
            display_text = max_chars > 0 and string.sub(display_text, 1, max_chars) .. ellipsis or "..."
        end
        
        local value_text_color
        if not selectable.multi and selectable.value then
            value_text_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha)
        else
            value_text_color = color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
        end
        render.text(display_text, fonts.StandartFont, vec2_t(button_x + 6, button_y + 4), value_text_color)
    end

    local function draw_selectable_dropdown(selectable, parent_pos, parent_right_padding, parent_size_x, alpha)
        if not selectable.visible then return end
        if not selectable or not selectable.opened then return end
        if not selectable.items or type(selectable.items) ~= "table" then return end
        
        local fade_alpha = alpha * (selectable.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local button_x = parent_pos.x + parent_size_x - parent_right_padding - selectable.button_width
        local button_y = parent_pos.y + selectable.y + (selectable.height - 20) / 2
        
        local max_item_width = 0
        for _, item in ipairs(selectable.items) do
            local item_width = get_text_width(fonts.StandartFont, item)
            if item_width > max_item_width then max_item_width = item_width end
        end
        local dropdown_width = math.max(120, max_item_width + 30)
        local dropdown_x = button_x
        local dropdown_y = button_y + 22
        
        local items_height = #selectable.items * 22
        local full_height = math.min(items_height, 1000)
        local current_height = full_height * (selectable.dropdown_height_progress or 0)
        
        if current_height > 0 then
            render.rect_filled(vec2_t(dropdown_x, dropdown_y + 2), vec2_t(dropdown_x + dropdown_width, dropdown_y + current_height + 2), color_t(0.15, 0.15, 0.15, 0.95 * fade_alpha), 4)
            render.rect(vec2_t(dropdown_x, dropdown_y + 2), vec2_t(dropdown_x + dropdown_width, dropdown_y + current_height + 2), color_t(0.3, 0.3, 0.3, 0.8 * fade_alpha), 4)
            
            local mouse_pos = input.GetMousePos()
            
            for i, item in ipairs(selectable.items) do
                local item_y = dropdown_y + (i - 1) * 22
                if item_y >= dropdown_y and item_y + 20 <= dropdown_y + current_height then
                    local item_rect = {x = dropdown_x + 2, y = item_y, w = dropdown_width - 4, h = 17}
                    local is_hovered = is_hovering(item_rect, mouse_pos)
                    local is_selected = selectable.selected and selectable.selected[i] or false
                    
                    local text_color
                    if is_hovered and not is_selected then
                        text_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.8 * fade_alpha)
                    elseif is_selected then
                        text_color = color_t(accent_color.r, accent_color.g, accent_color.b, 1 * fade_alpha)
                    else
                        text_color = color_t(0.7, 0.7, 0.7, 0.7 * fade_alpha)
                    end
                    render.text(item, fonts.StandartFont, vec2_t(dropdown_x + 8, item_y + 4), text_color)
                end
            end
        end
    end

    local function draw_button(button, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not button.visible then return end

        local fade_alpha = alpha * (button.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local button_width = button.width or (parent_size_x - parent_left_padding - parent_right_padding)
        local button_x = parent_pos.x + parent_left_padding
        local button_y = parent_pos.y + button.y
        local button_h = button.height - 1.5 or 22.5
        
        local bg_color
        if button.disabled then
            bg_color = color_t(0.15, 0.15, 0.15, 0.5 * fade_alpha)
        elseif button.is_holding then
            bg_color = color_t(0.2, 0.2, 0.2, 0.9 * fade_alpha)
        elseif button.hovered then
            bg_color = color_t(0.3, 0.3, 0.3, 0.9 * fade_alpha)
        else
            bg_color = color_t(0.3, 0.3, 0.3, 0.9 * fade_alpha)
        end
        
        render.rect_filled(vec2_t(button_x, button_y), vec2_t(button_x + button_width, button_y + button_h), bg_color, button.border_radius or 4)
        
        local pct = button.pct or 0
        if pct > 0 then
            local center_x = button_x + button_width * 0.5
            local half_width = button_width * 0.5
            local current_radius = half_width * pct
            
            local clip_start_x = center_x - current_radius
            local clip_end_x = center_x + current_radius
            
            if clip_end_x > clip_start_x then
                render.push_clip_rect(vec2_t(clip_start_x, button_y), vec2_t(clip_end_x, button_y + button_h))
                
                local overlay_alpha = pct * 0.7 * fade_alpha
                local overlay_color = color_t(accent_color.r, accent_color.g, accent_color.b, overlay_alpha)
                render.rect_filled(vec2_t(button_x, button_y), vec2_t(button_x + button_width, button_y + button_h), overlay_color, button.border_radius or 4)
                
                render.pop_clip_rect()
            end
        end
        
        local text_width = get_text_width(fonts.StandartFont, button.label)
        local text_x = button_x + (button_width - text_width) / 2
        local text_y = button_y + (button_h - 14) / 2
        
        local text_color = color_t(0.95, 0.95, 0.95, 0.95 * fade_alpha)
        render.text(button.label, fonts.StandartFont, vec2_t(text_x, text_y), text_color)
    end

    local function draw_label(label, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not label.visible then return end

        local fade_alpha = alpha * (label.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local text_y = parent_pos.y + label.y + (label.height / 2) - 6
        render.text(label.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha))

        if label.hasSettingsGear then
            local gear_x = parent_pos.x + parent_size_x - parent_right_padding - label.width + 15
            local gear_y = parent_pos.y + label.y + (label.height - 14) / 2 + 2
            add_gear_button(label, gear_x, gear_y, alpha)
        end
    end

    local function draw_color_picker_popup(picker, parent_pos, parent_right_padding, parent_size_x, alpha)
        if not picker.visible then return end
        if not picker.opened then return end
        
        local fade_alpha = alpha * (picker.dropdown_height_progress or 0)
        if fade_alpha <= 0.01 then return end
        
        local preview_x = picker.preview_bounds.x
        local preview_y = picker.preview_bounds.y
        
        local has_alpha = picker.show_alpha ~= false
        local popup_width = has_alpha and 205 or 187.5  
        local popup_height = 200
        local popup_x = preview_x - popup_width + 40
        local popup_y = preview_y + 25
        
        render.rect_filled(vec2_t(popup_x, popup_y), vec2_t(popup_x + popup_width, popup_y + popup_height), color_t(0.15, 0.15, 0.15, 1 * fade_alpha), 8)
        render.rect(vec2_t(popup_x, popup_y), vec2_t(popup_x + popup_width, popup_y + popup_height), color_t(0.3, 0.3, 0.3, 0.8 * fade_alpha), 8)
        
        local picker_size = 150
        local picker_x = popup_x + 10
        local picker_y = popup_y + 10
        
        render.rect_filled(vec2_t(picker_x, picker_y), vec2_t(picker_x + picker_size, picker_y + picker_size), color_t(0.2, 0.2, 0.2, 0.5 * fade_alpha), 4)
        
        for y = 0, picker_size do
            local t = y / picker_size
            local top_color = picker:hsv_to_rgb({picker.hsv[1], 1, 1 - t, 1})
            local bottom_color = picker:hsv_to_rgb({picker.hsv[1], 0, 1 - t, 1})
            top_color.a = 1 * fade_alpha
            bottom_color.a = 1 * fade_alpha
            
            render.rect_filled_fade(vec2_t(picker_x, picker_y + y), vec2_t(picker_x + picker_size, picker_y + y + 1), bottom_color, top_color, top_color, bottom_color)
        end
        
        local circle_x = picker_x + picker_size * picker.hsv[2]
        local circle_y = picker_y + picker_size * (1 - picker.hsv[3])
        local circle_radius = 4
        
        render.circle_filled(vec2_t(circle_x, circle_y), circle_radius + 1, 16, color_t(0, 0, 0, 0.9 * fade_alpha))
        render.circle_filled(vec2_t(circle_x, circle_y), circle_radius, 16, color_t(1, 1, 1, 1 * fade_alpha))
        
        local hue_x = picker_x + picker_size + 8
        local hue_y = picker_y
        local hue_width = 10
        local hue_height = picker_size
        
        render.rect_filled(vec2_t(hue_x, hue_y), vec2_t(hue_x + hue_width, hue_y + hue_height), color_t(0.2, 0.2, 0.2, 0.5 * fade_alpha), 4)
        
        local rainbow_colors = {
            color_t(1, 0, 0, 1), color_t(1, 1, 0, 1), color_t(0, 1, 0, 1),
            color_t(0, 1, 1, 1), color_t(0, 0, 1, 1), color_t(1, 0, 1, 1), color_t(1, 0, 0, 1)
        }
        
        for i = 1, #rainbow_colors - 1 do
            local step = 1 / (#rainbow_colors - 1)
            local segment_height = hue_height * step
            local bar_pos = vec2_t(hue_x, hue_y + (i - 1) * segment_height)
            local color1 = rainbow_colors[i]
            local color2 = rainbow_colors[i + 1]
            color1.a = 1 * fade_alpha
            color2.a = 1 * fade_alpha
            
            render.rect_filled_fade(
                bar_pos,
                bar_pos + vec2_t(hue_width, segment_height),
                color1, color1, color2, color2
            )
        end
        
        local indicator_y_hue = hue_y + picker.hsv[1] * hue_height
        render.rect_filled(vec2_t(hue_x - 2, indicator_y_hue - 2), vec2_t(hue_x + hue_width + 2, indicator_y_hue + 2), color_t(1, 1, 1, 1 * fade_alpha), 3)
        render.rect(vec2_t(hue_x - 2, indicator_y_hue - 2), vec2_t(hue_x + hue_width + 2, indicator_y_hue + 2), color_t(0, 0, 0, 0.8 * fade_alpha), 3)
        
        local current_color = picker:hsv_to_rgb(picker.hsv)
        
        if has_alpha then
            local alpha_x = hue_x + hue_width + 8
            local alpha_y = hue_y
            local alpha_width = 10
            local alpha_height = picker_size
            
            render.rect_filled(vec2_t(alpha_x, alpha_y), vec2_t(alpha_x + alpha_width, alpha_y + alpha_height), color_t(0.2, 0.2, 0.2, 0.5 * fade_alpha), 4)
            
            for y = 0, alpha_height do
                local a = y / alpha_height
                local final_color = color_t(
                    current_color.r * a,
                    current_color.g * a,
                    current_color.b * a,
                    a
                )
                final_color.a = 1 * fade_alpha
                
                render.rect_filled(
                    vec2_t(alpha_x, alpha_y + y),
                    vec2_t(alpha_x + alpha_width, alpha_y + y + 1),
                    final_color, 0
                )
            end
            
            local indicator_y_alpha = alpha_y + picker.value.a * alpha_height
            render.rect_filled(vec2_t(alpha_x - 2, indicator_y_alpha - 2), vec2_t(alpha_x + alpha_width + 2, indicator_y_alpha + 2), color_t(1, 1, 1, 1 * fade_alpha), 3)
            render.rect(vec2_t(alpha_x - 2, indicator_y_alpha - 2), vec2_t(alpha_x + alpha_width + 2, indicator_y_alpha + 2), color_t(0, 0, 0, 0.8 * fade_alpha), 3)
            
            picker.alpha_bounds = {
                x = alpha_x,
                y = alpha_y,
                w = alpha_width,
                h = alpha_height
            }
        else
            picker.alpha_bounds = nil
        end
        
        local buttons_total_width = has_alpha and (popup_width - 30) or (popup_width - 20)
        local button_width_alpha = buttons_total_width / 2 + 1
        local button_width_no_alpha = buttons_total_width / 2 - 4.5
        local button_width = has_alpha and button_width_alpha or button_width_no_alpha
        local button_height = 22
        local buttons_y = popup_y + popup_height - button_height - 8
        
        local copy_button_x = popup_x + 10
        local paste_button_x = copy_button_x + button_width + 10
        
        local copy_press = picker.copy_press or false
        local copy_bg_color = color_t(0.3, 0.3, 0.3, 0.9 * fade_alpha)
        if copy_press then
            copy_bg_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha)
        end
        
        render.rect_filled(vec2_t(copy_button_x, buttons_y), vec2_t(copy_button_x + button_width, buttons_y + button_height), copy_bg_color, 4)
        
        local copy_text_width = get_text_width(fonts.StandartFont, "Copy")
        render.text("Copy", fonts.StandartFont, vec2_t(copy_button_x + (button_width - copy_text_width) / 2, buttons_y + (button_height - 14) / 2), color_t(0.95, 0.95, 0.95, 0.95 * fade_alpha))
        
        local paste_press = picker.paste_press or false
        local paste_bg_color = color_t(0.3, 0.3, 0.3, 0.9 * fade_alpha)
        if paste_press then
            paste_bg_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha)
        end
        
        render.rect_filled(vec2_t(paste_button_x, buttons_y), vec2_t(paste_button_x + button_width, buttons_y + button_height), paste_bg_color, 4)
        
        local paste_text_width = get_text_width(fonts.StandartFont, "Paste")
        render.text("Paste", fonts.StandartFont, vec2_t(paste_button_x + (button_width - paste_text_width) / 2, buttons_y + (button_height - 14) / 2), color_t(0.95, 0.95, 0.95, 0.95 * fade_alpha))
        
        picker.popup_bounds = {
            x = popup_x,
            y = popup_y,
            w = popup_width,
            h = popup_height
        }
        picker.picker_bounds = {
            x = picker_x,
            y = picker_y,
            w = picker_size,
            h = picker_size
        }
        picker.hue_bounds = {
            x = hue_x,
            y = hue_y,
            w = hue_width,
            h = hue_height
        }
        picker.copy_bounds = {
            x = copy_button_x,
            y = buttons_y,
            w = button_width,
            h = button_height
        }
        picker.paste_bounds = {
            x = paste_button_x,
            y = buttons_y,
            w = button_width,
            h = button_height
        }
    end

    local function draw_color_picker(picker, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not picker.visible then return end

        local fade_alpha = alpha * (picker.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local text_y = parent_pos.y + picker.y + (picker.height / 2) - 6
        local text_color = picker.text_hovered and color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha) or color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
        render.text(picker.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), text_color)
        
        local preview_size = 16
        local preview_x = parent_pos.x + parent_size_x - parent_right_padding - preview_size
        local preview_y = parent_pos.y + picker.y + (picker.height - preview_size) / 2 + 2.5
        
        local preview_color = color_t(picker.value.r, picker.value.g, picker.value.b, picker.value.a * fade_alpha)
        render.rect_filled(vec2_t(preview_x, preview_y), vec2_t(preview_x + preview_size, preview_y + preview_size), preview_color, 3)
        render.rect(vec2_t(preview_x, preview_y), vec2_t(preview_x + preview_size, preview_y + preview_size), color_t(0.3, 0.3, 0.3, 0.8 * fade_alpha), 3)
        
        picker.preview_bounds = {
            x = preview_x,
            y = preview_y,
            w = preview_size,
            h = preview_size
        }
        
        if picker.opened and picker == active_selectable then
            draw_color_picker_popup(picker, parent_pos, parent_right_padding, parent_size_x, fade_alpha)
        end
    end

    local function draw_input(inp, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha, x_off)
        if not inp.visible then return end

        local fade_alpha = alpha * (inp.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local text_y = parent_pos.y + inp.y + (inp.height / 2) - 6
        local text_color = inp.text_hovered and color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha) or color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
        render.text(inp.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), text_color)
        
        local label_width = 100  
        local input_width = inp.width
        local input_x = x_off and parent_pos.x + parent_left_padding + label_width + 10 + x_off or parent_pos.x + parent_left_padding + label_width + 10
        local input_y = parent_pos.y + inp.y + (inp.height - 20) / 2 + 2.5
        
        local bg_color = inp.interacting and color_t(0.25, 0.25, 0.25, 0.9 * fade_alpha) or color_t(0.2, 0.2, 0.2, 0.8 * fade_alpha)
        render.rect_filled(vec2_t(input_x, input_y), vec2_t(input_x + input_width, input_y + 20), bg_color, 4)
        
        render.push_clip_rect(vec2_t(input_x + 3, input_y + 2), vec2_t(input_x + input_width - 3, input_y + 18))
        
        local max_text_width = input_width - 8
        local ellipsis = "..."
        local ellipsis_width = get_text_width(fonts.StandartFont, ellipsis)
        
        if inp.interacting then
            local text_before_cursor = inp.value:sub(1, inp.cursor_pos - 1)
            local text_after_cursor = inp.value:sub(inp.cursor_pos)
            
            local before_width = get_text_width(fonts.StandartFont, text_before_cursor)
            local after_width = get_text_width(fonts.StandartFont, text_after_cursor)
            local full_width = get_text_width(fonts.StandartFont, inp.value)
            
            if before_width - inp.scroll_offset > max_text_width - 10 then
                inp.scroll_offset = before_width - max_text_width + 10
            elseif before_width - inp.scroll_offset < 5 then
                inp.scroll_offset = math.max(0, before_width - 5)
            end
            
            inp.scroll_offset = math.max(0, math.min(inp.scroll_offset, math.max(0, full_width - max_text_width + 10)))
            
            local visible_text = ""
            local cursor_offset = before_width - inp.scroll_offset
            
            local show_start_ellipsis = inp.scroll_offset > 0
            
            if show_start_ellipsis then
                visible_text = ellipsis
                cursor_offset = cursor_offset + ellipsis_width
            end
            
            local remaining_width = max_text_width - (show_start_ellipsis and ellipsis_width or 0)
            local temp_text = ""
            local temp_width = 0
            local start_pos = 1
            
            if inp.scroll_offset > 0 then
                local accumulated = 0
                for i = 1, #inp.value do
                    local char = inp.value:sub(i, i)
                    local char_width = get_text_width(fonts.StandartFont, char)
                    if accumulated + char_width > inp.scroll_offset then
                        start_pos = i
                        break
                    end
                    accumulated = accumulated + char_width
                end
            end
            
            for i = start_pos, #inp.value do
                local char = inp.value:sub(i, i)
                local char_width = get_text_width(fonts.StandartFont, char)
                if temp_width + char_width <= remaining_width then
                    temp_text = temp_text .. char
                    temp_width = temp_width + char_width
                else
                    break
                end
            end
            
            visible_text = visible_text .. temp_text
            
            if get_text_width(fonts.StandartFont, visible_text) > max_text_width then
                local final_text = ""
                local final_width = 0
                for i = 1, #visible_text do
                    local char = visible_text:sub(i, i)
                    local char_width = get_text_width(fonts.StandartFont, char)
                    if final_width + char_width <= max_text_width then
                        final_text = final_text .. char
                        final_width = final_width + char_width
                    else
                        break
                    end
                end
                visible_text = final_text
            end
            
            render.text(visible_text, fonts.StandartFont, vec2_t(input_x + 4, input_y + 2), color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha))
            
            if not inp.last_blink then
                inp.last_blink = os.clock()
                inp.show_cursor = true
            end
            
            local current_time = os.clock()
            if current_time - inp.last_blink > 0.5 then
                inp.last_blink = current_time
                inp.show_cursor = not inp.show_cursor
            end
            
            if inp.show_cursor then
                local cursor_x = input_x + 4 + cursor_offset - (show_start_ellipsis and ellipsis_width or 0)
                cursor_x = math.max(input_x + 4, math.min(cursor_x, input_x + input_width - 4))

                render.rect_filled(vec2_t(cursor_x - 1, input_y + 4), vec2_t(cursor_x, input_y + 16), color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha), 1)
            end
        else
            local display_text = inp.value
            local is_placeholder = false
            
            if display_text == "" then
                display_text = inp.placeholder
                is_placeholder = true
            end
            
            local text_color_display = is_placeholder and color_t(0.5, 0.5, 0.5, 0.7 * fade_alpha) or color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
            
            local full_width = get_text_width(fonts.StandartFont, display_text)
            if full_width > max_text_width then
                local temp_text = ""
                local temp_width = 0
                for i = 1, #display_text do
                    local char = display_text:sub(i, i)
                    local char_width = get_text_width(fonts.StandartFont, char)
                    if temp_width + char_width + ellipsis_width <= max_text_width then
                        temp_text = temp_text .. char
                        temp_width = temp_width + char_width
                    else
                        break
                    end
                end
                display_text = temp_text .. ellipsis
            end
            
            render.text(display_text, fonts.StandartFont, vec2_t(input_x + 4, input_y + 2), text_color_display)
        end
        
        render.pop_clip_rect()
    end

    local function draw_hotkey(hotkey, parent_pos, parent_left_padding, parent_right_padding, parent_size_x, alpha)
        if not hotkey.visible then return end

        local fade_alpha = alpha * (hotkey.current_alpha or 1)
        if fade_alpha <= 0.01 then return end
        
        local key_display = "N/A"
        if hotkey.waiting_for_key then
            key_display = "..."
        elseif hotkey.key == 0 then
            key_display = "N/A"
        elseif hotkey.key then
            key_display = GetKeyName(hotkey.key)
        end
        
        local button_width = hotkey.current_button_width or 50
        
        local bounds = {
            text = {
                x = parent_pos.x + parent_left_padding,
                y = parent_pos.y + hotkey.y,
                w = get_text_width(fonts.StandartFont, hotkey.label),
                h = hotkey.height
            },
            button = {
                x = parent_pos.x + parent_size_x - parent_right_padding - button_width,
                y = parent_pos.y + hotkey.y + (hotkey.height - 22) / 2 + 1,
                w = button_width,
                h = 22
            }
        }
        
        hotkey._last_bounds = bounds
        hotkey._last_alpha = fade_alpha
        
        local text_y = parent_pos.y + hotkey.y + (hotkey.height / 2) - 7
        local text_color = hotkey.text_hovered and color_t(accent_color.r, accent_color.g, accent_color.b, 0.9 * fade_alpha) or color_t(0.9, 0.9, 0.9, 0.9 * fade_alpha)
            
        render.text(hotkey.label, fonts.StandartFont, vec2_t(parent_pos.x + parent_left_padding, text_y), text_color)
        
        local button_color = color_t(0.2, 0.2, 0.2, 0.9 * fade_alpha)
        if hotkey.mode_popup_opened then
            button_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.25 * fade_alpha)
        end
        
        render.rect_filled(vec2_t(bounds.button.x, bounds.button.y), vec2_t(bounds.button.x + bounds.button.w, bounds.button.y + bounds.button.h), button_color, 4)
        
        local text_width = get_text_width(fonts.StandartFont, key_display)
        local text_x = bounds.button.x + (button_width - text_width) / 2
        local text_y_pos = bounds.button.y + (bounds.button.h - 10) / 2 - 1.5
        
        local key_color
        if hotkey.waiting_for_key then
            key_color = color_t(0.6, 0.6, 0.6, 0.8 * fade_alpha)
        else
            key_color = color_t(0.8, 0.8, 0.8, 0.8 * fade_alpha)
        end
        
        render.text(key_display, fonts.StandartFont, vec2_t(text_x, text_y_pos), key_color)
        
        if hotkey.mode_popup_opened and hotkey.mode_popup_progress and hotkey.mode_popup_progress > 0 then
            table.insert(pending_hotkey_popups, hotkey)
        end
    end

    local function draw_hotkey_mode_popup(hotkey)
        if not hotkey.mode_popup_opened or not hotkey.mode_popup_progress or hotkey.mode_popup_progress <= 0 then return end
        if not hotkey._last_bounds then return end
        
        local bounds = hotkey._last_bounds
        local fade_alpha = hotkey._last_alpha or 1
        
        if not hotkey.available_modes then
            hotkey.available_modes = {true, true, true}
            hotkey.mode_names = {"Always", "Hold", "Toggle"}
        end
        
        local popup_bounds = get_mode_popup_bounds(hotkey, bounds.button)
        local current_progress = hotkey.mode_popup_progress
        local current_height = popup_bounds.h * current_progress
        
        if current_height > 0 then
            local popup_alpha = fade_alpha * math.min(1, current_progress * 1.5)
            
            render.rect_filled(vec2_t(popup_bounds.x, popup_bounds.y), vec2_t(popup_bounds.x + popup_bounds.w, popup_bounds.y + current_height), color_t(0.15, 0.15, 0.15, 0.95 * popup_alpha), 6)
            render.rect(vec2_t(popup_bounds.x, popup_bounds.y), vec2_t(popup_bounds.x + popup_bounds.w, popup_bounds.y + current_height), color_t(0.3, 0.3, 0.3, 0.8 * popup_alpha), 6)
            
            local selected_display_idx = 1
            if hotkey.mode then
                selected_display_idx = 1
                for i = 1, 3 do
                    if hotkey.available_modes[i] then
                        if i == hotkey.mode then break end
                        selected_display_idx = selected_display_idx + 1
                    end
                end
            end
            
            for i, mode_name in ipairs(popup_bounds.mode_names) do
                local item_y = popup_bounds.y + (i - 1) * 24
                if item_y >= popup_bounds.y and item_y + 22 <= popup_bounds.y + current_height then
                    local is_selected = (i == selected_display_idx)
                    
                    local item_color
                    if is_selected then
                        item_color = color_t(accent_color.r, accent_color.g, accent_color.b, 1 * popup_alpha)
                    elseif hotkey.hovered_mode_index == i then
                        item_color = color_t(accent_color.r, accent_color.g, accent_color.b, 0.7 * popup_alpha)
                    else
                        item_color = color_t(0.7, 0.7, 0.7, 0.7 * popup_alpha)
                    end
                    
                    render.text(mode_name, fonts.StandartFont, vec2_t(popup_bounds.x + 8, item_y + 3), item_color)
                end
            end
        end
    end

    universal_setting = function(element, action, option, value1, value2)
        if action == "get" then
            if option == "status" or option == "is_open" then
                return element.is_open
            elseif option == "pinned" or option == "is_pinned" then
                return element.is_pinned
            elseif option == "pos" then
                return element.pos
            elseif option == "size" then
                return element.size
            elseif option == "border" then
                return element.border
            elseif option == "border_thickness" then
                return element.border_thickness
            elseif option == "bg_color" then
                return element.bg_color
            elseif option == "border_color" then
                return element.border_color
            elseif option == "border_radius" then
                return element.border_radius
            elseif option == "name" then
                return element.name
            elseif option == "z_index" then
                return element.z_index
            elseif option == "constraints" then
                return element.constraints
            elseif option == "animation_speed" then
                return element.animation_speed
            elseif option == "visible" then
                return element.visible
            elseif option == "text_color" then
                return element.text_color
            elseif option == "active_text_color" then
                return element.active_text_color
            elseif option == "hover_text_color" then
                return element.hover_text_color
            elseif option == "icon" then
                return element.icon
            elseif option == "icon_color" then
                return element.icon_color
            elseif option == "active_icon_color" then
                return element.active_icon_color
            elseif option == "hover_icon_color" then
                return element.hover_icon_color
            else
                return element[option]
            end
            
        elseif action == "set" then
            if option == "status" or option == "is_open" then
                if value1 then
                    if element.open then element:open() end
                else
                    if element.close then element:close() end
                end
            elseif option == "pinned" or option == "is_pinned" then
                element.is_pinned = value1
                if value1 and element.bring_to_front then element:bring_to_front() end
            elseif option == "pos" then
                element.pos = value1
                if element.update_position then element:update_position() end
            elseif option == "size" then
                element.size = value1
                if element.update_position then element:update_position() end
            elseif option == "border" then
                element.border = value1
                if not value1 then
                    element.border_thickness_saved = element.border_thickness
                    element.border_thickness = 0
                else
                    element.border_thickness = element.border_thickness_saved or 1
                end
            elseif option == "border_thickness" then
                element.border_thickness = value1
                element.border = value1 > 0
            elseif option == "bg_color" then
                element.bg_color = value1
                if element.bg_alpha then element.bg_alpha = value1.a end
            elseif option == "border_color" then
                element.border_color = value1
                if element.border_alpha then element.border_alpha = value1.a end
            elseif option == "border_radius" then
                element.border_radius = value1
            elseif option == "name" then
                element.name = value1
            elseif option == "constraints" then
                if value1 and value2 then
                    element.constraints = {min_x = value1.x, min_y = value1.y, max_x = value2.x, max_y = value2.y}
                    if element.update_position then element:update_position() end
                end
            elseif option == "animation_speed" then
                element.animation_speed = value1
            elseif option == "visible" then
                element.visible = value1
            elseif option == "text_color" then
                element.text_color = value1
            elseif option == "active_text_color" then
                element.active_text_color = value1
            elseif option == "hover_text_color" then
                element.hover_text_color = value1
            elseif option == "icon" then
                element.icon = value1
            elseif option == "icon_color" then
                element.icon_color = value1
            elseif option == "active_icon_color" then
                element.active_icon_color = value1
            elseif option == "hover_icon_color" then
                element.hover_icon_color = value1
            else
                element[option] = value1
            end
            return element
            
        elseif action == "toggle" then
            if option == "status" or option == "is_open" then
                if element.is_open then
                    if element.close then element:close() end
                else
                    if element.open then element:open() end
                end
            elseif option == "pinned" or option == "is_pinned" then
                element.is_pinned = not element.is_pinned
                if element.is_pinned and element.bring_to_front then element:bring_to_front() end
            elseif option == "border" then
                local new_border = not element.border
                if new_border then
                    element.border_thickness = element.border_thickness_saved or 1
                else
                    element.border_thickness_saved = element.border_thickness
                    element.border_thickness = 0
                end
                element.border = new_border
            end
            return element
            
        elseif action == "close" then
            if element.close then element:close() end
            return element
        elseif action == "open" then
            if element.open then element:open() end
            return element
        elseif action == "focus" or action == "bring_to_front" then
            if element.bring_to_front then element:bring_to_front() end
            return element
        end
        
        return element
    end

    create_subtab = function(parent_tab, name, config)
        config = config or {}
        local subtab = {
            parent = parent_tab,
            name = name,
            pos = vec2_t(0, 0),
            size = vec2_t(parent_tab.size.x - 10, config.height or 28),
            text_color = config.text_color or color_t(0.5, 0.5, 0.5, 1),
            active_text_color = config.active_text_color or color_t(1, 1, 1, 1),
            hover_text_color = config.hover_text_color or color_t(0.8, 0.8, 0.8, 1),
            type = "subtab",
            is_hovered = false,
            is_active = false,
            callback = config.callback,
            groups = {},
            render_callback = nil,
            current_text_color = color_t(0.5, 0.5, 0.5, 1),
            alpha = 0,
            fade_progress = 1,
            click_processed = false,
            disabled = config.disabled or false,
        }

        function subtab:update_group_positions()
            for _, group in ipairs(self.groups) do
                if group.update_position then group:update_position() end
            end
        end

        function subtab:update_position()
            local idx = 0
            for i, st in ipairs(self.parent.subtabs) do
                if st == self then idx = i - 1; break end
            end
            local base_x = self.parent.pos.x + 35
            local base_y = self.parent.pos.y + self.parent.size.y + 5
            local subtab_spacing = -5
            local y_offset = (idx * (self.size.y + subtab_spacing)) * self.parent.expand_progress
            self.pos = vec2_t(base_x, base_y + y_offset)
            self:update_group_positions()
        end

        function subtab:Disable(value)
            self.disabled = (value ~= false)
            if self.disabled then
                for _, group in ipairs(self.groups) do
                    for _, sel in ipairs(group.selectables or {}) do
                        if sel.opened then
                            if sel.dropdown_anim then sel.dropdown_anim:stop() end
                            sel.opened = false
                            sel.dropdown_height_progress = 0
                        end
                        sel.click_processed = false
                    end
                    for _, cp in ipairs(group.color_pickers or {}) do
                        if cp.opened then
                            if cp.dropdown_anim then cp.dropdown_anim:stop() end
                            cp.opened = false
                            cp.dropdown_height_progress = 0
                        end
                    end
                end
                if active_selectable then
                    if active_selectable.opened then
                        if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                        active_selectable.opened = false
                        active_selectable.dropdown_height_progress = 0
                    end
                    active_selectable = nil
                end
                if active_slider then active_slider.dragging = false; active_slider = nil end
                if active_checkbox then active_checkbox = nil end
            end
            return self
        end

        function subtab:update_alpha()
            self.alpha = self.parent.expand_progress
        end

        function subtab:update_colors()
            local target = self.text_color
            if self.disabled then
                target = color_t(0.4, 0.4, 0.4, 0.55)
            elseif self.is_active then
                target = color_t(accent_color.r, accent_color.g, accent_color.b, 1)
            elseif self.is_hovered then
                target = color_t(accent_color.r, accent_color.g, accent_color.b, 0.9)
            end
            
            self.current_text_color.r = self.current_text_color.r + (target.r - self.current_text_color.r) * 0.2
            self.current_text_color.g = self.current_text_color.g + (target.g - self.current_text_color.g) * 0.2
            self.current_text_color.b = self.current_text_color.b + (target.b - self.current_text_color.b) * 0.2
            self.current_text_color.a = self.current_text_color.a + (target.a - self.current_text_color.a) * 0.2
        end

        function subtab:activate()
            if self.disabled then return end

            if active_selectable then
                active_selectable.opened = false
                active_selectable = nil
            end
            for _, group in ipairs(self.groups) do
                for _, sel in ipairs(group.selectables) do
                    sel.opened = false
                end
            end
            
            if self.parent.active_subtab == self then return end
            
            if self.parent.active_subtab then
                for _, group in ipairs(self.parent.active_subtab.groups) do
                    group:start_fade(0, 0.35)
                end
                self.parent.active_subtab.is_active = false
            end

            self.is_active = true
            self.parent.active_subtab = self

            for _, group in ipairs(self.groups) do
                group.visible = true
                if group.fade_progress and group.fade_progress > 0.01 then
                    group:start_fade(1, 0.35)
                else
                    group.fade_progress = 0
                    group:start_fade(1, 0.35)
                end
            end

            if self.callback then self.callback(self) end
        end

        function subtab:force_activate()
            self.is_active = true
            for _, group in ipairs(self.groups) do
                group.visible = true
                group.fade_progress = 1
                group:update_element_alphas()
            end
        end

        function subtab:force_show_groups()
            for _, group in ipairs(self.groups) do
                group.visible = true
                group.fade_progress = 1
                group:update_element_alphas()
                if group.update_position then
                    group:update_position()
                end
            end
        end

        function subtab:render(parent_alpha)
            self:update_position()
            self:update_alpha()
            self:update_colors()

            if self.alpha <= 0 then return end

            local render_color = color_t(
                self.current_text_color.r,
                self.current_text_color.g,
                self.current_text_color.b,
                self.current_text_color.a * self.alpha * (parent_alpha or 1)
            )

            render.text(self.name, fonts.StandartFont, self.pos, render_color)

            for _, group in ipairs(self.groups) do
                if group.visible or group.is_animating or group.fade_progress > 0 then
                    group:render(self.alpha * (parent_alpha or 1))
                end
            end

            if self.render_callback then
                self.render_callback(self)
            end
        end

        function subtab:update(mouse_pos, mouse_clicked, mouse_left)
            if not utils.IsCS2Foreground() then return end

            self:update_alpha()
            if self.alpha <= 0 then return end

            self:update_position()
            
            if self.disabled then
                self.is_hovered = false
                for _, group in ipairs(self.groups) do
                    if group.visible or group.is_animating or group.fade_progress > 0 then
                        group:update(mouse_pos, mouse_clicked, mouse_left)
                    end
                end
                return
            end
            
            self.is_hovered = is_hovering({x = self.pos.x, y = self.pos.y + 2.5, w = self.size.x - 20, h = self.size.y - 5}, mouse_pos)
            if self.is_hovered then
                any_interactive_hovered = true
            end
            
            local blocked = is_input_blocked()
            
            if self.is_hovered and mouse_clicked and not active_slider and not active_checkbox and not blocked then
                self:activate()
            end

            for _, group in ipairs(self.groups) do
                if group.visible or group.is_animating or group.fade_progress > 0 then
                    group:update(mouse_pos, mouse_clicked, mouse_left)
                end
            end
        end

        function subtab:create_group(offset, size, config)
            return create_group(self, offset, size, config)
        end

        function subtab:setting(action, option, value1, value2)
            if action == "get" then
                if option == "name" then return self.name end
            elseif action == "set" then
                if option == "name" then self.name = value1 end
            end
            return self
        end

        function subtab:render_func(callback)
            self.render_callback = callback
            return self
        end

        function subtab:force_hide()
            for _, group in ipairs(self.groups) do group:force_hide() end
        end

        function subtab:force_show()
            for _, group in ipairs(self.groups) do group:force_show() end
        end

        table.insert(parent_tab.subtabs, subtab)

        local should_be_active = false

        if #parent_tab.subtabs == 1 and parent_tab.parent and parent_tab.parent.active_tab == parent_tab then
            should_be_active = true
            parent_tab.active_subtab = subtab
            subtab.is_active = true
        end

        if should_be_active then
            for _, group in ipairs(subtab.groups) do
                group.visible = true
                group.fade_progress = 1
                group:update_element_alphas()
            end
        else
            for _, group in ipairs(subtab.groups) do
                group.visible = false
                group.fade_progress = 0
                group:update_element_alphas()
            end
        end

        return subtab
    end

    create_tab = function(parent, name, icon, config)
        config = config or {}
        if parent.type ~= "group" then return nil end

        local tab_height = config.height or 35
        local tab_index = #parent.tabs + 1

        local tab = {
            parent = parent,
            name = name or "Tab",
            icon = icon,
            pos = vec2_t(parent.pos.x + 5, parent.pos.y + 5),
            size = vec2_t(parent.size.x - 10, tab_height),
            text_color = config.text_color or color_t(0.7, 0.7, 0.7, 1),
            active_text_color = config.active_text_color or color_t(1, 1, 1, 1),
            hover_text_color = config.hover_text_color or color_t(0.9, 0.9, 0.9, 1),
            icon_color = config.icon_color or color_t(0.7, 0.7, 0.7, 1),
            active_icon_color = config.active_icon_color or color_t(1, 1, 1, 1),
            hover_icon_color = config.hover_icon_color or color_t(0.9, 0.9, 0.9, 1),
            type = "tab",
            is_hovered = false,
            tab_index = tab_index,
            current_text_color = color_t(0.7, 0.7, 0.7, 1),
            current_icon_color = color_t(0.7, 0.7, 0.7, 1),
            callback = config.callback,
            groups = {},
            subtabs = {},
            active_subtab = nil,
            is_expanded = false,
            expand_progress = 0,
            expand_animation = nil,
            collapse_animation = nil,
            render_callback = nil,
            fade_progress = 1,
            click_processed = false,
            disabled = config.disabled or false,
        }

        function tab:Disable(value)
            self.disabled = (value ~= false)
            if self.disabled then
                for _, group in ipairs(self.groups) do
                    for _, sel in ipairs(group.selectables or {}) do
                        if sel.opened then
                            if sel.dropdown_anim then sel.dropdown_anim:stop() end
                            sel.opened = false
                            sel.dropdown_height_progress = 0
                        end
                        sel.click_processed = false
                    end
                    for _, cp in ipairs(group.color_pickers or {}) do
                        if cp.opened then
                            if cp.dropdown_anim then cp.dropdown_anim:stop() end
                            cp.opened = false
                            cp.dropdown_height_progress = 0
                        end
                    end
                end
                for _, subtab in ipairs(self.subtabs) do
                    for _, group in ipairs(subtab.groups or {}) do
                        for _, sel in ipairs(group.selectables or {}) do
                            if sel.opened then
                                if sel.dropdown_anim then sel.dropdown_anim:stop() end
                                sel.opened = false
                                sel.dropdown_height_progress = 0
                            end
                            sel.click_processed = false
                        end
                        for _, cp in ipairs(group.color_pickers or {}) do
                            if cp.opened then
                                if cp.dropdown_anim then cp.dropdown_anim:stop() end
                                cp.opened = false
                                cp.dropdown_height_progress = 0
                            end
                        end
                    end
                end
                if active_selectable then
                    if active_selectable.opened then
                        if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                        active_selectable.opened = false
                        active_selectable.dropdown_height_progress = 0
                    end
                    active_selectable = nil
                end
                if active_slider then active_slider.dragging = false; active_slider = nil end
                if active_checkbox then active_checkbox = nil end
            end
            return self
        end

        function tab:update_position()
            local idx = self.tab_index - 1
            local tab_spacing = 3
            local y_offset = idx * (self.size.y + tab_spacing)
            
            for i = 1, self.tab_index - 1 do
                local prev_tab = self.parent.tabs[i]
                if prev_tab and #prev_tab.subtabs > 0 then
                    local subtab_spacing = 2
                    local subtab_height = 28
                    local subtabs_total_height = #prev_tab.subtabs * (subtab_height + subtab_spacing)
                    local after_subtabs_margin = -15
                    y_offset = y_offset + (subtabs_total_height + after_subtabs_margin) * prev_tab.expand_progress
                end
            end

            self.pos = vec2_t(self.parent.pos.x + 5, self.parent.pos.y + 5 + y_offset)
            for _, subtab in ipairs(self.subtabs) do
                subtab:update_position()
            end

            for _, group in ipairs(self.groups) do
                if group.update_position then group:update_position() end
            end
        end

        function tab:update_all_tabs_positions()
            for i, t in ipairs(self.parent.tabs) do t:update_position() end
            if self.parent.update_indicator then self.parent:update_indicator() end
        end

        function tab:expand()
            if self.is_expanded then return end
            self.is_expanded = true

            if self.active_subtab then
                for _, group in ipairs(self.active_subtab.groups) do
                    group.visible = true
                end
            end

            if self.expand_animation then self.expand_animation:stop() end
            local start = self.expand_progress
            self.expand_animation = anim.animate_to(self, "expand_progress", start, 1, 0.3, "cubic_out")
            self.expand_animation.on_update = function()
                self:update_all_tabs_positions()
                self.parent:update_indicator()
            end

            self.expand_animation.on_complete = function()
                if #self.subtabs > 0 and not self.active_subtab then
                    self.subtabs[1]:activate()
                end
            end

            self.expand_animation:start()
        end

        function tab:collapse()
            if not self.is_expanded then return end
            self.is_expanded = false

            if self.collapse_animation then self.collapse_animation:stop() end
            local start = self.expand_progress

            self.collapse_animation = anim.animate_to(self, "expand_progress", start, 0, 0.3, "cubic_in")
            self.collapse_animation.on_update = function()
                self:update_all_tabs_positions()
                self.parent:update_indicator()
            end

            self.collapse_animation.on_complete = function()
                if self.active_subtab then
                    self.active_subtab.is_active = false
                    self.active_subtab = nil
                end
            end

            self.collapse_animation:start()
        end

        function tab:switch_to_this()
            if self.disabled then return end

            if active_selectable then
                active_selectable.opened = false
                active_selectable = nil
            end
            
            for _, group in ipairs(self.groups) do
                for _, sel in ipairs(group.selectables) do
                    sel.opened = false
                end
            end
            
            for _, subtab in ipairs(self.subtabs) do
                for _, group in ipairs(subtab.groups) do
                    for _, sel in ipairs(group.selectables) do
                        sel.opened = false
                    end
                end
            end
            
            if self.parent.active_tab == self then return end
            
            for _, other_tab in ipairs(self.parent.tabs) do
                if other_tab ~= self then
                    for _, group in ipairs(other_tab.groups) do
                        group:start_fade(0, 0.35)
                    end
                    for _, subtab in ipairs(other_tab.subtabs) do
                        for _, group in ipairs(subtab.groups) do
                            group:start_fade(0, 0.35)
                        end
                    end
                    if #other_tab.subtabs > 0 then
                        other_tab:collapse()
                    end
                end
            end
            
            self.parent.active_tab = self
            
            if #self.subtabs > 0 and not self.active_subtab then
                self.active_subtab = self.subtabs[1]
                self.subtabs[1].is_active = true
            end
            
            for _, group in ipairs(self.groups) do
                group.fade_progress = 0
                group.visible = true
                group:start_fade(1, 0.35)
            end
            
            if self.active_subtab and not self.is_expanded then
                for _, group in ipairs(self.active_subtab.groups) do
                    group.fade_progress = 0
                    group.visible = true
                    group:start_fade(1, 0.35)
                end
            end
            
            local indicator_offset = (self.tab_index - 1) * (self.size.y + 3)
            for i = 1, self.tab_index - 1 do
                local prev_tab = self.parent.tabs[i]
                if prev_tab and #prev_tab.subtabs > 0 then
                    indicator_offset = indicator_offset + (#prev_tab.subtabs * (28 + 2) * prev_tab.expand_progress)
                end
            end
            self.parent.tab_indicator_target = indicator_offset
            
            if #self.subtabs > 0 then
                self:expand()
            end
            
            if self.callback then self.callback(self) end
        end

        function tab:select()
            self:switch_to_this()
        end

        function tab:select_subtab(subtab_name)
            for _, subtab in ipairs(self.subtabs) do
                if subtab.name == subtab_name then
                    if not self.is_expanded then
                        self:expand()
                        subtab:activate()
                    else
                        subtab:activate()
                    end
                    return true
                end
            end
            return false
        end

        function tab:create_subtab(name, config)
            local new_subtab = create_subtab(self, name, config)
            if #self.subtabs == 1 and self.parent.active_tab == self and self.is_expanded then
                new_subtab:activate()
            end
            return new_subtab
        end

        function tab:update_colors()
            local target_text, target_icon
            if self.disabled then
                target_text = color_t(0.5, 0.5, 0.5, 0.75)
                target_icon = color_t(0.5, 0.5, 0.5, 0.75)
            elseif self.parent.active_tab == self then
                target_text = color_t(accent_color.r, accent_color.g, accent_color.b, 1)
                target_icon = color_t(accent_color.r, accent_color.g, accent_color.b, 1)
            elseif self.is_hovered then
                target_text = color_t(accent_color.r, accent_color.g, accent_color.b, 0.7)
                target_icon = color_t(accent_color.r, accent_color.g, accent_color.b, 0.7)
            else
                target_text = self.text_color
                target_icon = self.icon_color
            end
            self.current_text_color.r = self.current_text_color.r + (target_text.r - self.current_text_color.r) * 0.2
            self.current_text_color.g = self.current_text_color.g + (target_text.g - self.current_text_color.g) * 0.2
            self.current_text_color.b = self.current_text_color.b + (target_text.b - self.current_text_color.b) * 0.2
            self.current_text_color.a = self.current_text_color.a + (target_text.a - self.current_text_color.a) * 0.2
            self.current_icon_color.g = self.current_icon_color.g + (target_icon.g - self.current_icon_color.g) * 0.2
            self.current_icon_color.r = self.current_icon_color.r + (target_icon.r - self.current_icon_color.r) * 0.2
            self.current_icon_color.b = self.current_icon_color.b + (target_icon.b - self.current_icon_color.b) * 0.2
            self.current_icon_color.a = self.current_icon_color.a + (target_icon.a - self.current_icon_color.a) * 0.2
        end

        function tab:render(parent_alpha)
            local alpha = (parent_alpha or 1) * self.fade_progress
            self:update_colors()
            local center_y = self.pos.y + (self.size.y / 2)
            local text_x = self.pos.x + 15
            if self.icon and self.icon ~= "" then
                local icon_color = color_t(self.current_icon_color.r, self.current_icon_color.g,
                                            self.current_icon_color.b, self.current_icon_color.a * alpha)
                render.text(self.icon, fonts.BigIcons, vec2_t(text_x, center_y - 12), icon_color)
                text_x = text_x + 28
            end
            local text_color = color_t(self.current_text_color.r, self.current_text_color.g,
                                        self.current_text_color.b, self.current_text_color.a * alpha)
            render.text(self.name, fonts.BigFont, vec2_t(text_x, center_y - 10), text_color)
            for _, subtab in ipairs(self.subtabs) do
                subtab:render(alpha)
            end
            for _, group in ipairs(self.groups) do
                if group.visible or group.is_animating or group.fade_progress > 0 then
                    group:render(alpha)
                end
            end
            if self.render_callback then
                self.render_callback(self)
            end
        end

        function tab:update(mouse_pos, mouse_clicked, mouse_left)
            if is_blocked_by_gear_popup(self) then return end
            
            if not utils.IsCS2Foreground() then return end
            
            if self.disabled then
                self.is_hovered = false
                for _, subtab in ipairs(self.subtabs) do
                    subtab:update(mouse_pos, mouse_clicked, mouse_left)
                end
                for _, group in ipairs(self.groups) do
                    if group.visible or group.is_animating or group.fade_progress > 0 then
                        group:update(mouse_pos, mouse_clicked, mouse_left)
                    end
                end
                return
            end
            
            self.is_hovered = is_hovering({x = self.pos.x, y = self.pos.y, w = self.size.x, h = self.size.y}, mouse_pos)
            if self.is_hovered then
                any_interactive_hovered = true
            end
            
            local blocked = is_input_blocked()
            
            if self.is_hovered and mouse_clicked and not active_slider and not active_checkbox and not blocked then
                self:select()
            end
            
            for _, subtab in ipairs(self.subtabs) do
                subtab:update(mouse_pos, mouse_clicked, mouse_left)
            end
            for _, group in ipairs(self.groups) do
                if group.visible or group.is_animating or group.fade_progress > 0 then
                    group:update(mouse_pos, mouse_clicked, mouse_left)
                end
            end
        end

        function tab:create_group(offset, size, config)
            return create_group(self, offset, size, config)
        end

        function tab:setting(action, option, value1, value2)
            return universal_setting(self, action, option, value1, value2)
        end

        function tab:render_func(callback)
            self.render_callback = callback
            return self
        end

        function tab:force_hide()
            for _, group in ipairs(self.groups) do group:force_hide() end
            for _, subtab in ipairs(self.subtabs) do
                for _, group in ipairs(subtab.groups) do group:force_hide() end
            end
        end

        function tab:force_show()
            for _, group in ipairs(self.groups) do group:force_show() end
            if self.active_subtab then
                for _, group in ipairs(self.active_subtab.groups) do group:force_show() end
            end
        end

        table.insert(parent.tabs, tab)

        if #parent.tabs == 1 then
            parent.active_tab = tab
            tab.is_active = true
            
            for _, group in ipairs(tab.groups) do
                group.visible = true
                group.fade_progress = 1
                group:update_element_alphas()
            end
            
            if #tab.subtabs > 0 then
                tab:expand()
                if tab.subtabs[1] then
                    tab.active_subtab = tab.subtabs[1]
                    tab.subtabs[1].is_active = true

                    for _, group in ipairs(tab.subtabs[1].groups) do
                        group.visible = true
                        group.fade_progress = 1
                        group:update_element_alphas()
                    end
                end
            end
        else
            for _, group in ipairs(tab.groups) do
                group.visible = false
                group.fade_progress = 0
                group:update_element_alphas()
            end

            for _, subtab in ipairs(tab.subtabs) do
                for _, group in ipairs(subtab.groups) do
                    group.visible = false
                    group.fade_progress = 0
                    group:update_element_alphas()
                end
            end
        end

        for i, t in ipairs(parent.tabs) do t:update_position() end
        return tab
    end

    create_group = function(parent, offset, size, config)
        config = config or {}

        local root = parent
        while root.parent and root.type ~= "window" do
            root = root.parent
        end
        local root_window = (root.type == "window") and root or nil

        local group = {
            parent = parent,
            root_window = root_window,
            offset = offset,
            size = size,
            name = config.name or nil,
            bg_color = config.bg_color or color_t(0.12, 0.12, 0.12, 0.95),
            border_color = config.border_color or color_t(0.25, 0.25, 0.25, 1),
            border_radius = config.border_radius or 4,
            border_thickness = config.border_thickness or 1,
            border = config.border_thickness == nil or (config.border_thickness > 0),
            visible = config.visible ~= false,
            is_animating = false,
            active = false,
            toggle_state = false,
            pos = vec2_t(0, 0),
            type = "group",
            animation_speed = config.animation_speed or 0.15,
            bg_alpha = (config.bg_color or color_t(0.12, 0.12, 0.12, 0.95)).a,
            border_alpha = (config.border_color or color_t(0.25, 0.25, 0.25, 1)).a,
            tabs = {},
            active_tab = nil,
            tab_indicator_pos = 0,
            tab_indicator_target = 0,
            render_callback = nil,
            fade_progress = (config.visible ~= false) and 1 or 0,
            is_fading = false,
            current_fade_anim = nil,
            checkboxes = {},
            sliders = {},
            selectables = {},
            buttons = {},
            labels = {},
            inputs = {},
            color_pickers = {},
            hotkeys = {},
            next_y = config.start_y or 10,
            left_padding = config.left_padding or 10,
            right_padding = config.right_padding or 10,
            slider_width = config.slider_width or 150,
        }

        function group:update_position()
            if self.parent.type == "tab" or self.parent.type == "subtab" then
                if self.root_window then
                    self.pos = vec2_t(self.root_window.pos.x + self.offset.x, self.root_window.pos.y + self.offset.y)
                else
                    self.pos = vec2_t(self.parent.pos.x + self.offset.x, self.parent.pos.y + self.offset.y)
                end
            else
                self.pos = vec2_t(self.parent.pos.x + self.offset.x, self.parent.pos.y + self.offset.y)
            end
            for _, tab in ipairs(self.tabs) do
                if tab.update_position then tab:update_position() end
            end
        end

        function group:update_element_alphas()
            local fade = self.fade_progress
            for _, cb in ipairs(self.checkboxes) do cb.current_alpha = fade end
            for _, sl in ipairs(self.sliders) do sl.current_alpha = fade end
            for _, sel in ipairs(self.selectables) do sel.current_alpha = fade end
            for _, btn in ipairs(self.buttons or {}) do btn.current_alpha = fade end
            for _, lbl in ipairs(self.labels or {}) do lbl.current_alpha = fade end
            for _, inp in ipairs(self.inputs or {}) do inp.current_alpha = fade end
            for _, cp in ipairs(self.color_pickers or {}) do cp.current_alpha = fade end
            for _, hk in ipairs(self.hotkeys or {}) do hk.current_alpha = fade end
        end

        function group:start_fade(target_progress, duration, callback)
            if self.current_fade_anim then self.current_fade_anim:stop() end
            self.is_fading = true
            local start = self.fade_progress or 0
            
            if target_progress > 0.01 then
                self.visible = true
            end
            
            self.current_fade_anim = anim.animate_to(self, "fade_progress", start, target_progress, duration or 0.25, "cubic_in_out")
            self.current_fade_anim.on_update = function() self:update_element_alphas() end
            self.current_fade_anim.on_complete = function()
                self.is_fading = false
                self.current_fade_anim = nil
                if target_progress <= 0.01 then
                    self.visible = false
                end
                if callback then callback() end
            end
            self.current_fade_anim:start()
        end

        function group:fade_out(duration, callback)
            self:start_fade(0, duration or 0.2, callback)
        end

        function group:fade_in(duration, callback)
            self.visible = true
            self.fade_progress = 0
            self:start_fade(1, duration or 0.2, callback)
        end

        function group:update_indicator()
            if not self.active_tab then
                self.tab_indicator_target = 0
                return
            end
            local indicator_offset = 0
            for i = 1, self.active_tab.tab_index - 1 do
                local prev_tab = self.tabs[i]
                indicator_offset = indicator_offset + (prev_tab.size.y + 3)
                if prev_tab and #prev_tab.subtabs > 0 then
                    indicator_offset = indicator_offset + (#prev_tab.subtabs * (28 + 2) * prev_tab.expand_progress)
                end
            end
            self.tab_indicator_target = indicator_offset
        end

        function group:select_tab(tab_name)
            for _, tab in ipairs(self.tabs) do
                if tab.name == tab_name then
                    tab:select()
                    return tab
                end
            end
            return nil
        end

        function group:setting(action, option, value1, value2)
            return universal_setting(self, action, option, value1, value2)
        end

        function group:render_func(callback)
            self.render_callback = callback
            return self
        end

        function group:force_hide()
            if self.is_animating then self.is_animating = false end
            if self.current_fade_anim then self.current_fade_anim:stop() end
            self.visible = false
            self.fade_progress = 0
            self:update_element_alphas()
            self.bg_color = color_t(self.bg_color.r, self.bg_color.g, self.bg_color.b, 0)
            self.border_color = color_t(self.border_color.r, self.border_color.g, self.border_color.b, 0)
        end

        function group:force_show()
            if self.is_animating then self.is_animating = false end
            if self.current_fade_anim then self.current_fade_anim:stop() end
            self.visible = true
            self.fade_progress = 1
            self:update_element_alphas()
            self.bg_color = color_t(self.bg_color.r, self.bg_color.g, self.bg_color.b, self.bg_alpha)
            self.border_color = color_t(self.border_color.r, self.border_color.g, self.border_color.b, self.border_alpha)
        end

        function group:get_active_tab()
            return self.active_tab
        end

        function group:Switch(label, default_value)
            local checkbox = {
                visible = true,
                type = "checkbox",
                label = label,
                value = default_value or false,
                height = 20,
                width = 32,
                toggle_height = 16,
                knob_radius = 6,
                knob_x = default_value and (32 - 6*2 - 2) or 2,
                knob_anim = nil,
                toggle_progress = default_value and 1 or 0,
                y = self.next_y,
                hovered = false,
                text_hovered = false,
                parent = self,
                current_alpha = self.fade_progress,
                disabled = false
            }
            
            function checkbox:Get(index)
                return get_element_value(self, index)
            end

            function checkbox:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 26
                return self
            end

            checkbox.hasSettingsGear = false
            checkbox.gear_callback = nil
            checkbox.gear_opened = false
            checkbox.gear_progress = 0

            function checkbox:Gear(gear_config)
                return add_gear_settings(self, gear_config)
            end

            function checkbox:Disable(value)
                self.disabled = (value ~= false)
                if self.disabled and self.gear_opened then
                    if self.gear_anim then self.gear_anim:stop() end
                    self.gear_opened = false
                    self.gear_progress = 0
                    if active_gear_popup == self then
                        active_gear_popup = nil
                        gear_blocking = false
                    end
                end
                return self
            end

            function checkbox:Set(value)
                self.value = value
                self.knob_x = value and (self.width - self.knob_radius*2 - 2) or 2
                if self.knob_anim then self.knob_anim:stop() end
                self.knob_anim = anim.animate_to(self, "knob_x", self.knob_x, self.knob_x, 0.1, "cubic_out")
                self.knob_anim:start()
                
                local target_toggle = value and 1 or 0
                if self.toggle_anim then self.toggle_anim:stop() end
                self.toggle_anim = anim.animate_to(self, "toggle_progress", self.toggle_progress or 0, target_toggle, 0.2, "cubic_out")
                self.toggle_anim:start()
            end
            
            if checkbox.visible then
                self.next_y = self.next_y + 26
            end
            table.insert(self.checkboxes, checkbox)
            return checkbox
        end

        function group:Slider(label, default_val, min_val, max_val, increment, format_str)
            local slider = {
                type = "slider",
                label = label,
                value = math.max(min_val or 0, math.min(max_val or 100, default_val or min_val or 0)),
                target_value = nil,
                min = min_val or 0,
                max = max_val or 100,
                increment = increment or 1,
                format = format_str or "%.0f",
                custom_formats = {},
                height = 24,
                slider_width = math.min(self.slider_width, self.size.x - self.left_padding - self.right_padding - 80),
                y = self.next_y,
                dragging = false,
                animating = false,
                value_anim = nil,
                hovered = false,
                text_hovered = false,
                parent = self,
                current_alpha = self.fade_progress,
                visible = true,
            }
            
            function slider:Get(index)
                return get_element_value(self, index)
            end

            function slider:Set(value)
                value = math.max(self.min, math.min(self.max, value))
                self.value = value
                self.target_value = value
                self.pct = (value - self.min) / (self.max - self.min)
            end

            function slider:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 30
                return self
            end

            function slider:Format(value, format_str)
                if not self.custom_formats then self.custom_formats = {} end
                self.custom_formats[value] = format_str
                return self
            end
            
            if slider.visible then
                self.next_y = self.next_y + 30
            end
            table.insert(self.sliders, slider)
            return slider
        end

        function group:Selectable(label, items, multi, default_value)
            multi = multi or false
            local default_selected = {}
            for i = 1, #items do default_selected[i] = false end
            
            local default_index = 1
            
            if default_value then
                if multi then
                    if type(default_value) == "table" then
                        for i = 1, math.min(#items, #default_value) do
                            default_selected[i] = default_value[i] or false
                        end
                    end
                else
                    if type(default_value) == "number" and default_value >= 1 and default_value <= #items then
                        default_selected[default_value] = true
                        default_index = default_value
                    else
                        for i, item in ipairs(items) do
                            if item == default_value then 
                                default_selected[i] = true
                                default_index = i
                                break 
                            end
                        end
                    end
                end
            end
            
            if not multi then
                local found = false
                for i = 1, #items do 
                    if default_selected[i] then 
                        found = true
                        default_index = i
                        break 
                    end 
                end
                if not found and #items > 0 then 
                    default_selected[1] = true
                    default_index = 1
                end
            end
            
            local selected_text = ""
            if not multi and #items > 0 and items[default_index] then
                selected_text = items[default_index]
            end
            
            local selected_text_width = get_text_width(fonts.StandartFont, selected_text or "")
            local button_width = math.min(140, math.max(selected_text_width + 35, self.size.x - self.left_padding - self.right_padding - 80))
            
            local selectable = {
                type = "selectable",
                label = label,
                items = items,
                multi = multi,
                selected = default_selected,
                value = multi and default_selected or default_index,
                height = 24,
                button_width = button_width,
                y = self.next_y,
                opened = false,
                hovered = false,
                text_hovered = false,
                parent = self,
                click_processed = false,
                dropdown_height_progress = 0,
                dropdown_anim = nil,
                current_alpha = self.fade_progress,
                visible = true,
            }

            selectable.hasSettingsGear = false
            selectable.gear_callback = nil
            selectable.gear_opened = false
            selectable.gear_progress = 0

            function selectable:Gear(gear_config)
                return add_gear_settings(self, gear_config)
            end

            function selectable:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 30
                return self
            end
            
            function selectable:SetItems(new_items)
                self.items = new_items or {}
                self.selected = {}
                for i = 1, #self.items do
                    self.selected[i] = false
                end
                if not self.multi and #self.items > 0 then
                    self.selected[1] = true
                    self.value = 1
                elseif self.multi then
                    self.value = self.selected
                end
                local first_item_text = ""
                if #self.items > 0 and not self.multi then
                    first_item_text = self.items[1] or ""
                end
                local text_width = get_text_width(fonts.StandartFont, first_item_text)
                self.button_width = math.min(140, math.max(text_width + 35, self.parent.size.x - self.parent.left_padding - self.parent.right_padding - 80))
            end
            
            function selectable:Get(index)
                return get_element_value(self, index)
            end

            function selectable:Set(value, index)
                if self.multi then
                    if index then
                        self.selected[index] = value or false
                        local selected_items = {}
                        for j = 1, #self.items do
                            if self.selected[j] then
                                table.insert(selected_items, self.items[j])
                            end
                        end
                        self.value = selected_items
                    else
                        if type(value) == "table" then
                            for i = 1, #self.items do
                                self.selected[i] = value[i] or false
                            end
                            self.value = value
                        end
                    end
                else
                    if type(value) == "number" and value >= 1 and value <= #self.items then
                        for i = 1, #self.items do
                            self.selected[i] = (i == value)
                        end
                        self.value = value
                    end
                end
            end
            
            if selectable.visible then
                self.next_y = self.next_y + 30
            end
            table.insert(self.selectables, selectable)
            return selectable
        end

        function group:Button(label, callback, config)
            config = config or {}
            local button = {
                type = "button",
                label = label,
                callback = callback,
                width = config.width or (self.size.x - self.left_padding - self.right_padding),
                height = config.height or 24,
                y = self.next_y,
                disabled = config.disabled or false,
                border_radius = config.border_radius or 4,
                parent = self,
                current_alpha = self.fade_progress,
                click_processed = false,
                is_holding = false,
                hovered = false,
                pct = 0,
                press_anim = nil,
                visible = true,
            }
            
            function button:Get()
                return self.disabled
            end
            
            function button:SetText(text)
                self.label = text
            end

            function button:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - button.height - 6
                return self
            end

            function button:Set(enabled)
                self.disabled = enabled
            end
            
            if button.visible then
                self.next_y = self.next_y + button.height + 6
            end
            
            if not self.buttons then self.buttons = {} end
            table.insert(self.buttons, button)
            return button
        end

        function group:Label(label)
            local lbl = {
                type = "label",
                label = label,
                y = self.next_y,
                height = 20,
                width = 32,
                parent = self,
                current_alpha = self.fade_progress,
                visible = true,
            }
            
            function lbl:Get()
                return self.label
            end
            
            function lbl:SetText(text)
                self.label = text
            end

            lbl.hasSettingsGear = false
            lbl.gear_callback = nil
            lbl.gear_opened = false
            lbl.gear_progress = 0

            function lbl:Gear(gear_config)
                return add_gear_settings(self, gear_config)
            end

            function lbl:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 26
                return self
            end
            
            if lbl.visible then
                self.next_y = self.next_y + 26
            end
            table.insert(self.labels or {}, lbl)
            return lbl
        end

        function group:ColorPicker(label, default_color, show_alpha)
            show_alpha = show_alpha ~= false  
            
            local color_picker = {
                type = "color_picker",
                label = label,
                value = default_color or color_t(1, 1, 1, 1),
                hsv = nil,
                height = 24,
                y = self.next_y,
                interacting = false,
                opened = false,
                pct = 0,
                dropdown_height_progress = 0,
                dropdown_anim = nil,
                preview_size = 24,
                parent = self,
                current_alpha = self.fade_progress,
                hex_hovered = false,
                text_hovered = false,
                preview_bounds = nil,
                hex_bounds = nil,
                show_alpha = show_alpha or true, 
                dragging_picker = false,
                dragging_hue = false,
                dragging_alpha = false,
                drag_pos = nil,
                copy_hovered = false,
                paste_hovered = false,
                copy_pct = 0,
                paste_pct = 0,
                copy_press = false,
                paste_press = false,
                copy_clicked = false,
                paste_clicked = false,
                copy_anim = nil,
                paste_anim = nil,
                copy_bounds = nil,
                paste_bounds = nil,
                visible = true,
            }

            color_picker.hasSettingsGear = false
            color_picker.gear_callback = nil
            color_picker.gear_opened = false
            color_picker.gear_progress = 0

            function color_picker:Gear(gear_config)
                return add_gear_settings(self, gear_config)
            end

            function color_picker:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 30
                return self
            end
            
            function color_picker:rgb_to_hsv(color)
                local r, g, b, a = color.r, color.g, color.b, color.a
                local max_rgb = math.max(r, g, b)
                local min_rgb = math.min(r, g, b)
                local delta = max_rgb - min_rgb
                local h = 0
                
                if delta ~= 0 then
                    if max_rgb == r then
                        h = (g - b) / delta % 6
                    elseif max_rgb == g then
                        h = (b - r) / delta + 2
                    else
                        h = (r - g) / delta + 4
                    end
                    h = h / 6
                end
                
                local s = (max_rgb ~= 0) and (delta / max_rgb) or 0
                local v = max_rgb
                
                return {h, s, v, a}
            end
            
            function color_picker:hsv_to_rgb(hsv)
                local h, s, v, a = hsv[1], hsv[2], hsv[3], hsv[4] or 1
                if s == 0 then
                    return color_t(v, v, v, a)
                end
                
                local h_section = math.floor(h * 6)
                local h_fraction = h * 6 - h_section
                local p = v * (1 - s)
                local q = v * (1 - s * h_fraction)
                local t = v * (1 - s * (1 - h_fraction))
                
                local r, g, b
                if h_section == 0 then
                    r, g, b = v, t, p
                elseif h_section == 1 then
                    r, g, b = q, v, p
                elseif h_section == 2 then
                    r, g, b = p, v, t
                elseif h_section == 3 then
                    r, g, b = p, q, v
                elseif h_section == 4 then
                    r, g, b = t, p, v
                else
                    r, g, b = v, p, q
                end
                
                return color_t(r, g, b, a)
            end
            
            color_picker.hsv = color_picker:rgb_to_hsv(color_picker.value)
            
            function color_picker:Get()
                return self.value
            end
            
            function color_picker:Set(color)
                self.value = color
                self.hsv = self:rgb_to_hsv(color)
            end
            
            function color_picker:Hex()
                if self.show_alpha then
                    return string.format("#%02x%02x%02x%02x", 
                        self.value.r * 255, 
                        self.value.g * 255, 
                        self.value.b * 255, 
                        self.value.a * 255):upper()
                else
                    return string.format("#%02x%02x%02x", 
                        self.value.r * 255, 
                        self.value.g * 255, 
                        self.value.b * 255):upper()
                end
            end
            
            if color_picker.visible then
                self.next_y = self.next_y + 30
            end
            if not self.color_pickers then self.color_pickers = {} end
            table.insert(self.color_pickers, color_picker)
            return color_picker
        end

        function group:Input(label, placeholder)
            local input = {
                type = "input",
                label = label,
                value = "",
                placeholder = placeholder or "",
                height = 24,
                y = self.next_y,
                interacting = false,
                cursor_pos = 1,
                scroll_offset = 0,
                parent = self,
                current_alpha = self.fade_progress,
                last_blink = 0,
                show_cursor = true,
                visible = true,
                width = 158.5,
            }

            input.hasSettingsGear = false
            input.gear_callback = nil
            input.gear_opened = false
            input.gear_progress = 0

            function input:Gear(gear_config)
                return add_gear_settings(self, gear_config)
            end
            
            function input:Get()
                return self.value
            end
            
            function input:Set(text)
                self.value = text or ""
                self.cursor_pos = #self.value + 1
                self.scroll_offset = 0
            end

            function input:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 30
                return self
            end
            
            function input:SetPlaceholder(text)
                self.placeholder = text or ""
            end
            
            if input.visible then
                self.next_y = self.next_y + 30
            end
            if not self.inputs then self.inputs = {} end
            table.insert(self.inputs, input)
            return input
        end

        function group:Hotkey(label, default_key, default_mode, available_modes, mode_names_custom, callback)
            default_key = default_key or 0
            default_mode = default_mode or 1
            
            local modes_available = available_modes or {true, true, true}
            local default_mode_names = {"Always", "Hold", "Toggle"}
            local mode_names = {}
            
            if mode_names_custom and type(mode_names_custom) == "table" then
                local custom_index = 1
                for i = 1, 3 do
                    if modes_available[i] then
                        if mode_names_custom[custom_index] then
                            table.insert(mode_names, mode_names_custom[custom_index])
                        else
                            table.insert(mode_names, default_mode_names[i])
                        end
                        custom_index = custom_index + 1
                    end
                end
            else
                if modes_available[1] then table.insert(mode_names, "Always") end
                if modes_available[2] then table.insert(mode_names, "Hold") end
                if modes_available[3] then table.insert(mode_names, "Toggle") end
            end
            
            local function get_real_mode(display_index)
                local real_index = 1
                local display_count = 0
                for i = 1, 3 do
                    if modes_available[i] then
                        display_count = display_count + 1
                        if display_count == display_index then
                            return i
                        end
                    end
                end
                return 1
            end
            
            local function get_display_mode(real_mode)
                local display_index = 1
                for i = 1, 3 do
                    if modes_available[i] then
                        if i == real_mode then
                            return display_index
                        end
                        display_index = display_index + 1
                    end
                end
                return 1
            end
            
            local function get_mode_display_name(real_mode)
                local display_idx = get_display_mode(real_mode)
                return mode_names[display_idx] or default_mode_names[real_mode]
            end
            
            local key_display = default_key == 0 and "?" or GetKeyName(default_key)
            local text_width = get_text_width(fonts.StandartFont, key_display)
            local button_width = text_width + 16
            
            local hotkey = {
                type = "hotkey",
                label = label,
                key = default_key,
                mode = default_mode,
                available_modes = modes_available,
                mode_names = mode_names,
                get_real_mode = get_real_mode,
                get_display_mode = get_display_mode,
                get_mode_display_name = get_mode_display_name,
                toggle_state = false,
                active = (default_mode == 1),
                height = 26,
                y = self.next_y,
                hovered = false,
                text_hovered = false,
                mode_popup_opened = false,
                mode_popup_progress = 0,
                mode_popup_anim = nil,
                current_button_width = button_width,
                parent = self,
                current_alpha = self.fade_progress,
                click_processed = false,
                mode_click_processed = false,
                waiting_for_key = false,
                callback = callback or nil,
                visible = true,
            }
            
            function hotkey:Get()
                return self.active
            end

            function hotkey:Visibility(value)
                self.visible = value
                group.next_y = group.next_y - 32
                return self
            end
            
            function hotkey:GetKey()
                return { key = self.key, mode = self.mode }
            end
            
            function hotkey:GetModeName()
                return self:get_mode_display_name(self.mode)
            end
            
            function hotkey:SetKey(key_code)
                self.key = key_code
                local new_display = key_code == 0 and "?" or GetKeyName(key_code)
                local new_width = get_text_width(fonts.StandartFont, new_display) + 16
                self.current_button_width = new_width
                if self.mode == 1 then
                    self.active = true
                elseif self.mode == 3 then
                    self.toggle_state = false
                    self.active = false
                end
                if self.callback then
                    self.callback(self.active, self)
                end
            end
            
            function hotkey:SetMode(mode)
                if not self.available_modes[mode] then
                    for i = 1, 3 do
                        if self.available_modes[i] then
                            mode = i
                            break
                        end
                    end
                end
                self.mode = mode
                if mode == 1 then
                    self.active = true
                elseif mode == 2 then
                    self.active = (self.key ~= 0) and input.IsKeyPressed(self.key) or false
                elseif mode == 3 then
                    self.toggle_state = false
                    self.active = false
                end
                if self.callback then
                    self.callback(self.active, self)
                end
            end
            
            function hotkey:SetCallback(callback_func)
                self.callback = callback_func
                return self
            end
            
            function hotkey:Set(key_settings)
                if key_settings.key then self:SetKey(key_settings.key) end
                if key_settings.mode then self:SetMode(key_settings.mode) end
            end
            
            if hotkey.visible then
                self.next_y = self.next_y + 32
            end
            
            if not self.hotkeys then self.hotkeys = {} end
            table.insert(self.hotkeys, hotkey)
            table.insert(hotkey_widgets, hotkey)
            
            return hotkey
        end

        function group:Get(element, index)
            return get_element_value(element, index)
        end

        function group:render(parent_alpha)
            if self.fade_progress <= 0.01 and not self.is_animating and not self.visible then return end
            
            local alpha = self.fade_progress * (parent_alpha or 1)
            if alpha > 0.01 or self.is_animating then
                local render_bg = color_t(self.bg_color.r, self.bg_color.g, self.bg_color.b, self.bg_color.a * alpha)
                local render_border = color_t(self.border_color.r, self.border_color.g, self.border_color.b, self.border_color.a * alpha)
                local end_pos = vec2_t(self.pos.x + self.size.x, self.pos.y + self.size.y)
                render.rect_filled(self.pos, end_pos, render_bg, self.border_radius)
                if self.border_thickness > 0 and self.border then
                    render.rect(self.pos, end_pos, render_border, self.border_radius)
                end
                if self.name and self.name ~= "" then
                    render.text(self.name, fonts.BigFont, vec2_t(self.pos.x + 10, self.pos.y - 18), color_t(0.8, 0.8, 0.8, 0.8 * alpha))
                end
                if self.active_tab then
                    local diff = self.tab_indicator_target - self.tab_indicator_pos
                    self.tab_indicator_pos = math.abs(diff) > 0.5 and self.tab_indicator_pos + diff * 0.2 or self.tab_indicator_target
                    local ind_start = vec2_t(self.pos.x + 5, self.pos.y + 5 + self.tab_indicator_pos)
                    local ind_end = vec2_t(self.pos.x + self.size.x - 5, self.pos.y + 5 + self.tab_indicator_pos + 35)
                    render.rect_filled(ind_start, ind_end, color_t(0.18, 0.18, 0.18, 0.95 * alpha), 6)
                end
                for _, tab in ipairs(self.tabs) do tab:render(alpha) end
                for _, cb in ipairs(self.checkboxes) do draw_checkbox(cb, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) end
                for _, sl in ipairs(self.sliders) do draw_slider(sl, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) end
                for _, btn in ipairs(self.buttons or {}) do draw_button(btn, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) end
                for _, sel in ipairs(self.selectables) do draw_selectable_button(sel, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) end
                for _, lbl in ipairs(self.labels or {}) do draw_label(lbl, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) end
                for _, inp in ipairs(self.inputs or {}) do 
                    draw_input(inp, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) 
                end
                
                local closed_pickers = {}
                local opened_pickers = {}
                for _, cp in ipairs(self.color_pickers or {}) do
                    if cp.opened and cp == active_selectable then
                        table.insert(opened_pickers, cp)
                    else
                        table.insert(closed_pickers, cp)
                    end
                end
                for _, hk in ipairs(self.hotkeys or {}) do 
                    draw_hotkey(hk, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) 
                end
                
                for _, cp in ipairs(closed_pickers) do 
                    draw_color_picker(cp, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) 
                end
                
                for _, cp in ipairs(opened_pickers) do 
                    draw_color_picker(cp, self.pos, self.left_padding, self.right_padding, self.size.x, alpha) 
                end

                for _, sel in ipairs(self.selectables) do
                    if sel.opened and sel == active_selectable then
                        draw_selectable_dropdown(sel, self.pos, self.right_padding, self.size.x, alpha)
                    end
                end
                
                if self.render_callback then self.render_callback(self) end
            end
        end

        function group:update(mouse_pos, mouse_clicked, mouse_left)
            if not utils.IsCS2Foreground() then return end
            if self.fade_progress < 0.01 and not self.is_animating and not self.visible then return end

            for _, tab in ipairs(self.tabs) do tab:update(mouse_pos, mouse_clicked, mouse_left) end
            
            for _, cb in ipairs(self.checkboxes) do 
                update_checkbox(cb, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x) 
            end
            for _, sl in ipairs(self.sliders) do 
                update_slider(sl, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x) 
            end
            for _, btn in ipairs(self.buttons or {}) do
                update_button(btn, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
            end
            for _, inp in ipairs(self.inputs or {}) do 
                update_input(inp, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x) 
            end
            for _, hk in ipairs(self.hotkeys or {}) do 
                update_hotkey(hk, mouse_pos, mouse_left, input.IsKeyPressed(VK_RBUTTON), true, self.pos, self.left_padding, self.right_padding, self.size.x)
            end
            for _, cp in ipairs(self.color_pickers or {}) do 
                update_color_picker(cp, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x) 
            end
            for _, sel in ipairs(self.selectables) do 
                local can_interact_with_sel = not is_input_blocked() or (sel == active_selectable)
                update_selectable(sel, mouse_pos, mouse_clicked, can_interact_with_sel, self.pos, self.left_padding, self.right_padding, self.size.x) 
            end
        end

        function group:create_tab(name, icon, config)
            return create_tab(self, name, icon, config)
        end

        if parent.type == "tab" or parent.type == "subtab" then
            group.pos = root_window and vec2_t(root_window.pos.x + offset.x, root_window.pos.y + offset.y) or vec2_t(parent.pos.x + offset.x, parent.pos.y + offset.y)
        else
            group.pos = vec2_t(parent.pos.x + offset.x, parent.pos.y + offset.y)
        end

        if parent.type == "window" or parent.type == "tab" or parent.type == "subtab" then
            if not parent.groups then parent.groups = {} end
            table.insert(parent.groups, group)
        end

        local should_be_visible = true

        if parent.type == "subtab" then
            should_be_visible = parent.is_active
        elseif parent.type == "tab" then
            if parent.parent and parent.parent.active_tab then
                should_be_visible = (parent.parent.active_tab == parent)
            else
                should_be_visible = false
            end
        end

        if should_be_visible then
            group.visible = true
            group.fade_progress = 1
            group.current_alpha = 1
        else
            group.visible = false
            group.fade_progress = 0
            group.current_alpha = 0
        end
        group:update_element_alphas()

        return group
    end

    function gui.force_close_all()
        if active_gear_popup then
            if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
            active_gear_popup.gear_opened = false
            active_gear_popup.gear_progress = 0
            active_gear_popup = nil
            gear_blocking = false
        end
        
        if active_selectable then
            if active_selectable.opened then
                if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                active_selectable.opened = false
            end
            active_selectable = nil
        end
        
        if active_slider then
            active_slider.dragging = false
            active_slider = nil
        end
        
        if active_checkbox then
            active_checkbox = nil
        end
        
        dragging_window = nil
        any_interactive_hovered = false
    end

    function gui.create_window(name, pos, size)
        local max_z = 0
        for i = 1, #all_windows do if all_windows[i].z_index > max_z then max_z = all_windows[i].z_index end end
        
        local window = {
            name = name or "Window",
            pos = pos,
            size = size,
            is_open = true,
            is_animating = false,
            is_dragging = false,
            drag_offset = vec2_t(0, 0),
            border = true,
            bg_color = color_t(0.1, 0.1, 0.1, 0.95),
            border_color = color_t(0.2, 0.2, 0.2, 1),
            border_radius = 4,
            border_thickness = 1,
            render_callback = nil,
            z_index = max_z + 1,
            is_pinned = false,
            constraints = nil,
            groups = {},
            type = "window",
            animation_speed = 0.15,
            bg_alpha = 0.95,
            border_alpha = 1,
            is_hovering_tab = false,
            current_alpha = 1.0,
            window_fade_progress = 1.0,
            window_fade_anim = nil,
            click_processed = false,
        }
        
        function window:start_window_fade(target_progress, duration, callback)
            if self.window_fade_anim then self.window_fade_anim:stop() end
            local start = self.window_fade_progress
            self.window_fade_anim = anim.animate_to(self, "window_fade_progress", start, target_progress, duration or 0.25, "cubic_in_out")
            self.window_fade_anim.on_complete = function()
                self.window_fade_anim = nil
                if callback then callback() end
            end
            self.window_fade_anim:start()
        end
        
        function window:create_group(offset, size, config)
            return create_group(self, offset, size, config)
        end

        function window:SetStatus(Status)
            self.is_open = Status
        end

        function window:GetStatus()
            return self.is_open
        end
        
        function window:setting(action, option, value1, value2)
            return universal_setting(self, action, option, value1, value2)
        end
        
        function window:render_func(callback)
            self.render_callback = callback
            return self
        end
        
        function window:get_active_tab()
            for _, group in ipairs(self.groups) do if group.active_tab then return group.active_tab end end
            return nil
        end
        
        function window:select_tab(tab_name)
            for _, group in ipairs(self.groups) do local tab = group:select_tab(tab_name); if tab then return tab end end
            return nil
        end
        
        function window:select_subtab(tab_name, subtab_name)
            local tab = self:select_tab(tab_name)
            return tab and tab:select_subtab(subtab_name) or false
        end
            
        local function resolve_pinned_collision(win, new_x, new_y)
            for i = 1, #all_windows do
                local other = all_windows[i]
                if other.is_pinned and other.is_open and other ~= win then
                    if not (new_x + win.size.x <= other.pos.x or new_x >= other.pos.x + other.size.x or
                            new_y + win.size.y <= other.pos.y or new_y >= other.pos.y + other.size.y) then
                        local offset_x, offset_y = 0, 0
                        if new_x < other.pos.x then 
                            offset_x = other.pos.x - (new_x + win.size.x)
                        else 
                            offset_x = other.pos.x + other.size.x - new_x
                        end
                        if new_y < other.pos.y then 
                            offset_y = other.pos.y - (new_y + win.size.y)
                        else 
                            offset_y = other.pos.y + other.size.y - new_y
                        end
                        if math.abs(offset_x) < math.abs(offset_y) then 
                            new_x = new_x + offset_x
                        else 
                            new_y = new_y + offset_y
                        end
                    end
                end
            end
            return new_x, new_y
        end
        
        local function apply_constraints(win, x, y)
            if win.constraints then
                if x < win.constraints.min_x then x = win.constraints.min_x end
                if x + win.size.x > win.constraints.max_x then x = win.constraints.max_x - win.size.x end
                if y < win.constraints.min_y then y = win.constraints.min_y end
                if y + win.size.y > win.constraints.max_y then y = win.constraints.max_y - win.size.y end
            end
            return x, y
        end
        
        function window.bring_to_front()
            if window.is_pinned then return end
            local max_z = 0
            for i = 1, #all_windows do
                if all_windows[i].z_index > max_z and not all_windows[i].is_pinned then
                    max_z = all_windows[i].z_index
                end
            end
            window.z_index = max_z + 1
            table.sort(all_windows, function(a, b)
                if a.is_pinned ~= b.is_pinned then return not a.is_pinned end
                return a.z_index < b.z_index
            end)
        end
        
        function window:close()
            if active_gear_popup then force_close_gear_popup() end
            
            if active_gear_popup then
                if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
                active_gear_popup.gear_opened = false
                active_gear_popup.gear_progress = 0
                active_gear_popup = nil
                gear_blocking = false
            end
            
            if active_selectable then
                if active_selectable.opened then
                    if active_selectable.dropdown_anim then active_selectable.dropdown_anim:stop() end
                    active_selectable.opened = false
                    active_selectable.dropdown_height_progress = 0
                end
                if active_selectable.type ~= "input" then
                    active_selectable = nil
                end
            end
            
            for _, group in ipairs(window.groups or {}) do
                for _, cp in ipairs(group.color_pickers or {}) do
                    if cp.opened then
                        if cp.dropdown_anim then cp.dropdown_anim:stop() end
                        cp.opened = false
                        cp.dropdown_height_progress = 0
                    end
                    cp.dragging_picker = false
                    cp.dragging_hue = false
                    cp.dragging_alpha = false
                end
            end
            
            if active_slider then
                active_slider.dragging = false
                active_slider = nil
            end
            if active_checkbox then
                active_checkbox = nil
            end
            
            if not window.is_open or window.closing then return end
            
            window.closing = true
            window:start_window_fade(0, 0.2, function()
                window.is_open = false
                window.closing = false
            end)
        end

        function window:open()
            if window.is_open and not window.closing then
                return
            end
            
            window.is_open = true
            window.closing = false
            
            for _, group in ipairs(self.groups) do 
                group.visible = true
            end
            
            window:start_window_fade(1, 0.2)
        end
        
        function window.update(mouse_pos, mouse_clicked, mouse_left)
            local is_color_picker_interacting = false
            for _, group in ipairs(window.groups) do
                for _, cp in ipairs(group.color_pickers or {}) do
                    if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                        is_color_picker_interacting = true
                        break
                    end
                end
                if is_color_picker_interacting then break end
            end
            
            if not is_color_picker_interacting and active_gear_popup and active_gear_popup.gear_group then
                for _, cp in ipairs(active_gear_popup.gear_group.color_pickers or {}) do
                    if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                        is_color_picker_interacting = true
                        break
                    end
                end
            end

            if active_selectable and active_selectable.opened then
                for _, group in ipairs(window.groups) do
                    if group.fade_progress > 0 or group.is_animating or group.visible then
                        group:update(mouse_pos, mouse_clicked, mouse_left)
                    end
                end
                return
            end
            
            if is_color_picker_interacting then
                if window.is_dragging then
                    window.is_dragging = false
                    dragging_window = nil
                end
                for _, group in ipairs(window.groups) do
                    if group.fade_progress > 0 or group.is_animating or group.visible then
                        group:update(mouse_pos, mouse_clicked, mouse_left)
                    end
                end
                return
            end
            
            if active_gear_popup and active_gear_popup.gear_opened then
                if window.is_dragging then
                    window.is_dragging = false
                    dragging_window = nil
                end
                return
            end

            if not utils.IsCS2Foreground() then
                if window.is_dragging then window.is_dragging = false; dragging_window = nil end
                return
            end

            if not window.is_open and not window.is_animating and (window.window_fade_progress or 0) <= 0.01 then return end
            
            any_interactive_hovered = false
            for _, group in ipairs(window.groups) do
                if group.fade_progress > 0 or group.is_animating or group.visible then
                    group:update(mouse_pos, mouse_clicked, mouse_left)
                end
            end
            
            if active_slider and active_slider.dragging then any_interactive_hovered = true end
            if active_checkbox then any_interactive_hovered = true end

            if active_selectable and active_selectable.opened then
                any_interactive_hovered = true
                if window.is_dragging then
                    window.is_dragging = false
                    dragging_window = nil
                end
                return
            end
            
            if active_checkbox and not mouse_left then
                if active_checkbox.hovered and not active_checkbox.disabled then
                    active_checkbox.value = not active_checkbox.value
                    local target_knob_x = active_checkbox.value and (active_checkbox.width - active_checkbox.knob_radius*2 - 2) or 2
                    if active_checkbox.knob_anim then active_checkbox.knob_anim:stop() end
                    active_checkbox.knob_anim = anim.animate_to(active_checkbox, "knob_x", active_checkbox.knob_x, target_knob_x, 0.2, "cubic_out")
                    active_checkbox.knob_anim:start()
                    
                    local target_toggle = active_checkbox.value and 1 or 0
                    if active_checkbox.toggle_anim then active_checkbox.toggle_anim:stop() end
                    active_checkbox.toggle_anim = anim.animate_to(active_checkbox, "toggle_progress", active_checkbox.toggle_progress or 0, target_toggle, 0.2, "cubic_out")
                    active_checkbox.toggle_anim:start()
                end
                active_checkbox = nil
            end
            
            if window.is_dragging then
                if mouse_left then
                    local new_x, new_y = apply_constraints(window, mouse_pos.x - window.drag_offset.x, mouse_pos.y - window.drag_offset.y)
                    if window.is_pinned then new_x, new_y = resolve_pinned_collision(window, new_x, new_y) end
                    window.pos.x, window.pos.y = new_x, new_y
                    for _, group in ipairs(window.groups) do
                        group:update_position()
                    end
                else
                    window.is_dragging = false
                    dragging_window = nil
                end
                return
            end
            
            if dragging_window then return end
            
            local top_window, top_z = nil, -1
            for i = 1, #all_windows do
                local w = all_windows[i]
                if (w.is_open or w.is_animating) and is_hovering({x = w.pos.x, y = w.pos.y, w = w.size.x, h = w.size.y}, mouse_pos) then
                    local z = w.z_index or 0
                    if w.is_pinned then z = z + 100000 end
                    if z > top_z then top_z, top_window = z, w end
                end
            end
            
            if top_window ~= window then return end
            
            local is_hovering_window = is_hovering({x = window.pos.x, y = window.pos.y, w = window.size.x, h = window.size.y}, mouse_pos)
            if is_hovering_window and mouse_left and not window.is_dragging and not any_interactive_hovered then
                if not window.is_pinned then window.bring_to_front() end
                window.is_dragging = true
                dragging_window = window
                window.drag_offset = vec2_t(mouse_pos.x - window.pos.x, mouse_pos.y - window.pos.y)
            end
        end
        
        function window.render()
            if not window._positions_updated then
                for _, group in ipairs(window.groups) do
                    if group.update_position then
                        group:update_position()
                    end
                    if group.active_tab and group.active_tab.active_subtab then
                        for _, subtab_group in ipairs(group.active_tab.active_subtab.groups or {}) do
                            if subtab_group.update_position then
                                subtab_group:update_position()
                            end
                        end
                    end
                end
                window._positions_updated = true
            end

            if not window.is_open and not window.is_animating and window.window_fade_progress <= 0.01 then 
                return 
            end
            
            local window_alpha = window.window_fade_progress
            if window_alpha <= 0.01 then return end
            
            render.rect_filled(window.pos, window.pos + window.size, color_t(window.bg_color.r, window.bg_color.g, window.bg_color.b, window.bg_color.a * window_alpha), window.border_radius)
            if window.border_thickness > 0 and window.border then
                render.rect(window.pos, window.pos + window.size, color_t(window.border_color.r, window.border_color.g, window.border_color.b, window.border_color.a * window_alpha), window.border_radius)
            end
            
            for _, group in ipairs(window.groups) do
                if group.visible or group.is_animating or group.fade_progress > 0 then
                    group:render(window_alpha)
                end
            end
            
            if window.render_callback then window.render_callback(window, window_alpha) end
        end
        
        table.insert(all_windows, window)
        table.sort(all_windows, function(a, b)
            if a.is_pinned ~= b.is_pinned then return not a.is_pinned end
            return a.z_index < b.z_index
        end)
        
        return window
    end

    function gui.bring_to_front(window)
        if window and not window.is_pinned then window.bring_to_front() end
    end

    local active_gear_popup = nil

    local function gear_update_size(element)
        if not element or not element.gear_group then return end
        
        local total_h = 15 
        for _, cb in ipairs(element.gear_group.checkboxes) do 
            if cb.visible ~= false then total_h = total_h + 22 end
        end
        for _, sl in ipairs(element.gear_group.sliders) do 
            if sl.visible ~= false then total_h = total_h + 26 end
        end
        for _, sel in ipairs(element.gear_group.selectables) do 
            if sel.visible ~= false then total_h = total_h + 26 end
        end
        for _, btn in ipairs(element.gear_group.buttons or {}) do 
            if btn.visible ~= false then total_h = total_h + 24 end
        end
        for _, lbl in ipairs(element.gear_group.labels or {}) do 
            if lbl.visible ~= false then total_h = total_h + 24 end
        end
        for _, inp in ipairs(element.gear_group.inputs or {}) do 
            if inp.visible ~= false then total_h = total_h + 24 end
        end
        for _, cp in ipairs(element.gear_group.color_pickers or {}) do 
            if cp.visible ~= false then total_h = total_h + 24 end
        end
        for _, hk in ipairs(element.gear_group.hotkeys or {}) do 
            if hk.visible ~= false then total_h = total_h + 26 end
        end
        
        element.gear_content_height = total_h + 10  
        element.gear_group.size = vec2_t(320, total_h)
    end

    local function gear_close_popup(element, instant)
        if not element or not element.gear_opened then return end
        if element.gear_anim then element.gear_anim:stop() end
        if instant then
            element.gear_opened = false
            element.gear_progress = 0
            if active_gear_popup == element then active_gear_popup = nil end
            gear_blocking = false
            return
        end
        element.gear_anim = anim.animate_to(element, "gear_progress", element.gear_progress or 1, 0, 0.15, "cubic_out")
        element.gear_anim.on_complete = function()
            element.gear_opened = false
            if active_gear_popup == element then active_gear_popup = nil end
            gear_blocking = false
        end
        element.gear_anim:start()
    end

    local function gear_draw_popup(element)
        if not element or not element.gear_opened then return end
        local prog = element.gear_progress or 0
        if prog <= 0.01 then return end
        
        local gear_x = element.gear_x or 0
        local gear_y = element.gear_y or 0
        local popup_width = 340
        local popup_height = (element.gear_content_height or 100) * prog
        local popup_x = gear_x - popup_width + 340
        local popup_y = gear_y + 20
        
        local screen_size = render.screen_size()
        if popup_x < 5 then popup_x = gear_x + 20 end
        if popup_y + popup_height > screen_size.y - 5 then popup_y = screen_size.y - popup_height - 5 end
        if popup_y < 5 then popup_y = 5 end
        
        element.gear_popup_bounds = {x = popup_x, y = popup_y, w = popup_width, h = popup_height}
        
        render.rect_filled(vec2_t(popup_x, popup_y), vec2_t(popup_x + popup_width, popup_y + popup_height), color_t(0.15, 0.15, 0.15, 1 * prog), 8)
        render.rect(vec2_t(popup_x, popup_y), vec2_t(popup_x + popup_width, popup_y + popup_height), color_t(0.3, 0.3, 0.3, 0.8 * prog), 8, 1.5)
        
        if element.gear_group and prog > 0.3 then
            local alpha = math.min(1, (prog - 0.3) / 0.7)
            element.gear_group.pos = vec2_t(popup_x + 10, popup_y + 10)
            element.gear_group.fade_progress = alpha
            element.gear_group:render() 
        end
    end

    function add_gear_settings(element, config_func)
        local gear_group = {
            parent = element,
            widgets = {}, 
            checkboxes = {},
            sliders = {},
            selectables = {},
            buttons = {},
            labels = {},
            inputs = {},
            color_pickers = {},
            hotkeys = {},
            tabs = {},
            pos = vec2_t(0, 0),
            next_y = 0,
            left_padding = 5,
            right_padding = 5,
            fade_progress = 1,
            size = vec2_t(320, 0),
        }
        
        function gear_group:add_widget(widget, type)
            widget.gear_type = type
            widget.visible = widget.visible ~= false
            table.insert(self.widgets, widget)
            
            if type == "checkbox" then table.insert(self.checkboxes, widget)
            elseif type == "slider" then table.insert(self.sliders, widget)
            elseif type == "selectable" then table.insert(self.selectables, widget)
            elseif type == "button" then 
                if not self.buttons then self.buttons = {} end
                table.insert(self.buttons, widget)
            elseif type == "label" then 
                if not self.labels then self.labels = {} end
                table.insert(self.labels, widget)
            elseif type == "input" then 
                if not self.inputs then self.inputs = {} end
                table.insert(self.inputs, widget)
            elseif type == "color_picker" then 
                if not self.color_pickers then self.color_pickers = {} end
                table.insert(self.color_pickers, widget)
            elseif type == "hotkey" then 
                if not self.hotkeys then self.hotkeys = {} end
                table.insert(self.hotkeys, widget)
            end
        end
        
        function gear_group:recalculate_layout()
            local y = 0
            for _, widget in ipairs(self.widgets) do
                if widget.visible ~= false then
                    widget.y = y
                    if widget.gear_type == "checkbox" then
                        y = y + 24
                    elseif widget.gear_type == "slider" then
                        y = y + 26
                    elseif widget.gear_type == "selectable" then
                        y = y + 26
                    elseif widget.gear_type == "button" then
                        y = y + 26
                    elseif widget.gear_type == "label" then
                        y = y + 26
                    elseif widget.gear_type == "input" then
                        y = y + 26
                    elseif widget.gear_type == "color_picker" then
                        y = y + 26
                    elseif widget.gear_type == "hotkey" then
                        y = y + 26
                    end
                end
            end
            gear_update_size(element)
        end
        
        gear_group.Switch = function(self, label, default_value)
            local cb = {
                type = "checkbox",
                label = label,
                value = default_value or false,
                height = 20,
                width = 32,
                toggle_height = 16,
                knob_radius = 6,
                knob_x = default_value and (32 - 12 - 2) or 2,
                toggle_progress = default_value and 1 or 0,
                y = self.next_y,
                current_alpha = 1,
                parent = element,
                visible = true,
                gear_type = "checkbox",
                disabled = false
            }
            function cb:Get() return self.value end

            function cb:Set(val)
                local old_value = self.value
                self.value = val
                
                local old_knob_x = old_value and (self.width - self.knob_radius*2 - 2) or 2
                local new_knob_x = val and (self.width - self.knob_radius*2 - 2) or 2
                
                self.knob_x = old_knob_x
                
                if self.knob_anim then self.knob_anim:stop() end
                self.knob_anim = anim.animate_to(self, "knob_x", old_knob_x, new_knob_x, 0.1, "cubic_out")
                self.knob_anim:start()

                local target_toggle = val and 1 or 0
                if self.toggle_anim then self.toggle_anim:stop() end
                self.toggle_anim = anim.animate_to(self, "toggle_progress", self.toggle_progress or (old_value and 1 or 0), target_toggle, 0.1, "cubic_out")
                self.toggle_anim:start()
            end

            function cb:Disable(value)
                self.disabled = (value ~= false)
                if self.disabled and self.gear_opened then
                    if self.gear_anim then self.gear_anim:stop() end
                    self.gear_opened = false
                    self.gear_progress = 0
                    if active_gear_popup == self then
                        active_gear_popup = nil
                        gear_blocking = false
                    end
                end
                return self
            end

            function cb:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end

            gear_group:add_widget(cb, "checkbox")
            gear_group:recalculate_layout()
            return cb
        end
        
        gear_group.Slider = function(self, label, default_val, min_val, max_val, increment, format_str)
            local sl = {
                type = "slider",
                label = label,
                value = default_val or 50,
                min = min_val or 0,
                max = max_val or 100,
                increment = increment or 1,
                format = format_str or "%.0f",
                custom_formats = {},
                height = 24,
                slider_width = 150,
                y = self.next_y,
                current_alpha = 1,
                parent = element,
                visible = true,
                gear_type = "slider",
            }
            function sl:Get() return self.value end

            function sl:Set(val) 
                val = math.max(self.min, math.min(self.max, val))
                self.value = val 
            end

            function sl:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end

            function sl:Format(value, format_str)
                if not self.custom_formats then self.custom_formats = {} end
                self.custom_formats[value] = format_str
                return self
            end

            gear_group:add_widget(sl, "slider")
            gear_group:recalculate_layout()
            return sl
        end
        
        gear_group.Selectable = function(self, label, items, multi, default_value)
            items = items or {}
            local selected = {}
            for i = 1, #items do selected[i] = false end
            
            if default_value then
                if multi then
                    if type(default_value) == "table" then
                        for i = 1, math.min(#items, #default_value) do
                            selected[i] = default_value[i] or false
                        end
                    end
                else
                    if type(default_value) == "number" then
                        if default_value >= 1 and default_value <= #items then
                            selected[default_value] = true
                        end
                    elseif type(default_value) == "string" then
                        for i, item in ipairs(items) do
                            if item == default_value then
                                selected[i] = true
                                break
                            end
                        end
                    elseif #items > 0 then
                        selected[1] = true
                    end
                end
            elseif #items > 0 and not multi then
                selected[1] = true
            end
            
            local sel_index = 1
            if not multi then
                for i = 1, #selected do
                    if selected[i] then
                        sel_index = i
                        break
                    end
                end
            end
            
            local sel = {
                type = "selectable",
                label = label,
                items = items,
                multi = multi or false,
                selected = selected,
                value = multi and selected or sel_index,
                height = 24,
                button_width = 140,
                y = self.next_y,
                opened = false,
                current_alpha = 1,
                parent = self,
                parent_group = self,
                click_processed = false,
                dropdown_height_progress = 0,
                dropdown_anim = nil,
                text_hovered = false,
                visible = true,
                gear_type = "selectable",
            }
            
            function sel:SetItems(Items)
                self.items = Items
                self.selected = {}
                for i = 1, #Items do self.selected[i] = false end
                if not self.multi and #Items > 0 then
                    self.selected[1] = true
                    self.value = 1
                elseif self.multi then
                    self.value = self.selected
                end
            end

            function sel:GetItems()
                return self.items
            end

            function sel:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end
            
            function sel:Get(index)
                if self.multi then
                    if index then 
                        return self.selected[index] or false 
                    end
                    local res = {}
                    for i, v in ipairs(self.selected) do
                        if v then table.insert(res, self.items[i]) end
                    end
                    return res
                else
                    if index then 
                        return self.selected[index] or false 
                    end
                    return self.value
                end
            end
            
            function sel:Set(value, index)
                if self.multi then
                    if index then
                        self.selected[index] = value or false
                        self.value = self.selected
                    elseif type(value) == "table" then
                        for i = 1, #self.items do
                            self.selected[i] = value[i] or false
                        end
                        self.value = self.selected
                    end
                else
                    if type(value) == "number" and value >= 1 and value <= #self.items then
                        for i = 1, #self.items do
                            self.selected[i] = (i == value)
                        end
                        self.value = value
                    elseif type(value) == "string" then
                        for i, item in ipairs(self.items) do
                            if item == value then
                                for j = 1, #self.items do
                                    self.selected[j] = (j == i)
                                end
                                self.value = i
                                break
                            end
                        end
                    end
                end
            end
            
            gear_group:add_widget(sel, "selectable")
            gear_group:recalculate_layout()
            return sel
        end
        
        gear_group.Button = function(self, label, callback)
            local btn = {
                type = "button",
                label = label,
                callback = callback,
                y = self.next_y,
                height = 24,
                width = 310,
                current_alpha = 1,
                parent = element,
                click_processed = false,
                is_holding = false,
                hovered = false,
                pct = 0,
                press_anim = nil,
                visible = true,
                gear_type = "button",
            }
            function btn:Get() return self.label end
            function btn:SetText(text) self.label = text end

            function btn:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end

            gear_group:add_widget(btn, "button")
            gear_group:recalculate_layout()
            return btn
        end
        
        gear_group.Label = function(self, label)
            local lbl = {
                type = "label", 
                label = label, 
                y = self.next_y, 
                height = 20, 
                visible = true, 
                current_alpha = 1,
                gear_type = "label",
            }
            function lbl:Get() return self.label end
            function lbl:SetText(text) self.label = text end

            function lbl:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end

            gear_group:add_widget(lbl, "label")
            gear_group:recalculate_layout()
            return lbl
        end
        
        gear_group.Input = function(self, label, placeholder)
            local inp = {
                type = "input",
                label = label,
                value = "",
                placeholder = placeholder or "",
                height = 24,
                y = self.next_y,
                interacting = false,
                cursor_pos = 1,
                scroll_offset = 0,
                current_alpha = 1,
                width = 140,
                parent = element,
                last_blink = 0,
                show_cursor = true,
                last_key = nil,
                last_key_time = nil,
                repeat_state = false,
                repeat_delay = 0.5,
                repeat_interval = 0.03,
                visible = true,
                gear_type = "input",
            }
            
            function inp:Get() return self.value end
            function inp:Set(text) self.value = text or ""; self.cursor_pos = #self.value + 1; self.scroll_offset = 0 end

            function inp:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end

            gear_group:add_widget(inp, "input")
            gear_group:recalculate_layout()
            return inp
        end
        
        gear_group.ColorPicker = function(self, label, default_color, show_alpha)
            show_alpha = show_alpha ~= false
            local color = default_color or color_t(1, 1, 1, 1)
            
            local function rgb_to_hsv(r, g, b)
                local mx = math.max(r, g, b)
                local mn = math.min(r, g, b)
                local d = mx - mn
                local h = 0
                if d ~= 0 then
                    if mx == r then h = (g - b) / d % 6
                    elseif mx == g then h = (b - r) / d + 2
                    else h = (r - g) / d + 4 end
                    h = h / 6
                end
                local s = (mx ~= 0) and (d / mx) or 0
                return h, s, mx
            end
            
            local h, s, v = rgb_to_hsv(color.r, color.g, color.b)
            
            local cp = {
                type = "color_picker",
                label = label,
                value = color,
                hsv = {h, s, v, color.a},
                height = 24,
                y = self.next_y,
                opened = false,
                current_alpha = 1,
                parent = element,
                show_alpha = show_alpha,
                preview_bounds = nil,
                popup_bounds = nil,
                picker_bounds = nil,
                hue_bounds = nil,
                alpha_bounds = nil,
                copy_bounds = nil,
                paste_bounds = nil,
                dragging_picker = false,
                dragging_hue = false,
                dragging_alpha = false,
                copy_press = false,
                paste_press = false,
                copy_clicked = false,
                paste_clicked = false,
                copy_anim = nil,
                paste_anim = nil,
                visible = true,
                gear_type = "color_picker",
                rgb_to_hsv = function(self, col)
                    local rr, gg, bb = col.r, col.g, col.b
                    local mx = math.max(rr, gg, bb)
                    local mn = math.min(rr, gg, bb)
                    local d = mx - mn
                    local hh = 0
                    if d ~= 0 then
                        if mx == rr then hh = (gg - bb) / d % 6
                        elseif mx == gg then hh = (bb - rr) / d + 2
                        else hh = (rr - gg) / d + 4 end
                        hh = hh / 6
                    end
                    local ss = (mx ~= 0) and (d / mx) or 0
                    return {hh, ss, mx, col.a}
                end,
                hsv_to_rgb = function(self, hsv)
                    local hh, ss, vv, aa = hsv[1], hsv[2], hsv[3], hsv[4] or 1
                    if ss == 0 then return color_t(vv, vv, vv, aa) end
                    local h_section = math.floor(hh * 6)
                    local h_fraction = hh * 6 - h_section
                    local p = vv * (1 - ss)
                    local q = vv * (1 - ss * h_fraction)
                    local t = vv * (1 - ss * (1 - h_fraction))
                    local rr, gg, bb
                    if h_section == 0 then rr, gg, bb = vv, t, p
                    elseif h_section == 1 then rr, gg, bb = q, vv, p
                    elseif h_section == 2 then rr, gg, bb = p, vv, t
                    elseif h_section == 3 then rr, gg, bb = p, q, vv
                    elseif h_section == 4 then rr, gg, bb = t, p, vv
                    else rr, gg, bb = vv, p, q end
                    return color_t(rr, gg, bb, aa)
                end,
            }

            function cp:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end
            
            function cp:Get() return self.value end
            function cp:Set(col) self.value = col; self.hsv = self:rgb_to_hsv(col) end
            function cp:Hex() 
                if self.show_alpha then
                    return string.format("#%02x%02x%02x%02x", self.value.r*255, self.value.g*255, self.value.b*255, self.value.a*255):upper()
                else
                    return string.format("#%02x%02x%02x", self.value.r*255, self.value.g*255, self.value.b*255):upper()
                end
            end
            
            gear_group:add_widget(cp, "color_picker")
            gear_group:recalculate_layout()
            return cp
        end

        gear_group.Hotkey = function(self, label, default_key, default_mode, available_modes, mode_names_custom, callback)
            default_key = default_key or 0
            default_mode = default_mode or 1
            
            local modes_available = available_modes or {true, true, true}
            
            local default_mode_names = {"Always", "Hold", "Toggle"}
            local mode_names = {}
            
            if mode_names_custom and type(mode_names_custom) == "table" then
                local custom_index = 1
                for i = 1, 3 do
                    if modes_available[i] then
                        if mode_names_custom[custom_index] then
                            table.insert(mode_names, mode_names_custom[custom_index])
                        else
                            table.insert(mode_names, default_mode_names[i])
                        end
                        custom_index = custom_index + 1
                    end
                end
            else
                if modes_available[1] then table.insert(mode_names, "Always") end
                if modes_available[2] then table.insert(mode_names, "Hold") end
                if modes_available[3] then table.insert(mode_names, "Toggle") end
            end
            
            local key_display = default_key == 0 and "?" or GetKeyName(default_key)
            local text_width = get_text_width(fonts.StandartFont, key_display)
            local button_width = text_width + 16
            
            local hotkey = {
                type = "hotkey",
                label = label,
                key = default_key,
                mode = default_mode,
                available_modes = modes_available,
                mode_names = mode_names,
                toggle_state = false,
                active = (default_mode == 1),
                height = 26,
                y = self.next_y,
                hovered = false,
                text_hovered = false,
                mode_popup_opened = false,
                mode_popup_progress = 0,
                mode_popup_anim = nil,
                current_button_width = button_width,
                parent = element,
                current_alpha = 1,
                click_processed = false,
                mode_click_processed = false,
                waiting_for_key = false,
                callback = callback or nil,
                visible = true,
                gear_type = "hotkey",
            }
            
            function hotkey:Get()
                return self.active
            end

            function hotkey:Visibility(value)
                self.visible = value
                gear_group:recalculate_layout()
                return self
            end
            
            function hotkey:GetKey()
                return { key = self.key, mode = self.mode }
            end
            
            function hotkey:GetModeName()
                local display_idx = 1
                for i = 1, 3 do
                    if self.available_modes[i] then
                        if i == self.mode then
                            return self.mode_names[display_idx]
                        end
                        display_idx = display_idx + 1
                    end
                end
                return self.mode_names[1] or "Always"
            end
            
            function hotkey:SetKey(key_code)
                self.key = key_code
                local new_display = key_code == 0 and "?" or GetKeyName(key_code)
                local new_width = get_text_width(fonts.StandartFont, new_display) + 16
                self.current_button_width = new_width
                if self.mode == 1 then
                    self.active = true
                elseif self.mode == 3 then
                    self.toggle_state = false
                    self.active = false
                end
                if self.callback then
                    self.callback(self.active, self)
                end
            end
            
            function hotkey:SetMode(mode)
                if not self.available_modes[mode] then
                    for i = 1, 3 do
                        if self.available_modes[i] then
                            mode = i
                            break
                        end
                    end
                end
                self.mode = mode
                if mode == 1 then
                    self.active = true
                elseif mode == 2 then
                    self.active = (self.key ~= 0) and input.IsKeyPressed(self.key) or false
                elseif mode == 3 then
                    self.toggle_state = false
                    self.active = false
                end
                if self.callback then
                    self.callback(self.active, self)
                end
            end
            
            function hotkey:SetCallback(callback_func)
                self.callback = callback_func
                return self
            end
            
            function hotkey:Set(key_settings)
                if key_settings.key then self:SetKey(key_settings.key) end
                if key_settings.mode then self:SetMode(key_settings.mode) end
            end
            
            gear_group:add_widget(hotkey, "hotkey")
            table.insert(hotkey_widgets, hotkey)
            gear_group:recalculate_layout()
            return hotkey
        end
        
        gear_group.render = function(self)
            local alpha = self.fade_progress
            
            local opened_color_picker = nil
            
            for _, widget in ipairs(self.widgets) do
                if widget.visible ~= false then
                    if widget.gear_type == "checkbox" then
                        draw_checkbox(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    elseif widget.gear_type == "slider" then
                        draw_slider(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    elseif widget.gear_type == "selectable" then
                        draw_selectable_button(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    elseif widget.gear_type == "button" then
                        draw_button(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    elseif widget.gear_type == "label" then
                        draw_label(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    elseif widget.gear_type == "input" then
                        draw_input(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha, 60)
                    elseif widget.gear_type == "color_picker" then
                        draw_color_picker(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha, false) 
                        if widget.opened then
                            opened_color_picker = widget
                        end
                    elseif widget.gear_type == "hotkey" then
                        draw_hotkey(widget, self.pos, self.left_padding, self.right_padding, self.size.x, alpha)
                    end
                end
            end
            
            for _, widget in ipairs(self.widgets) do
                if widget.visible ~= false and widget.gear_type == "selectable" and widget.opened and widget.dropdown_height_progress > 0 then
                    draw_selectable_dropdown(widget, self.pos, self.right_padding, self.size.x, alpha)
                end
            end
            
            if opened_color_picker then
                draw_color_picker_popup(opened_color_picker, self.pos, self.right_padding, self.size.x, alpha)
            end
        end
        
        gear_group.update = function(self, mouse_pos, mouse_left)
            for _, widget in ipairs(self.widgets) do
                if widget.visible ~= false then
                    if widget.gear_type == "checkbox" then
                        update_checkbox(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    elseif widget.gear_type == "slider" then
                        update_slider(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    elseif widget.gear_type == "selectable" then
                        update_selectable(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    elseif widget.gear_type == "button" then
                        update_button(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    elseif widget.gear_type == "input" then
                        update_input(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x, 60)
                    elseif widget.gear_type == "color_picker" then
                        update_color_picker(widget, mouse_pos, mouse_left, true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    elseif widget.gear_type == "hotkey" then
                        update_hotkey(widget, mouse_pos, mouse_left, input.IsKeyPressed(VK_RBUTTON), true, self.pos, self.left_padding, self.right_padding, self.size.x)
                    end
                end
            end
        end
        
        local result = config_func(gear_group)
        if result then
            for k, v in pairs(result) do
                element[k] = v
            end
        end
        
        element.gear_group = gear_group
        element.hasSettingsGear = true
        element.gear_callback = config_func
        element.gear_opened = false
        element.gear_progress = 0
        element.gear_group_created = true
        element.gear_x = 0
        element.gear_y = 0
        
        gear_group:recalculate_layout()
        
        return element
    end

    function add_gear_button(element, x, y, alpha)
        if not element or not element.hasSettingsGear then return end

        if element.disabled then
            local gear_color = color_t(0.6, 0.6, 0.6, 0.55 * alpha)
            render.text(ICON_GEAR, fonts.StandartIcons, vec2_t(x, y - 1), gear_color)
            return
        end
        
        local is_selectable_open = false
        if active_selectable and active_selectable.opened then is_selectable_open = true end
        
        local is_color_picker_active = false
        if active_selectable and active_selectable.type == "color_picker" then
            local cp = active_selectable
            if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                is_color_picker_active = true
            end
        end
        
        if not is_color_picker_active then
            for _, win in ipairs(all_windows) do
                for _, group in ipairs(win.groups or {}) do
                    for _, cp in ipairs(group.color_pickers or {}) do
                        if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                            is_color_picker_active = true
                            break
                        end
                    end
                    if is_color_picker_active then break end
                end
                if is_color_picker_active then break end
            end
        end
        
        if is_selectable_open or is_color_picker_active then
            local gear_color = color_t(0.6, 0.6, 0.6, 0.8 * alpha)
            render.text(ICON_GEAR, fonts.StandartIcons, vec2_t(x, y - 1), gear_color)
            return
        end
        
        element.gear_x = x
        element.gear_y = y
        
        local mouse_pos = input.GetMousePos()
        local is_hovered = mouse_pos.x >= x and mouse_pos.x <= x + 14 and mouse_pos.y >= y and mouse_pos.y <= y + 14
        local gear_color = color_t(0.6, 0.6, 0.6, 0.8 * alpha)
        if is_hovered then gear_color = color_t(accent_color.r, accent_color.g, accent_color.b, 1 * alpha) end
        render.text(ICON_GEAR, fonts.StandartIcons, vec2_t(x, y - 1), gear_color)
        
        local mouse_left = input.IsKeyPressed(VK_LBUTTON)
        if is_hovered and mouse_left and not active_gear_popup then
            if element.gear_opened then
                gear_close_popup(element, false)
            else
                if active_gear_popup then gear_close_popup(active_gear_popup, true) end
                
                element.gear_opened = true
                active_gear_popup = element
                gear_blocking = true
                if element.gear_anim then element.gear_anim:stop() end
                element.gear_progress = 0
                element.gear_anim = anim.animate_to(element, "gear_progress", 0, 1, 0.2, "cubic_out")
                element.gear_anim:start()
            end
        end
    end

    local function gear_update_interaction()
        if not active_gear_popup or not active_gear_popup.gear_opened then 
            gear_blocking = false 
            return  
        end
        
        local blocked, blocking_win = is_gear_blocked_by_pinned_window(active_gear_popup)
        if blocked then
            gear_close_popup(active_gear_popup, true)
            active_gear_popup = nil
            gear_blocking = false
            return
        end
        
        local open_selectable_in_gear = nil
        local open_selectable_bounds = nil
        if active_gear_popup.gear_group then
            for _, sel in ipairs(active_gear_popup.gear_group.selectables or {}) do
                if sel.opened and sel.dropdown_height_progress > 0.5 then
                    open_selectable_in_gear = sel
                    local button_x = active_gear_popup.gear_popup_bounds.x + 10 + 
                                        active_gear_popup.gear_group.size.x - 
                                        active_gear_popup.gear_group.right_padding - sel.button_width
                    local button_y = active_gear_popup.gear_popup_bounds.y + 10 + sel.y + (sel.height - 20) / 2
                    
                    local max_item_width = 0
                    for _, item in ipairs(sel.items) do
                        local item_width = get_text_width(fonts.StandartFont, item)
                        if item_width > max_item_width then max_item_width = item_width end
                    end
                    local dropdown_width = math.max(120, max_item_width + 30)
                    local dropdown_height = math.min(#sel.items * 22, 1000) * (sel.dropdown_height_progress or 1)
                    
                    open_selectable_bounds = {
                        x = button_x,
                        y = button_y + 22,
                        w = dropdown_width,
                        h = dropdown_height
                    }
                    break
                end
            end
        end
        
        local open_color_picker_in_gear = nil
        local open_color_picker_bounds = nil
        if active_gear_popup.gear_group then
            for _, cp in ipairs(active_gear_popup.gear_group.color_pickers or {}) do
                if cp.opened and cp.popup_bounds then
                    open_color_picker_in_gear = cp
                    open_color_picker_bounds = cp.popup_bounds
                    break
                end
            end
        end
        
        for _, hotkey in ipairs(hotkey_widgets) do
            if hotkey.mode_popup_opened then
                if active_gear_popup.gear_group then
                    active_gear_popup.gear_group.pos = vec2_t(active_gear_popup.gear_popup_bounds.x + 10, active_gear_popup.gear_popup_bounds.y + 10)
                    active_gear_popup.gear_group:update(input.GetMousePos(), input.IsKeyPressed(VK_LBUTTON))
                end
                return
            end
        end
        
        local bounds = active_gear_popup.gear_popup_bounds
        if not bounds then return end
        
        local mouse_pos = input.GetMousePos()
        local mouse_left = input.IsKeyPressed(VK_LBUTTON)
        
        local in_popup = mouse_pos.x >= bounds.x and mouse_pos.x <= bounds.x + bounds.w and
                            mouse_pos.y >= bounds.y and mouse_pos.y <= bounds.y + bounds.h
        
        local in_open_selectable = false
        if open_selectable_in_gear and open_selectable_bounds then
            in_open_selectable = mouse_pos.x >= open_selectable_bounds.x and 
                                    mouse_pos.x <= open_selectable_bounds.x + open_selectable_bounds.w and
                                    mouse_pos.y >= open_selectable_bounds.y and 
                                    mouse_pos.y <= open_selectable_bounds.y + open_selectable_bounds.h
        end
        
        local in_open_color_picker = false
        if open_color_picker_in_gear and open_color_picker_bounds then
            in_open_color_picker = mouse_pos.x >= open_color_picker_bounds.x and 
                                    mouse_pos.x <= open_color_picker_bounds.x + open_color_picker_bounds.w and
                                    mouse_pos.y >= open_color_picker_bounds.y and 
                                    mouse_pos.y <= open_color_picker_bounds.y + open_color_picker_bounds.h
        end
        
        local on_gear_element_button = false
        if open_selectable_in_gear then
            local btn_x = bounds.x + 10 + active_gear_popup.gear_group.size.x - 
                            active_gear_popup.gear_group.right_padding - open_selectable_in_gear.button_width
            local btn_y = bounds.y + 10 + open_selectable_in_gear.y + (open_selectable_in_gear.height - 20) / 2
            on_gear_element_button = mouse_pos.x >= btn_x and mouse_pos.x <= btn_x + open_selectable_in_gear.button_width and
                                        mouse_pos.y >= btn_y and mouse_pos.y <= btn_y + 20
        end
        
        local over_pinned, _ = is_position_blocked_by_pinned_window(mouse_pos.x, mouse_pos.y, nil)
        
        local is_dragging_inside = false
        if active_gear_popup.gear_group then
            for _, sl in ipairs(active_gear_popup.gear_group.sliders or {}) do
                if sl.dragging then
                    is_dragging_inside = true
                    break
                end
            end
            if not is_dragging_inside then
                for _, cp in ipairs(active_gear_popup.gear_group.color_pickers or {}) do
                    if cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                        is_dragging_inside = true
                        break
                    end
                end
            end
        end
        
        local is_dropdown_open_in_gear = false
        if active_gear_popup.gear_group then
            for _, sel in ipairs(active_gear_popup.gear_group.selectables or {}) do
                if sel.opened then
                    is_dropdown_open_in_gear = true
                    break
                end
            end
        end
        
        if active_gear_popup.gear_group then
            active_gear_popup.gear_group.pos = vec2_t(bounds.x + 10, bounds.y + 10)
            active_gear_popup.gear_group:update(mouse_pos, mouse_left)
        end
        
        local on_color_picker_drag = false
        if active_gear_popup.gear_group then
            for _, cp in ipairs(active_gear_popup.gear_group.color_pickers or {}) do
                if cp.opened and cp.popup_bounds then
                    if cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                        on_color_picker_drag = true
                        break
                    end
                    if mouse_pos.x >= cp.popup_bounds.x and mouse_pos.x <= cp.popup_bounds.x + cp.popup_bounds.w and
                        mouse_pos.y >= cp.popup_bounds.y and mouse_pos.y <= cp.popup_bounds.y + cp.popup_bounds.h then
                        on_color_picker_drag = true
                        break
                    end
                end
            end
        end
        
        local should_keep_open = in_open_selectable or in_open_color_picker or on_gear_element_button or 
                                    on_color_picker_drag or is_dragging_inside or is_dropdown_open_in_gear
        
        if mouse_left and (over_pinned or (not in_popup and not should_keep_open)) then
            local gear_x = active_gear_popup.gear_x or 0
            local gear_y = active_gear_popup.gear_y or 0
            local on_gear = mouse_pos.x >= gear_x and mouse_pos.x <= gear_x + 14 and 
                            mouse_pos.y >= gear_y and mouse_pos.y <= gear_y + 14
            if not on_gear then
                gear_close_popup(active_gear_popup, false)
            end
        end
    end

    function gui.update()
        if not utils.IsCS2Foreground() then return end

        local mouse_pos = input.GetMousePos()
        local mouse_left = input.IsKeyPressed(VK_LBUTTON)
        local mouse_clicked = mouse_left and not last_mouse_left
        last_mouse_left = mouse_left
        
        if active_gear_popup then
            local window_exists = false
            local gear_parent = active_gear_popup

            while gear_parent do
                if gear_parent.type == "window" then
                    if not gear_parent.is_open then
                        window_exists = false
                        break
                    end
                    window_exists = true
                    break
                end
                gear_parent = gear_parent.parent
            end
            
            if not window_exists then
                if active_gear_popup.gear_anim then active_gear_popup.gear_anim:stop() end
                active_gear_popup.gear_opened = false
                active_gear_popup.gear_progress = 0
                active_gear_popup = nil
                gear_blocking = false
            end
        end
        
        update_all_hotkeys()
        gear_update_interaction()
        
        local open_hotkey_popup = nil
        local open_hotkey_widget = nil
        
        for _, win in ipairs(all_windows) do
            for _, group in ipairs(win.groups or {}) do
                for _, hk in ipairs(group.hotkeys or {}) do
                    if hk.mode_popup_opened then
                        open_hotkey_popup = hk
                        open_hotkey_widget = hk
                        break
                    end
                end
                if open_hotkey_popup then break end
            end
            if open_hotkey_popup then break end
        end
        
        if not open_hotkey_popup and active_gear_popup and active_gear_popup.gear_group then
            for _, hk in ipairs(active_gear_popup.gear_group.hotkeys or {}) do
                if hk.mode_popup_opened then
                    open_hotkey_popup = hk
                    open_hotkey_widget = hk
                    break
                end
            end
        end
        
        if open_hotkey_popup then
            if dragging_window then
                dragging_window.is_dragging = false
                dragging_window = nil
            end
            
            if active_slider then
                active_slider.dragging = false
                active_slider = nil
            end
            if active_checkbox then active_checkbox = nil end
            
            for _, win in ipairs(all_windows) do
                for _, group in ipairs(win.groups or {}) do
                    for _, hk in ipairs(group.hotkeys or {}) do
                        if hk == open_hotkey_popup then
                            update_hotkey(hk, mouse_pos, mouse_left, input.IsKeyPressed(VK_RBUTTON), true, 
                                            group.pos, group.left_padding, group.right_padding, group.size.x)
                            break
                        end
                    end
                end
            end
            
            if active_gear_popup and active_gear_popup.gear_group then
                for _, hk in ipairs(active_gear_popup.gear_group.hotkeys or {}) do
                    if hk == open_hotkey_popup then
                        local gear_bounds = active_gear_popup.gear_popup_bounds
                        if gear_bounds then
                            update_hotkey(hk, mouse_pos, mouse_left, input.IsKeyPressed(VK_RBUTTON), true, vec2_t(gear_bounds.x + 10, gear_bounds.y + 10), 5, 5, 320)
                        end
                        break
                    end
                end
            end
            
            return
        end
        
        local function is_any_color_picker_interacting()
            for _, win in ipairs(all_windows) do
                for _, group in ipairs(win.groups or {}) do
                    for _, cp in ipairs(group.color_pickers or {}) do
                        if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                            return true, win
                        end
                    end
                end
            end
            if active_gear_popup and active_gear_popup.gear_group then
                for _, cp in ipairs(active_gear_popup.gear_group.color_pickers or {}) do
                    if cp.opened or cp.dragging_picker or cp.dragging_hue or cp.dragging_alpha then
                        return true, nil
                    end
                end
            end
            return false, nil
        end
        
        local color_picker_active, active_win = is_any_color_picker_interacting()
        
        if color_picker_active then
            for _, win in ipairs(all_windows) do
                local was_dragging = win.is_dragging
                win.is_dragging = false
                
                for _, group in ipairs(win.groups or {}) do
                    if group.fade_progress > 0 or group.is_animating or group.visible then
                        group:update(mouse_pos, mouse_clicked, mouse_left)
                    end
                end
                
                win.is_dragging = was_dragging
            end
            
            if dragging_window then
                dragging_window.is_dragging = false
                dragging_window = nil
            end

            for _, win in ipairs(all_windows) do
                if win.is_pinned then
                    win.update(mouse_pos, mouse_clicked, mouse_left)
                end
            end
            for _, win in ipairs(all_windows) do
                if not win.is_pinned then
                    win.update(mouse_pos, mouse_clicked, mouse_left)
                end
            end
            
            return
        end
        
        if not mouse_left then
            if dragging_window then dragging_window.is_dragging = false; dragging_window = nil end
            if active_slider then active_slider.dragging = false; active_slider = nil end
            for _, win in ipairs(all_windows) do
                for _, group in ipairs(win.groups or {}) do
                    for _, sel in ipairs(group.selectables or {}) do sel.click_processed = false end
                end
            end
        end
        
        for i = 1, #all_windows do 
            local w = all_windows[i]
            if w.is_pinned and (w.is_open or w.window_fade_progress > 0.01) then 
                w.update(mouse_pos, mouse_clicked, mouse_left) 
            end 
        end
        if not dragging_window or not dragging_window.is_pinned then
            for i = 1, #all_windows do 
                local w = all_windows[i]
                if not w.is_pinned and (w.is_open or w.window_fade_progress > 0.01) then 
                    w.update(mouse_pos, mouse_clicked, mouse_left) 
                end 
            end
        end
    end

    function gui.render()
        pending_hotkey_popups = {}
        
        for i = 1, #all_windows do 
            local w = all_windows[i]
            if not w.is_pinned and (w.is_open or w.window_fade_progress > 0.01) then 
                w.render() 
            end 
        end

        if active_gear_popup and active_gear_popup.gear_opened then
            gear_draw_popup(active_gear_popup)
        end

        for i = 1, #all_windows do if all_windows[i].is_pinned then all_windows[i].render() end end
        
        for _, hk in ipairs(pending_hotkey_popups) do
            draw_hotkey_mode_popup(hk)
        end
        pending_hotkey_popups = {}
    end

    function gui.get_window(name)
        for i = 1, #all_windows do if all_windows[i].name == name then return all_windows[i] end end
        return nil
    end

    function gui.get_all_windows()
        return all_windows
    end

    local paint_under_callbacks = {}
    function gui.paint(callback)
        if callback then
            table.insert(paint_under_callbacks, callback)
            return callback
        end

        for _, cb in ipairs(paint_under_callbacks) do
            pcall(cb)
        end
    end

    function gui.clear_paint_under()
        paint_under_callbacks = {}
    end

    function gui.remove_paint_under(callback)
        for i = #paint_under_callbacks, 1, -1 do
            if paint_under_callbacks[i] == callback then
                table.remove(paint_under_callbacks, i)
            end
        end
    end

    function gui.draw()
        for _, cb in ipairs(paint_under_callbacks) do
            pcall(cb)
        end

        gui.update()
        gui.render()
    end

    return gui

end

libraries["library.render.animation"] = function()
    local events = require("library.engine.events")

    local animations = {}

    local Animation = {}
    Animation.__index = Animation

    function Animation.new(target, property, start_value, end_value, duration, easing)
        local anim = {
            target = target,
            property = property,
            start_value = start_value,
            end_value = end_value,
            duration = duration,
            elapsed = 0,
            easing = easing or "linear",
            active = true,
            loop = false,
            pingpong = false,
            reverse = false,
            on_start = nil,
            on_update = nil,
            on_complete = nil,
            original_value = nil,
            is_color = false,
            color_components = nil
        }
        
        if start_value and end_value and type(start_value) == "userdata" and type(end_value) == "userdata" then
            local s_r = start_value.r
            local s_g = start_value.g
            local s_b = start_value.b
            local s_a = start_value.a
            local e_r = end_value.r
            local e_g = end_value.g
            local e_b = end_value.b
            local e_a = end_value.a
            
            if s_r and s_g and s_b and s_a and e_r and e_g and e_b and e_a then
                anim.is_color = true
                anim.color_components = {
                    r = {start = tonumber(s_r) or 0, finish = tonumber(e_r) or 0},
                    g = {start = tonumber(s_g) or 0, finish = tonumber(e_g) or 0},
                    b = {start = tonumber(s_b) or 0, finish = tonumber(e_b) or 0},
                    a = {start = tonumber(s_a) or 0, finish = tonumber(e_a) or 0}
                }
            end
        end
        
        setmetatable(anim, Animation)
        
        if target and target[property] then
            anim.original_value = target[property]
        end
        
        table.insert(animations, anim)
        return anim
    end

    local easings = {
        linear = function(t) return t end,
        quad_in = function(t) return t * t end,
        quad_out = function(t) return t * (2 - t) end,
        quad_in_out = function(t) 
            if t < 0.5 then return 2 * t * t 
            else return 1 - math.pow(-2 * t + 2, 2) / 2 end
        end,
        cubic_in = function(t) return t * t * t end,
        cubic_out = function(t) return 1 - math.pow(1 - t, 3) end,
        cubic_in_out = function(t)
            if t < 0.5 then return 4 * t * t * t
            else return 1 - math.pow(-2 * t + 2, 3) / 2 end
        end,
        expo_in = function(t) return t == 0 and 0 or math.pow(2, 10 * t - 10) end,
        expo_out = function(t) return t == 1 and 1 or 1 - math.pow(2, -10 * t) end,
        bounce_out = function(t)
            local t_val = t
            if t_val < 1 / 2.75 then
                return 7.5625 * t_val * t_val
            elseif t_val < 2 / 2.75 then
                t_val = t_val - 1.5 / 2.75
                return 7.5625 * t_val * t_val + 0.75
            elseif t_val < 2.5 / 2.75 then
                t_val = t_val - 2.25 / 2.75
                return 7.5625 * t_val * t_val + 0.9375
            else
                t_val = t_val - 2.625 / 2.75
                return 7.5625 * t_val * t_val + 0.984375
            end
        end,
        elastic_out = function(t)
            if t == 0 or t == 1 then return t end
            return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi) / 3) + 1
        end,
        back_out = function(t)
            local c1 = 1.70158
            local c3 = c1 + 1
            return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
        end
    }

    function Animation:update(delta_time)
        if not self.active then return end
        
        self.elapsed = self.elapsed + delta_time
        
        local t = math.min(1, self.elapsed / self.duration)
        local eased_t = easings[self.easing](t)
        
        if self.is_color then
            local r = self.color_components.r.start + (self.color_components.r.finish - self.color_components.r.start) * eased_t
            local g = self.color_components.g.start + (self.color_components.g.finish - self.color_components.g.start) * eased_t
            local b = self.color_components.b.start + (self.color_components.b.finish - self.color_components.b.start) * eased_t
            local a = self.color_components.a.start + (self.color_components.a.finish - self.color_components.a.start) * eased_t
            
            local current_value = color_t(r, g, b, a)
            
            if self.target and self.target[self.property] then
                self.target[self.property] = current_value
            end
            
            if self.on_update and type(self.on_update) == "function" then
                self.on_update(self.target, current_value, t)
            end
        else
            local current_value = self.start_value + (self.end_value - self.start_value) * eased_t
            
            if self.target and self.target[self.property] then
                self.target[self.property] = current_value
            end
            
            if self.on_update and type(self.on_update) == "function" then
                self.on_update(self.target, current_value, t)
            end
        end
        
        if t >= 1 then
            if self.loop then
                self.elapsed = 0
                if self.pingpong then
                    self.start_value, self.end_value = self.end_value, self.start_value
                    if self.is_color then
                        self.color_components = {
                            r = {start = self.color_components.r.finish, finish = self.color_components.r.start},
                            g = {start = self.color_components.g.finish, finish = self.color_components.g.start},
                            b = {start = self.color_components.b.finish, finish = self.color_components.b.start},
                            a = {start = self.color_components.a.finish, finish = self.color_components.a.start}
                        }
                    end
                end
                if self.on_start and type(self.on_start) == "function" then
                    self.on_start(self.target)
                end
            else
                self.active = false
                if self.on_complete and type(self.on_complete) == "function" then
                    self.on_complete(self.target)
                end
            end
        end
    end

    function Animation:stop()
        self.active = false
        return self
    end

    function Animation:start()
        self.active = true
        self.elapsed = 0
        if self.on_start and type(self.on_start) == "function" then
            self.on_start(self.target)
        end
        return self
    end

    function Animation:reset()
        self.elapsed = 0
        if self.target and self.target[self.property] and self.original_value then
            self.target[self.property] = self.original_value
        end
        return self
    end

    function Animation:reverse()
        self.start_value, self.end_value = self.end_value, self.start_value
        if self.is_color then
            self.color_components = {
                r = {start = self.color_components.r.finish, finish = self.color_components.r.start},
                g = {start = self.color_components.g.finish, finish = self.color_components.g.start},
                b = {start = self.color_components.b.finish, finish = self.color_components.b.start},
                a = {start = self.color_components.a.finish, finish = self.color_components.a.start}
            }
        end
        self.elapsed = 0
        return self
    end

    function animations.animate(target, property, end_value, duration, easing)
        local start_value = target[property]
        return Animation.new(target, property, start_value, end_value, duration, easing)
    end

    function animations.animate_to(target, property, start_value, end_value, duration, easing)
        return Animation.new(target, property, start_value, end_value, duration, easing)
    end

    function animations.animate_color(target, property, end_color, duration, easing)
        local start_color = target[property]
        return Animation.new(target, property, start_color, end_color, duration, easing)
    end

    function animations.fade_in(target, duration, easing)
        if target and target.setting then
            local start_color = target:setting("get", "bg_color")
            local end_color = color_t(start_color.r, start_color.g, start_color.b, 1)
            return Animation.new(target, "bg_color", start_color, end_color, duration, easing)
        end
        return nil
    end

    function animations.fade_out(target, duration, easing)
        if target and target.setting then
            local start_color = target:setting("get", "bg_color")
            local end_color = color_t(start_color.r, start_color.g, start_color.b, 0)
            return Animation.new(target, "bg_color", start_color, end_color, duration, easing)
        end
        return nil
    end

    function animations.move_to(target, end_pos, duration, easing)
        if not target then return nil end
        local start_pos = target.pos
        return Animation.new(target, "pos", start_pos, end_pos, duration, easing)
    end

    function animations.resize_to(target, end_size, duration, easing)
        if not target then return nil end
        local start_size = target.size
        return Animation.new(target, "size", start_size, end_size, duration, easing)
    end

    local last_time = nil

    function animations.update_all()
        local current_time = os.clock()
        if not last_time then
            last_time = current_time
            return
        end
        
        local delta_time = math.min(0.033, current_time - last_time)
        last_time = current_time
        
        for i = #animations, 1, -1 do
            local anim_obj = animations[i]
            if anim_obj and anim_obj.active then
                anim_obj:update(delta_time)
            end
            if not anim_obj or not anim_obj.active then
                table.remove(animations, i)
            end
        end
    end

    function animations.stop_all()
        for _, anim_obj in ipairs(animations) do
            if anim_obj then
                anim_obj.active = false
            end
        end
        animations = {}
    end

    function animations.get_active_count()
        local count = 0
        for _, anim_obj in ipairs(animations) do
            if anim_obj and anim_obj.active then
                count = count + 1
            end
        end
        return count
    end

    events.paint(function()
        animations.update_all()
    end)

    return animations

end

libraries["library.render.blur"] = function()
    BlurSettings = {
        DownScale = 0.15,      
        BlurFpsLimit = 30,   
        KernelRadius = 7,     
        Sigma = 1.5,           
        OverlayAlpha = 240,   
        CleanupInterval = 60,
        BorderRadius = 0
    }

    local Blur = {
        ctx = nil,
        env = nil,
        last_cleanup = os.time()
    }

    local blur_code = [=[
        local f, b, m = require("ffi"), require("bit"), math
        local bd, rs, ls, br = b.band, b.rshift, b.lshift, b.bor
        local fl, mx, mn, ex = m.floor, m.max, m.min, m.exp
        local u3, g3 = f.load("user32"), f.load("gdi32")

        pcall(f.cdef, [[
            typedef struct {
                unsigned long s; long w; long h; unsigned short p; unsigned short c;
                unsigned long cm; unsigned long si; long x; long y; unsigned long cu; unsigned long ci;
            } BIH;
            typedef struct { BIH h; unsigned long c[1]; } BI;
            void* GetWindowDC(void* w); void* CreateCompatibleDC(void* d);
            void* CreateCompatibleBitmap(void* d, int w, int h);
            void* SelectObject(void* d, void* o);
            int BitBlt(void* d, int x, int y, int w, int h, void* s, int x1, int y1, unsigned long r);
            int DeleteObject(void* o); int DeleteDC(void* d); int ReleaseDC(void* w, void* d);
            int GetDIBits(void* d, void* b, unsigned int s, unsigned int c, void* l, BI* i, unsigned int u);
            void* GetDesktopWindow(void);
        ]])

        local P = { b = {}, s = {}, k = nil }
        local function g_b(id, sz)
            if P.b[id] and P.s[id] >= sz then return P.b[id] end
            local n = fl(sz * 1.1)
            P.b[id] = f.new("uint32_t[?]", n)
            P.s[id] = n
            return P.b[id]
        end

        local function g_r(sz)
            if P.b["r"] and P.s["r"] >= sz then return P.b["r"] end
            local n = fl(sz * 1.1)
            P.b["r"] = f.new("unsigned char[?]", n)
            P.s["r"] = n
            return P.b["r"]
        end

        local function g_k(r, s)
            if P.k then return P.k end
            local z = r * 2 + 1; local k = f.new("float[?]", z); local sm = 0.0
            for i = -r, r do
                local v = ex(-(i * i) / (2 * s * s))
                k[i + r] = v; sm = sm + v
            end
            for i = 0, z - 1 do k[i] = k[i] / sm end
            P.k = k; return k
        end

        _G.st = _G.st or { t = nil, lu = 0, ac = 0, p_buf = {} }  

        return function(x, y, w, h, a, c)
            local cur = render.frame_count() / 1000.0
            _G.st.ac = _G.st.ac + render.frame_time()
            
            local up_i = 1.0 / c.BlurFpsLimit
            if (_G.st.ac - _G.st.lu) > up_i or _G.st.t == nil then
                
                
                local hw = u3.GetDesktopWindow()
                local hsc = u3.GetWindowDC(hw)
                local hmc = g3.CreateCompatibleDC(hsc)
                local hbm = g3.CreateCompatibleBitmap(hsc, w, h)
                local old = g3.SelectObject(hmc, hbm)
                
                g3.BitBlt(hmc, 0, 0, w, h, hsc, x, y, 0x40CC0020)
                
                local bi = f.new("BI")
                bi.h.s = 40; bi.h.w = w; bi.h.h = -h; bi.h.p = 1; bi.h.c = 32
                
                local rb = g_r(w * h * 4)
                local res = g3.GetDIBits(hmc, hbm, 0, h, rb, bi, 0)
                
                g3.SelectObject(hmc, old)
                g3.DeleteObject(hbm)
                g3.DeleteDC(hmc)
                u3.ReleaseDC(hw, hsc)
                
                if res ~= 0 then
                    local sc = c.DownScale
                    local dw = mx(1, fl(w * sc))
                    local dh = mx(1, fl(h * sc))
                    local np = dw * dh
                    
                    local bA = g_b("A", np)
                    local bB = g_b("B", np)
                    local iX, iY = w / dw, h / dh

                    for dy = 0, dh - 1 do
                        local sY = fl((dy + 0.5) * iY)
                        if sY >= h then sY = h - 1 end
                        local rS, rD = sY * w * 4, dy * dw
                        for dx = 0, dw - 1 do
                            local sX = fl((dx + 0.5) * iX)
                            if sX >= w then sX = w - 1 end
                            local i = rS + (sX * 4)
                            bA[rD + dx] = br(rb[i+2], ls(rb[i+1], 8), ls(rb[i], 16), 0xFF000000)
                        end
                    end
                    
                    local kr = g_k(c.KernelRadius, c.Sigma)
                    local rd = c.KernelRadius

                    for iy = 0, dh - 1 do
                        local rO = iy * dw
                        for ix = 0, dw - 1 do
                            local r, g, b_ = 0, 0, 0
                            for k = -rd, rd do
                                local sx = ix + k
                                if sx < 0 then sx = 0 elseif sx >= dw then sx = dw - 1 end
                                local p = bA[rO + sx]; local wk = kr[k + rd]
                                r = r + bd(p, 0xFF) * wk
                                g = g + bd(rs(p, 8), 0xFF) * wk
                                b_ = b_ + bd(rs(p, 16), 0xFF) * wk
                            end
                            bB[rO + ix] = br(mn(r, 255), ls(mn(g, 255), 8), ls(mn(b_, 255), 16), 0xFF000000)
                        end
                    end

                    local msk = ls(c.OverlayAlpha, 24)
                    local idx = 1
                    for iy = 0, dh - 1 do
                        local rO = iy * dw
                        for ix = 0, dw - 1 do
                            local r, g, b_ = 0, 0, 0
                            for k = -rd, rd do
                                local sy = iy + k
                                if sy < 0 then sy = 0 elseif sy >= dh then sy = dh - 1 end
                                local p = bB[sy * dw + ix]; local wk = kr[k + rd]
                                r = r + bd(p, 0xFF) * wk
                                g = g + bd(rs(p, 8), 0xFF) * wk
                                b_ = b_ + bd(rs(p, 16), 0xFF) * wk
                            end
                            _G.st.p_buf[idx] = br(mn(r, 255), ls(mn(g, 255), 8), ls(mn(b_, 255), 16), msk)
                            idx = idx + 1
                        end
                    end
                    
                    
                    for i = idx, #_G.st.p_buf do _G.st.p_buf[i] = nil end
                    
                    _G.st.t = render.setup_texture_rgba(_G.st.p_buf, vec2_t(dw, dh))
                    _G.st.lu = _G.st.ac
                end
            end

            if _G.st.t then
                render.texture(_G.st.t, vec2_t(x, y), vec2_t(x + w, y + h), color_t(1, 1, 1, a), c.BorderRadius)
            end
        end
    ]=]


    function render.Blur(Pos, Size, BorderRadius, FpsLimit, Alpha, OverlayAlpha)
        local a = Alpha or 1
        if a < 0.01 then return end

        local now = os.time()
        
        BlurSettings.BorderRadius = BorderRadius or 0
        BlurSettings.BlurFpsLimit = FpsLimit or 30
        BlurSettings.OverlayAlpha = OverlayAlpha or 240

        if not Blur.ctx or (BlurSettings.CleanupInterval > 0 and now - Blur.last_cleanup > BlurSettings.CleanupInterval) then
            if Blur.env then
                if Blur.env.st and Blur.env.st.t then
                    Blur.env.st.t = nil  
                end
                for k, v in pairs(Blur.env) do Blur.env[k] = nil end
            end
            
            Blur.ctx = nil
            Blur.env = nil
            
            collectgarbage("collect")
            collectgarbage("collect")
            
            local new_env = {
                render = render, vec2_t = vec2_t, color_t = color_t, 
                require = require, pcall = pcall, math = math, 
                os = os, table = table, ffi = ffi, bit = bit
            }
            new_env._G = new_env  
            
            local loader, err = loadstring(blur_code)
            if loader then
                setfenv(loader, new_env)
                Blur.ctx = loader()
                Blur.env = new_env
                Blur.last_cleanup = now
            else
            end
        end

        if Blur.ctx then
            local status, err = pcall(Blur.ctx, Pos.x, Pos.y, Size.x, Size.y, a, BlurSettings)
            if not status then 
                Blur.ctx = nil 
            end
        end
    end

    register_callback("unload", function()
        if Blur.env then
            if Blur.env.st and Blur.env.st.t then
                Blur.env.st.t = nil
            end
            for k, v in pairs(Blur.env) do Blur.env[k] = nil end
        end

        Blur.ctx = nil

        collectgarbage("collect")
        collectgarbage("collect")
    end)

end

libraries["library.engine.buffer_string"] = function()
    local buffer_string = {}
    require("library.system.memory")

    ffi.cdef([[
        typedef struct CBufferString {
            uint32_t m_nUnknown1;
            uint32_t m_nUnknown2;
            uint8_t data[200];
            uint64_t m_nUnknown3;
            uint64_t m_nUnknown4;
        } CBufferString;
    ]])

    local CBufferStringInitPattern = FindPattern("client.dll", "48 89 5C 24 ? 57 48 83 EC ? 8B 41 ? 48 8D 79", "CBufferStringInit")
    local fnCBufferStringInit = ffi.cast("bool(__fastcall*)(CBufferString*, const char*)", CBufferStringInitPattern)

    function buffer_string.CBufferString(Path, Ext)
        local Buffer = ffi.new("CBufferString")
        Buffer.m_nUnknown1 = 0
        Buffer.m_nUnknown2 = 0xC00000C8
        Buffer.m_nUnknown3 = 0
        Buffer.m_nUnknown4 = Ext or 0x74616D76
        
        local PathBuf = ffi.new("char[?]", #Path + 1)
        ffi.copy(PathBuf, Path)
        
        fnCBufferStringInit(Buffer, PathBuf)

        return Buffer
    end

    return buffer_string

end

libraries["library.engine.interfaces"] = function()
    local interfaces = {}
    local utils = require("library.core.utils")
    require("library.system.memory")

    interfaces.ParticleSystemManager = utils.CreateInterface("particles.dll", "ParticleSystemMgr003")
    interfaces.Source2Client = utils.CreateInterface("client.dll", "Source2Client002")
    interfaces.LegacyGameUI = utils.CreateInterface("client.dll", "LegacyGameUI001")
    interfaces.ResourceSystem = utils.CreateInterface("resourcesystem.dll", "ResourceSystem013")
    interfaces.EngineCvar = utils.CreateInterface("tier0.dll", "VEngineCvar007")
    interfaces.InputSystem = utils.CreateInterface("inputsystem.dll", "InputSystemVersion001")
    interfaces.EngineClient = utils.CreateInterface("engine2.dll", "Source2EngineToClient001")

    return interfaces

end

libraries["library.engine.global_vars"] = function()
    require("library.system.memory")
    local user_cmd = require("library.engine.user_cmd")
    local global_vars = {}

    ffi.cdef([[
        typedef struct CGlobalVars {
            float m_flRealTime; //0x0000
            int32_t m_nFrameCount; //0x0004
            float m_flFrameTime; //0x0008
            float m_flFrameTime2; //0x000C
            int32_t m_nMaxClients; //0x0010
            int16_t m_nTickBase; //0x0014
            char pad_0016[22]; //0x0016
            float m_flIntervalPerSubTick; //0x002C
            float m_flCurrentTime; //0x0030
            float m_flCurrentTime2; //0x0034
            char pad_0038[16]; //0x0038
            int32_t m_nTickCount; //0x0048
            float m_flTickFraction; //0x004C
            char pad_0050[296]; //0x0050
            char* m_szCurrentMap; //0x0178
            char* m_szCurrentMapName; //0x0180
        } CGlobalVars;
    ]])

    local GlobalVars = ffi.cast("struct CGlobalVars**", FindRelative("client.dll", "48 89 15 ? ? ? ? 48 89 42", "GlobalVars", 3, 0))[0] 

    user_cmd.level_shutdown(function()
        GlobalVars = nil
    end)

    user_cmd.level_init(function()
        GlobalVars = ffi.cast("struct CGlobalVars**", FindRelative("client.dll", "48 89 15 ? ? ? ? 48 89 42", "GlobalVars", 3, 0))[0] 
    end)

    setmetatable(global_vars, {
        __index = function(_, Name)
            if not GlobalVars or not Name then return end
            return GlobalVars[Name]
        end
    })

    return global_vars

end

libraries["library.engine.particle_system"] = function()
    local particle_system = {}
    local ActiveParticles = {}
    local particle = {}
    local snapshot = {}

    particle.__index = particle
    snapshot.__index = snapshot

    require("library.system.memory")
    local utils = require("library.core.utils")
    local interfaces = require("library.engine.interfaces")
    local events = require("library.engine.events")
    local user_cmd = require("library.engine.user_cmd")
    local global_vars = require("library.engine.global_vars")
    require("library.core.enum")

    ffi.cdef([[
        typedef struct CParticleColor {
            float r, g, b;
        } CParticleColor;

        typedef struct CParticleInfo {
            float m_flLifetime, m_flWidth, m_flAlpha;
        } CParticleInfo;

        typedef struct CParticleData {
            Vector* m_vPositions;
            char pad[0x74];
            float* m_flTimes;
            char pad2[0x28];
            float* m_flTimes2;
            char pad3[0x98];
        } CParticleData;
    ]])

    local GetGameParticleManagerPattern = FindRelative("client.dll", "E8 ? ? ? ? 8B 93 ? ? ? ? 4C 8D 4C 24", "GetGameParticleManager", 1, 0)
    local GameParticleManagerPattern = FindPattern("client.dll", "48 8B 0D ? ? ? ? 41 B8 ? ? ? ? F3 0F 11 74 24", "GameParticleManager")
    local CreateParticlePattern = FindPattern("client.dll", "4C 8B DC 53 48 81 EC ? ? ? ? F2 0F 10 05", "CreateParticle")
    local SetParticleSettingsPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? F3 0F 10 1D ? ? ? ? 41 8B F8 8B DA 4C 8D 05", "SetParticleSettings")
    local DestroyParticlePattern = FindPattern("client.dll", "83 FA ? 0F 84 ? ? ? ? 41 54", "DestroyParticle")
    local SetSnapshotPattern = FindPattern("client.dll", "40 56 48 83 EC ? 41 8B F0", "SetSnapshot")

    local fnGetGameParticleManager = ffi.cast("void*(__fastcall*)()", GetGameParticleManagerPattern)
    local fnCreateParticle = ffi.cast("int*(__fastcall*)(void*, unsigned int*, const char*, int, int64_t, int64_t, int64_t, int)", CreateParticlePattern)
    local fnSetParticleSettings = ffi.cast("bool(__fastcall*)(void*, unsigned int, int, void*, int)", SetParticleSettingsPattern)
    local fnDestroyParticle = ffi.cast("void(__fastcall*)(void*, unsigned int, bool, bool)", DestroyParticlePattern)
    local fnSetSnapshot = ffi.cast("bool(__fastcall*)(void*, int, unsigned int, uintptr_t)", SetSnapshotPattern)

    local function GetGameParticleManager()
        local Ptr = ffi.cast("uintptr_t", GameParticleManagerPattern)
        local Addr = Ptr + 7 + ffi.cast("int*", Ptr + 3)[0]
        local Mgr = ffi.cast("void**", Addr)[0]
        if not Mgr then return nil end
        
        return Mgr
    end

    function particle.new(EffectIndex)
        local self = setmetatable({}, particle)
        self.Index = EffectIndex
        return self
    end

    function particle_system.CreateParticle(EffectPath)
        if not fnGetGameParticleManager() or not EffectPath then return nil end

        local EffectIndex = ffi.new("unsigned int[1]")
        fnCreateParticle(fnGetGameParticleManager(), EffectIndex, EffectPath, 8, 0, 0, 0, 0)
        if not EffectIndex or not EffectIndex[0] or EffectIndex[0] == 0 then return nil end

        return particle.new(EffectIndex[0])
    end

    function particle:SetColor(Color)
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 or not Color then return end

        local ParticleColor = ffi.new("CParticleColor", Color.r, Color.g, Color.b)
        fnSetParticleSettings(fnGetGameParticleManager(), self.Index, PARTICLE_SETTING_COLOR, ParticleColor, 0)

        return self
    end

    function particle:SetPosition(Position)
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 or not Position then return end

        local ParticlePosition = ffi.new("Vector", Position.x, Position.y, Position.z)
        fnSetParticleSettings(fnGetGameParticleManager(), self.Index, PARTICLE_SETTING_POSITION, ParticlePosition, 0)

        return self
    end

    function particle:SetDensity(Density)
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 or not Density then return end

        local VecDensity = ffi.new("Vector", Density, 0, 0)
        fnSetParticleSettings(fnGetGameParticleManager(), self.Index, PARTICLE_SETTING_DENSITY, VecDensity, 0)

        return self
    end

    function particle:SetInfo(Lifetime, Width, Alpha)
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 or not Lifetime or not Width or not Alpha then return end

        local ParticleInfo = ffi.new("CParticleInfo", Lifetime, Width, Alpha)
        fnSetParticleSettings(fnGetGameParticleManager(), self.Index, PARTICLE_SETTING_INFO, ParticleInfo, 0)

        return self
    end

    function particle:ReleaseParticle()
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 then return end

        CallVFunc(fnGetGameParticleManager(), "void(__fastcall*)(void*, unsigned int)", 3, self.Index)
    end

    function particle:DestroyParticle()
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 then return end

        fnDestroyParticle(fnGetGameParticleManager(), self.Index, true, true)
        self:ReleaseParticle()
    end

    function particle:SetSnapshot(Particle)
        if not fnGetGameParticleManager() or not self.Index or self.Index == 0 or not Particle then return end

        fnSetSnapshot(fnGetGameParticleManager(), self.Index, 0, Particle.Snapshot[0])
        return self
    end

    function snapshot.new(Snapshot)
        local self = setmetatable({}, snapshot)
        self.Snapshot = Snapshot
        return self
    end

    function particle_system.CreateSnapshot()
        local Snapshot = ffi.new("uintptr_t[1]")
        CallVFunc(interfaces.ParticleSystemManager, "void(__fastcall*)(void*, uintptr_t*, int64_t*)", 41, Snapshot, ffi.new("int64_t[1]", 0))
        return snapshot.new(Snapshot)
    end

    function snapshot:DrawSnapshot(Count, Data)
        CallVFunc(interfaces.ParticleSystemManager, "void(__fastcall*)(void*, uintptr_t, int, void*)", 42, self.Snapshot[0], Count, Data)
        return self
    end

    function particle_system.AddParticle1Point(Path, Pos, Lifetime, Color)
        if not global_vars then return end   
        if not Path or not Pos or not Lifetime then return end

        local Index = particle_system.CreateParticle(Path)
        if not Index or Index == 0 then return end

        Index:SetPosition(Pos)

        if Color then
            Index:SetColor(Color)
        end

        table.insert(ActiveParticles, { Id = Index, Time = global_vars.m_flCurrentTime, Lifetime =  Lifetime})
        return Index
    end

    function particle_system.AddParticle2Point(Path, StartPos, EndPos, Color, Lifetime, Width, StartLerp, MidLerp)
        if not global_vars then return end   

        StartLerp = StartLerp or 0.05
        MidLerp = MidLerp or 0.95

        local Index = particle_system.CreateParticle(Path)
        if Index == 0 then return end
        
        Index:SetColor(color_t(Color.r * 255, Color.g * 255, Color.b * 255, 1))
        Index:SetInfo(Lifetime, Width, Color.a)
        
        local MidPos = StartPos + (EndPos - StartPos) * 0.5
        local Pts = {StartPos, StartPos:lerp(MidPos, StartLerp), MidPos, MidPos:lerp(EndPos, MidLerp), EndPos}
        
        local PosArray = ffi.new("Vector[5]")
        local TimeArray = ffi.new("float[5]")
        for i = 0, 4 do
            PosArray[i].x, PosArray[i].y, PosArray[i].z = Pts[i+1].x, Pts[i+1].y, Pts[i+1].z
            TimeArray[i] = 0.015 * (i + 1)
        end
        
        local Data = ffi.new("CParticleData")
        Data.m_vPositions = PosArray
        Data.m_flTimes = TimeArray
        
        local Particle = particle_system.CreateSnapshot()
        Index:SetSnapshot(Particle)
        Particle:DrawSnapshot(5, Data)
        
        table.insert(ActiveParticles, {Id = Index, Time = global_vars.m_flCurrentTime, Lifetime = Lifetime})
        return Index
    end

    function particle_system.AddParticlePoints(Path, Points, Color, Width, Lifetime)
        if not fnGetGameParticleManager() or not Points or #Points < 2 or not Color or not Width then return end
        
        local Index = particle_system.CreateParticle(Path)
        if not Index or Index == 0 then return end
        
        Index:SetColor(color_t(Color.r * 255, Color.g * 255, Color.b * 255, 1))
        Index:SetInfo(Lifetime, Width, Color.a)
        
        local Count = #Points
        
        local PosArray = ffi.new("Vector[" .. Count .. "]")
        local TimeArray = ffi.new("float[" .. Count .. "]")
        
        for i = 0, Count - 1 do
            PosArray[i].x = Points[i+1].x
            PosArray[i].y = Points[i+1].y
            PosArray[i].z = Points[i+1].z
            TimeArray[i] = 0.015 * (i + 1)
        end
        
        local Data = ffi.new("CParticleData")
        Data.m_vPositions = PosArray
        Data.m_flTimes = TimeArray
        
        local Particle = particle_system.CreateSnapshot()
        Index:SetSnapshot(Particle)
        Particle:DrawSnapshot(Count, Data)

        return Index
    end

    function particle_system.AddParticleCircle(Path, Center, Radius, Color, Width, Lifetime)
        if not fnGetGameParticleManager() or not Center or not Radius or not Color or not Width then return end
        
        local Index = particle_system.CreateParticle(Path)
        if not Index or Index == 0 then return end
        
        Index:SetColor(color_t(Color.r * 255, Color.g * 255, Color.b * 255, 1))
        Index:SetInfo(Lifetime or 0.01, Width, Color.a)
        
        local TotalPoints = 36
        local Positions = {}
        
        for i = 0, TotalPoints - 1 do
            local Angle = 2.16 * math.pi * i / TotalPoints
            local X = Center.x + Radius * math.cos(Angle)
            local Y = Center.y + Radius * math.sin(Angle)
            local Z = Center.z + 1
            table.insert(Positions, {x = X, y = Y, z = Z})
        end
        
        table.insert(Positions, Positions[1])
        
        local PosArray = ffi.new("Vector[" .. (TotalPoints + 1) .. "]")
        local TimeArray = ffi.new("float[" .. (TotalPoints + 1) .. "]")
        
        for i = 0, TotalPoints do
            PosArray[i].x = Positions[i+1].x
            PosArray[i].y = Positions[i+1].y
            PosArray[i].z = Positions[i+1].z
            TimeArray[i] = 0.01 * (i + 1)  
        end
        
        local Data = ffi.new("CParticleData")
        Data.m_vPositions = PosArray
        Data.m_flTimes = TimeArray
        
        local Particle = particle_system.CreateSnapshot()
        Index:SetSnapshot(Particle)
        Particle:DrawSnapshot(TotalPoints + 1, Data)
        
        return Index
    end

    function particle_system.ParticlesUpdate() 
        if not global_vars then return end   
        for i = #ActiveParticles, 1, -1 do
            local particle = ActiveParticles[i]
            if global_vars.m_flCurrentTime - particle.Time >= particle.Lifetime then
                local Index = particle.Id
                Index:DestroyParticle()
                table.remove(ActiveParticles, i)
            end
        end
    end

    function particle_system.DestroyParticles()
        for i = #ActiveParticles, 1, -1 do
            local Index = ActiveParticles[i].Id
            Index:DestroyParticle()
        end
    end

    events.paint(function()
        particle_system.ParticlesUpdate()
    end)

    events.round_start(function()
        particle_system.DestroyParticles()
        ActiveParticles = {}
    end)

    user_cmd.level_init(function()
        ActiveParticles = {}
    end)

    user_cmd.level_shutdown(function()
        ActiveParticles = {}
    end)

    events.unload(function()
        particle_system.DestroyParticles()
    end)

    return particle_system

end

libraries["library.engine.resource_system"] = function()
    local ResourceSystem = {}

    local interfaces = require("library.engine.interfaces")
    require("library.system.memory")
    local buffer_string = require("library.engine.buffer_string")

    ffi.cdef([[
        typedef struct ResourceBinding_t {
            void* m_pData;
        } ResourceBinding_t;
    ]])

    local QueryInterfacePattern = FindPattern("resourcesystem.dll", "48 89 5C 24 ? 57 48 83 EC ? 48 8B FA 48 8B D9 48 8B CF", "QueryInterface")
    local GetLoadedResourcePattern = FindPattern("resourcesystem.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? 41 8B D8", "GetLoadedResource")
    local LoadResourcePattern = FindPattern("resourcesystem.dll", "40 53 55 57 48 81 EC 80 00 00 00 48 8B 01 49 8B E8 48 8B FA", "LoadResource")
    local BlockingLoadResourceByNamePattern = FindPattern("resourcesystem.dll", "40 53 55 57 48 81 EC", "BlockingLoadResourceByName")
    local EnumerateMaterialsPattern = FindPattern("resourcesystem.dll", "48 89 5C 24 ? 48 89 6C 24 ? 48 89 74 24 ? 57 48 83 EC ? 41 8B D9 49 8B F0", "EnumerateMaterials")
    local DeleteResourcePattern = FindPattern("resourcesystem.dll", "48 85 D2 0F 84 ? ? ? ? 48 8B C4", "DeleteResource")
    local PlayVSoundPattern = FindPattern("soundsystem.dll", "48 89 5C 24 ? 48 89 74 24 ? 48 89 7C 24 ? 55 48 8D 6C 24 ? 48 81 EC ? ? ? ? 33 F6 C7 45 ? ? ? ? ? 4C 8B C1", "PlayVSound")

    ResourceSystem.fnQueryInterface = ffi.cast("void*(__fastcall*)(void*, const char*)", QueryInterfacePattern)
    ResourceSystem.fnGetLoadedResource = ffi.cast("void*(__fastcall*)(void*, CBufferString*, unsigned int)", GetLoadedResourcePattern)
    ResourceSystem.fnLoadResource = ffi.cast("void*(__fastcall*)(void*, CBufferString*, const char*)", LoadResourcePattern)
    ResourceSystem.fnBlockingLoadResourceByName = ffi.cast("ResourceBinding_t*(__fastcall*)(void*, CBufferString*, const char*)", BlockingLoadResourceByNamePattern)
    ResourceSystem.fnEnumerateMaterials = ffi.cast("void(__fastcall*)(void*, uint64_t, void*, uint8_t)", EnumerateMaterialsPattern)
    ResourceSystem.fnDeleteResource = ffi.cast("void(__fastcall*)(void*, ResourceBinding_t*)", DeleteResourcePattern)
    ResourceSystem.fnPlayVSound = ffi.cast("void(__fastcall*)(const char*)", PlayVSoundPattern)

    function ResourceSystem.QueryInterface(InterfaceName)
        if not InterfaceName or InterfaceName == "" or not interfaces.ResourceSystem then return nil end
        return ResourceSystem.fnQueryInterface(interfaces.ResourceSystem, InterfaceName)
    end

    function ResourceSystem.GetLoadedResource(Path)
        if not Path or Path == "" or not interfaces.ResourceSystem then return nil end
        return ResourceSystem.fnGetLoadedResource(interfaces.ResourceSystem, buffer_string.CBufferString(Path), 0)
    end

    function ResourceSystem.BlockingLoadResourceByName(Path, Name)
        if not Path or Path == "" or not Name or Name == "" or not interfaces.ResourceSystem then return nil end
        return ResourceSystem.fnBlockingLoadResourceByName(interfaces.ResourceSystem, buffer_string.CBufferString(Path, 0x78746576), Name)
    end

    function ResourceSystem.LoadResource(Path)
        if not Path or Path == "" or not interfaces.ResourceSystem then return nil end
        ResourceSystem.fnLoadResource(interfaces.ResourceSystem, buffer_string.CBufferString(Path), ffi.new("char[1]", ""))
        return ResourceSystem.BlockingLoadResourceByName(Path, Path)
    end

    function ResourceSystem.EnumerateMaterials(TypeHash, ResultArray, Flags)
        if not interfaces.ResourceSystem then return false end 
        ResourceSystem.fnEnumerateMaterials(interfaces.ResourceSystem, TypeHash or 0, ResultArray, Flags or 1)
    end

    function ResourceSystem.DeleteResource(Binding)
        if not interfaces.ResourceSystem then return false end 
        ResourceSystem.fnDeleteResource(ResourceSystem.QueryInterface("ResourceHandleUtils001"), Binding)
    end

    function ResourceSystem.PlayVSound(SoundName)
        if not SoundName then return false end 
        ResourceSystem.fnPlayVSound("sounds/" .. SoundName)
    end

    return ResourceSystem

end

libraries["library.engine.convars"] = function()
    local utils = require("library.core.utils")
    require("library.system.memory")
    local interfaces = require("library.engine.interfaces")
    local Convars = {}

    ffi.cdef([[
        typedef union {
            bool bValue;
            int iValue;
            float flValue;
            const char* szValue;
        } CvarValue_t;

        typedef struct {
            const char* szName;
            CvarValue_t* m_pDefaultValue;
            char pad_0010[0x10];
            const char* szDescription;
            uint32_t nType;
            uint32_t nRegistered;
            uint32_t nFlags;
            char pad_0034[0x24];
            CvarValue_t value;
        } CConVar;
    ]])

    local GetFirstIteratorPattern = FindPattern("tier0.dll", "48 89 74 24 ? 48 89 7C 24 ? 41 56 48 83 EC ? 48 8B F2 48 8D B9", "GetFirstIterator")
    local GetNextIteratorPattern = FindPattern("tier0.dll", "40 53 55 56 41 56 41 57 48 83 EC ? 49 8B D8 48 8D B1 ? ? ? ? 4C 8B F2 48 8B E9 FF 15 ? ? ? ? 8B D0 39 46 ? 75 ? 66 FF 46 ? EB ? 8B 06 90 85 C0 75 ? B9 ? ? ? ? F0 0F B1 0E 75 ? 66 C7 46 ? ? ? 89 56 ? EB ? 48 8B CE E8 ? ? ? ? 41 BF ? ? ? ? 48 89 7C 24 ? 4C 89 6C 24 ? 66 41 3B DF 74 ? 41 BD ? ? ? ? 66 44 85 6D", "GetNextIterator")
    local FindByIndexPattern = FindPattern("tier0.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? 48 8B DA 48 8D B9 ? ? ? ? 48 8B F1 FF 15 ? ? ? ? 8B D0 39 47 ? 75 ? 66 FF 47 ? EB ? 8B 07 90 85 C0 75 ? B9 ? ? ? ? F0 0F B1 0F 75 ? 66 C7 47 ? ? ? 89 57 ? EB ? 48 8B CF E8 ? ? ? ? BA", "FindByIndex")

    local fnGetFirstIterator = ffi.cast("void(__fastcall*)(void*, uint64_t*)", GetFirstIteratorPattern)
    local fnGetNextIterator = ffi.cast("void(__fastcall*)(void*, uint64_t*, uint64_t)", GetNextIteratorPattern)
    local fnFindByIndex = ffi.cast("void*(__fastcall*)(void*, uint64_t)", FindByIndexPattern)
    local CvarsPtrType = ffi.typeof("CConVar*")

    local function FindCvar(CvarName)
        local Iterator = ffi.new("uint64_t[1]", 0)
        fnGetFirstIterator(interfaces.EngineCvar, Iterator)

        while Iterator[0] ~= 4294967295 do
            local CvarPtr = fnFindByIndex(interfaces.EngineCvar, Iterator[0])
            if CvarPtr ~= nil then
                local Cvar = ffi.cast(CvarsPtrType, CvarPtr)
                if ffi.string(Cvar.szName) == CvarName then
                    return Cvar
                end
            end
            fnGetNextIterator(interfaces.EngineCvar, Iterator, Iterator[0])
        end

        return nil
    end

    local function UnlockCvar(name)
        local Cvar = FindCvar(name)
        if not Cvar then return end
        
        Cvar.nFlags = 33408
    end

    local function UnlockCvars()
        local Iterator = ffi.new("uint64_t[1]", 0)
        fnGetFirstIterator(interfaces.EngineCvar, Iterator)

        while Iterator[0] ~= 4294967295 do
            local CvarPtr = fnFindByIndex(interfaces.EngineCvar, Iterator[0])
            if CvarPtr ~= nil then
                local Cvar = ffi.cast(CvarsPtrType, CvarPtr)
                if bit.band(Cvar.nFlags, FCVAR_HIDDEN) ~= 0 then
                    Cvar.nFlags = bit.band(Cvar.nFlags, bit.bnot(FCVAR_HIDDEN))
                end
            end
            fnGetNextIterator(interfaces.EngineCvar, Iterator, Iterator[0])
        end
    end

    setmetatable(Convars, {
        __index = function(_, Name)
            return {
                Bool = function(self, NewValue)
                    if not self or not Name then return end

                    local Cvar = FindCvar(Name)
                    if not Cvar then return end

                    if NewValue ~= nil then
                        Cvar.value.bValue = NewValue and 1 or 0
                        return
                    end
                    return Cvar.value.bValue
                end,

                Int = function(self, NewValue)
                    if not self or not Name then return end

                    local Cvar = FindCvar(Name)
                    if not Cvar then return end

                    if NewValue ~= nil then
                        Cvar.value.iValue = NewValue
                        return
                    end
                    return Cvar.value.iValue
                end,

                Float = function(self, NewValue)
                    if not self or not Name then return end

                    local Cvar = FindCvar(Name)
                    if not Cvar then return end

                    if NewValue ~= nil then
                        Cvar.value.flValue = NewValue
                        return
                    end
                    return Cvar.value.flValue
                end,

                String = function(self, NewValue)
                    if not self or not Name then return end

                    local Cvar = FindCvar(Name)
                    if not Cvar then return end

                    if NewValue ~= nil then
                        Cvar.value.szValue = NewValue
                        return
                    end
                    
                    if Cvar.value.szValue ~= nil then
                        return ffi.string(Cvar.value.szValue)
                    end
                    return ""
                end,

                Unlock = function(self)
                    if not self or not Name then return end

                    UnlockCvar(Name)
                end
            }
        end
    })

    Convars.UnlockCvars = function()
        UnlockCvars()
    end

    Convars.FindCvar = function(Name)
        if not Name then return end
        return FindCvar(Name)
    end

    return Convars

end

libraries["library.engine.events"] = function()
    local Events = {}
    local Callbacks = {}
    local ErrorLog = {}

    local init = require("library.core.initializate")
    require("library.core.helper")
    require("library.core.enum")

    ffi.cdef([[
        typedef struct { 
            Vector Position; 
            float TimeStamp; 
            float ExpireTime; 
        } BulletElement_t;
    ]])

    local UtlMem = ffi.typeof("struct { BulletElement_t* m_pMemory; int m_iAllocationCount; int m_iGrowSize; }")
    local UtlVec = ffi.typeof("struct { int m_iSize; $ Memory; }", UtlMem)
    local bullet_vec_ptr = ffi.typeof("$*", UtlVec)

    local bullet_services_offset = engine.get_netvar_offset("client.dll", "C_CSPlayerPawn", "m_pBulletServices")
    local bullet_vec_offset = 0x50

    local last_count = nil
    local force_err = 0

    local function SafeCall(CallbackName, Func, ...)
        local success, err = pcall(Func, ...)
        if not success then
            local Trace = debug.traceback()
            local ErrorKey = CallbackName .. ":" .. err .. ":" .. Trace:match(":(%d+):")
            local ErrSrt = ts(err)

            if ErrSrt:find("table overflow") or ErrSrt:find("stack overflow") or ErrSrt:find("overflow") then
                force_err = force_err + 1
                if force_err ~= 2 then
                    Restart(sf("Script Error %s.", ERR_TABLE_OVERFLOW))
                end
                return false, err
            end
            
            if not ErrorLog[ErrorKey] then
                ErrorLog[ErrorKey] = true
                
                if init.VersionType == "Beta" then
                    print(string.format("[Events] Error in callback '%s': %s", CallbackName, err))
                    print(Trace)
                end
            end
        end
        return success, err
    end

    local function update_bullet_impacts()
        local lp = entitylist.get_local_player_pawn()
        if not lp or lp.m_iHealth <= 0 then
            last_count = nil
            return
        end
        
        local bullet_services = ffi.cast("uintptr_t*", ffi.cast("uintptr_t", lp[0]) + bullet_services_offset)[0]
        if bullet_services == 0 then return end
        
        local bullet_vec = ffi.cast(bullet_vec_ptr, bullet_services + bullet_vec_offset)
        local current_count = bullet_vec.m_iSize
        
        if last_count == nil then
            last_count = current_count
            return
        end
        
        if current_count > last_count and bullet_vec.Memory ~= nil then
            for i = last_count, current_count - 1 do
                local bullet = bullet_vec.Memory.m_pMemory[i]
                local impact_pos = vec3_t(bullet.Position.x, bullet.Position.y, bullet.Position.z)
                
                if impact_pos.x ~= 0 and impact_pos.y ~= 0 and impact_pos.z ~= 0 and math.abs(impact_pos.x) < 100000 then
                    if Callbacks["bullet_impact"] then
                        for _, callback in ipairs(Callbacks["bullet_impact"]) do
                            SafeCall("bullet_impact", callback, impact_pos)
                        end
                    end
                end
            end
        end
        
        last_count = current_count
    end

    local function RegisterSafeCallback(CallbackName, Func)
        if not Callbacks[CallbackName] then
            Callbacks[CallbackName] = {}
            
            if CallbackName == "bullet_impact" then
                register_callback("paint", function()
                    update_bullet_impacts()
                end)
            else
                register_callback(CallbackName, function(...)
                    for _, CallbackFunc in ipairs(Callbacks[CallbackName]) do
                        SafeCall(CallbackName, CallbackFunc, ...)
                    end
                end)
            end
        end
        
        for _, existing in ipairs(Callbacks[CallbackName]) do
            if existing == Func then
                return false
            end
        end
        
        table.insert(Callbacks[CallbackName], Func)
        return true
    end

    local function UnregisterCallback(CallbackName, Func)
        if Callbacks[CallbackName] then
            for i, CallbackFunc in ipairs(Callbacks[CallbackName]) do
                if CallbackFunc == Func then
                    table.remove(Callbacks[CallbackName], i)
                    return true
                end
            end
        end
        return false
    end

    local EventMetatable = {
        __index = function(EventObj, key)
            if key == "Add" then
                return function(_, Handler)
                    return RegisterSafeCallback(EventObj.Name, Handler)
                end
            elseif key == "Remove" then
                return function(_, Handler)
                    return UnregisterCallback(EventObj.Name, Handler)
                end
            elseif key == "Clear" then
                return function()
                    Callbacks[EventObj.Name] = {}
                end
            elseif key == "Name" then
                return EventObj.Name
            elseif key == "Handlers" then
                return Callbacks[EventObj.Name] or {}
            end
            return nil
        end,
        __call = function(EventObj, Handler, ShouldAdd)
            if ShouldAdd == nil then
                ShouldAdd = true
            end
            
            if ShouldAdd then
                return RegisterSafeCallback(EventObj.Name, Handler)
            else
                return UnregisterCallback(EventObj.Name, Handler)
            end
        end
    }

    local EventMap = {}

    local function GetEventObject(EventName)
        if not EventMap[EventName] then
            EventMap[EventName] = setmetatable({ Name = EventName }, EventMetatable)
        end
        return EventMap[EventName]
    end

    local EventsMetatable = {
        __index = function(t, CallbackName)
            if type(CallbackName) ~= "string" then
                return nil
            end
            
            if CallbackName == "bullet_impact" then
                return GetEventObject("bullet_impact")
            end
            
            return GetEventObject(CallbackName)
        end
    }

    setmetatable(Events, EventsMetatable)

    function Events.ClearErrors()
        ErrorLog = {}
    end

    function Events.Clear(CallbackName)
        if Callbacks[CallbackName] then
            Callbacks[CallbackName] = {}
        end
    end

    function Events.Remove(CallbackName, Func)
        return UnregisterCallback(CallbackName, Func)
    end

    function Events.Get(CallbackName)
        return Callbacks[CallbackName] or {}
    end

    function Events.Once(CallbackName, Func)
        local Wrapper
        Wrapper = function(...)
            SafeCall(CallbackName, Func, ...)
            Events.Remove(CallbackName, Wrapper)
        end
        RegisterSafeCallback(CallbackName, Wrapper)
    end

    function Events.Add(EventName, Handler)
        return RegisterSafeCallback(EventName, Handler)
    end

    function Events.RemoveEvent(EventName, Handler)
        return UnregisterCallback(EventName, Handler)
    end

    return Events

end

libraries["library.engine.entity"] = function()
    require("library.system.memory")
    local convars = require("library.engine.convars")
    require("library.core.enum")

    ffi.cdef([[
        typedef struct CEffectData {
            void* m_pVTable;			// 0x0
            Vector m_vecOrigin;			// 0x8
            Vector m_vecStart;			// 0x14
            Vector m_vecNormal;			// 0x20
            Vector m_angAngles;			// 0x2C
            uint32_t m_hEntity;			// 0x38
            uint32_t m_hOtherEntity;	// 0x3C
            float m_flScale;			// 0x40
            float m_flMagnitude;		// 0x44
            float m_flRadius;			// 0x48
            int m_nSurfaceProp; 		// 0x4C
            void* pEffectIndex; 		// 0x50
            uint32_t m_nEffectIndex;	// 0x58
            uint8_t m_nPenetrate;		// 0x5C
            char MEM_PAD[0x1];		    // 0x5D
            uint16_t m_nMaterial;		// 0x5E
            uint16_t m_nHitBox;			// 0x60
            Color m_nColor;			    // 0x62
            uint8_t m_fFlags;			// 0x63
            uint8_t m_nAttachmentIndex;	// 0x64
            char MEM_PAD[0x3];			// 0x65
            int m_nAttachmentName;		// 0x68
            uint16_t m_iEffectName;		// 0x6C
            uint8_t m_nExplosionType;	// 0x6E
            char MEM_PAD[0x9];			// 0x6F
        } CEffectData;
    ]])

    local VecViewOffset = engine.get_netvar_offset("client.dll", "C_BaseModelEntity", "m_vecViewOffset")
    local pCollision = engine.get_netvar_offset("client.dll", "C_BaseEntity", "m_pCollision")
    local vecMins = engine.get_netvar_offset("client.dll", "CCollisionProperty", "m_vecMins")
    local vecMaxs = engine.get_netvar_offset("client.dll", "CCollisionProperty", "m_vecMaxs")
    local pGameSceneNode = engine.get_netvar_offset("client.dll", "C_BaseEntity", "m_pGameSceneNode")
    local m_nodeToWorld = engine.get_netvar_offset("client.dll", "CGameSceneNode", "m_nodeToWorld")

    local DispatchEffectPattern = FindRelative("client.dll", "E8 ? ? ? ? 80 BF ? ? ? ? 00 44 0F 28 84 24", "DispatchEffect", 1, 0) 
    local PlayEffectPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 7C 24 ? 55 41 56", "PlayEffect") 
    local SetModelPattern = FindPattern("client.dll", "40 53 48 83 ? ? 48 8B ? 4C 8B ? 48 8B ? ? ? ? ? 48 8D ? ? ? 48 8B", "SetModel") 

    local fnDispatchEffect = ffi.cast("void*(__fastcall*)(const char*, void*)", DispatchEffectPattern)
    local fnPlayEffect = ffi.cast("void(__fastcall*)(const char*, int, uintptr_t, char, int, char, unsigned int, int, char)", PlayEffectPattern)
    local fnSetModel = ffi.cast("void*(__fastcall*)(void*, const char*)", SetModelPattern)

    function GetLocalPawn()
        local Pawn = entitylist.get_local_player_pawn()
        if not Pawn then return nil end

        return Pawn
    end

    function GetLocalController()
        local Controller = entitylist.get_local_player_controller()
        if not Controller then return nil end

        return Controller
    end

    function GetEntities(ClassName, Callback)
        entitylist.get_entities(ClassName, function(Entity) 
            Callback(Entity)
        end)
    end

    function GetPlayers(Callback)
        entitylist.get_entities("C_CSPlayerPawn", function(Pawn) 
            Callback(Pawn)
        end)
    end

    function GetPlayersController(Callback)
        entitylist.get_entities("C_CSPlayerPawn", function(Pawn) 
            local Controller = Pawn.m_hController or nil
            Callback(Pawn, Controller)
        end)
    end

    function GetGameRules()
        local GameRules = entitylist.get_game_rules()
        if not GameRules then return nil end

        return GameRules
    end

    function SetName(Text)
        if not GetLocalController() then return end
        
        convars.name:Unlock()
        GetLocalController().m_iszPlayerName = Text
        GetLocalController().m_bIsPlayerNameDirty = true
        engine.execute_client_cmd('setinfo name "' .. Text .. '"')
    end

    function base_entity_t:GetPawn()
        if not self then return nil end
        
        local Pawn = self.m_hPawn
        if not Pawn then return nil end

        return Pawn
    end

    function base_entity_t:GetController()
        if not self then return nil end
        
        local Controller = self.m_hController
        if not Controller then return nil end

        return Controller
    end

    function base_entity_t:GetBbox()
        if not self then return nil end

        local EntityPtr = ffi.cast("uintptr_t*", self)[0]
        if EntityPtr == 0 then return nil end

        local Collision = ffi.cast("uintptr_t*", EntityPtr + pCollision)[0]
        local GameSceneNode = ffi.cast("uintptr_t*", EntityPtr + pGameSceneNode)[0]
        if Collision == 0 or GameSceneNode == 0 then return nil end

        local MinsPtr = ffi.cast("float*", Collision + m_vecMins)
        local MaxsPtr = ffi.cast("float*", Collision + m_vecMaxs)
        local TransformAddr = GameSceneNode + m_nodeToWorld

        local Pos = ffi.cast("float*", TransformAddr)
        local Rot = ffi.cast("float*", TransformAddr + 16)

        local qx, qy, qz, qw = Rot[0], Rot[1], Rot[2], Rot[3]
        local px, py, pz = Pos[0], Pos[1], Pos[2]

        local m1, m2, m3 = 1.0 - 2.0 * (qy * qy + qz * qz), 2.0 * (qx * qy - qw * qz), 2.0 * (qx * qz + qw * qy)
        local m5, m6, m7 = 2.0 * (qx * qy + qw * qz), 1.0 - 2.0 * (qx * qx + qz * qz), 2.0 * (qy * qz - qw * qx)
        local m9, m10, m11 = 2.0 * (qx * qz - qw * qy), 2.0 * (qy * qz + qw * qx), 1.0 - 2.0 * (qx * qx + qy * qy)

        local MinX, MinY, MaxX, MaxY = FLT_MAX, FLT_MAX, FLT_MIN, FLT_MIN

        local bMinsX, bMinsY, bMinsZ = MinsPtr[0], MinsPtr[1], MinsPtr[2]
        local bMaxsX, bMaxsY, bMaxsZ = MaxsPtr[0], MaxsPtr[1], MaxsPtr[2]

        for i = 0, 7 do
            local lx = (bit.band(i, 1) ~= 0) and bMaxsX or bMinsX
            local ly = (bit.band(i, 2) ~= 0) and bMaxsY or bMinsY
            local lz = (bit.band(i, 4) ~= 0) and bMaxsZ or bMinsZ

            local wx = lx * m1 + ly * m2 + lz * m3 + px
            local wy = lx * m5 + ly * m6 + lz * m7 + py
            local wz = lx * m9 + ly * m10 + lz * m11 + pz

            local Screen = render.world_to_screen(vec3_t(wx, wy, wz))
            if not Screen then return nil end

            if Screen.x < MinX then MinX = Screen.x end
            if Screen.y < MinY then MinY = Screen.y end
            if Screen.x > MaxX then MaxX = Screen.x end
            if Screen.y > MaxY then MaxY = Screen.y end
        end

        local Width, Height = MaxX - MinX, MaxY - MinY

        if Width < 4.0 then
            local Half = (4.0 - Width) * 0.5
            MinX = MinX - math.floor(Half)
            MaxX = MaxX + math.ceil(Half)
            Width = MaxX - MinX
        end

        if Height < 4.0 then
            local Half = (4.0 - Height) * 0.5
            MinY = MinY - math.floor(Half)
            MaxY = MaxY + math.ceil(Half)
            Height = MaxY - MinY
        end

        return { x = MinX, y = MinY, w = Width, h = Height }
    end

    function base_entity_t:IsAlive()
        if not self then return false end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end
        
        local Health = Pawn.m_iHealth
        local IsAlive = Health and Health > 0

        return IsAlive
    end

    function base_entity_t:IsEnemy()
        if not self or not GetLocalPawn() then return false end
        
        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local EntityTeam = self.m_iTeamNum
        local PawnTeam = GetLocalPawn().m_iTeamNum
        local IsEnemy = EntityTeam ~= PawnTeam

        return IsEnemy
    end

    function base_entity_t:IsTeammate()
        if not self or not GetLocalPawn() then return false end
        
        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local EntityTeam = Pawn.m_iTeamNum
        local PawnTeam = GetLocalPawn().m_iTeamNum
        local IsTeammate = EntityTeam == PawnTeam

        return IsTeammate
    end

    function base_entity_t:InScope()
        if not self or not GetLocalPawn() then return false end
        
        local Pawn = self.m_hPawn or self
        if not Pawn then return false end

        local m_bIsScoped = Pawn.m_bIsScoped
        if not m_bIsScoped then return false end

        return m_bIsScoped
    end

    function base_entity_t:IsKnife()
        return self:get_class_name():lower():find("knife") ~= nil
    end

    function base_entity_t:CanShoot()
        local Controller = self.m_hController or self
        if not Controller then return end

        local TickBase = Controller.m_nTickBase
        if not TickBase then return end

        local Weapon = self:GetActiveWeapon()
        if not Weapon then return end

        return TickBase > Weapon.m_nNextPrimaryAttackTick
    end

    function base_entity_t:GetPing()
        if not self then return nil end

        local Controller = self.m_hController or self
        if not Controller then return end

        local Ping = Controller.m_iPing
        if not Ping then return nil end

        return Ping
    end

    function base_entity_t:HasArmor(hitgroup)
        if not self then return false end

        local Pawn = self.m_hPawn or self
        if not Pawn then return false end

        if hitgroup == 1 then
            local ItemServices = Pawn.m_pItemServices
            if not ItemServices then return false end
            
            return ItemServices.m_bHasHelmet
        end

        return (Pawn.m_ArmorValue or 0) > 0
    end

    function base_entity_t:GetActiveWeapon(str)
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end
        
        local WeaponServices = Pawn.m_pWeaponServices
        if not WeaponServices then return 0 end

        local ActiveWeapon = WeaponServices.m_hActiveWeapon
        if not ActiveWeapon then return 0 end

        if str then
            local ActiveWeaponString = tostring(ActiveWeapon):lower()
            if not ActiveWeaponString then return 0 end

            return ActiveWeaponString
        end

        return ActiveWeapon
    end

    function base_entity_t:GetDuckAmount()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end
        
        local MovementServices = Pawn.m_pMovementServices
        if not MovementServices then return 0 end

        local DuckAmount = MovementServices.m_flDuckAmount
        if not DuckAmount then return 0 end

        return DuckAmount
    end

    function base_entity_t:GetJumpHeight()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end
        
        local MovementServices = Pawn.m_pMovementServices
        if not MovementServices then return 0 end

        local HeightAtJumpStart = MovementServices.m_flHeightAtJumpStart
        if not HeightAtJumpStart then return 0 end

        local JumpHeight = self:get_abs_origin().z - HeightAtJumpStart
        if not JumpHeight then return 0 end

        return JumpHeight
    end

    function base_entity_t:GetName()
        if not self then return nil end

        local Controller = self.m_hController or self
        if not Controller then return end

        local EntityName = Controller.m_sSanitizedPlayerName  
        if not EntityName then return nil end

        return EntityName
    end

    function base_entity_t:GetEyePos(Standing)
        if not self then return 0 end

        local AbsOrigin = self:get_abs_origin()
        if not AbsOrigin then return 0 end

        local ViewOffset = ffi.cast("Vector*", ffi.cast("uintptr_t", self[0]) + VecViewOffset)[0]
        if not ViewOffset then return 0 end
        
        local EyePos = vec3_t(AbsOrigin.x + ViewOffset.x, AbsOrigin.y + ViewOffset.y, AbsOrigin.z + ViewOffset.z)
        if not EyePos then return 0 end

        if Standing then
            EyePos.z = EyePos.z + 20
        end

        return EyePos
    end

    function base_entity_t:GetStamina()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local MovementServices = Pawn.m_pMovementServices
        if not MovementServices then return 0 end

        local DuckSpeed = MovementServices.m_flDuckSpeed
        if not DuckSpeed then return 0 end

        local Stamina = DuckSpeed / 8
        if not Stamina then return 0 end

        return Stamina
    end

    function base_entity_t:GetVelocity()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local Velocity = Pawn.m_vecAbsVelocity
        if not Velocity then return 0 end

        return Velocity
    end

    function base_entity_t:GetPosition()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local Position = Pawn:get_abs_origin()
        if not Position then return 0 end

        return Position
    end

    function base_entity_t:GetCameraPos()
        if not self then return 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local CameraPos = Pawn:get_abs_rotation()
        if not CameraPos then return 0 end

        return CameraPos
    end

    function base_entity_t:CreateEffect(EffectName, Color) -- EffectName csshocked
        if not EffectName or not self or not Color then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local VTable = FindRelative("client.dll", "48 89 44 24 ? E8 ? ? ? ? 48 8D 4C 24 ? E8 ? ? ? ? 48 8D 4C 24 ? E8 ? ? ? ? 48 8D 4C 24", "DispatchEffect VTable", 3, 0) 
        if not VTable then return end

        local EffectData = ffi.new("CEffectData")
        EffectData.m_pVTable = VTable
        EffectData.m_hEntity = Pawn:get_entity_handle()
        EffectData.m_hOtherEntity = 0xFFFFFFFF
        EffectData.m_nColor = ffi.new("Color", Color.r, Color.g, Color.b, Color.a)

        fnDispatchEffect(EffectName, EffectData)
    end

    function base_entity_t:PlayEffect(Effect)
        if not Effect or not self then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        fnPlayEffect(Effect, 5, ffi.cast("uintptr_t", Pawn[0]), 0, 0, 0, 0, 0, 0)
    end

    function base_entity_t:SetModel(ModelPath)
        if not self or not ModelPath then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        if pCollision == 0 or vecMins == 0 or vecMaxs == 0 then
            fnSetModel(Pawn[0], ModelPath)
            return
        end

        local pCollisionPtr = ffi.cast("uintptr_t*", self[pCollision])[0]
        if pCollisionPtr == 0 then
            fnSetModel(Pawn[0], ModelPath)
            return
        end
        
        local Mins = ffi.cast("float*", pCollisionPtr + vecMins)
        local Maxs = ffi.cast("float*", pCollisionPtr + vecMaxs)
        local MinX, MinY, MinZ = Mins[0], Mins[1], Mins[2]
        local MaxX, MaxY, MaxZ = Maxs[0], Maxs[1], Maxs[2]

        fnSetModel(Pawn[0], ModelPath)

        Mins[0], Mins[1], Mins[2] = MinX, MinY, MinZ
        Maxs[0], Maxs[1], Maxs[2] = MaxX, MaxY, MaxZ
    end

    function base_entity_t:GetHitboxPos(Hitbox)
        if not self or not Hitbox then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local HitboxPos = engine.get_hitbox_pos(Pawn, Hitbox)
        if not HitboxPos then return end

        return HitboxPos
    end

    function base_entity_t:GetHitboxPos2D(Hitbox)
        if not self or not Hitbox then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local HitboxPos = engine.get_hitbox_pos(Pawn, Hitbox)
        if not HitboxPos then return end

        local Pos2D = render.world_to_screen(HitboxPos)
        if not Pos2D then return end

        return Pos2D
    end

    function base_entity_t:CanHit(StartPos, EndPos, Entity)
        if not self then return false, 0 end

        local Pawn = self.m_hPawn or self
        if not Pawn then return false, 0 end

        local PenData = TraceBullet(StartPos, EndPos, Entity)
        if not PenData then return false, 0 end

        local Damage = PenData.m_damage
        if not Damage or Damage <= 0 then return false, 0 end

        return true, Damage
    end

    function base_entity_t:SetSpottedState(value)
        if not self then return end

        local Pawn = self.m_hPawn or self
        if not Pawn then return end

        local SpottedState = Pawn.m_entitySpottedState
        if not SpottedState then return end

        SpottedState.m_bSpotted = value
    end

    function base_entity_t:GetIndex()
        local Handle = ffi.cast("uintptr_t", self:get_entity_handle())
        if not Handle then return end

        local Index = bit.band(Handle, 0x7FFF)
        if not Index then return end

        return tonumber(Index)
    end

end

libraries["library.engine.user_cmd"] = function()
    local hooks = require("library.system.hooks")
    require("library.system.memory")
    local utils = require("library.core.utils")
    local interfaces = require("library.engine.interfaces")
    local init = require("library.core.initializate")
    require("library.core.enum")

    local bIsMouseInputEnabled = true
    local bEnableCursor = false

    ffi.cdef([[
        typedef struct CInButtonState {
            char pad[8];
            uint64_t m_uButtonState;
            uint64_t m_uButtonState2;
            uint64_t m_uButtonState3;
        } CInButtonState;
        
        typedef struct CUserCmd {
            char pad[84]; 
            CInButtonState m_pButtonState;
        } CUserCmd;

        typedef struct ICSGOInput {
            char pad[593];
            bool m_bInThirdPerson; 
            char pad2[6]; 
            Vector m_vThirdPersonAngles;
        } ICSGOInput;
    ]])

    local ICSGOInputPattern = FindAbsolute("client.dll", "48 8B 0D ? ? ? ? 8B D3 E8 ? ? ? ? F2 0F 10 87", "ICSGOInput", 3, 0)
    local GetLocalControllerByIdPattern = FindPattern("client.dll", "48 83 EC ?? 83 F9 ?? 75 ?? 48 8B 0D ?? ?? ?? ?? 48 8D 54 24 ?? 48 8B 01 FF 90 ?? ?? ?? ?? 8B 08 48 63 C1 48 8D 0D ?? ?? ?? ?? 48 8B 04 C1 48 83 C4 ?? C3 CC CC CC CC CC CC CC CC CC CC CC CC CC 48 83 EC ?? 83 F9", "GetLocalControllerById")
    local SetupCmdPattern = FindPattern("client.dll", "48 83 EC 28 E8 ?? ?? ?? ?? 8B 80", "SetupCmd")
    local GetControllerCmdPattern = FindPattern("client.dll", "40 53 48 83 EC 20 8B DA E8 ?? ?? ?? ?? 4C", "GetControllerCmd")
    local GetViewAnglesPattern = FindPattern("client.dll", "4C 8B C1 85 D2 74 ? 48 8D 05", "GetViewAngles")
    local SetViewAnglesPattern = FindPattern("client.dll", "85 D2 75 ? 48 63 81", "SetViewAngles")

    local ICSGOInput = ffi.cast("ICSGOInput*", ffi.cast("void***", ICSGOInputPattern)[0])
    local fnGetLocalControllerById = ffi.cast("uintptr_t(__fastcall*)(int)", GetLocalControllerByIdPattern)
    local fnSetupCmd = ffi.cast("uintptr_t(__fastcall*)(uintptr_t)", SetupCmdPattern)
    local fnGetControllerCmd = ffi.cast("uintptr_t(__fastcall*)(uintptr_t, uintptr_t)", GetControllerCmdPattern)
    local fnGetViewAngles = ffi.cast("void*(__fastcall*)(ICSGOInput*, int)", GetViewAnglesPattern)
    local fnSetViewAngles = ffi.cast("void(__fastcall*)(ICSGOInput*, int, Vector&)", SetViewAnglesPattern)

    ffi.metatype("struct ICSGOInput", {
        __index = {
            GetViewAngles = function(this)
                local ViewAngles = fnGetViewAngles(this, 0)
                if not ViewAngles then return end

                local vViewAngles = ffi.cast("Vector*", ViewAngles)
                if not vViewAngles then return end

                return vec3_t(vViewAngles.x, vViewAngles.y, vViewAngles.z)
            end,

            SetViewAngles = function(this, vec3)
                local vViewAngles = ffi.new("Vector", vec3.x, vec3.y, vec3.z)
                if not ViewAngles then return end

                fnSetViewAngles(this, 0, vViewAngles)
            end,

            GetUserCmd = function(this)
                local Controller = fnGetLocalControllerById(0)
                if not Controller or Controller == 0 then return end

                local SetupCmd = fnSetupCmd(Controller)
                if not SetupCmd or SetupCmd == 0 then return end

                local Cmd = fnGetControllerCmd(Controller, SetupCmd)
                if not Cmd or Cmd == 0 then return end

                return ffi.cast("CUserCmd*", Cmd)
            end,
        }
    })

    ffi.metatype("struct CUserCmd", {
        __index = {
            Set = function(this, Button, Value)
                if Value == 1 or Value == true then
                    this.m_pButtonState.m_uButtonState = bit.bor(this.m_pButtonState.m_uButtonState, Button)
                else
                    this.m_pButtonState.m_uButtonState = bit.band(this.m_pButtonState.m_uButtonState, bit.bnot(Button))
                    this.m_pButtonState.m_uButtonState2 = bit.band(this.m_pButtonState.m_uButtonState2, bit.bnot(Button))
                    this.m_pButtonState.m_uButtonState3 = bit.band(this.m_pButtonState.m_uButtonState3, bit.bnot(Button))
                end
            end,

            Get = function(this, Button)
                local Status = bit.band(this.m_pButtonState.m_uButtonState, Button) ~= 0
                return (Status and 1 or 0)
            end,
        }
    })

    local EventSetup = {}
    local EventInterface = {}

    local function FireEvent(EventName, ...)
        local Handlers = EventSetup[EventName]
        if not Handlers then return end
        
        for _, Handler in ipairs(Handlers) do
            local success, err = pcall(Handler, ...)
            if not success then
                print("[Event] Error in " .. EventName .. ": " .. tostring(err))
            end
        end
    end

    setmetatable(EventInterface, {
        __index = function(_, EventName)
            return function(Handler)
                if type(Handler) ~= "function" then return end
                
                if not EventSetup[EventName] then
                    EventSetup[EventName] = {}
                end
                
                table.insert(EventSetup[EventName], Handler)
            end
        end
    })

    local fnCreateMove = GetVFunc(ICSGOInput, 5)
    local fnMouseInputEnabled = GetVFunc(ICSGOInput, 23)
    local fnEnableCursor = GetVFunc(interfaces.InputSystem, 76)
    local fnFrameStageNotify = GetVFunc(interfaces.Source2Client, 36) 
    local fnLevelInit = FindPattern("client.dll", "48 89 74 24 ? 57 48 83 EC ? 48 8B 0D ? ? ? ? 48 8B FA", "LevelInit")
    local fnLevelShutdown = FindPattern("client.dll", "48 83 EC ? 48 8B 0D ? ? ? ? 48 8D 15 ? ? ? ? 45 33 C9 45 33 C0 48 8B 01 FF 50 ? 48 85 C0 74 ? 48 8B 0D ? ? ? ? 48 8B D0 4C 8B 01 41 FF 50 ? 48 83 C4", "LevelShutdown")

    local function hkCreateMove(Original, Rcx, Slot, Active)
        Original(Rcx, Slot, Active)

        local Cmd = Rcx:GetUserCmd()

        if Cmd then
            FireEvent("createmove", Cmd)
        end
    end

    local function hkFrameStageNotify(Original, Client, Stage)
        if Stage then
            FireEvent("frame_stage_notify", Stage)
        end

        Original(Client, Stage)
    end

    local function hkMouseInputEnabled(Original, Ptr)
        if not bIsMouseInputEnabled then
            return false
        end

        return Original(Ptr)
    end

    local function hkEnableCursor(Original, Rcx, Active)
        if bEnableCursor then
            Active = false
        end

        return Original(Rcx, Active)
    end

    local function hkLevelInit(Original, a1, a2)
        if a2 then
            FireEvent("level_init")
        end

        return Original(a1, a2)
    end

    local function hkLevelShutdown(Original, a1)
        if a1 then
            FireEvent("level_shutdown")
        end

        return Original(a1)
    end

    pcall(function()
        hooks.CreateHook(fnCreateMove, hkCreateMove, "void(__fastcall*)(ICSGOInput*, int, bool)")
        hooks.CreateHook(fnFrameStageNotify, hkFrameStageNotify, "void(__fastcall*)(void*, int)")
        hooks.CreateHook(fnMouseInputEnabled, hkMouseInputEnabled, "bool(__fastcall*)(void*)")
        hooks.CreateHook(fnEnableCursor, hkEnableCursor, "void*(__fastcall*)(void*, bool)")
        hooks.CreateHook(fnLevelInit, hkLevelInit, "void*(__fastcall*)(void*, const char*)")
        hooks.CreateHook(fnLevelShutdown, hkLevelShutdown, "void(__fastcall*)(void*, void*)")
    end)

    function SetMouseInput(bEnabled)
        bIsMouseInputEnabled = bEnabled
    end

    function SetCursorStatus(bEnabled)
        bEnableCursor = bEnabled and true or false
    end

    return EventInterface

end

libraries["library.engine.cmd_button_t"] = function()
    local _private2 = setmetatable({}, { __mode = 'k' })

    local cmd_button_t = setmetatable({
        __index = {
            GetButtonName = function(self)
                return _private2[self].ButtonName
            end,

            SetButtonName = function(self, ButtonName)
                _private2[self].ButtonName = ButtonName
            end,

            IsPressed = function(self)
                return _private2[self].IsPressed
            end,

            Press = function(self)
                local Data = _private2[self]
                if not Data.IsPressed then
                    Data.IsPressed = true
                    engine.execute_client_cmd('+' .. Data.ButtonName)
                end
            end,

            Release = function(self)
                local Data = _private2[self]
                if Data.IsPressed then
                    Data.IsPressed = false
                    engine.execute_client_cmd('-' .. Data.ButtonName)
                end
            end,
        }
    }, {
        __call = function(cls, ButtonName)
            local self = setmetatable({}, cls)
            _private2[self] = {
                ButtonName = ButtonName,
                IsPressed = false
            }
            return self
        end
    })

    return cmd_button_t

end

libraries["library.engine.game_ui"] = function()
    local game_ui = {}
    local interfaces = require("library.engine.interfaces")
    require("library.system.memory")

    local MessageBoxPattern = FindPattern("client.dll", "44 88 4C 24 ? 53 41 56", "MessageBox") 
    local fnMessageBox = ffi.cast("void(__fastcall*)(void*, const char*, const char*, bool, bool, const char*, const char*, const char*, int, __int64)", MessageBoxPattern)

    function game_ui.MessageBox(Title, Message, bShowOk, bShowCancel, OkCommand, CancelCommand, ClosedCommand)
        fnMessageBox(interfaces.LegacyGameUI, Title, Message, bShowOk or false, bShowCancel or false, OkCommand or "", CancelCommand or "", ClosedCommand or "", 0, 0)
    end

    return game_ui

end

libraries["library.engine.post_processing"] = function()
    local post_processing = {}
    local events = require("library.engine.events")

    local LastExposure = 100
    local ExposureNeededUpdate = true
    function post_processing.SetExposure(Value)
        local Pawn = entitylist.get_local_player_pawn()
        if not Pawn then return end

        local CameraServices = Pawn.m_pCameraServices
        if not CameraServices then return end
        
        local ActivePostProcessingVolume = CameraServices.m_hActivePostProcessingVolume
        if not ActivePostProcessingVolume then return end

        ActivePostProcessingVolume.m_bExposureControl = true
        ActivePostProcessingVolume.m_flExposureFadeSpeedUp = 0
        ActivePostProcessingVolume.m_flExposureFadeSpeedDown = 0
        ActivePostProcessingVolume.m_flMaxExposure = Value / 100
        ActivePostProcessingVolume.m_flMinExposure = Value / 100

        LastExposure = Value
    end

    events.round_start(function()
        ExposureNeededUpdate = true
    end)

    events.override_view(function()
        if ExposureNeededUpdate then
            post_processing.SetExposure(LastExposure)
            ExposureNeededUpdate = false
        end
    end)

    return post_processing

end

libraries["library.engine.i_engine_client"] = function()
    require("library.system.memory")
    local interfaces = require("library.engine.interfaces")

    ffi.cdef([[
        typedef struct CLocalData {
            char pad_0000[12]; //0x0000
            Vector m_vEyePos; //0x000C
        } CLocalData; //Size: 0x0018

        typedef struct CNetworkedClientInfo {
            char pad_0000[4]; //0x0000
            int32_t m_iRenderTick; //0x0004
            float m_flRenderTickFraction; //0x0008
            int32_t m_iPlayerTickCount; //0x000C
            float m_flPlayerTickFraction; //0x0010
            char pad_0014[4]; //0x0014
            CLocalData* m_pLocalData; //0x0018
            char pad_0030[24]; //0x0030
        } CNetworkedClientInfo; //Size: 0x0048
    ]])

    function GetMaxClients()
        return CallVFunc(interfaces.EngineClient, "int(__fastcall*)(void*)", 34)
    end

    function IsInGame()
        return CallVFunc(interfaces.EngineClient, "bool(__fastcall*)(void*)", 39)
    end

    function IsConnected()
        return CallVFunc(interfaces.EngineClient, "bool(__fastcall*)(void*)", 40)
    end

    function GetNetworkedClientInfo()
        local ClientInfo = ffi.new("struct CNetworkedClientInfo[1]") 
        CallVFunc(interfaces.EngineClient, "CNetworkedClientInfo*(__fastcall*)(void*)", 179, ClientInfo)
        return ClientInfo[0] 
    end

end

libraries["library.engine.i_client"] = function()
    require("library.system.memory")
    local interfaces = require("library.engine.interfaces")

    local AddBoxOverlayPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? 48 8B F1 49 8B D9 48 8D 4C 24 ? 49 8B F8 E8 ? ? ? ? 0F B6 94 24 ? ? ? ? 4C 8B D0", "AddBoxOverlay")
    local fnAddBoxOverlay = ffi.cast("void(__fastcall*)(void*, Vector, Vector, Vector, Vector, char, char, char, char, int, double, int)", AddBoxOverlayPattern)

    ffi.cdef([[
        typedef struct IDebugOverlayGameSystem {
        } IDebugOverlayGameSystem;
    ]])

    ffi.metatype("struct IDebugOverlayGameSystem", {
        __index = {
            RenderWithoutDots = function(this, bShouldDot)
                return CallVFunc(this, "void(__fastcall*)(void*, bool)", 10, bShouldDot)
            end,

            AddBoxOverlay = function(this, Origin, Mins, Maxs, Rotation, Color, DrawFill, Duration)
                local Orig = ffi.new("Vector", Origin.x, Origin.y, Origin.z)
                local Min = ffi.new("Vector", Mins.x, Mins.y, Mins.z)
                local Max = ffi.new("Vector", Maxs.x, Maxs.y, Maxs.z)
                local Rot = ffi.new("Vector", Rotation.x, Rotation.y, Rotation.z)
                return fnAddBoxOverlay(this, Orig, Min, Max, Rot, Color.r, Color.g, Color.b, Color.a, DrawFill and 0 or 1, Duration, 0)
            end
        }
    })

    function GetDebugOverlayGameSystem()
        return CallVFunc(interfaces.Source2Client, "IDebugOverlayGameSystem*(__fastcall*)(void*)", 168) 
    end

end

libraries["library.engine.timers"] = function()
    local timers = {}
    local global_vars = require("library.engine.global_vars")
    local user_cmd = require("library.engine.user_cmd")

    timers.Timers = {}

    function timers.GetTime()
        return math.floor(global_vars.m_flCurrentTime * 1000)
    end

    function timers.NewTimer(is_interval, callback, ms)
        table.insert(timers.Timers, {
            time = timers.GetTime() + ms,
            ms = ms * 10,
            is_interval = is_interval,
            callback = callback
        })

        return #timers.Timers
    end

    timers.NewTimeout = function(callback, ms)
        local index = timers.NewTimer(false, callback, ms)
        return index
    end

    timers.NewInterval = function(callback, ms)
        local index = timers.NewTimer(true, callback, ms)
        return index
    end

    timers.Listener = function()
        for i = 1, #timers.Timers do
            local timer = timers.Timers[i]
            local current_time = timers.GetTime()

            if current_time >= timer.time then
                timer.callback()

                if timer.is_interval then
                    timer.time = timers.GetTime() + timer.ms
                else
                    table.remove(Timer.Timers, i)
                end
            end
        end
    end

    timers.Remove = function(index)
        table.remove(timers.Timers, index)
    end

    register_callback("paint", function()
        timers.Listener();
    end)

    user_cmd.level_init(function()
        timers.Timers = {}
    end)

    return timers

end

libraries["library.engine.trace"] = function()
    local cvars = require("library.engine.convars")

    ffi.cdef([[
        typedef struct ITrace { } ITrace;

        typedef struct {
            Vector m_start;
            Vector m_end;
            Vector m_mins;
            Vector m_maxs;
            uint8_t pad_001[0x4];
            uint8_t type;
        } Ray_t;

        typedef struct {
            uint8_t pad_001[0x8];
            float m_pen_data_modifier;
            float m_dmg_modifier;
            uint8_t pad_002[0x4];
            int m_material;
        } SurfaceData_t;

        typedef struct {
            uint8_t pad_001[0x38];
            int m_hit_group;
            uint8_t pad_002[0x4];
            int m_hitbox_id;
        } TraceHitboxData_t;

        typedef struct {
            uint8_t pad_001[0x38];
        } TraceArrayElement_t;

        typedef struct {
            int32_t uk1;
            float uk2;
            void* arr_pointer;
            int32_t uk3;
            int32_t uk4;
            TraceArrayElement_t arr[0x80];
            uint8_t pad_001[0x8];
            int32_t num_update;
            int32_t uk5;
            void* pointer_update_value;
            int32_t hit_capacity;
            int32_t hit_flags;
            uint8_t hit_elements[0xC0];
            Vector start, end;
            float fraction;
            bool uk6;
            uint8_t pad_003[0x4B];
        } TraceData_t;

        typedef struct {
            float m_previous_length_mod;
            float m_current_length_mod;
            uint8_t pad_001[0x8];
            short m_handle_index;
            uint8_t pad_002[0x6];
        } UpdateValue_t;

        typedef struct {
            void* m_surface;
            void* m_hit_entity;
            TraceHitboxData_t* m_hitbox_data;
            uint8_t pad_001[0x38];
            uint32_t m_contents;
            uint8_t pad_002[0x24];
            Vector m_start;
            Vector m_end;
            Vector m_normal;
            Vector m_pos;
            uint8_t pad_003[0x4];
            float m_fraction;
            uint8_t pad_004[0x6];
            bool m_all_solid;
            uint8_t pad_005[0x51];
        } GameTrace_t;

        typedef struct {
            void* m_vtable;
            uint64_t m_mask;
            int64_t m_ptr[2];
            int32_t m_skip_handles[4];
            int16_t m_arr_collisions[2];
            uint8_t pad_0034[3];
            uint8_t m_trace_type;
            uint8_t m_layer;
            uint8_t m_flags;
            uint8_t pad_003A[6];
            char m_v7;
        } TraceFilter_t;
        
        typedef struct {
            float enter_fraction;
            float exit_fraction;
            float damage;
            int team;
            uint16_t enter_contact;
            uint16_t exit_contact;
            uint8_t can_penetrate;
            uint8_t pad[3];
        } BulletTraceRecord_t;

        typedef struct {
            float m_damage;
            uint8_t m_hitgroup;
            int m_hitbox;
            bool m_penetrated;
        } PenetrationData_t;
    ]])

    local itrace = ffi.cast("ITrace**", FindRelative("client.dll", "4C 8B 35 ? ? ? ? 24 ? 0C ? 66 0F 7F 45 ? 88 45 ? 48 8B CB 48 8D 05 ? ? ? ? 89 7D ? 48 89 45 ? 89 7D ? C7 45 ? ? ? ? ? 66 C7 45 ? ? ? 44 88 7D", "ITrace", 3, 0))[0]

    local CreateTracePattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 6C 24 ? 48 89 74 24 ? 57 41 56 41 57 48 83 EC 40 F2 0F 10 02 4D 8D 71 08", "CreateTrace")
    local InitTraceInfoPattern = FindPattern("client.dll", "40 55 41 55 41 57 48 83 EC", "InitTraceInfo")
    local GetTraceInfoPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 6C 24 ? 48 89 74 24 ? 57 48 81 EC 80 00 00 00 48 8B E9 0F 29 74 24 ? 48 8B CA 49 8B F9", "GetTraceInfo")
    local TraceFilterPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? 0F B6 41 ? 33 FF 24", "TraceFilter")
    local TraceBulletPattern = FindPattern("client.dll", "40 53 57 41 56 48 83 EC 50 8B 84 24", "TraceBullet")

    local fnCreateTrace = ffi.cast("void(__fastcall*)(TraceData_t*, const Vector&, const Vector&, TraceFilter_t&, int, bool)", CreateTracePattern)
    local fnInitTraceInfo = ffi.cast("void(__fastcall*)(GameTrace_t*)", InitTraceInfoPattern)
    local fnGetTraceInfo = ffi.cast("void(__fastcall*)(TraceData_t*, GameTrace_t*, float, void*)", GetTraceInfoPattern)
    local fnTraceFilter = ffi.cast("void(__fastcall*)(TraceFilter_t*, void*, uint64_t, int)", TraceFilterPattern)
    local fnTraceBullet = ffi.cast("void(__fastcall*)(TraceData_t*, float, float, float, int, int, uintptr_t)", TraceBulletPattern)

    ffi.metatype("struct ITrace", {
        __index = {
            CreateTrace = function(this, trace_data, startpos, endpos, filter, penetration_count)
                if not trace_data or not filter or not trace_data.arr_pointer or not trace_data.pointer_update_value then return false end
                fnCreateTrace(trace_data, startpos, endpos, filter, penetration_count, 1)
                return true
            end,

            InitTraceInfo = function(this, trace)
                fnInitTraceInfo(trace)
            end,

            GetTraceInfo = function(this, trace_data, trace, unknown_float, unknown)
                fnGetTraceInfo(trace_data, trace, unknown_float, unknown)
            end,
        }
    })

    local function isfinite(x)
        return type(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge
    end

    local function FillTraceData(TraceData)
        TraceData.uk1 = 0
        TraceData.uk2 = 52.0
        TraceData.arr_pointer = TraceData.arr
        TraceData.uk3 = 128
        TraceData.uk4 = ffi.cast("int32_t", 0x80000000)
        TraceData.num_update = 0
        TraceData.uk5 = 0
        TraceData.pointer_update_value = TraceData.hit_elements
        TraceData.hit_capacity = 8
        TraceData.hit_flags = ffi.cast("int32_t", 0x80000000)
        TraceData.fraction = 1.0
    end

    local function TraceFilter(mask, entity, layer, trace_type)
        local tf = ffi.new("TraceFilter_t")
        fnTraceFilter(tf, entity, mask, layer)
        tf.m_trace_type = bit.band(trace_type, 0xFF)
        return tf
    end

    local function ScaleDamage(hitgroup, entity, weapon_data, damage)
        if not entity or not weapon_data then return 0 end

        local damage_scale_ct_head = cvars.mp_damage_scale_ct_head:Float()
        local damage_scale_t_head = cvars.mp_damage_scale_t_head:Float()
        local damage_scale_ct_body = cvars.mp_damage_scale_ct_body:Float()
        local damage_scale_t_body = cvars.mp_damage_scale_t_body:Float()

        local is_ct = entity.m_iTeamNum == 3
        local is_t = entity.m_iTeamNum == 2

        local head_damage_scale = (is_ct and damage_scale_ct_head) or (is_t and damage_scale_t_head) or 1
        local body_damage_scale = (is_ct and damage_scale_ct_body) or (is_t and damage_scale_t_body) or 1

        if hitgroup == 1 then
            damage = damage * weapon_data.m_flHeadshotMultiplier * head_damage_scale
        elseif hitgroup == 3 then
            damage = damage * 1.25 * body_damage_scale
        elseif hitgroup == 6 or hitgroup == 7 then
            damage = damage * 0.75 * body_damage_scale
        else
            damage = damage * body_damage_scale
        end

        if not entity:HasArmor(hitgroup) then
            return damage
        end

        local heavy_armor_bonus, armor_bonus, armor_ratio = 1, 0.5, weapon_data.m_flArmorRatio * 0.5
        local damage_to_health = damage * armor_ratio
        local damage_to_armor = (damage - damage_to_health) * (heavy_armor_bonus * armor_bonus)

        if damage_to_armor > entity.m_ArmorValue then
            damage_to_health = damage - entity.m_ArmorValue / armor_bonus
        end

        return damage_to_health
    end

    local function FireBullet(startpos, endpos, entity, weapon_data, pen_data, is_taser)
        local pawn = GetLocalPawn()
        if not pawn or not entity or not weapon_data then return false end

        local range = weapon_data.m_flRange
        local direction = endpos - startpos
        local length = direction:length()
        if not isfinite(length) or length <= 0.001 or not isfinite(range) or range <= 0.0 then return false end

        local delta = direction * (range / length)

        local trace_data = ffi.new("TraceData_t")
        FillTraceData(trace_data)

        startpos = ffi.new("Vector", startpos.x, startpos.y, startpos.z)
        delta = ffi.new("Vector", delta.x, delta.y, delta.z)

        local pawn_ptr = ffi.cast("void*", pawn[0])
        if not pawn_ptr then return end

        local trace_filter = TraceFilter(0x1C300B, pawn_ptr, 3, 15)
        if not itrace:CreateTrace(trace_data, startpos, delta, trace_filter, 4) or trace_data.num_update <= 0 or not trace_data.pointer_update_value or not trace_data.arr_pointer then return false end

        fnTraceBullet(trace_data, weapon_data.m_nDamage, weapon_data.m_flPenetration, weapon_data.m_flRangeModifier, 4, pawn.m_iTeamNum, 0)

        local hits = ffi.cast("BulletTraceRecord_t*", trace_data.pointer_update_value)
        local surfaces = ffi.cast("TraceArrayElement_t*", trace_data.arr_pointer)
        local penetrated = false

        for i = 0, math.min(trace_data.num_update, 128) - 1 do
            local hit = hits[i]
            if not isfinite(hit.damage) or hit.damage < 1 then break end

            if bit.band(hit.can_penetrate, 1) ~= 0 then
                penetrated = true
                if hit.exit_fraction >= 1 then
                    break 
                end
            else
                local contact = bit.band(hit.enter_contact, 0x7FFF)

                if contact < 128 then 
                    local game_trace = ffi.new("GameTrace_t")
                    itrace:InitTraceInfo(game_trace)
                    itrace:GetTraceInfo(trace_data, game_trace, 0, ffi.cast("TraceArrayElement_t*", surfaces[contact]))

                    local hit_group = 0
                    local hitbox_id = 0
                    if game_trace.m_hitbox_data then
                        hit_group = game_trace.m_hitbox_data.m_hit_group or 0
                        hitbox_id = game_trace.m_hitbox_data.m_hitbox_id or 0
                    end

                    pen_data.m_hitbox = hitbox_id
                    pen_data.m_penetrated = penetrated
                    
                    local entity_ptr = ffi.cast("uintptr_t", entity[0])
                    local hit_entity_ptr = ffi.cast("uintptr_t", game_trace.m_hit_entity)

                    if hit_entity_ptr == entity_ptr then
                        local scaled = ScaleDamage(hit_group, entity, weapon_data, hit.damage)
                        pen_data.m_damage = scaled

                        if pen_data.m_damage <= 0 then
                            return false
                        end

                        return not is_taser or not penetrated
                    end
                end
            end
        end

        return false
    end

    function TraceBullet(StartPos, EndPos, Entity)
        if not StartPos or not EndPos or not Entity or not GetLocalPawn() or not GetLocalPawn():GetActiveWeapon() or not GetLocalPawn():GetActiveWeapon().m_pWeaponData then return nil end

        local PenData = ffi.new("PenetrationData_t")
        FireBullet(StartPos, EndPos, Entity, GetLocalPawn():GetActiveWeapon().m_pWeaponData, PenData, false)

        return PenData
    end

end

libraries["library.engine.shader"] = function()
    require("library.system.memory")
    local detour = require("library.system.detour")

    local Shader = {}

    Shader.Hash = {
        rain_exposure_to_sky = 0x374C1B3C,
        rain_exposure_to_sky_wetness = 0x0F592812,
        rain_wetness = 0x0F592812,
        rain_exposure_local_timer = 0x2DBEE393,
        rain_timer = 0x2DBEE393,
        wind_direction = 0xCDE54581,
        wind_strength_frequency = 0xEB0D997E,
        gradient_fog = 0x4B01FF63,
        gradient_fog2 = 0x0AA49C2A,
        gradient_fog3 = 0xFBF6448D,
        enable_gradient_fog = 0x6E0FAD7E,
        dof = 0x2ACAB07C,
        gamma = 0x24470A87,
        bloom_scale = 0x565EAF76,
        bloom_threshold = 0xBA98A9B0,
        bloom_width = 0x2AE72B37,
        bloom_strength = 0xB692902E,
        bloom_skybox = 0x1313A424,
    }

    local Offsets = {
        Stub = 0x40,
        Return = 0x80,
        Entries = 0x100,
        PrologueLen = 15,
    }

    local StubCode = {
        0x8B, 0x05, 0xBA, 0xFF, 0xFF, 0xFF,
        0x85, 0xC0,
        0x74, 0x21,
        0x4C, 0x8D, 0x0D, 0xAF, 0x00, 0x00, 0x00,
        0x41, 0x39, 0x11,
        0x75, 0x0D,
        0x41, 0x83, 0x79, 0x04, 0x00,
        0x74, 0x06,
        0x4D, 0x8D, 0x41, 0x10,
        0xEB, 0x08,
        0x49, 0x83, 0xC1, 0x20,
        0xFF, 0xC8,
        0x75, 0xE6,
        0x48, 0x89, 0x6C, 0x24, 0x10,
        0x48, 0x89, 0x74, 0x24, 0x18,
        0x57,
        0x48, 0x83, 0xEC, 0x20,
        0xFF, 0x25, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    }

    local TargetAddr, StubMem, PCount, HookInstance
    local ResolveAttempted = false

    local Entries, FreeSlots = {}, {}

    local function ResetFreeSlots()
        FreeSlots = {}
        for i = 0, 63 do
            FreeSlots[i + 1] = i
        end
    end

    ResetFreeSlots()

    local function ResolveTarget()
        local addr = find_pattern("client.dll", "E8 ? ? ? ? 66 0F 6F 0D ? ? ? ? 4C 8D 8B ? ? ? ? 49 8B C1 33 C9")
        assert(addr and ffi.cast("uintptr_t", addr) ~= 0, "SetShaderParam Outdated")

        local target = MemRip(ffi.cast("uint8_t*", addr), 1, 5)
        assert(target and ffi.cast("uintptr_t", target) ~= 0, "SetShaderParam: Invalid Target")

        return target
    end

    local function Init()
        if HookInstance and HookInstance.active then return true end
        if ResolveAttempted then return false end
        ResolveAttempted = true

        TargetAddr = ResolveTarget()
        if not TargetAddr then return false end

        StubMem = MemAlloc(4096)
        if not StubMem then return false end

        PCount = ffi.cast("uint32_t*", StubMem)
        PCount[0] = 0

        MemWrite(StubMem + Offsets.Stub, StubCode)
        ffi.cast("uintptr_t*", StubMem + Offsets.Return)[0] = ffi.cast("uintptr_t", TargetAddr + Offsets.PrologueLen)

        HookInstance = detour.Create(TargetAddr, StubMem + Offsets.Stub, Offsets.PrologueLen)
        HookInstance:Apply()

        return true
    end

    local function ParseHash(h)
        if type(h) == "number" then return h end
        if type(h) == "string" then return Shader.Hash[h] or Shader.Hash[h:lower()] or tonumber(h) end
        return nil
    end

    local function WriteSlot(slot, x, y, z, w)
        if type(x) == "number" and y == nil then
            slot.val[0], slot.val[1], slot.val[2], slot.val[3] = x, x, x, x
        elseif type(x) == "table" then
            if x.r and x.g and x.b then
                slot.val[0] = x.r / 255.0
                slot.val[1] = x.g / 255.0
                slot.val[2] = x.b / 255.0
                slot.val[3] = (x.a or 255) / 255.0
            else
                slot.val[0] = x[1] or x.x or 0
                slot.val[1] = x[2] or x.y or 0
                slot.val[2] = x[3] or x.z or 0
                slot.val[3] = x[4] or x.w or 0
            end
        else
            slot.val[0], slot.val[1], slot.val[2], slot.val[3] = x or 0, y or 0, z or 0, w or 0
        end
    end

    function Shader.Set(hash, x, y, z, w)
        local h = ParseHash(hash)
        if not h then return end

        if x == nil then
            Shader.Remove(h)
            return
        end

        if not HookInstance or not HookInstance.active then
            if not Init() then return end
        end

        local slot = Entries[h]
        if not slot then
            if #FreeSlots == 0 then return end

            local idx = table.remove(FreeSlots, 1)
            local ptr = StubMem + Offsets.Entries + idx * 0x20

            slot = {
                index = idx,
                hash = ffi.cast("uint32_t*", ptr),
                active = ffi.cast("uint32_t*", ptr + 4),
                val = ffi.cast("float*", ptr + 16)
            }

            slot.hash[0] = h
            slot.active[0] = 1
            Entries[h] = slot

            if idx + 1 > PCount[0] then
                PCount[0] = idx + 1
            end
        else
            slot.active[0] = 1
        end

        WriteSlot(slot, x, y, z, w)
    end

    function Shader.Get(hash)
        local h = ParseHash(hash)
        if not h then return nil end

        local slot = Entries[h]
        if not slot or slot.active[0] == 0 then return nil end

        return { slot.val[0], slot.val[1], slot.val[2], slot.val[3] }
    end

    function Shader.Remove(hash)
        local h = ParseHash(hash)
        if not h then return end

        local slot = Entries[h]
        if not slot then return end

        slot.active[0] = 0
        slot.hash[0] = 0
        Entries[h] = nil
        table.insert(FreeSlots, 1, slot.index)

        local max_idx = -1
        for _, s in pairs(Entries) do
            if s.index > max_idx then max_idx = s.index end
        end

        if PCount then PCount[0] = max_idx + 1 end
    end

    function Shader.Clear()
        local keys = {}

        for h in pairs(Entries) do keys[#keys + 1] = h end
        for i = 1, #keys do Shader.Remove(keys[i]) end

        if PCount then PCount[0] = 0 end
    end

    function Shader.Unload()
        if HookInstance then
            HookInstance:Remove()
            HookInstance = nil
        end

        if StubMem then
            MemFree(StubMem)
            StubMem = nil
        end

        Entries = {}
        ResetFreeSlots()

        TargetAddr, PCount = nil, nil
        ResolveAttempted = false
    end

    return Shader

end

local init = require("library.core.initializate")
require("library.core.helper")
local utils = require("library.core.utils")
require("library.core.logs")
require("library.core.override")
require("library.core.enum")
local cfgsys = require("library.lua.configs")
local input = require("library.system.input")
local fs = require("library.system.file_system")
require("library.render.render")
require("library.render.color")
local gui = require("library.render.gui")
require("library.engine.buffer_string")
local events = require("library.engine.events")
local global_vars = require("library.engine.global_vars")
local hooks = require("library.system.hooks")
require("library.system.memory")
local cvars = require("library.engine.convars")
local particle_system = require("library.engine.particle_system")
local resource_system = require("library.engine.resource_system")
local entity = require("library.engine.entity")
local user_cmd = require("library.engine.user_cmd")
local cmd_button_t = require("library.engine.cmd_button_t")
local game_ui = require("library.engine.game_ui")
local post_process = require("library.engine.post_processing")
require("library.engine.i_engine_client")
require("library.engine.i_client")
require("library.engine.trace")
local shader = require("library.engine.shader")

--globals

pawn = GetLocalPawn()
controller = GetLocalController()
gamerules = GetGameRules()
view_angles = angle_t(0, 0, 0)
camera_pos = vec3_t(0, 0, 0)

events.paint(function()
    pawn = GetLocalPawn()
    controller = GetLocalController()
    gamerules = GetGameRules()
end)

events.override_view(function(view)
    view_angles = view.angles
    camera_pos = view.origin
end)

--resources

local Resources = {
    "bin/flowers_s.vpcf",
    "bin/lightning_s.vpcf",
    "bin/coins_s.vpcf",
    "bin/tombstone_s.vpcf",
    "bin/sakura_pink.vpcf",
    "bin/sakura_red.vpcf",
    "bin/sakura_purple.vpcf",
    "bin/sakura_white.vpcf",
    "bin/sakura_blue.vpcf",
    "bin/sakura_grey.vpcf",
}

function LoadResources()
    for _, i in ipairs(Resources) do
        resource_system.LoadResource(i)
    end

    for _, i in ipairs(utils.GetHitsoundsFiles()) do
        resource_system.LoadResource("sounds/" .. i:gsub("%.vsnd_c$", ".vsnd"))
    end
    
    for _, i in ipairs(utils.GetHitsoundsFiles()) do
        fs.CopyFile(Path.HitSounds .. i, Path.CS2Sounds .. i, true)
    end
end

LoadResources()

--menu

local uix = {}; do
    local menu = gui.create_window("Main Menu", vec2_t(850, 450), vec2_t(800, 600))
    local playername = init.NixwareName
    
    menu:setting("set", "border", false)
    menu:setting("set", "bg_color", color_t(0.1, 0.1, 0.1, 1))
    menu:render_func(function(win, a)
        render.rect_filled(vec2_t(win.pos.x, win.pos.y), vec2_t(win.pos.x + 200, win.pos.y + 80), color_t(0.075, 0.075, 0.075, 1 * a), 5)
        render.rect_filled(vec2_t(win.pos.x, win.pos.y), vec2_t(win.pos.x + 800, win.pos.y + 70), color_t(0.075, 0.075, 0.075, 1 * a), 5)
        render.line(vec2_t(win.pos.x + 200, win.pos.y + 70), vec2_t(win.pos.x + 800, win.pos.y + 70), color_t(1, 1, 1, 0.05 * a), 1)
        render.line(vec2_t(win.pos.x + 200, win.pos.y), vec2_t(win.pos.x + 200, win.pos.y + 600), color_t(1, 1, 1, 0.05 * a), 1)
        render.line(vec2_t(win.pos.x + 5, win.pos.y + 70), vec2_t(win.pos.x + 195, win.pos.y + 70), color_t(1, 1, 1, 0.2 * a), 1)
        render.line(vec2_t(win.pos.x, win.pos.y + 530), vec2_t(win.pos.x + 200, win.pos.y + 530), color_t(1, 1, 1, 0.05 * a), 1)
        render.text(ICON_LOGO, init.TitleIcons, vec2_t(win.pos.x + 5, win.pos.y + 15), color_t(1, 1, 1, 1 * a)) 
        render.text("Shadow.lua", init.TitleFont, vec2_t(win.pos.x + 45, win.pos.y + 17.5), color_t(1, 1, 1, 1 * a))
        render.text(playername, init.StandartFont, vec2_t(win.pos.x + 65, win.pos.y + 550), color_t(1, 1, 1, 1 * a))
        render.text("Expires: " .. tostring(init.SubscriptionTime), init.SmallFont, vec2_t(win.pos.x + 65, win.pos.y + 565), color_t(0.75, 0.75, 0.75, 1 * a))
        render.circle_filled(vec2_t(win.pos.x + 35, win.pos.y + 565), 22.5, 32, color_t(0.2, 0.2, 0.2, 1 * a))
        render.text(ICON_USER, init.TitleIcons, vec2_t(win.pos.x + 17.5, win.pos.y + 545), color_t(0.5, 0.5, 0.5, 1 * a))
    end)

    local tabs = menu:create_group(vec2_t(0, 75), vec2_t(200, 525)):setting("set", "border", false):setting("set", "bg_color", color_t(0.075, 0.075, 0.075, 1))
    
    local rage = tabs:create_tab("Rage", ICON_RAGE); do
        local general = rage:create_group(vec2_t(207.5, 90), vec2_t(288.75, 70), {name = "General"}); do
            general.DuckPeekAssist = general:Label("Duck-Peek Assist"):Gear(function(gear)
                return {
                    Enabled = gear:Hotkey("Enabled", nil, 3, {false, true, true}, {"Hold", "Toggle"}),
                    MinDamage = gear:Slider("Min-Damage", 100, 1, 100, 1, "%.0fhp"),
                    MinDamageOverride = gear:Slider("Override Min-Dmg", 10, 1, 100, 1, "%.0fhp"),
                    MinDamageOverrideEnabled = gear:Hotkey("Override Min-Dmg Enabled", nil, 2, {false, true, true}, {"Hold", "Toggle"}),
                }
            end)

            general.AiPeek = general:Label("Ai Peek"):Gear(function(gear)
                return {
                    Enabled = gear:Hotkey("Enabled", nil, 2),
                    MinDamage = gear:Slider("Min-Damage", 100, 1, 100, 1, "%.0fhp"),
                    MinDamageOverride = gear:Slider("Override Min-Dmg", 10, 1, 100, 1, "%.0fhp"),
                    MinDamageOverrideEnabled = gear:Hotkey("Override Min-Dmg Enabled", nil, 2, {false, true, true}, {"Hold", "Toggle"}),
                    PeekOffset = gear:Slider("Peek Offset", 75, 30, 200, 1, "%.0f"),
                    Indicator = gear:Switch("Indicator", false),
                    Width = gear:Slider("Width", 1, 0.1, 10, 0.1, "%.1f"):Visibility(false),
                    Radius = gear:Slider("Radius", 15, 0.1, 20, 0.5, "%.1f"):Visibility(false),
                    Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true):Visibility(false),
                }
            end)
        end
        
        local manual_aa = rage:create_group(vec2_t(505, 90), vec2_t(288.75, 45)); do
            manual_aa.ManualAA = manual_aa:Switch("Manual AA", false):Gear(function(gear)
                return {
                    Left = gear:Hotkey("Left", nil, 2, {false, true, false}, {"Toggle"}),
                    Right = gear:Hotkey("Right", nil, 2, {false, true, false}, {"Toggle"}),
                }
            end)
        end

        rage.general = general
        rage.manual_aa = manual_aa
    end

    local legit = tabs:create_tab("Legit", ICON_LEGIT):Disable(true); do
    end

    local visuals = tabs:create_tab("Visuals", ICON_VISUALS); do
        local local_player = visuals:create_subtab("Local Player"); do
            local general = local_player:create_group(vec2_t(207.5, 90), vec2_t(288.75, 70), {name = "General"}); do
                general.PerspectiveOptions = general:Label("Perspective Options"):Gear(function(gear)
                    return {
                        ForceThirdpersonInSpectate = gear:Switch("Force Thirdperson In Spectate", false),
                        ThirdpersonDistance = gear:Slider("Distance", 150, 30, 200, 1, "%.0f"),
                        FirstpersonWithUtilities = gear:Switch("Firstperson With Utilities", false),
                    }
                end)

                general.ViewOptions = general:Switch("View Options", false):Gear(function(gear)
                    return {
                        Fov = gear:Slider("Fov", 100, 1, 200, 1, "%.0f°"),
                        ZoomFov1 = gear:Slider("Zoom(x1)", 100, 0, 100, 1, "%.0f%%"),
                        ZoomFov2 = gear:Slider("Zoom(x2)", 100, 0, 100, 1, "%.0f%%"),
                    }
                end)
            end
        
            local model = local_player:create_group(vec2_t(207.5, 165), vec2_t(288.75, 70)); do
                model.ModelChanger = model:Switch("Model Changer", false):Gear(function(gear)
                    local Name = { 
                        [2] = {
                            "None", "Custom(Soon...)", "Getaway Sally", "Number K", "Little Kev", "Safecracker Voltzmann", "Sir Bloody Darryl The Strapped", "Sir Bloody Loudmouth Darryl",
                            "Sir Bloody Darryl Royale", "Sir Bloody Skullhead Darryl", "Sir Bloody Silent Darryl", "Sir Bloody Miami Darryl", "Street Soldier",
                            "Soldier", "Slingshot", "Enforcer", "Prof. Shahmat", "Osiris", "Jungle Rebel", "Ground Rebel", "The Elite Mr. Muhlik", "Trapper",
                            "Trapper Aggressor", "Vypa Sista of the Revolution", "Col. Mangos Dabisi", "Arno The Overgrown", "'Medium Rare' Crasswater", "Crasswater The Forgotten",
                            "Elite Trapper Solman", "'The Doctor' Romanov", "Blackwolf", "Maximus", "Dragomir", "Rezan The Ready", "Rezan the Redshirt", "Dragomir Footsoldier"
                        },

                        [3] = {
                            "None", "Custom(Soon...)", "Cmdr. Davida 'Goggles' Fernandez", "Cmdr. Frank 'Wet Sox' Baroud", "Lieutenant Rex Krikey", "Michael Syfers",  "Operator", 
                            "Special Agent Ava", "Markus Delrow", "Sous-Lieutenant Medic", "Chem-Haz Capitaine", "Chef d'Escadron Rouchard", "Aspirant",
                            "Officer Jacques Beltram", "D Squadron Officer", "B Squadron Officer", "Seal Team 6 Soldier", "Buckshot", "Lt. Commander Ricksaw", 
                            "'Blueberries' Buckshot", "3rd Commando Company", "'Two Times' McCoy TACP Cavalry", "'Two Times' McCoy USAF TACP", "Primeiro Tenente",
                            "Cmdr. Mae 'Dead Cold' Jamison", "1st Lieutenant Farlow", "John 'Van Healen' Kask", "Bio-Haz Specialist", "Sergeant Bombson", 
                            "Chem-Haz Specialist", "Lieutenant 'Tree Hugger' Farlow"
                        }
                    }

                    return {
                        [TEAM_T] = gear:Selectable("T Model", Name[2], false, 1),
                        CustomT = gear:Selectable("Custom T", {"None"}, false, 1):Visibility(false),
                        [TEAM_CT] = gear:Selectable("CT Model", Name[3], false, 1),
                        CustomCT = gear:Selectable("Custom CT", {"None"}, false, 1):Visibility(false),
                    }
                end)

                model.DisableModelAnim = model:Switch("Disable Model Anim", false)
            end
        
            local overlay = local_player:create_group(vec2_t(207.5, 240), vec2_t(288.75, 45)); do
                overlay.ScopeOverlay = overlay:Switch("Scope Overlay", false):Gear(function(gear)
                    return {
                        TargetLines = gear:Selectable("Target Lines", {"Top", "Bottom", "Left", "Right"}, true, {true, true, true, true}),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                        AnimationSpeed = gear:Slider("Animation Speed", 15, 1, 50, 1, "%.0f"),
                        LinesDistance = gear:Slider("Lines Distance", 15, 0, 200, 1, "%.0f"),
                        LinesSize = gear:Slider("Lines Size", 16, 5, 100, 0.5, "%.1f"),
                        GradientSize = gear:Slider("Gradient Size", 30, 0, 150, 1, "%.0f"),
                        AspectRatio = gear:Slider("Aspect Ratio", 0, 0, 100, 1, "%.0f"),
                    }
                end)
            end

            local dlights = local_player:create_group(vec2_t(207.5, 290), vec2_t(288.75, 45)); do 
                dlights.DLights = dlights:Switch("DLights", false):Gear(function(gear)
                    return {
                        Radius = gear:Slider("Radius", 100, 0, 200, 1, "%.0f"),
                        ZOffset = gear:Slider("Z-Offset", 40, 0, 100, 1, "%.0f"),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                    }
                end)
            end

            local effects = local_player:create_group(vec2_t(505, 90), vec2_t(288.75, 175), {name = "Effects"}); do 
                effects.HealthBoostHitEffect = effects:Switch("Health Boost Hit Effect", false)

                effects.ShotEffects = effects:Switch("Shot Effects", false):Gear(function(gear)
                    return {
                        Effect = gear:Selectable("Effect", {"Sparks", "HE Explosion", "Explosion", "Water Explosion", "Flashbang Explosion", "Flowers", "Lightning", "Coins"}, false, 1),
                    }
                end)

                effects.BulletImpacts = effects:Switch("Bullet Impacts", false):Gear(function(gear)
                    return {
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                        Size = gear:Slider("Size", 1.5, 0.1, 5, 0.1, "%.1f"),
                        Lifetime = gear:Slider("Lifetime", 2.0, 0.1, 5.0, 0.1, "%.1f"),
                        DrawFill = gear:Switch("Draw Fill", true),
                        DrawWithoutDots = gear:Switch("Draw Without Dots", true):Visibility(true),
                    }
                end)

                effects.BulletTracers = effects:Switch("Bullet Tracers", false):Gear(function(gear)
                    return {
                        Type = gear:Selectable("Type", {"Direct", "Smooth"}, false, 1),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                        Width = gear:Slider("Width", 0.5, 0.1, 5.0, 0.1, "%.1f"),
                        Lifetime = gear:Slider("Lifetime", 2.0, 0.1, 5.0, 0.1, "%.1f"),
                    }
                end)

                effects.Trails = effects:Switch("Trails", false):Gear(function(gear)
                    return {
                        Type = gear:Selectable("Type", {"Money", "Utils"}, false, 1):Visibility(false),
                        Delay = gear:Slider("Delay", 1, 0, 10, 0.1, "%.1f"):Visibility(true),
                    }
                end)

                effects.JumpCircles = effects:Switch("Jump Circles", false):Gear(function(gear)
                    return {
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                        Width = gear:Slider("Width", 1.0, 0.1, 3.0, 0.1, "%.1f"),
                        Lifetime = gear:Slider("Lifetime", 1, 0.1, 2.0, 0.1, "%.1f"),
                        Radius = gear:Slider("Radius", 10.0, 0.1, 20.0, 0.1, "%.1f"),
                    }
                end)
            end

            local glow = local_player:create_group(vec2_t(505, 270), vec2_t(288.75, 45)); do 
                glow.Glow = glow:Switch("Glow", false):Gear(function(gear)
                    return {
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                    }
                end)
            end

            local wetness = local_player:create_group(vec2_t(505, 320), vec2_t(288.75, 45)); do 
                wetness.WetnessEffect = wetness:Switch("Wetness Effect", false):Gear(function(gear)
                    return {
                        Speed = gear:Slider("Speed", 150, 1, 300, 1, "%.0f%%"),
                        Density = gear:Slider("Density", 50, 0, 100, 1, "%.0f%%"),
                    }
                end)
            end

            local_player.general = general
            local_player.effects = effects
            local_player.model = model
            local_player.overlay = overlay
            local_player.glow = glow
            local_player.wetness = wetness
            local_player.dlights = dlights
        end

        local world = visuals:create_subtab("World"); do
            local general = world:create_group(vec2_t(207.5, 90), vec2_t(288.75, 120), {name = "General"}); do
                general.FogOverride = general:Switch("Fog Override", false):Gear(function(gear)
                    return {
                        MaxDensity = gear:Slider("Max Density", 50, 0, 100, 1, "%.0f"),
                        Exponent = gear:Slider("Exponent", 10, 1, 100, 1, "%.0f"),
                        Start = gear:Slider("Start", 200, 1, 3500, 1, "%.0f"),
                        End = gear:Slider("End", 2500, 1, 5000, 1, "%.0f"),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, false),
                    }
                end)

                general.DoFOverride = general:Switch("DoF Override", false):Gear(function(gear)
                    return {
                        FarBlurry = gear:Slider("Far Blurry", 1500, 0, 2000, 1, "%.0f"),
                        FarCrisp = gear:Slider("Far Crisp", 1000, 0, 1000, 1, "%.0f"),
                        NearBlurry = gear:Slider("Near Blurry", -100, -100, 2000, 1, "%.0f"),
                        NearCrisp = gear:Slider("Near Crisp", 0, -500, 500, 1, "%.0f"),
                    }
                end)

                general.Fullbright = general:Switch("Fullbright", false)

                general.Wind = general:Switch("Wind", false):Gear(function(gear)
                    return {
                        Strength = gear:Slider("Strength", 1.5, 0, 10, 0.1, "%.1f"),
                    }
                end)
            end

            local screen = world:create_group(vec2_t(207.5, 215), vec2_t(288.75, 95)); do
                screen.DisablePostProcessing = screen:Switch("Disable Post-Processing", false)

                screen.Exposure = screen:Switch("Exposure", false):Gear(function(gear)
                    return {
                        Value = gear:Slider("Value", 80, 0, 300, 1, "%.0f"),
                    }
                end)

                screen.Gamma = screen:Switch("Gamma", false):Gear(function(gear)
                    return {
                        Value = gear:Slider("Value", DEF_VALUE_GAMMA, 0.0, 4.0, 0.1, "%.1f"),
                    }
                end)
            end

            local removals = world:create_group(vec2_t(207.5, 315), vec2_t(288.75, 45)); do
                removals.Removals = removals:Switch("Removals", false):Gear(function(gear)
                    return {
                        Remove = gear:Selectable("Remove", {"World", "Skybox", "Molotov"}, true, {false, false, false})
                    }
                end)
            end

            local effects = world:create_group(vec2_t(505, 90), vec2_t(288.75, 70), {name = "Effects"}); do
                effects.WorldEffects = effects:Switch("World Effects", false):Gear(function(gear)
                    return {
                        Effect = gear:Selectable("Effect", {"Snow", "Snow1", "Snow2", "Snow3", "Ash", "Ash1", "Rain", "Stars"}, false, 1),
                        Density = gear:Slider("Density", 40, 0, 100, 1, "%.0f%%"),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, false),
                    }
                end)
                
                effects.KillEffects = effects:Switch("Kill Effects", false):Gear(function(gear)
                    return {
                        Effect = gear:Selectable("Effect", {"C4 Explosion", "HE Explosion", "Explosion", "Sparks", "Water Explosion", "Flashbang Explosion", "Flowers", "Lightning", "Ash", "Coins", "Tombstone", "Sakura Pink", "Sakura Red", "Sakura Purple", "Sakura White", "Sakura Blue", "Sakura Grey", "Taser Shock"}, false, 14),
                    }
                end)
            end

            local grenades = world:create_group(vec2_t(505, 165), vec2_t(288.75, 120)); do
                grenades.GrenadeESP = grenades:Label("Grenade ESP"):Gear(function(gear)
                    return {
                        SmokeRadius = gear:Switch("Smoke Radius", false),
                        SmokeColor = gear:ColorPicker("Smoke Color", COLOR_SHADOWLUA2, true):Visibility(false),
                        MolotovRadius = gear:Switch("Molotov Radius", false),
                        MolotovColor = gear:ColorPicker("Molotov Color", COLOR_SHADOWLUA2, true):Visibility(false),
                    }
                end)

                grenades.CustomSmokeColor = grenades:Switch("Custom Smoke Color", false):Gear(function(gear)
                    return {
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, false),
                    }
                end)

                grenades.FlyingGrenadeIcons = grenades:Switch("Flying Grenade Icons", false)
                grenades.GrenadeTrails = grenades:Switch("Grenade Trails", false)
            end

            world.general = general
            world.screen = screen
            world.removals = removals
            world.skybox = skybox
            world.effects = effects
            world.grenades = grenades
        end

        visuals.local_player = local_player
        visuals.world = world
    end

    local misc = tabs:create_tab("Misc", ICON_GEAR); do
        local general = misc:create_group(vec2_t(207.5, 90), vec2_t(288.75, 70), {name = "General"}); do
            general.ClanTag = general:Switch("ClanTag", false):Gear(function(gear)
                return {
                    Delay = gear:Slider("Delay", 1.5, 0.1, 10, 0.1, "%.1f"),
                    Type = gear:Selectable("Type", {
                        "Shadow.lua", "Neverlose.cc", "Nixware.cc", "Midnight.im", 
                        "Fatality.win", "Bankroll.su", "Legendware.pw", "Interium.ooo", 
                        "MemeSense.gg", "Plaguecheat.cc", "Tracele.cc", "Custom"
                    }, false, 1),
                    Custom = gear:Input("Custom", "ClanTag"):Visibility(false),
                    Font = gear:Selectable("Font", {
                        "Normal", "Bold", "Italic", "Bold Italic", "Fraktur", "Bold Fraktur",
                        "Double-Struck", "Monospace", "Script Bold", "Script Light",
                        "Circled", "Small Caps", "Strikethrough", "Underline",
                        "Diaeresis", "Fullwidth"
                    }, false, 1),
                    AnimMode = gear:Selectable("Anim Mode", {
                        "<--", "-->", "AbCdQwEr", "Wave's", "Typewriter", "Bounce", "Glitch", 
                        "Heartbeat", "Matrix", "Scramble", "DNA Helix", "Radar", "Static", "Snake", 
                        "Flip", "Fade Dots", "Brackets", "Fill", "Decrypt", "Pendulum", "Loading", 
                        "Split", "Swap Case", "Neon", "Countdown", "Binary", "Progress Bar"
                    }, false, 6),
                }
            end)

            general.AutoBuy = general:Switch("Auto-Buy", false):Gear(function(gear)
                return {
                    Main = gear:Selectable("Main", {"None", "SSG08", "AWP", "Auto"}, false, 1),
                    Secondary = gear:Selectable("Secondary", {"None", "Deagle", "Revolver"}, false, 1),
                    Other = gear:Selectable("Other", {"Armor", "HE Grenade", "Smoke", "Molotov", "Flashbang", "Defuser", "Taser"}, true, {false, false, false, false, false, false, false}),
                }
            end)
        end

        local hitsounds = misc:create_group(vec2_t(207.5, 165), vec2_t(288.75, 45)); do
            hitsounds.HitSounds = hitsounds:Switch("Hit-Sounds", false):Gear(function(gear)
                return {
                    Volume = gear:Slider("Volume", 1, 0.01, 1, 0.01, "%.2f"):Visibility(false),
                    Sound = gear:Selectable("Sound", utils.GetHitsoundsFiles(), false, 1),
                }
            end)
        end

        local interface = misc:create_group(vec2_t(207.5, 215), vec2_t(288.75, 70)); do
            interface.RevealRadar = interface:Switch("Reveal Radar", false)
            interface.PreserveKillFeed = interface:Switch("Preserve KillFeed", false):Gear(function(gear)
                return {
                    Time = gear:Slider("Time", 10.1, 0, 10.1, 0.1, "%.1f"):Format(0, "Remove"):Format(10.1, "Preserve"),
                }
            end)
        end

        local other = misc:create_group(vec2_t(505, 90), vec2_t(288.75, 45), {name = "Other"}); do
            other.Ragdolls = other:Switch("Ragdolls", false):Gear(function(gear)
                return {
                    Gravity = gear:Slider("Gravity", 0, -100, 100, 1, "%.0f%%"),
                    Friction = gear:Slider("Friction", 1, 0, 100, 1, "%.0f%%"),
                }
            end)
        end

        local freecam = misc:create_group(vec2_t(505, 140), vec2_t(288.75, 45)); do
            freecam.Freecam = freecam:Hotkey("Freecam", nil, 3)
        end

        local movement = misc:create_group(vec2_t(505, 190), vec2_t(288.75, 45)); do
            movement.EdgeJump = movement:Hotkey("Edge Jump", nil, 2)
        end

        local viewmodel = misc:create_group(vec2_t(505, 240), vec2_t(288.75, 95)); do
            viewmodel.RemoveViewmodelInScope = viewmodel:Switch("Remove Viewmodel In Scope", false)
            viewmodel.ViewmodelRotation = viewmodel:Switch("Viewmodel Rotation", false):Gear(function(gear)
                return {
                    Pitch = gear:Slider("Pitch", 0, -150, 150, 1, "%.0f"),
                    Yaw = gear:Slider("Yaw", 0, -150, 150, 1, "%.0f"),
                    Roll = gear:Slider("Roll", 0, -200, 200, 1, "%.0f"),
                }
            end)
            viewmodel.CustomViewmodelInScope = viewmodel:Switch("Custom Viewmodel In Scope", false):Gear(function(gear)
                return {
                    X = gear:Slider("Z", 0, -20, 20, 0.1, "%.1f"),
                    Y = gear:Slider("Y", 0, -20, 20, 0.1, "%.1f"),
                    Z = gear:Slider("X", 0, -20, 20, 0.1, "%.1f"),
                    Fov = gear:Slider("Fov", 0, 0, 180, 1, "%.0f"),
                    Pitch = gear:Slider("Pitch", 0, -150, 150, 1, "%.0f"),
                    Yaw = gear:Slider("Yaw", 0, -150, 150, 1, "%.0f"),
                    Roll = gear:Slider("Roll", 0, -200, 200, 1, "%.0f"),
                }
            end)
        end

        misc.general = general
        misc.hitsounds = hitsounds
        misc.interface = interface
        misc.other = other
        misc.freecam = freecam
        misc.movement = movement
        misc.viewmodel = viewmodel
    end

    local settings_tab = tabs:create_tab("Settings", ICON_FOLDER); do
        local cfg = settings_tab:create_subtab("Configs"); do
            local general = cfg:create_group(vec2_t(207.5, 90), vec2_t(288.75, 225), {name = "Settings"}); do
                general.ConfigName = general:Input("Config Name", "Name")

                general.Config = general:Selectable("Config", {""}, false, 1)

                local function RefreshConfigList()
                    local list = cfgsys.GetList()
                    if #list == 0 then
                        general.Config:SetItems({"None"})
                        general.Config:Set(1)
                    else
                        general.Config:SetItems(list)
                        general.Config:Set(1)
                    end
                end

                general.CfgSaveCreateButton = general:Button("Create/Save", function()
                    local idx = general.Config:Get()
                    local list = cfgsys.GetList()
                    local input_name = general.ConfigName:Get()
                    
                    if input_name and input_name ~= "" and input_name ~= "None" then
                        cfgsys.Save(input_name)
                        RefreshConfigList()
                        general.ConfigName:Set("")

                        log():SetConsolePrefix("Config System"):Send(CONSOLE, PREFIX, "Config successfully created.")
                    elseif idx and #list > 0 and list[idx] ~= "None" then
                        cfgsys.Save(list[idx])
                        RefreshConfigList()
                        general.ConfigName:Set("")

                        log():SetConsolePrefix("Config System"):Send(CONSOLE, PREFIX, "Config successfully saved.")
                    end
                end)

                general.CfgLoadButton = general:Button("Load", function()
                    local idx = general.Config:Get()
                    local list = cfgsys.GetList()
                    if idx and #list > 0 and list[idx] ~= "None" then
                        cfgsys.Load(list[idx])
                        general.ConfigName:Set("")
                        RefreshConfigList()

                        local CfgData = cfgsys.GetInfo(list[idx])
                        log():SetConsolePrefix("Config System"):Send(CONSOLE, PREFIX, "Config by " .. CfgData.author .. " successfully loaded.")
                    end
                end)

                general.CfgDeleteButton = general:Button("Delete", function()
                    local idx = general.Config:Get()
                    local list = cfgsys.GetList()
                    if idx and #list > 0 and list[idx] ~= "None" then
                        cfgsys.Delete(list[idx])
                        RefreshConfigList()

                        log():SetConsolePrefix("Config System"):Send(CONSOLE, PREFIX, "Config successfully deleted.")
                    end
                end)

                general.CfgRefreshButton = general:Button("Refresh", function()
                    RefreshConfigList()
                end)

                general.CfgDefButton = general:Button("Reset Settings", function()
                    cfgsys.ResetSettings()
                    RefreshConfigList()

                    log():SetConsolePrefix("Config System"):Send(CONSOLE, PREFIX, "Config has been successfully reset.")
                end)

                RefreshConfigList()
            end

            local folders = cfg:create_group(vec2_t(207.5, 320), vec2_t(288.75, 75)); do
                folders.ConfigsFolder = folders:Button("Configs Folder", function()
                    fs.OpenFolder(Path.Configs)
                end)

                folders.HitSoundsFolder = folders:Button("Hit-Sounds Folder", function()
                    fs.OpenFolder(Path.HitSounds)
                end)
            end

            cfg.general = general
        end

        local settings_sub = settings_tab:create_subtab("Settings"); do
            local overlay = settings_sub:create_group(vec2_t(207.5, 90), vec2_t(288.75, 150), {name = "Overlay"}); do
                overlay.Watermark = overlay:Switch("Watermark", false):Gear(function(gear)
                    return {
                        BorderRadius = gear:Slider("Border Radius", 3.5, 0, 20, 0.1, "%.1f"),
                        Fields = gear:Selectable("Fields", {"Name", "FPS", "Time"}, true, {true, true, true}),
                        Name = gear:Selectable("Name", {"NixWare", "Steam", "Custom"}, false, 1),
                        Custom = gear:Input("Custom", "Name"):Visibility(false),
                        pos_x = gear:Slider("x", 10, 0, render.screen_size().x, 1, "%.0f"):Visibility(false),
                        pos_y = gear:Slider("y", 10, 0, render.screen_size().y, 1, "%.0f"):Visibility(false),
                    }
                end)

                overlay.ManualAAIndicators = overlay:Switch("Manual AA Indicators", false):Gear(function(gear)
                    return {
                        Distance = gear:Slider("Distance", 50, 5, 100, 1, "%0.f"),
                        Color = gear:ColorPicker("Color", COLOR_SHADOWLUA2, true),
                    }
                end)

                overlay.BombIndicator = overlay:Switch("Bomb Indicator", false):Gear(function(gear)
                    return {
                        BorderRadius = gear:Slider("Border Radius", 3.5, 0, 30, 0.1, "%.1f"),
                        pos_x = gear:Slider("x", 600, 0, render.screen_size().x, 1, "%.0f"):Visibility(false),
                        pos_y = gear:Slider("y", 10, 0, render.screen_size().y, 1, "%.0f"):Visibility(false),
                    }
                end)

                overlay.Logs = overlay:Switch("Logs", false):Gear(function(gear)
                    return {
                        Events = gear:Selectable("Events", {"Hit"--[[, "Miss"]]}, true, {false, false}),
                        Output = gear:Selectable("Output", {"Screen", "Console", "Chat"}, true, {false, false}),
                        BorderRadius = gear:Slider("Border Radius", 3.5, 0, 20, 0.1, "%.1f"):Visibility(false),
                        pos_x = gear:Slider("x", 10, 0, render.screen_size().x, 1, "%.0f"):Visibility(false),
                        pos_y = gear:Slider("y", 10, 0, render.screen_size().y, 1, "%.0f"):Visibility(false),
                    }
                end)

                overlay.KeybindsList = overlay:Switch("Keybinds List", false):Gear(function(gear)
                    return {
                        Binds = gear:Selectable("Binds", {"Duck Peek Assist", "DP MinDmg", "AI Peek", "AI MinDmg", "Freecam", "Edge Jump"}, true, {false, false, false, false, false, false}),
                        BorderRadius = gear:Slider("Border Radius", 3, 0, 12, 0.1, "%.1f"),
                        pos_x = gear:Slider("x", 610, 0, render.screen_size().x, 1, "%.0f"):Visibility(false),
                        pos_y = gear:Slider("y", 10, 0, render.screen_size().y, 1, "%.0f"):Visibility(false),
                    }
                end)
            end

            local menu = settings_sub:create_group(vec2_t(505, 90), vec2_t(288.75, 50), {name = "Menu"}); do
                menu.Name = menu:Selectable("Name", {"NixWare", "Steam"}, false, 1)
            end

            settings_sub.overlay = overlay
            settings_sub.menu = menu
        end

        settings_tab.cfg = cfg
        settings_tab.settings = settings_sub
    end

    uix.menu = menu
    uix.rage = rage
    uix.legit = legit
    uix.visuals = visuals
    uix.misc = misc
    uix.settings = settings_tab

    function uix.createmove(cmd)
        if ui.is_menu_opened() then
            cmd:Set(IN_ATTACK, 0)
            cmd:Set(IN_ATTACK2, 0)
        end
    end

    function uix.paint()
        gui.draw()
        
        uix.menu:setting("set", "is_open", ui.is_menu_opened())
        playername = (uix.settings.settings.menu.Name:Get() == 1 and init.NixwareName) or (uix.settings.settings.menu.Name:Get() == 2 and init.SteamName)
    end
end

local rage = {}; do
    local general = uix.rage.general
    
    local duck_peek_assist = {}; do
        local gear = general.DuckPeekAssist
        local DuckPeekCanShoot = false

        function duck_peek_assist:createmove(cmd)
            if not gear.Enabled:Get() then return end
            if not pawn or not controller then return end

            DuckPeekCanShoot = false

            local EyePos = pawn:GetEyePos(true)
            local MinDamage = gear.MinDamageOverrideEnabled:Get() and gear.MinDamageOverride:Get() or gear.MinDamage:Get()

            GetPlayers(function(entity)
                if DuckPeekCanShoot then return end
                if not entity then return end
                if not entity:IsEnemy() or not entity:IsAlive() or entity:IsTeammate() then return end

                local HitboxesPos = {
                    entity:GetHitboxPos(HITBOX_HEAD),
                    entity:GetHitboxPos(HITBOX_CHEST),
                    entity:GetHitboxPos(HITBOX_NECK),
                }

                for _, i in ipairs(HitboxesPos) do
                    if i then
                        local CanHit, Damage = pawn:CanHit(EyePos, i, entity)
                        if CanHit and Damage and Damage >= MinDamage and pawn:CanShoot() and not pawn:GetActiveWeapon():IsKnife() then
                            DuckPeekCanShoot = true
                            break
                        end
                    end
                end
            end)

            if not DuckPeekCanShoot then
                cmd:Set(IN_DUCK, 1)
            elseif DuckPeekCanShoot then
                return
            end
        end
    end

    local ai_peek = {}; do
        local gear = general.AiPeek

        local AiPeekLeft = false
        local AiPeekRight = false
        local AiPeekLeftMove = cmd_button_t("left")
        local AiPeekRightMove = cmd_button_t("right")
        local AiPeekReturn = false
        local AiPeekStartedPos = nil
        local AiPeekType = nil

        local ActiveCircles = {}
        local WasEnabled = false
        local LastCircleCreateTime = 0

        local function ClearPositionCircles()
            for _, i in ipairs(ActiveCircles) do
                if i and i.id then
                    pcall(function() i.id:DestroyParticle() end)
                end
            end
            ActiveCircles = {}
        end

        local function CreatePositionCircle(Pos, Radius)
            if not Pos then return end

            local Id = particle_system.AddParticleCircle("particles/entity/spectator_utility_trail.vpcf", Pos, Radius, gear.Color:Get(), gear.Width:Get(), 0.15)
            if Id then
                table.insert(ActiveCircles, {id = Id, time = global_vars and global_vars.m_flCurrentTime or 0})
            end

            local Now = global_vars and global_vars.m_flCurrentTime or 0
            for i = #ActiveCircles, 1, -1 do
                if Now - ActiveCircles[i].time > 0.3 then
                    if ActiveCircles[i].id then
                        pcall(function() ActiveCircles[i].id:DestroyParticle() end)
                    end
                    table.remove(ActiveCircles, i)
                end
            end

            if #ActiveCircles > 16 then
                local old = table.remove(ActiveCircles, 1)
                if old and old.id then pcall(function() old.id:DestroyParticle() end) end
            end
        end

        local function UpdateIndicator()
            if not gear.Indicator:Get() or not global_vars then
                ClearPositionCircles()
                return
            end

            if not pawn or not pawn:IsAlive() then
                ClearPositionCircles()
                return
            end

            if not WasEnabled then
                AiPeekStartedPos = pawn:GetPosition()
                WasEnabled = true
                LastCircleCreateTime = 0
            end

            local Now = global_vars.m_flCurrentTime
            if AiPeekStartedPos and (Now - LastCircleCreateTime) >= 0.1 then
                LastCircleCreateTime = Now
                CreatePositionCircle(AiPeekStartedPos, gear.Radius:Get())
            end
        end

        local function GetOffsets()
            local EyePos = pawn:GetEyePos()
            local _, RightVector = math.angle_vectors(view_angles)
            local LeftOffset = EyePos - RightVector * gear.PeekOffset:Get()
            local RightOffset = EyePos + RightVector * gear.PeekOffset:Get()

            return LeftOffset, RightOffset
        end

        function ai_peek:createmove()
            gear.Color:Visibility(gear.Indicator:Get())
            gear.Width:Visibility(gear.Indicator:Get())
            gear.Radius:Visibility(gear.Indicator:Get())

            if not gear.Enabled:Get() then
                AiPeekRightMove:Release()
                AiPeekLeftMove:Release()
                AiPeekReturn = false
                AiPeekStartedPos = nil
                AiPeekType = nil
                AiPeekLeft = false
                AiPeekRight = false
                WasEnabled = false
                last_circle_create_time = 0
                ClearPositionCircles()
                return
            end

            if not pawn or not controller then return end

            UpdateIndicator()

            AiPeekLeft = false
            AiPeekRight = false
            AiPeekLeftMove:Release()
            AiPeekRightMove:Release()

            if not AiPeekReturn then
                local weapon = pawn:GetActiveWeapon()
                if not pawn:CanShoot() or not weapon or weapon:IsKnife() then return end

                local LeftOffset, RightOffset = GetOffsets()
                if not LeftOffset or not RightOffset then return end

                local MinDamage = gear.MinDamageOverrideEnabled:Get() and gear.MinDamageOverride:Get() or gear.MinDamage:Get()

                GetPlayers(function(entity)
                    if AiPeekLeft and AiPeekRight then return end
                    if not entity then return end
                    if not entity:IsEnemy() or not entity:IsAlive() or entity:IsTeammate() then return end

                    local Hitboxes = {
                        entity:GetHitboxPos(HITBOX_HEAD),
                        entity:GetHitboxPos(HITBOX_NECK),
                        entity:GetHitboxPos(HITBOX_CHEST),
                    }

                    for i = 1, 3 do
                        local hb = Hitboxes[i]
                        if hb then
                            if not AiPeekLeft then
                                local CanHit, LeftDamage = pawn:CanHit(LeftOffset, hb, entity)
                                if LeftDamage and LeftDamage >= MinDamage then
                                    AiPeekLeft = true
                                end
                            end
                            if not AiPeekRight then
                                local CanHit, RightDamage = pawn:CanHit(RightOffset, hb, entity)
                                if RightDamage and RightDamage >= MinDamage then
                                    AiPeekRight = true
                                end
                            end
                            if AiPeekLeft and AiPeekRight then break end
                        end
                    end
                end)

                if (AiPeekLeft or AiPeekRight) and not input.WASDPressed() then
                    AiPeekType = AiPeekLeft and "Left" or "Right"
                    if AiPeekLeft then
                        AiPeekLeftMove:Press()
                    else
                        AiPeekRightMove:Press()
                    end
                end
            end

            if AiPeekReturn then
                if not AiPeekStartedPos then
                    AiPeekRightMove:Release()
                    AiPeekLeftMove:Release()
                    AiPeekReturn = false
                    AiPeekType = nil
                    return
                end

                local CurrentPos = pawn:GetPosition()
                local Dist = CurrentPos:dist_to(AiPeekStartedPos)

                if AiPeekType == "Left" then
                    AiPeekRightMove:Press()
                    if Dist < 5 or input.WASDPressed() then
                        AiPeekRightMove:Release()
                        AiPeekLeftMove:Release()
                        AiPeekReturn = false
                        AiPeekType = nil
                    end
                elseif AiPeekType == "Right" then
                    AiPeekLeftMove:Press()
                    if Dist < 5 or input.WASDPressed() then
                        AiPeekRightMove:Release()
                        AiPeekLeftMove:Release()
                        AiPeekReturn = false
                        AiPeekType = nil
                    end
                end
            end
        end

        function ai_peek:bullet_impact()
            AiPeekReturn = true
        end

        function ai_peek:unload()
            AiPeekLeftMove:Release()
            AiPeekRightMove:Release()
            ClearPositionCircles()
        end
    end

    function rage.createmove(cmd)
        duck_peek_assist:createmove(cmd)
        ai_peek:createmove()
    end

    function rage.bullet_impact()
        ai_peek:bullet_impact()
    end

    function rage.unload()
        ai_peek:unload()
    end
end

local antiaim = {}; do
    local tab = uix.rage

    local manual_aa = {}; do
        local gear = tab.manual_aa.ManualAA

        local Left = false
        local Right = false
        local Off = false

        function manual_aa:paint()
            if not gear:Get() then 
                if not Off then
                    menu.ragebot_anti_aim_base_yaw_offset = DEF_VALUE_AA_YAW
                    Off = true
                end
                return 
            end

            local LeftPressed = gear.Left:Get()
            local RightPressed = gear.Right:Get()

            if LeftPressed and not Left then
                if menu.ragebot_anti_aim_base_yaw_offset == 59 then
                    menu.ragebot_anti_aim_base_yaw_offset = 180
                else
                    menu.ragebot_anti_aim_base_yaw_offset = 59
                end
            elseif RightPressed and not Right then
                if menu.ragebot_anti_aim_base_yaw_offset == -19 then
                    menu.ragebot_anti_aim_base_yaw_offset = 180
                else
                    menu.ragebot_anti_aim_base_yaw_offset = -19
                end
            end

            Left = LeftPressed
            Right = RightPressed
            Off = false
        end
    end

    function antiaim.paint()
        manual_aa:paint()
    end

    function antiaim.unload()
        menu.ragebot_anti_aim_base_yaw_offset = DEF_VALUE_AA_YAW
    end
end

local visuals = {}; do
    local tab = uix.visuals
    local slocal_player = tab.local_player
    local sworld = tab.world

    local local_player = {}; do
        local perspective_options = {}; do
            local gear = slocal_player.general.PerspectiveOptions
            local WasHodingGrenade = false

            function perspective_options:paint()
                if not pawn then return end

                cvars.cam_idealdist:Float(gear.ThirdpersonDistance:Get())

                if gear.ForceThirdpersonInSpectate:Get() then
                    if pawn.m_iHealth <= 0 then
                        exe_cmd("spec_mode 3")
                    end
                end

                if gear.FirstpersonWithUtilities:Get() then
                    local w = pawn:GetActiveWeapon(true)
                    if not w or w == nil or w == 0 then return end
                    local HodingGrenade = (w:find("grenade") or w:find("flash") or w:find("smoke") or w:find("incendiary") or w:find("decoy") or w:find("molotov"))

                    if HodingGrenade and not WasHodingGrenade then
                        menu.misc_thirdperson = false
                    elseif not HodingGrenade and WasHodingGrenade then
                        menu.misc_thirdperson = true
                    end

                    WasHodingGrenade = HodingGrenade
                end
            end

            function perspective_options:unload()
                cvars.cam_idealdist:Float(150)
            end
        end

        local view_options = {}; do
            local gear = slocal_player.general.ViewOptions

            local CurrentFov = 90
            local TargetFov = 90
            local DefZoomFov1 = 40
            local DefZoomFov2 = 15
            local Off = false

            --@param ViewSetup view_setup_t
            function view_options:override_view(ViewSetup)
                if not pawn or not controller then return end
                if not gear:Get() then return end
                
                if not pawn.m_pWeaponServices or not pawn.m_pWeaponServices.m_hActiveWeapon then return end
                local ZoomLevel = pawn.m_pWeaponServices.m_hActiveWeapon.m_zoomLevel

                if not pawn.m_bIsScoped then
                    TargetFov = gear.Fov:Get()
                elseif pawn.m_bIsScoped and not pawn:GetActiveWeapon():IsKnife() then
                    if ZoomLevel == 1 then
                        local Percent = gear.ZoomFov1:Get() / 100
                        TargetFov = DefZoomFov1 + (gear.Fov:Get() - DefZoomFov1) * Percent
                    elseif ZoomLevel == 2 then
                        local Percent = gear.ZoomFov2:Get() / 100
                        TargetFov = DefZoomFov2 + (gear.Fov:Get() - DefZoomFov2) * Percent
                    end
                end

                CurrentFov = CurrentFov + (TargetFov - CurrentFov)
                ViewSetup.fov = CurrentFov
                Off = false
            end
        end

        local model_changer = {}; do
            local gear = slocal_player.model.ModelChanger
            local Off = false

            local CustomPlayerModels = fs.RecursiveScanDirectory(Path.Models, "vmdl_c")
            gear.CustomT:SetItems(CustomPlayerModels)
            gear.CustomCT:SetItems(CustomPlayerModels)

            local function ApplyModel(Unload)
                pcall(function()
                    if not pawn then return end
                    if not pawn:IsAlive() then return end

                    local Team = pawn.m_iTeamNum
                    if Team ~= TEAM_T and Team ~= TEAM_CT then return end

                    if not gear:Get() or gear[Team]:Get() == 1 or Unload then
                        if not Off then
                            local DefaultModel = ternary(Team == TEAM_T and Team ~= TEAM_CT, "agents/models/tm_phoenix/tm_phoenix.vmdl", "agents/models/ctm_sas/ctm_sas.vmdl")
                            pawn:SetModel(DefaultModel)
                            Off = true
                        end
                        return
                    end
                    Off = false

                    local Path = ({
                        [2] = { -- t
                            "",
                            "tm_professional/tm_professional_varj",
                            "tm_professional/tm_professional_vari",
                            "tm_professional/tm_professional_varh",
                            "tm_professional/tm_professional_varg",
                            "tm_professional/tm_professional_varf5",
                            "tm_professional/tm_professional_varf4",
                            "tm_professional/tm_professional_varf3",
                            "tm_professional/tm_professional_varf2",
                            "tm_professional/tm_professional_varf1",
                            "tm_professional/tm_professional_varf",

                            "tm_phoenix/tm_phoenix_varianti",
                            "tm_phoenix/tm_phoenix_varianth",
                            "tm_phoenix/tm_phoenix_variantg",
                            "tm_phoenix/tm_phoenix_variantf",

                            "tm_leet/tm_leet_varianti",
                            "tm_leet/tm_leet_varianth",
                            "tm_leet/tm_leet_variantj",
                            "tm_leet/tm_leet_variantg",
                            "tm_leet/tm_leet_variantf",

                            "tm_jungle_raider/tm_jungle_raider_variantf2",
                            "tm_jungle_raider/tm_jungle_raider_variantf",
                            "tm_jungle_raider/tm_jungle_raider_variante",
                            "tm_jungle_raider/tm_jungle_raider_variantd",
                            "tm_jungle_raider/tm_jungle_raider_variantc",
                            "tm_jungle_raider/tm_jungle_raider_variantb2",
                            "tm_jungle_raider/tm_jungle_raider_variantb",
                            "tm_jungle_raider/tm_jungle_raider_varianta",

                            "tm_balkan/tm_balkan_varianth",
                            "tm_balkan/tm_balkan_variantj",
                            "tm_balkan/tm_balkan_varianti",
                            "tm_balkan/tm_balkan_variantf",
                            "tm_balkan/tm_balkan_variantg",
                            "tm_balkan/tm_balkan_variantk",
                            "tm_balkan/tm_balkan_variantl",
                        },

                        [3] = { -- ct
                            "",
                            "ctm_diver/ctm_diver_varianta",
                            "ctm_diver/ctm_diver_variantb",
                            "ctm_diver/ctm_diver_variantc",

                            "ctm_fbi/ctm_fbi_varianth",
                            "ctm_fbi/ctm_fbi_variantf",
                            "ctm_fbi/ctm_fbi_variantb",
                            "ctm_fbi/ctm_fbi_variantg",

                            "ctm_gendarmerie/ctm_gendarmerie_varianta",
                            "ctm_gendarmerie/ctm_gendarmerie_variantb",
                            "ctm_gendarmerie/ctm_gendarmerie_variantc",
                            "ctm_gendarmerie/ctm_gendarmerie_variantd",
                            "ctm_gendarmerie/ctm_gendarmerie_variante",

                            "ctm_sas/ctm_sas_variantg",
                            "ctm_sas/ctm_sas_variantf",

                            "ctm_st6/ctm_st6_variante",
                            "ctm_st6/ctm_st6_variantg",
                            "ctm_st6/ctm_st6_varianti",
                            "ctm_st6/ctm_st6_variantj",
                            "ctm_st6/ctm_st6_variantk",
                            "ctm_st6/ctm_st6_variantl",
                            "ctm_st6/ctm_st6_variantm",
                            "ctm_st6/ctm_st6_variantn",

                            "ctm_swat/ctm_swat_variante",
                            "ctm_swat/ctm_swat_variantf",
                            "ctm_swat/ctm_swat_variantg",
                            "ctm_swat/ctm_swat_varianth",
                            "ctm_swat/ctm_swat_varianti",
                            "ctm_swat/ctm_swat_variantj",
                            "ctm_swat/ctm_swat_variantk"
                        }
                    })[Team][gear[Team]:Get()]

                    pawn:SetModel(sf("agents/models/%s.vmdl", Path))
                end)
            end
            
            function model_changer:frame_stage_notify()
                ApplyModel(false)
            end

            function model_changer:unload()
                ApplyModel(true)
            end
        end

        local disable_model_anim = {}; do
            local switch = slocal_player.model.DisableModelAnim

            local DisableModelAnimPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC ? 4C 8B 89 ? ? ? ? 33 F6", "DisableModelAnim")

            hooks.CreateHook(DisableModelAnimPattern, function(orig, a1)
                if switch:Get() then
                    return 0
                end

                return orig(a1)
            end, "char(__fastcall*)(__int64)")
        end

        local health_boost_hit_effect = {}; do
            local switch = slocal_player.effects.HealthBoostHitEffect

            function health_boost_hit_effect:player_hurt(event)
                if not switch:Get() then return end
                if not global_vars then return end

                local attacker = event:get_pawn("attacker")
                local userid = event:get_pawn("userid")

                if not attacker or not userid or not pawn then return end
                if attacker ~= pawn or userid == pawn then return end

                pawn.m_flHealthShotBoostExpirationTime = global_vars.m_flCurrentTime + 1.2
            end
        end

        local bullet_impacts = {}; do
            local gear = slocal_player.effects.BulletImpacts

            function bullet_impacts:paint()
                gear.DrawWithoutDots:Visibility(gear.DrawFill:Get())
            end

            function bullet_impacts:bullet_impact(ImpactsPos)
                if not pawn or not gear:Get() then return end

                local Size = gear.Size:Get()
                local Lifetime = gear.Lifetime:Get()
                local Color = color_t(gear.Color:Get().r * 255, gear.Color:Get().g * 255, gear.Color:Get().b * 255, gear.Color:Get().a * 255)

                GetDebugOverlayGameSystem():RenderWithoutDots(gear.DrawWithoutDots:Get())
                GetDebugOverlayGameSystem():AddBoxOverlay(ImpactsPos, vec3_t(-Size, -Size, -Size), vec3_t(Size, Size, Size), vec3_t(0, 0, 0), Color, gear.DrawFill:Get(), Lifetime)
            end
        end
                
        local bullet_tracers = {}; do
            local gear = slocal_player.effects.BulletTracers

            function bullet_tracers:bullet_impact(ImpactsPos)
                if gear:Get() and pawn then
                    local Type = gear.Type:Get()

                    if Type == 1 then
                        particle_system.AddParticle2Point("particles/entity/spectator_utility_trail.vpcf", pawn:GetEyePos(), ImpactsPos, gear.Color:Get(), gear.Lifetime:Get(), gear.Width:Get(), 0.05, 0.95)
                    elseif Type == 2 then
                        particle_system.AddParticle2Point("particles/entity/spectator_utility_trail.vpcf", pawn:GetEyePos(), ImpactsPos, gear.Color:Get(), gear.Lifetime:Get(), gear.Width:Get(), 0.5, 0.3)
                    end
                end
            end
        end

        local shot_effects = {}; do
            local gear = slocal_player.effects.ShotEffects

            function shot_effects:bullet_impact(Pos)
                if not pawn or not controller or not gear:Get() or not Pos then return end

                local Effect = ({
                    {particle = "particles/inferno_fx/explosion_incend_air_falling.vpcf", time = 5},
                    {particle = "particles/explosions_fx/explosion_hegrenade.vpcf", time = 10},
                    {particle = "particles/explosions_fx/explosion_hegrenade_snow.vpcf", time = 10},
                    {particle = "particles/explosions_fx/explosion_basic_water.vpcf", time = 5},
                    {particle = "particles/explosions_fx/explosion_flashbang.vpcf", time = 2.5},
                    {particle = "bin/flowers_s.vpcf", time = 5},
                    {particle = "bin/lightning_s.vpcf", time = 2.5},
                    {particle = "bin/coins_s.vpcf", time = 5},
                })[gear.Effect:Get()]

                local Particle =Effect.particle
                local Time = Effect.time

                particle_system.AddParticle1Point(Particle, Pos, Time)
            end
        end

        local trails = {}; do
            local gear = slocal_player.effects.Trails

            local ActiveMTrails = {}
            local LastMTUpdate = 0

            function ClearTrails()
                for n, id in ipairs(ActiveMTrails) do
                    if id and global_vars then
                        id:DestroyParticle()
                        table.remove(ActiveMTrails, n)
                    end
                end
            end

            function trails:paint()
                gear.Delay:Visibility(true)

                if not pawn or not global_vars or not gear:Get() then 
                    ClearTrails()
                    return 
                end

                if gear.Type:Get() == 1 then
                    if global_vars.m_flCurrentTime - LastMTUpdate >= gear.Delay:Get() / 10 then
                        local Pos = pawn:GetPosition()
                        local Index = particle_system.AddParticle1Point("particles/money_fx/money_burst_money_single.vpcf", Pos, 5)

                        table.insert(ActiveMTrails, Index)
                        LastMTUpdate = global_vars.m_flCurrentTime
                    end
                end
            end
        end

        local jump_circles = {}; do
            local gear = slocal_player.effects.JumpCircles

            local ActiveCircles = {}
            local JumpPositions = {}
            local WasJumping = false
            local MaxJumps = 30
            local MaxCircles = 20

            local function ClearJumpCircles()
                for i = #ActiveCircles, 1, -1 do
                    local Index = ActiveCircles[i].id
                    if Index then 
                        Index:DestroyParticle()
                    end
                end
                ActiveCircles = {}
                JumpPositions = {}
            end

            function jump_circles:paint()
                if not pawn or not global_vars then return end
                if not gear:Get() or not pawn:IsAlive() then 
                    ClearJumpCircles()
                    return 
                end
                
                local Now = global_vars.m_flCurrentTime
                local Lifetime = gear.Lifetime:Get()
                
                for i = #ActiveCircles, 1, -1 do
                    if Now - ActiveCircles[i].time >= Lifetime then
                        local Index = ActiveCircles[i].id
                        if Index then 
                            Index:DestroyParticle()
                        end
                        table.remove(ActiveCircles, i)
                    end
                end
                
                local IsJumping = bit.band(pawn.m_fFlags, 1) == 0
                local Pos = pawn:GetPosition()
                
                for i = #JumpPositions, 1, -1 do
                    if Now - JumpPositions[i].time >= Lifetime then
                        table.remove(JumpPositions, i)
                    end
                end
                
                while #JumpPositions > MaxJumps do
                    table.remove(JumpPositions, 1)
                end
                
                if IsJumping and not WasJumping then
                    table.insert(JumpPositions, {pos = Pos, time = Now})
                end
                
                WasJumping = IsJumping
                
                while #ActiveCircles > MaxCircles do
                    local oldest = table.remove(ActiveCircles, 1)
                    local Index = oldest.id
                    if Index then 
                        Index:DestroyParticle()
                    end
                end
                
                for _, jump in ipairs(JumpPositions) do
                    local already_exists = false
                    for _, circle in ipairs(ActiveCircles) do
                        if circle.pos and circle.pos.x == jump.pos.x and 
                        circle.pos.y == jump.pos.y and 
                        circle.pos.z == jump.pos.z then
                            already_exists = true
                            break
                        end
                    end
                    
                    if not already_exists then
                        local Id = particle_system.AddParticleCircle("particles/entity/spectator_utility_trail.vpcf", jump.pos, gear.Radius:Get(), 
                            gear.Color:Get(), gear.Width:Get(), Lifetime)       
                        if Id then
                            table.insert(ActiveCircles, {id = Id, time = Now, pos = jump.pos})
                        end
                    end
                end
            end

            function jump_circles:unload()
                ClearJumpCircles()
            end
        end

        local scope_overlay = {}; do
            local gear = slocal_player.overlay.ScopeOverlay

            local LineLength = 350
            local PointLength = 20
            local AspectRatio = 0
            local Gap = 30
            local LastTime = 0
            local Alpha = 0

            local ScopeOverlayPattern = FindPattern("client.dll", "48 8B C4 53 57 48 83 EC ? 48 8B FA", "ScopeOverlay")
            hooks.CreateHook(ScopeOverlayPattern, function(original, a1, a2)
                local result = original(a1, a2)

                if pawn and pawn.m_bIsScoped and gear:Get() and a2 then
                    ffi.cast("unsigned char*", a2)[4] = 0
                end

                return result
            end, "void(__fastcall*)(void*, void*)")

            function scope_overlay:under_gui()
                Override("misc_removals", gear:Get() and bit.band(menu.misc_removals, bit.bnot(REMOVALS_SCOPE_BORDERS)) or nil)
                if not pawn or not pawn:IsAlive() or not controller or not gear:Get() or not (gear.TargetLines:Get(1) and gear.TargetLines:Get(2) and gear.TargetLines:Get(3) and gear.TargetLines:Get(4)) then return end

                local Screen = render.screen_size()
                if not Screen then return end

                local Scoped = pawn.m_bIsScoped
                
                local dt = math.min(os.clock() - LastTime, 0.033)
                if not dt or dt <= 0 then return end

                LastTime = os.clock()
                
                local AnimSpeed = gear.AnimationSpeed:Get()
                local TargetGap = gear.LinesDistance:Get()
                local TargetLength = gear.LinesSize:Get()
                local TargetGradient = gear.GradientSize:Get()
                local TargetAspectRatio = gear.AspectRatio:Get()
                
                Gap = Gap + (TargetGap - Gap) * dt * AnimSpeed
                LineLength = LineLength + (TargetLength - LineLength) * dt * AnimSpeed
                PointLength = PointLength + (TargetGradient - PointLength) * dt * AnimSpeed
                AspectRatio = AspectRatio + (TargetAspectRatio - AspectRatio) * dt * AnimSpeed
                
                Alpha = Alpha + ((Scoped and 1 or 0) - Alpha) * dt * AnimSpeed
                
                if Alpha < 0.01 then return end
                
                local CenterX, CenterY = Screen.x / 2, Screen.y / 2
                local Mult = Screen.y / 1080
                
                local BaseLen = (LineLength * 10) * Mult * Alpha
                local ArMult = 1 + (AspectRatio > 0 and (AspectRatio / 100) * 2 or 0)
                local GradLen = PointLength * Mult
                
                local Gap = Gap * Mult * Alpha
                
                local function Color(a)
                    return color_t(gear.Color:Get().r, gear.Color:Get().g, gear.Color:Get().b, gear.Color:Get().a * Alpha * a)
                end
                
                local function DrawHorizontalScopeLine(sx, ex, y, GradMult)
                    local a, b = math.min(sx, ex), math.max(sx, ex)
                    local Pixels = b - a
                    if Pixels <= 1 then return end
                    
                    local GradLenAdj = GradLen * GradMult
                    local FullColor = Color(1)
                    
                    if GradLenAdj < 2 or GradLenAdj >= Pixels / 2 then
                        if FullColor.a > 0 then
                            render.rect_filled(vec2_t(a, y), vec2_t(b, y + 1), FullColor)
                        end
                        return
                    end
                    
                    for p = 0, math.min(GradLenAdj - 1, Pixels - 1) do
                        local c = Color(p / GradLenAdj)
                        if c.a > 0 then
                            render.rect_filled(vec2_t(a + p, y), vec2_t(a + p + 1, y + 1), c)
                        end
                    end
                    
                    if Pixels > GradLenAdj * 2 then
                        render.rect_filled(vec2_t(a + GradLenAdj - 1, y), vec2_t(b - GradLenAdj, y + 1), FullColor)
                    end
                    
                    for p = Pixels - GradLenAdj, Pixels - 1 do
                        local c = Color((Pixels - p) / GradLenAdj)
                        if c.a > 0 then
                            render.rect_filled(vec2_t(a + p, y), vec2_t(a + p + 1, y + 1), c)
                        end
                    end
                end
                
                local function DrawVerticalScopeLine(sy, ey, x, GradMult)
                    local a, b = math.min(sy, ey), math.max(sy, ey)
                    local Pixels = b - a
                    if Pixels <= 1 then return end
                    
                    local GradLenAdj = GradLen * GradMult
                    local FullColor = Color(1)
                    
                    if GradLenAdj < 2 or GradLenAdj >= Pixels / 2 then
                        if FullColor.a > 0 then
                            render.rect_filled(vec2_t(x, a), vec2_t(x + 1, b), FullColor)
                        end
                        return
                    end
                    
                    for p = 0, math.min(GradLenAdj - 1, Pixels - 1) do
                        local c = Color(p / GradLenAdj)
                        if c.a > 0 then
                            render.rect_filled(vec2_t(x, a + p), vec2_t(x + 1, a + p + 1), c)
                        end
                    end
                    
                    if Pixels > GradLenAdj * 2 then
                        render.rect_filled(vec2_t(x, a + GradLenAdj - 1), vec2_t(x + 1, b - GradLenAdj), FullColor)
                    end
                    
                    for p = Pixels - GradLenAdj, Pixels - 1 do
                        local c = Color((Pixels - p) / GradLenAdj)
                        if c.a > 0 then
                            render.rect_filled(vec2_t(x, a + p), vec2_t(x + 1, a + p + 1), c)
                        end
                    end
                end
                
                if gear.TargetLines:Get(1) then
                    DrawVerticalScopeLine(math.floor(CenterY - Gap), math.floor(CenterY - Gap - BaseLen), math.floor(CenterX), 1)
                end
                if gear.TargetLines:Get(2) then
                    DrawVerticalScopeLine(math.floor(CenterY + Gap), math.floor(CenterY + Gap + BaseLen), math.floor(CenterX), 1)
                end
                if gear.TargetLines:Get(3) then
                    DrawHorizontalScopeLine(math.floor(CenterX - Gap), math.floor(CenterX - Gap - BaseLen * ArMult), math.floor(CenterY), ArMult)
                end
                if gear.TargetLines:Get(4) then
                    DrawHorizontalScopeLine(math.floor(CenterX + Gap), math.floor(CenterX + Gap + BaseLen * ArMult), math.floor(CenterY), ArMult)
                end
            end
        end

        local glow = {}; do
            local gear = slocal_player.glow.Glow

            local IsGlowingPattern = FindRelative("client.dll", "E8 ? ? ? ? 41 3B C4 74", "IsGlowing", 1, 0)

            hooks.CreateHook(IsGlowingPattern, function(orig, a1)
                if pawn and engine.camera_in_thirdperson() and pawn.m_iHealth > 0 then
                    pawn.m_Glow.m_glowColorOverride = gear.Color:Get()
                    pawn.m_Glow.m_bGlowing = gear:Get()
                end

                return orig(a1)
            end, "bool(__fastcall*)(void*)")
        end

        local dlights = {}; do
            local gear = slocal_player.dlights.DLights

            ffi.cdef([[
                typedef struct CDynamicLights {
                    char pad[4];        // 0x00
                    Vector Position;    // 0x04, 0x08, 0x0C
                    float Radius;       // 0x10
                    uint32_t Color;     // 0x14
                    float Lifetime;     // 0x18
                    float Exponent;     // 0x1C
                } CDynamicLights;
            ]])

            local DlightManagerPattern = FindAbsolute("client.dll", "48 8B 0D ? ? ? ? BA ? ? ? ? E8 ? ? ? ? ? ? 48 8B F8", "DlightManager", 3, 0)
            local GetDlightIdxPattern = FindPattern("client.dll", "48 89 5C 24 ? 48 89 6C 24 ? 48 89 74 24 ? 57 48 83 EC ? 41 8B D8 48 8D B9", "GetDlightIdx")

            local DlightManager = ffi.cast("void***", DlightManagerPattern)[0]
            local fnGetDlightIdx = ffi.cast("CDynamicLights*(__fastcall*)(void*, uint32_t, int32_t)", GetDlightIdxPattern)

            local LastErrorTime = 0

            function dlights:paint()
                if not pawn or not DlightManager or not global_vars or not gear:Get() then return end
                if bit32.band(menu.misc_removals, REMOVALS_LIGHTING) ~= 0 then
                    if global_vars.m_flCurrentTime - LastErrorTime > 1 then
                        log():SetAllPrefix("Error | "):SetPrefixColor(color_t(1, 0, 0, 1)):Send(ALL, PREFIX, "Please, Disable Light Removal!")
                        LastErrorTime = global_vars.m_flCurrentTime
                    end
                    return
                end

                local Position = pawn:GetPosition()
                if not Position then return end
                
                local DLight = fnGetDlightIdx(DlightManager, 1, 0)
                if not DLight then return end
                
                local Color = gear.Color:Get()
                local r, g, b, a = Color.r * 255, Color.g * 255, Color.b * 255, Color.a * 255

                DLight.Position.x = Position.x
                DLight.Position.y = Position.y
                DLight.Position.z = Position.z + gear.ZOffset:Get()
                DLight.Radius = gear.Radius:Get() * 100
                DLight.Color = bit.bor(r, bit.lshift(g, 8), bit.lshift(b, 16), bit.lshift(a, 24))
                DLight.Lifetime = global_vars.m_flCurrentTime
                DLight.Exponent = 42.0
            end
        end

        local wetness_effect = {}; do
            local gear = slocal_player.wetness.WetnessEffect

            local Timer = 0
            local LastTime = 0

            function wetness_effect:paint()
                if not gear:Get() then
                    shader.Remove("rain_exposure_to_sky")
                    shader.Remove("rain_wetness")
                    shader.Remove("rain_timer")
                    LastTime = global_vars.m_flCurrentTime
                    return
                end

                local Now = global_vars.m_flCurrentTime
                local dt = Now - LastTime
                LastTime = Now

                if dt > 0 and dt < 1.0 then
                    Timer = Timer + dt * (gear.Speed:Get() / 100.0)
                end

                shader.Set("rain_exposure_to_sky", 1.0)
                shader.Set("rain_wetness", gear.Density:Get() * 2 / 100.0)
                shader.Set("rain_timer", Timer)
            end

            function wetness_effect:unload()
                shader.Remove("rain_exposure_to_sky")
                shader.Remove("rain_wetness")
                shader.Remove("rain_timer")
            end
        end

        function local_player:paint()
            perspective_options:paint()
            trails:paint()
            jump_circles:paint()
            dlights:paint()
            bullet_impacts:paint()
            wetness_effect:paint()
        end

        function local_player:under_gui()
            scope_overlay:under_gui()
        end

        function local_player:player_hurt(event)
            health_boost_hit_effect:player_hurt(event)
        end

        function local_player:bullet_impact(ImpactsPos)
            shot_effects:bullet_impact(ImpactsPos)
            bullet_impacts:bullet_impact(ImpactsPos)
            bullet_tracers:bullet_impact(ImpactsPos)
        end

        function local_player:frame_stage_notify(stage)
            if stage == FRAME_RENDER_END then
                model_changer:frame_stage_notify()
            end
        end

        function local_player:override_view(view)
            view_options:override_view(view)
        end

        function local_player:unload()
            perspective_options:unload()
            model_changer:unload()
            jump_circles:unload()
            wetness_effect:unload()
        end
    end

    local world = {}; do
        local disable_post_processing = {}; do
            local switch = sworld.screen.DisablePostProcessing

            function disable_post_processing:paint()
                cvars.r_csgo_postprocess_enable:Bool(not switch:Get())
            end

            function disable_post_processing:unload()
                cvars.r_csgo_postprocess_enable:Bool(true)
            end
        end

        local fullbright = {}; do
            local switch = sworld.general.Fullbright

            function fullbright:paint()
                cvars.mat_fullbright:Bool(switch:Get())
            end

            function fullbright:unload()
                cvars.mat_fullbright:Bool(false)
            end
        end

        local exposure = {}; do
            local gear = sworld.screen.Exposure

            function exposure:paint()
                post_process.SetExposure(ternary(gear:Get(), gear.Value:Get(), 100))
            end

            function exposure:unload()
                post_process.SetExposure(100)
            end
        end

        local gamma = {}; do
            local gear = sworld.screen.Gamma

            function gamma:paint()
                cvars.r_fullscreen_gamma:Float(ternary(gear:Get(), gear.Value:Get(), DEF_VALUE_GAMMA))
            end

            function gamma:unload()
                cvars.r_fullscreen_gamma:Float(DEF_VALUE_GAMMA)
            end
        end

        local dof_override = {}; do
            local gear = sworld.general.DoFOverride

            function dof_override:paint()
                cvars.r_dof_override:Bool(gear:Get())
                cvars.r_dof_override_near_blurry:Float(ternary(gear:Get(), gear.NearBlurry:Get(), 0))
                cvars.r_dof_override_far_blurry:Float(ternary(gear:Get(), gear.FarBlurry:Get(), 180))
                cvars.r_dof_override_near_crisp:Float(ternary(gear:Get(), gear.NearCrisp:Get(), 2000))
                cvars.r_dof_override_far_crisp:Float(ternary(gear:Get(), gear.FarCrisp:Get(), -100))
            end

            function dof_override:unload()
                cvars.r_dof_override:Bool(false)
                cvars.r_dof_override_near_blurry:Float(0)
                cvars.r_dof_override_far_blurry:Float(180)
                cvars.r_dof_override_near_crisp:Float(2000)
                cvars.r_dof_override_far_crisp:Float(-100)
            end
        end

        local fog_override = {}; do
            local gear = sworld.general.FogOverride

            function fog_override:paint()
                if not pawn then return end

                local CameraServices = pawn.m_pCameraServices
                if not CameraServices then return end

                local CurrentFog = CameraServices.m_CurrentFog
                if not CurrentFog then return end

                CurrentFog.enable = gear:Get()
                CurrentFog.maxdensity = gear.MaxDensity:Get() / 100
                CurrentFog.HDRColorScale = 1
                CurrentFog.start = gear.Start:Get()
                CurrentFog["end"] = gear.End:Get()
                CurrentFog.colorPrimary = gear.Color:Get()
                CurrentFog.colorSecondary = gear.Color:Get()
                CurrentFog.exponent = gear.Exponent:Get() / 10

                local Skybox3dFog = pawn.m_skybox3d.fog

                Skybox3dFog.enable = gear:Get()
                Skybox3dFog.maxdensity = gear.MaxDensity:Get() / 100
                Skybox3dFog.HDRColorScale = 1
                Skybox3dFog.start = gear.Start:Get()
                Skybox3dFog["end"] = gear.End:Get()
                Skybox3dFog.colorPrimary = gear.Color:Get()
                Skybox3dFog.colorSecondary = gear.Color:Get()
                Skybox3dFog.exponent = gear.Exponent:Get() / 10
            end
        end

        local removals = {}; do
            local gear = sworld.removals.Removals

            local DrawMolotovPattern = FindPattern("client.dll", "40 53 55 57 48 81 EC ? ? ? ? 48 8D 05", "DrawMolotov")
            hooks.CreateHook(DrawMolotovPattern, function(orig, a1)
                if gear:Get() and gear.Remove:Get(2) then
                    return ffi.cast("void*", 0)
                end

                return orig(a1)
            end, "void*(__fastcall*)(void*)")

            function removals:paint()
                cvars.r_drawworld:Bool(not gear:Get() or not gear.Remove:Get(1))
                cvars.r_drawskybox:Bool(not gear:Get() or not gear.Remove:Get(3))
            end

            function removals:unload()
                cvars.r_drawskybox:Bool(true)
                cvars.r_drawworld:Bool(true)
                cvars.r_draw3dskybox:Bool(true)
            end
        end

        local world_effects = {}; do
            local gear = sworld.effects.WorldEffects

            local Id1, Id2 = nil, nil
            local LastWorldEffect = -1
            local LastWorldEffectRoundTime = -1

            local function CalculatePosition(PlayerPos)
                local s = gear.Effect:Get() == 3 or gear.Effect:Get() == 4 or gear.Effect:Get() == 6

                if not s then
                    return PlayerPos
                else
                    return vec3_t(PlayerPos.x - 500, PlayerPos.y, PlayerPos.z + 70)
                end
            end

            local function ClearWorldEffects()
                if Id1 then
                    Id1:DestroyParticle()
                    Id1 = nil
                end
                
                if Id2 then
                    Id2:DestroyParticle()
                    Id2 = nil
                end
            end

            function world_effects:paint()
                if not pawn or not gamerules then return end

                local ColorVis = gear.Effect:Get() ~= 3 and gear.Effect:Get() ~= 4 and gear.Effect:Get() ~= 6
                local DensityVis = gear.Effect:Get() ~= 2 and gear.Effect:Get() ~= 3 and gear.Effect:Get() ~= 6 and gear.Effect:Get() ~= 7

                gear.Color:Visibility(ternary(ColorVis, true, false))
                gear.Density:Visibility(ternary(DensityVis, true, false))

                if not gear:Get() or not pawn:IsAlive() then
                    if Id1 or Id2 then
                        ClearWorldEffects()
                        LastWorldEffect = -1
                        LastWorldEffectRoundTime = -1
                    end
                    return 
                end
                
                local CurrentWorldEffectRoundTime = gamerules.m_fRoundStartTime
                local CurrentWorldEffect = gear.Effect:Get()
                local PlayerPos = pawn:GetPosition()

                if LastWorldEffect ~= CurrentWorldEffect or LastWorldEffectRoundTime ~= CurrentWorldEffectRoundTime then
                    ClearWorldEffects()
                    LastWorldEffect = CurrentWorldEffect
                    LastWorldEffectRoundTime = CurrentWorldEffectRoundTime

                    local Effect = ({
                        {"bin/snow_s.vpcf"},
                        {"bin/snow_s1.vpcf"},
                        {"bin/econ_snow.vpcf"},
                        {"bin/snow_s2.vpcf"},
                        {"bin/ash_s1.vpcf", "bin/ash_s2.vpcf"},
                        {"bin/econ_weather_ash.vpcf", "bin/econ_weather_ash_b.vpcf"},
                        {"bin/rain_s.vpcf"},
                        {"bin/stars_s.vpcf"}
                    })[CurrentWorldEffect]
                    
                    Id1 = particle_system.CreateParticle(Effect[1]) or nil
                    Id2 = particle_system.CreateParticle(Effect[2]) or nil
                end
            
                if Id1 then
                    Id1:SetPosition(CalculatePosition(PlayerPos)):SetColor(gear.Color:Get()):SetDensity(gear.Density:Get() * 5)
                end
                
                if Id2 then
                    Id2:SetPosition(CalculatePosition(PlayerPos)):SetColor(gear.Color:Get()):SetDensity(gear.Density:Get() * 5)
                end
            end

            function world_effects:unload()
                ClearWorldEffects()
            end
        end

        local kill_effects = {}; do
            local gear = sworld.effects.KillEffects

            function kill_effects:player_death(event)
                if not event or not gear:Get() then return end

                local attacker = event:get_pawn("attacker")
                local victim = event:get_pawn("userid")
                
                if not pawn or not victim or not attacker then return end
                if attacker ~= pawn or attacker == victim then return end
                if victim.m_iTeamNum == attacker.m_iTeamNum then return end

                local Effect = ({
                    "particles/explosions_fx/explosion_c4_500.vpcf",
                    "particles/explosions_fx/explosion_hegrenade.vpcf",
                    "particles/explosions_fx/explosion_hegrenade_snow.vpcf",
                    "particles/inferno_fx/explosion_incend_air_falling.vpcf",
                    "particles/explosions_fx/explosion_basic_water.vpcf",
                    "particles/explosions_fx/explosion_flashbang.vpcf",
                    "bin/flowers_s.vpcf",
                    "bin/lightning_s.vpcf",
                    "particles/critters/chicken/chicken_gone_feathers_fire.vpcf",
                    "bin/coins_s.vpcf",
                    "bin/tombstone_s.vpcf",
                    "bin/sakura_pink.vpcf",
                    "bin/sakura_red.vpcf",
                    "bin/sakura_purple.vpcf",
                    "bin/sakura_white.vpcf",
                    "bin/sakura_blue.vpcf",
                    "bin/sakura_grey.vpcf",
                    "particles/blood_impact/impact_taser_bodyfx.vpcf",
                })[gear.Effect:Get()]

                victim:PlayEffect(Effect)
            end
        end

        local grenades = {}; do
            local group = sworld.grenades

            local grenade_esp = {}; do
                local gear = group.GrenadeESP

                local m_firePositions = engine.get_netvar_offset("client.dll", "C_Inferno", "m_firePositions")

                local function ConvexHull(Points)
                    if #Points <= 1 then return Points end
                    
                    table.sort(Points, function(a, b)
                        return a.x < b.x or (a.x == b.x and a.y < b.y)
                    end)
                    
                    local Lower = {}
                    for _, p in ipairs(Points) do
                        while #Lower >= 2 do
                            local a = Lower[#Lower-1]
                            local b = Lower[#Lower]
                            if (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x) <= 0 then
                                table.remove(Lower)
                            else
                                break
                            end
                        end
                        table.insert(Lower, p)
                    end
                    
                    local Upper = {}
                    for i = #Points, 1, -1 do
                        local p = Points[i]
                        while #Upper >= 2 do
                            local a = Upper[#Upper-1]
                            local b = Upper[#Upper]
                            if (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x) <= 0 then
                                table.remove(Upper)
                            else
                                break
                            end
                        end
                        table.insert(Upper, p)
                    end
                    
                    for i = 2, #Upper - 1 do
                        table.insert(Lower, Upper[i])
                    end
                    
                    return Lower
                end

                local function DrawSmoke(Entity, Color)
                    if not Entity or not Color or not pawn then return end

                    local Center = ffi.cast("Vector*", Entity.m_vSmokeDetonationPos)
                    if not Center then return end

                    local Pos = vec3_t(Center[0].x, Center[0].y, Center[0].z)
                    if not Pos then return end

                    local Radius = 175
                    render.circle_3d(Pos, Radius, Color, 1)
                    render.circle_filled_3d(Pos, Radius, color_t(Color.r, Color.g, Color.b, Color.a * 0.5))
                end

                local function DrawMolotov(Entity, Color)
                    if not Entity or not Color then return end
                    
                    local Count = Entity.m_fireCount
                    if not Count or Count <= 0 then return end

                    local Burning = Entity.m_bFireIsBurning
                    local Positions = ffi.cast("float*", Entity[m_firePositions])

                    if not Burning or not Positions then return end

                    local ScreenPoints = {}
                    
                    for i = 0, Count - 1 do
                        if Burning[i] then
                            local x = Positions[i*3]
                            local y = Positions[i*3+1]
                            local z = Positions[i*3+2]

                            if x and y and z then
                                if math.abs(x) > 0.1 then
                                    local Segments = 32
                                    for Angle = 0, 360 - (360/Segments), 360/Segments do
                                        local rad = math.rad(Angle)
                                        local px = x + math.cos(rad) * 80
                                        local py = y + math.sin(rad) * 80
                                        
                                        local Screen = render.world_to_screen(vec3_t(px, py, z))
                                        if Screen then
                                            table.insert(ScreenPoints, {x = Screen.x, y = Screen.y})
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if #ScreenPoints < 3 then return end

                    local Hull = ConvexHull(ScreenPoints)
                    local HullVec = {}
                    
                    for _, p in ipairs(Hull) do
                        table.insert(HullVec, vec2_t(p.x, p.y))
                    end

                    render.concave_polygon(HullVec, color_t(Color.r, Color.g, Color.b, Color.a * 0.5))
                    render.poly_line(HullVec, Color, 2)
                end
                
                function grenade_esp:under_gui()
                    gear.SmokeColor:Visibility(gear.SmokeRadius:Get())
                    gear.MolotovColor:Visibility(gear.MolotovRadius:Get())

                    if not pawn then return end
                    
                    GetEntities("C_SmokeGrenadeProjectile", function(ent)
                        if not ent or not ent.m_bDidSmokeEffect or not ent.m_bSmokeEffectSpawned or not gear.SmokeRadius:Get() then return end
                        DrawSmoke(ent, gear.SmokeColor:Get())
                    end)

                    GetEntities("C_Inferno", function(ent)
                        if not ent or not gear.MolotovRadius:Get() then return end
                        DrawMolotov(ent, gear.MolotovColor:Get())
                    end)
                end
            end
            
            local custom_smoke_color = {}; do
                local gear = group.CustomSmokeColor

                function custom_smoke_color:paint()
                    if not gear:Get() then return end
                    
                    GetEntities("C_SmokeGrenadeProjectile", function(ent)
                        if not ent then return end
                        ent.m_vSmokeColor = vec3_t(gear.Color:Get().r, gear.Color:Get().g, gear.Color:Get().b)
                    end)
                end
            end
            
            local flying_grenade_icons = {}; do
                local gear = group.FlyingGrenadeIcons

                local function DrawIcon(Entity, Letter)
                    if not Entity or not Letter or not init.GrenadeIcons then return end

                    local PositionVec3 = Entity:GetPosition()
                    if not PositionVec3 then return end

                    local PositionVec2 = render.world_to_screen(PositionVec3)
                    if not PositionVec2 then return end

                    PositionVec2.x = PositionVec2.x - 10
                    PositionVec2.y = PositionVec2.y - 10

                    render.text(Letter, init.GrenadeIcons, PositionVec2, color_t(1, 1, 1, 1))
                end

                function flying_grenade_icons:under_gui()
                    if not pawn or not gear:Get() then return end
                    
                    GetEntities("C_SmokeGrenadeProjectile", function(ent)
                        if not ent or ent.m_bDidSmokeEffect or ent.m_bSmokeEffectSpawned then return end
                        DrawIcon(ent, ICON_SMOKE)
                    end)

                    GetEntities("C_FlashbangProjectile", function(ent)
                        if not ent then return end
                        DrawIcon(ent, ICON_FLASH)
                    end)
                    
                    GetEntities("C_HEGrenadeProjectile", function(ent)
                        if not ent or ent.m_bExplodeEffectBegan then return end
                        DrawIcon(ent, ICON_HE)
                    end)

                    GetEntities("C_MolotovProjectile", function(ent)
                        if not ent then return end
                        DrawIcon(ent, ICON_MOLOTOV)
                    end)

                    GetEntities("C_DecoyProjectile", function(ent)
                        if not ent then return end
                        DrawIcon(ent, ICON_DECOY)
                    end)
                end
            end
            
            local grenade_trails = {}; do
                local gear = group.GrenadeTrails

                function grenade_trails:paint()
                    cvars.sv_grenade_trajectory_prac_trailtime:Float(ternary(gear:Get(), 5, 0))
                end
            end

            function grenades:paint()
                custom_smoke_color:paint()
                grenade_trails:paint()
            end

            function grenades:under_gui()
                grenade_esp:under_gui()
                flying_grenade_icons:under_gui()
            end
        end

        local wind = {}; do
            local gear = sworld.general.Wind

            local function clamp(v, lo, hi)
                if v < lo then return lo end
                if v > hi then return hi end
                return v
            end

            function wind:paint()
                if not gear:Get() then
                    shader.Remove("wind_direction")
                    shader.Remove("wind_strength_frequency")
                    return
                end

                local Strength = clamp(gear.Strength:Get(), 0.0, 10.0)

                shader.Set("wind_direction", 1.0, 0.0, 0.0, 0.0)
                shader.Set("wind_strength_frequency", Strength, Strength, Strength, Strength)
            end

            function wind:unload()
                shader.Remove("wind_direction")
                shader.Remove("wind_strength_frequency")
            end
        end

        function world:paint()
            disable_post_processing:paint()
            fullbright:paint()
            exposure:paint()
            gamma:paint()
            dof_override:paint()
            fog_override:paint()
            world_effects:paint()
            grenades:paint()
            removals:paint()
            wind:paint()
        end

        function world:under_gui()
            grenades:under_gui()
        end

        function world:player_death(event)
            kill_effects:player_death(event)
        end

        function world:unload()
            world_effects:unload()
            disable_post_processing:unload()
            fullbright:unload()
            exposure:unload()
            gamma:unload()
            dof_override:unload()
            removals:unload()
            wind:unload()
        end
    end

    function visuals.paint()
        local_player:paint()
        world:paint()
    end

    function visuals.under_gui()
        local_player:under_gui()
        world:under_gui()
    end

    function visuals.player_hurt(event)
        local_player:player_hurt(event)
    end

    function visuals.player_death(event)
        world:player_death(event)
    end

    function visuals.bullet_impact(ImpactsPos)
        local_player:bullet_impact(ImpactsPos)
    end

    function visuals.frame_stage_notify(stage)
        local_player:frame_stage_notify(stage)
    end

    function visuals.override_view(view)
        local_player:override_view(view)
    end

    function visuals.unload()
        local_player:unload()
        world:unload()
    end
end

local misc = {}; do
    local tab = uix.misc

    local clantag = {}; do
        local gear = tab.general.ClanTag

        local function Unicode8(cp)
            if cp < 0x80 then return string.char(cp)
            elseif cp < 0x800 then return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + (cp % 0x40))
            elseif cp < 0x10000 then return string.char(0xE0 + math.floor(cp / 0x1000), 0x80 + math.floor((cp % 0x1000) / 0x40), 0x80 + (cp % 0x40))
            else return string.char(0xF0 + math.floor(cp / 0x40000), 0x80 + math.floor((cp % 0x40000) / 0x1000), 0x80 + math.floor((cp % 0x1000) / 0x40), 0x80 + (cp % 0x40)) end
        end

        local function bmm(us, ls, ds)
            local m = {}
            if us then for i = 0, 25 do m[65 + i] = Unicode8(us + i) end end
            if ls then for i = 0, 25 do m[97 + i] = Unicode8(ls + i) end end
            if ds then for i = 0, 9 do m[48 + i] = Unicode8(ds + i) end end
            return m
        end

        local FM = {}
        FM[0] = nil -- Normal
        FM[1] = bmm(0x1D400, 0x1D41A, 0x1D7CE) -- Bold
        FM[2] = bmm(0x1D434, 0x1D44E, nil) -- Italic
        FM[3] = bmm(0x1D468, 0x1D482, nil) -- Bold Italic
        FM[4] = bmm(0x1D504, 0x1D51E, nil) -- Fraktur
        FM[5] = bmm(0x1D56C, 0x1D586, nil) -- Bold Fraktur
        FM[6] = bmm(0x1D538, 0x1D552, 0x1D7D8) -- Double-Struck
        FM[7] = bmm(0x1D670, 0x1D68A, 0x1D7F6) -- Monospace
        FM[8] = bmm(0x1D4D0, 0x1D4EA, nil) -- Script Bold
        FM[9] = bmm(0x1D49C, 0x1D4B6, nil) -- Script Light
        
        do
            local m = {}
            for i = 0, 25 do m[65 + i] = Unicode8(0x24B6 + i); m[97 + i] = Unicode8(0x24D0 + i) end
            FM[10] = m -- Circled
        end
        
        do
            local sc = "ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ"
            local m = {}
            local p = 1
            for i = 0, 25 do
                local b = sc:byte(p)
                local l = 1
                if b >= 0xF0 then l = 4 elseif b >= 0xE0 then l = 3 elseif b >= 0xC0 then l = 2 end
                m[97 + i] = sc:sub(p, p + l - 1)
                m[65 + i] = sc:sub(p, p + l - 1)
                p = p + l
            end
            FM[11] = m -- Small Caps
        end
        
        do
            local m = {}
            local s = Unicode8(0x0336)
            for i = 0, 25 do m[65 + i] = string.char(65 + i) .. s; m[97 + i] = string.char(97 + i) .. s end
            for i = 0, 9 do m[48 + i] = string.char(48 + i) .. s end
            FM[12] = m -- Strikethrough
        end
        
        do
            local m = {}
            local s = Unicode8(0x0332)
            for i = 0, 25 do m[65 + i] = string.char(65 + i) .. s; m[97 + i] = string.char(97 + i) .. s end
            for i = 0, 9 do m[48 + i] = string.char(48 + i) .. s end
            FM[13] = m -- Underline
        end
        
        do
            local m = {}
            local s = Unicode8(0x0308)
            for i = 0, 25 do m[65 + i] = string.char(65 + i) .. s; m[97 + i] = string.char(97 + i) .. s end
            FM[14] = m -- Diaeresis
        end
        
        do
            local m = {}
            for i = 0, 25 do m[65 + i] = Unicode8(0xFF21 + i); m[97 + i] = Unicode8(0xFF41 + i) end
            for i = 0, 9 do m[48 + i] = Unicode8(0xFF10 + i) end
            FM[15] = m -- Fullwidth
        end

        local function ApplyFont(text, style)
            if style == 0 or not FM[style] then return text end
            local font = FM[style]
            local result = {}
            for i = 1, #text do
                local byte = text:byte(i)
                if font[byte] then
                    result[i] = font[byte]
                else
                    result[i] = text:sub(i, i)
                end
            end
            return table.concat(result)
        end

        local function BuildFrames(text, mode)
            if not text or text == "" then return {""} end
            local chars = {}
            for i = 1, #text do chars[i] = text:sub(i, i) end
            local len = #chars
            local frames = {}
            local cur = "_"

            if mode == 0 then -- <--
                for i = 0, len - 1 do
                    local f = {}
                    for j = 1, len do
                        f[j] = chars[((i + j - 1) % len) + 1]
                    end
                    frames[#frames + 1] = table.concat(f)
                end
            elseif mode == 1 then -- -->
                for i = 0, len - 1 do
                    local f = {}
                    for j = 1, len do
                        f[j] = chars[((len - i - 1 + j - 1) % len) + 1]
                    end
                    frames[#frames + 1] = table.concat(f)
                end
            elseif mode == 2 then -- AbCdQwEr
                for i = 0, len - 1 do
                    local f = {}
                    local upper = true
                    for j = 1, len do
                        local ch = chars[((i + j - 1) % len) + 1]
                        if ch:match("%a") then
                            f[j] = upper and ch:upper() or ch:lower()
                            upper = not upper
                        else
                            f[j] = ch
                        end
                    end
                    frames[#frames + 1] = table.concat(f)
                end
            elseif mode == 3 then -- Wave's
                for i = 1, len do
                    local f = {}
                    for j = 1, len do
                        local ch = chars[j]
                        if ch:match("%a") and j == i then
                            f[j] = ch:upper()
                        elseif ch:match("%a") then
                            f[j] = ch:lower()
                        else
                            f[j] = ch
                        end
                    end
                    frames[#frames + 1] = " " .. table.concat(f) .. " "
                end
            elseif mode == 4 then -- Typewriter
                for i = 1, len do
                    frames[#frames + 1] = table.concat(chars, "", 1, i)
                end
                for _ = 1, 4 do frames[#frames + 1] = text end
                for i = len - 1, 0, -1 do
                    frames[#frames + 1] = i > 0 and table.concat(chars, "", 1, i) .. cur or cur
                end
                frames[#frames + 1] = " "
                frames[#frames + 1] = " "
            elseif mode == 5 then -- Bounce
                for i = 1, len do
                    frames[#frames + 1] = table.concat(chars, "", 1, i)
                end
                for i = len - 1, 1, -1 do
                    frames[#frames + 1] = table.concat(chars, "", 1, i)
                end
            elseif mode == 6 then -- Glitch
                local gc = {"█", "▓", "▒", "░", "¿", "×", "÷", "±", "¤", "#", "?", "!", "@"}
                for k = 1, 24 do
                    if k % 3 == 0 then
                        local s = {}
                        local pos = {}
                        for _ = 1, math.random(2, math.max(3, math.floor(len * 0.6))) do pos[math.random(1, len)] = true end
                        for j = 1, len do s[j] = pos[j] and gc[math.random(#gc)] or chars[j] end
                        frames[#frames + 1] = table.concat(s)
                    else
                        frames[#frames + 1] = text
                    end
                end
            elseif mode == 7 then -- Heartbeat
                local mid = math.ceil(len / 2)
                for _ = 1, 4 do frames[#frames + 1] = text end
                for i = 1, mid do
                    frames[#frames + 1] = table.concat(chars, "", math.max(1, mid - i), math.min(len, mid + i))
                end
                for _ = 1, 2 do frames[#frames + 1] = chars[mid] end
                for i = mid, 1, -1 do
                    frames[#frames + 1] = table.concat(chars, "", math.max(1, mid - (mid - i)), math.min(len, mid + (mid - i)))
                end
            elseif mode == 8 then -- Matrix
                local ch = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%"
                local steps = math.max(8, len * 2)
                for s = 1, steps do
                    local o = {}
                    local res = math.floor((s / steps) * len)
                    for j = 1, len do
                        if j <= res then o[j] = chars[j] else o[j] = ch:sub(math.random(1, #ch), math.random(1, #ch)) end
                    end
                    frames[#frames + 1] = table.concat(o)
                end
                for _ = 1, 5 do frames[#frames + 1] = text end
            elseif mode == 9 then -- Scramble
                local ch = "abcdefghijklmnopqrstuvwxyz"
                for step = 0, len do
                    for _ = 1, 3 do
                        local s = {}
                        for j = 1, len do
                            s[j] = j <= step and chars[j] or ch:sub(math.random(1, #ch), math.random(1, #ch))
                        end
                        frames[#frames + 1] = table.concat(s)
                    end
                end
                for _ = 1, 5 do frames[#frames + 1] = text end
            elseif mode == 10 then -- DNA Helix
                for ph = 0, len * 2 - 1 do
                    local s = {}
                    for j = 1, len do
                        local ch = chars[j]
                        if ch:match("%a") then
                            s[j] = math.sin((j + ph) * 0.8) > 0 and ch:upper() or ch:lower()
                        else
                            s[j] = ch
                        end
                    end
                    frames[#frames + 1] = table.concat(s)
                end
            elseif mode == 11 then -- Radar
                local len2 = math.max(len, 12)
                for i = 1, len2 do
                    local s = {}
                    for j = 1, len2 do
                        if j == i then s[j] = "●"
                        elseif math.abs(j - i) == 1 then s[j] = "◉"
                        elseif math.abs(j - i) == 2 then s[j] = "○"
                        else s[j] = "·" end
                    end
                    frames[#frames + 1] = table.concat(s)
                end
            elseif mode == 12 then -- Static
                frames = {text}
            elseif mode == 13 then -- Snake
                for i = 1, len do
                    local s = {}
                    for j = 1, len do s[j] = (j == i) and "█" or chars[j] end
                    frames[#frames + 1] = table.concat(s)
                end
            elseif mode == 14 then -- Flip
                for _ = 1, 3 do frames[#frames + 1] = text end
                local rev = {}
                for i = #chars, 1, -1 do rev[#rev + 1] = chars[i] end
                for _ = 1, 3 do frames[#frames + 1] = table.concat(rev) end
            elseif mode == 15 then -- Fade Dots
                local b = text:match("^(.-)%s*$") or text
                frames = {b .. "...", b .. "..", b .. ".", b, b .. ".", b .. ".."}
            elseif mode == 16 then -- Brackets
                for i = 1, len do
                    local s = {}
                    for j = 1, len do s[j] = (j == i) and ("[" .. chars[j] .. "]") or chars[j] end
                    frames[#frames + 1] = table.concat(s)
                end
            elseif mode == 17 then -- Fill
                for i = 0, len do
                    local s = {}
                    for j = 1, len do s[j] = j <= i and chars[j] or cur end
                    frames[#frames + 1] = table.concat(s)
                end
                for _ = 1, 3 do frames[#frames + 1] = text end
            elseif mode == 18 then -- Decrypt
                local gc = {"%", "#", "@", "&", "!", "$", "?", "*", "+", "~"}
                local steps = math.max(6, len)
                for s = 0, steps do
                    local o = {}
                    local res = math.floor((s / steps) * len)
                    for j = 1, len do o[j] = j <= res and chars[j] or gc[math.random(1, #gc)] end
                    frames[#frames + 1] = table.concat(o)
                end
                for _ = 1, 4 do frames[#frames + 1] = text end
            elseif mode == 19 then -- Pendulum
                local b = text:match("^(.-)%s*$") or text
                for i = 0, 4 do frames[#frames + 1] = string.rep(" ", i) .. b end
                for i = 3, 0, -1 do frames[#frames + 1] = string.rep(" ", i) .. b end
            elseif mode == 20 then -- Loading
                local b = text:match("^(.-)%s*$") or text
                frames = {"Loading", "Loading.", "Loading..", "Loading...", b .. "!", b .. "!", b .. "!", b .. "!", " "}
            elseif mode == 21 then -- Split
                local mid = math.ceil(len / 2)
                local left = table.concat(chars, "", 1, mid)
                local right = table.concat(chars, "", mid + 1, len)
                for g = 0, 4 do frames[#frames + 1] = left .. string.rep(" ", g) .. right end
                for g = 3, 0, -1 do frames[#frames + 1] = left .. string.rep(" ", g) .. right end
            elseif mode == 22 then -- Swap Case
                for _ = 1, 16 do
                    local s = {}
                    for j = 1, len do
                        local ch = chars[j]
                        if ch:match("%a") then s[j] = math.random() > 0.5 and ch:upper() or ch:lower()
                        else s[j] = ch end
                    end
                    frames[#frames + 1] = table.concat(s)
                end
            elseif mode == 23 then -- Neon
                local b = text:match("^(.-)%s*$") or text
                frames = {">" .. b .. "<", ">>" .. b .. "<<", ">>>" .. b .. "<<<", ">>" .. b .. "<<", ">" .. b .. "<", b}
            elseif mode == 24 then -- Countdown
                local b = text:match("^(.-)%s*$") or text
                frames = {"3", "2", "1", b .. "!", b .. "!", b .. "!", b, b, " "}
            elseif mode == 25 then -- Binary
                local bin = {}
                for j = 1, len do bin[j] = math.random(0, 1) == 1 and "1" or "0" end
                for s = 0, len do
                    local o = {}
                    for j = 1, len do o[j] = j <= s and chars[j] or bin[j] end
                    frames[#frames + 1] = table.concat(o)
                end
                for _ = 1, 4 do frames[#frames + 1] = text end
            elseif mode == 26 then -- Progress Bar
                local b = text:match("^(.-)%s*$") or text
                local bl = 8
                for i = 0, bl do frames[#frames + 1] = "[" .. string.rep("█", i) .. string.rep("░", bl - i) .. "]" end
                frames[#frames + 1] = b .. "!"
                frames[#frames + 1] = b .. "!"
                frames[#frames + 1] = b .. "!"
                frames[#frames + 1] = b
                frames[#frames + 1] = b
                frames[#frames + 1] = " "
            else -- Default
                frames = {text}
            end

            return frames
        end

        local Frames = {}
        local FrameIndex = 1
        local Accum = 0
        local LastText = ""
        local LastAnim = -1
        local LastFont = -1
        local CurrentDisplay = ""
        local OriginalName = nil
        local WasEnabled = false
        local LastUpdate = 0

        local function ApplyClanTag()
            gear.Custom:Visibility(gear.Type:Get() == 12 and true or false)

            if not gear:Get() then
                if WasEnabled then
                    WasEnabled = false
                    if OriginalName then
                        SetName(OriginalName)
                        OriginalName = nil
                    end
                end
                return
            end

            if not pawn or not controller then return end
            if not OriginalName then
                OriginalName = init.SteamName
            end

            WasEnabled = true

            local Text = ({"Shadow.lua", "Neverlose.cc", "Nixware.cc", "Midnight.im", 
                          "Fatality.win", "Bankroll.su", "Legendware.pw", "Interium.ooo", 
                          "MemeSense.gg", "Plaguecheat.cc", "Tracele.cc", gear.Custom:Get()})[gear.Type:Get()]
            local Nick = init.SteamName or ""
            local Anim = gear.AnimMode:Get() - 1
            local Font = gear.Font:Get() - 1
            local Delay = gear.Delay:Get()

            if Text ~= LastText or Anim ~= LastAnim then
                Frames = BuildFrames(Text, Anim)
                FrameIndex = 1
                LastText = Text
                LastAnim = Anim
                Accum = Delay * 0.1
            end

            if Font ~= LastFont then
                LastFont = Font
            end

            local now = os.clock()
            if #Frames > 0 then
                Accum = Accum + (now - LastUpdate)
                if Accum >= Delay * 0.1 then
                    Accum = 0
                    CurrentDisplay = Frames[FrameIndex]
                    FrameIndex = (FrameIndex % #Frames) + 1
                end
            end
            LastUpdate = now

            if CurrentDisplay and CurrentDisplay ~= "" then
                local ClantagText = ApplyFont(CurrentDisplay, Font)
                local FullDisplay = ClantagText .. "  " .. Nick
                SetName(FullDisplay)
            end
        end

        function clantag:paint()
            ApplyClanTag()
        end

        function clantag:unload()
            if OriginalName then
                SetName(OriginalName)
            end
        end
    end

    local autobuy = {}; do
        local gear = tab.general.AutoBuy

        function autobuy:round_start()
            if not pawn or not gear:Get() then return end

            local command = ""

            if gear.Main:Get() == 2 then
                command = command .. "buy ssg08; "
            elseif gear.Main:Get() == 3 then
                command = command .. "buy g3sg1; "
            elseif gear.Main:Get() == 4 then
                command = command .. "buy awp; "
            end

            if gear.Secondary:Get() == 2 then
                command = command .. "buy deagle; "
            elseif gear.Secondary:Get() == 3 then
                command = command .. "buy revolver; "
            end

            if gear.Other:Get(1) then
                command = command .. "buy vest; buy vesthelm; "
            end
            if gear.Other:Get(2) then
                command = command .. "buy hegrenade; "
            end
            if gear.Other:Get(3) then
                command = command .. "buy smokegrenade; "
            end
            if gear.Other:Get(4) then
                command = command .. "buy molotov; buy incgrenade; "
            end
            if gear.Other:Get(5) then
                command = command .. "buy flashbang; "
            end
            if gear.Other:Get(6) then
                command = command .. "buy defuser; "
            end
            if gear.Other:Get(7) then
                command = command .. "buy taser; "
            end

            exe_cmd(command)
        end
    end

    local hitsounds = {}; do
        local gear = tab.hitsounds.HitSounds

        function hitsounds:player_hurt(event)
            if not gear:Get() then return end

            local attacker = event:get_pawn("attacker")
            local userid = event:get_pawn("userid")

            if not userid or not attacker or not pawn then return end
            if userid == pawn then return end
            if attacker ~= pawn then return end
            if userid.m_iTeamNum == pawn.m_iTeamNum then return end

            local SoundsNames = utils.GetHitsoundsFiles()
            if SoundsNames == nil then return end
            local SoundName = SoundsNames[gear.Sound:Get()]

            resource_system.PlayVSound(SoundName)
        end
    end

    local ragdolls = {}; do
        local gear = tab.other.Ragdolls

        function ragdolls:paint()
            if gear:Get() then
                if gear.Friction:Get() ~= 0 then
                    cvars.ragdoll_friction_scale:Float(gear.Friction:Get() / 10)
                else
                    cvars.ragdoll_friction_scale:Float(-1)
                end
            else
                cvars.ragdoll_friction_scale:Float(0.6)
            end

            if gear:Get() then       
                cvars.ragdoll_gravity_scale:Float(gear.Gravity:Get() / 10)
            else
                cvars.ragdoll_gravity_scale:Float(1)
            end
        end

        function ragdolls:unload()
            cvars.ragdoll_gravity_scale:Float(1)
            cvars.ragdoll_friction_scale:Float(0.6)
        end
    end

    local edge_jump = {}; do
        local hotkey = tab.movement.EdgeJump
        local jump = cmd_button_t("jump")

        function edge_jump:paint()
            if not pawn then return end
            if not hotkey:Get() then return end

            local OnGround = bit.band(pawn.m_fFlags, 1) ~= 0

            if not (pawn.m_fFlags and OnGround) then
                jump:Press()
                jump:Release()
            end
        end

        function edge_jump:unload()
            jump:Release()
        end
    end

    local reveal_radar = {}; do
        local gear = tab.interface.RevealRadar
        
        local DrawRadarEntitiesPattern = FindPattern("client.dll", "48 89 4C 24 ? 55 41 54 48 8D 6C 24", "DrawRadarEntities")
        hooks.CreateHook(DrawRadarEntitiesPattern, function(orig, a1)
            if gear:Get() and a1 then
                pcall(function()
                    ffi.cast("uint8_t*", ffi.cast("uintptr_t", a1) + 95750)[0] = 1
                end)
            end

            return orig(a1)
        end, "void(__fastcall*)(void*)")
    end

    local preserve_killfeed = {}; do
        local gear = tab.interface.PreserveKillFeed
        local Clear = false
        local Off = false

        local FindHudElementPattern = FindPattern("client.dll", "40 53 48 83 EC ? 48 8B 05 ? ? ? ? 48 8B D9 48 85 C0 74 ? 48 89 5C 24", "FindHudElement")
        local ClearNoticesPattern = FindPattern("client.dll", "48 89 5C 24 08 48 89 74 24 10 57 48 83 EC 20 48 8B 71 60", "ClearNotices")
        local fnFindHudElement = ffi.cast("int64_t(__fastcall*)(const char*)", FindHudElementPattern)
        local fnClearNotices = ffi.cast("void(__fastcall*)(int64_t)", ClearNoticesPattern)

        local function ClearNotices(Ptr)
            if not Ptr or Ptr == 0 then return end
            fnClearNotices(ffi.cast("int64_t", Ptr) - 32)
            Clear = false
        end

        local function SetTime(Ptr, Value)
            if not Ptr or Ptr == 0 then return end

            ffi.cast("float*", ffi.cast("int64_t", Ptr) + 88)[0] = Value
        end

        function preserve_killfeed:paint(Unload)
            local Ptr = fnFindHudElement("CCSGO_HudDeathNotice")
            if not Ptr or Ptr == 0 then return end

            if not gear:Get() then
                if not Off then
                    ClearNotices(Ptr)
                    SetTime(Ptr, 1.5)
                    Off = true
                end
                return
            end

            SetTime(Ptr, Unload and 1.5 or (gear.Time:Get() == 10.1 and FLT_MAX or gear.Time:Get()))

            if Clear then
                ClearNotices(Ptr)
            end

            Off = false
        end
        
        function preserve_killfeed:round_start()
            Clear = true
        end

        function preserve_killfeed:unload()
            Clear = true
            self:paint(true)
        end
    end

    local freecam = {}; do
        local gear = tab.freecam.Freecam

        local FreecamActive = false
        local FreecamPos = nil

        function freecam:override_view(view)
            if not view then return end

            if not gear:Get() then
                if FreecamActive then
                    FreecamActive = false
                    FreecamPos = nil
                end
                return
            end

            if not pawn or not controller or not global_vars then
                FreecamActive = false
                FreecamPos = nil
                return
            end

            if not FreecamActive then
                FreecamPos = view.origin
                FreecamActive = true
            end

            local Angle = view.angles
            local Forward, Right, Up = math.angle_vectors(Angle)

            local dt = global_vars.m_flFrameTime
            if not dt or dt <= 0 then dt = 0.015 end
            local Speed = 500 * dt

            if input.IsKeyPressed(VK_SHIFT) then Speed = Speed * 1.5 end

            local Move = vec3_t(0, 0, 0)

            if input.IsKeyPressed(VK_W) then Move = Move + Forward * Speed end
            if input.IsKeyPressed(VK_S) then Move = Move - Forward * Speed end
            if input.IsKeyPressed(VK_A) then Move = Move - Right * Speed end
            if input.IsKeyPressed(VK_D) then Move = Move + Right * Speed end
            if input.IsKeyPressed(VK_SPACE) then Move = Move + Up * Speed end
            if input.IsKeyPressed(VK_CONTROL) then Move = Move - Up * Speed end

            FreecamPos = FreecamPos + Move
            view.origin = FreecamPos
        end

        function freecam:paint()
            if not gear:Get() then return end

            exe_cmd("-left")
            exe_cmd("-right")
            exe_cmd("-forward")
            exe_cmd("-back")
        end
    end

    local remove_viewmodel_in_scope = {}; do
        local gear = tab.viewmodel.RemoveViewmodelInScope

        function remove_viewmodel_in_scope:paint()
            if gear:Get() and pawn then
                if pawn:InScope() then
                    cvars.r_drawviewmodel:Bool(false)
                else
                    cvars.r_drawviewmodel:Bool(true)
                end
            else
                cvars.r_drawviewmodel:Bool(true)
            end
        end

        function remove_viewmodel_in_scope:unload()
            cvars.r_drawviewmodel:Bool(true)
        end
    end

    local viewmodel_rotation = {}; do
        local gear = tab.viewmodel.ViewmodelRotation
        local gear2 = tab.viewmodel.CustomViewmodelInScope
        local gear3 = tab.viewmodel.RemoveViewmodelInScope
        
        local fnCalcViewmodel = FindPattern("client.dll", "48 8B C4 55 56 57 41 57 48 8D A8 ? ? ? ? 48 81 EC ? ? ? ? 48 8B F9", "CalcViewmodel")

        local function hkCalcViewmodel(orig, a1, pos, rot)
            if gear:Get() and (not gear2:Get() or (gear2:Get() and not pawn:InScope())) and pawn then
                rot.pitch = rot.pitch + gear.Pitch:Get()
                rot.yaw = rot.yaw + gear.Yaw:Get()
                rot.roll = gear.Roll:Get()
            elseif gear2:Get() and not gear3:Get() and pawn and pawn:InScope() then
                rot.pitch = rot.pitch + gear2.Pitch:Get()
                rot.yaw = rot.yaw + gear2.Yaw:Get()
                rot.roll = gear2.Roll:Get()
            end

            orig(a1, pos, rot)
        end

        hooks.CreateHook(fnCalcViewmodel, hkCalcViewmodel, "void(__fastcall*)(void*, Vector*, QAngle*)")
    end
    
    local custom_viewmodel_in_scope = {}; do
        local gear = tab.viewmodel.CustomViewmodelInScope

        function custom_viewmodel_in_scope:paint()
            if pawn and pawn:InScope() and gear:Get() then
                Override("misc_viewmodel_editor", true)
                Override("misc_viewmodel_editor_x", gear.X:Get())
                Override("misc_viewmodel_editor_y", gear.Y:Get())
                Override("misc_viewmodel_editor_z", gear.Z:Get())
                Override("misc_viewmodel_editor_fov", gear.Fov:Get())
            else
                Override("misc_viewmodel_editor", DEF_VALUE_VM)
                Override("misc_viewmodel_editor_x", DEF_VALUE_VM_X)
                Override("misc_viewmodel_editor_y", DEF_VALUE_VM_Y)
                Override("misc_viewmodel_editor_z", DEF_VALUE_VM_Z)
                Override("misc_viewmodel_editor_fov", DEF_VALUE_VM_FOV)
            end
        end
    end

    function misc.override_view(view)
        freecam:override_view(view)
    end

    function misc.paint()
        edge_jump:paint()
        ragdolls:paint()
        clantag:paint()
        preserve_killfeed:paint()
        freecam:paint()
        remove_viewmodel_in_scope:paint()
        custom_viewmodel_in_scope:paint()
    end

    function misc.round_start()
        autobuy:round_start()
        preserve_killfeed:round_start()
    end

    function misc.round_prestart()
        autobuy:round_start()
    end

    function misc.player_hurt(event)
        hitsounds:player_hurt(event)
    end

    function misc.unload()
        clantag:unload()
        edge_jump:unload()
        ragdolls:unload()
        preserve_killfeed:unload()
        remove_viewmodel_in_scope:unload()
    end
end

local settings = {}; do
    local group = uix.settings.settings.overlay

    local watermark = {}; do
        local gear = group.Watermark
        local win = gui.create_window("watermark", vec2_t(0, 0), vec2_t(300, 25))
        win:setting("set", "bg_color", color_t(0, 0, 0, 0)):setting("set", "constraints", vec2_t(0, 0), vec2_t(render.screen_size().x, render.screen_size().y)):setting("set", "pos", vec2_t(render.screen_size().x - 250, 10))

        local last_slider_x = gear.pos_x:Get()
        local last_slider_y = gear.pos_y:Get()

        local alpha = 0

        local FPS = 0
        local FPSCount = 0
        local LastUpdateTime = LastUpdateTime or 0
        function GetFPS()
            local m_flCurrentTime = os.clock()
            FPSCount = FPSCount + 1

            if m_flCurrentTime - LastUpdateTime >= 1 then
                FPS = FPSCount
                FPSCount = 0
                LastUpdateTime = m_flCurrentTime
            end

            return FPS
        end

        function watermark:paint()
            gear.Custom:Visibility(ternary(gear.Name:Get() == 3, true, false))

            local current_x = gear.pos_x:Get()
            local current_y = gear.pos_y:Get()
            local win_pos = win:setting("get", "pos")

            if current_x ~= last_slider_x or current_y ~= last_slider_y then
                win:setting("set", "pos", vec2_t(current_x, current_y))
                last_slider_x = current_x
                last_slider_y = current_y
            elseif win_pos.x ~= last_slider_x or win_pos.y ~= last_slider_y then
                gear.pos_x:Set(win_pos.x)
                gear.pos_y:Set(win_pos.y)
                last_slider_x = win_pos.x
                last_slider_y = win_pos.y
            end

            if gear:Get() then
                alpha = lerp(alpha, 1, 0.2)
                if not win:GetStatus() then
                    win:open()
                end
            else
                alpha = lerp(alpha, 0, 0.2)
                if alpha <= 0.01 and win:GetStatus() then
                    win:close()
                end
            end
        end

        local current_width = 0
        win:render_func(function(win)
            win.border = false
            win.is_pinned = true
            win.border_radius = gear.BorderRadius:Get()

            local win_x = win.pos.x
            local win_y = win.pos.y
            local next_x = 30

            local nselected = not gear.Fields:Get(1) and not gear.Fields:Get(2) and not gear.Fields:Get(3)

            local br = gear.BorderRadius:Get()
            local icon_pad = math.max(3.5, br * 0.3)
            local content_shift = math.max(0, icon_pad - 3.5)

            win.size = vec2_t(nselected and current_width - 3.5 or current_width, 25)
            win.bg_color = color_t(0.2, 0.2, 0.2, alpha * 0.55)
            render.rect_filled(vec2_t(win_x + 26, win_y), vec2_t(win_x + current_width, win_y + 25), color_t(0.135, 0.135, 0.135, nselected and 0 or alpha), win.border_radius)
            render.text(ICON_LOGO, init.SmallBigIcons, vec2_t(win_x + icon_pad, win_y + 3.5), color_t(1, 1, 1, alpha))
            render.rect(vec2_t(win_x, win_y), vec2_t(win_x + (nselected and current_width - 3.5 or current_width), win_y + 25), color_t(1, 1, 1, alpha * 0.1), win.border_radius, 1)

            next_x = next_x + content_shift

            local a = 1

            if a > 0 and gear.Fields:Get(1) then
                local text = (gear.Name:Get() == 1 and init.NixwareName) or (gear.Name:Get() == 2 and init.SteamName) or (gear.Name:Get() == 3 and gear.Custom:Get())
                local text_size = render.calc_text_size(text, init.StandartFont, 16)

                render.text(ICON_USER, init.StandartIcons, vec2_t(win_x + next_x, win_y + 4.5), color_t(1, 1, 1, alpha))
                next_x = next_x + 17.5

                render.text(text, init.StandartFont, vec2_t(win_x + next_x, win_y + 5), color_t(1, 1, 1, alpha))
                next_x = next_x + text_size.x + 7.5
            end

            if a > 0 and gear.Fields:Get(2) then
                local text = GetFPS()
                local text_size = render.calc_text_size(text, init.StandartFont, 16)

                render.text(ICON_FPS, init.StandartIcons, vec2_t(win_x + next_x, win_y + 4.5), color_t(1, 1, 1, alpha))
                next_x = next_x + 17.5

                render.text(text, init.StandartFont, vec2_t(win_x + next_x, win_y + 5), color_t(1, 1, 1, alpha))
                next_x = next_x + text_size.x + 7.5
            end

            if a > 0 and gear.Fields:Get(3) then
                local text = os.date("%H:%M:%S")
                local text_size = render.calc_text_size(text, init.StandartFont, 16)

                render.text(ICON_TIME, init.StandartIcons, vec2_t(win_x + next_x, win_y + 4.5), color_t(1, 1, 1, alpha))
                next_x = next_x + 17.5

                render.text(text, init.StandartFont, vec2_t(win_x + next_x, win_y + 5), color_t(1, 1, 1, alpha))
                next_x = next_x + text_size.x + 7.5
            end

            current_width = lerp(current_width, next_x, 0.15)
        end)
    end

    local manual_aa_indicators = {}; do
        local gear = group.ManualAAIndicators
        local gear_aa = uix.rage.manual_aa.ManualAA

        local left_alpha = 0
        local right_alpha = 0
        local left_size = 1
        local right_size = 1
        
        local y_offset = 0
        local target_y_offset = 0
        local was_scoped = false

        function manual_aa_indicators:under_gui()
            if not gear:Get() or not gear_aa:Get() or not pawn or not pawn:IsAlive() then 
                left_alpha = lerp(left_alpha, 0, 0.25)
                right_alpha = lerp(right_alpha, 0, 0.25)
                left_size = lerp(left_size, 0.85, 0.25)
                right_size = lerp(right_size, 0.55, 0.25)
                if left_alpha < 0.5 and right_alpha < 0.5 then return end
            end

            local current_left = menu.ragebot_anti_aim_base_yaw_offset == 59
            local current_right = menu.ragebot_anti_aim_base_yaw_offset == -19

            local is_scoped = pawn and pawn.m_bIsScoped or false
            
            if is_scoped then
                target_y_offset = 35 
            else
                target_y_offset = 0 
            end
            
            y_offset = lerp(y_offset, target_y_offset, 0.2)
            
            if not is_scoped and math.abs(y_offset) < 1 then
                y_offset = 0
            end

            if not current_left and not current_right then
                left_alpha = lerp(left_alpha, 0, 0.25)
                right_alpha = lerp(right_alpha, 0, 0.25)
                left_size = lerp(left_size, 0.85, 0.25)
                right_size = lerp(right_size, 0.55, 0.25)
                if left_alpha < 0.01 and right_alpha < 0.01 then return end
            end

            if current_left then
                left_alpha = lerp(left_alpha, 1, 0.25)
                left_size = lerp(left_size, 1.25, 0.25)
                right_alpha = lerp(right_alpha, 0.3, 0.25)
                right_size = lerp(right_size, 0.75, 0.25)
            elseif current_right then
                right_alpha = lerp(right_alpha, 1, 0.25)
                right_size = lerp(right_size, 1.1, 0.25)
                left_alpha = lerp(left_alpha, 0.3, 0.25)
                left_size = lerp(left_size, 0.95, 0.25)
            end

            local screen_center = vec2_t(render.screen_size().x / 2, render.screen_size().y / 2)
            local distance = gear.Distance:Get()
            local base_size = 1
            local color = gear.Color:Get()
            
            local ArrowLeft = {
                vec2_t(screen_center.x - 33 * base_size * left_size - distance, screen_center.y + y_offset),
                vec2_t(screen_center.x - 16 * base_size * left_size - distance, screen_center.y - 6 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 17 * base_size * left_size - distance, screen_center.y - 5 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 18 * base_size * left_size - distance, screen_center.y - 4 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 18.7 * base_size * left_size - distance, screen_center.y - 3 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 19.3 * base_size * left_size - distance, screen_center.y - 2 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 19.8 * base_size * left_size - distance, screen_center.y - 1 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 20.2 * base_size * left_size - distance, screen_center.y + y_offset),
                vec2_t(screen_center.x - 19.8 * base_size * left_size - distance, screen_center.y + 1 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 19.3 * base_size * left_size - distance, screen_center.y + 2 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 18.7 * base_size * left_size - distance, screen_center.y + 3 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 18 * base_size * left_size - distance, screen_center.y + 4 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 17 * base_size * left_size - distance, screen_center.y + 5 * base_size * left_size + y_offset),
                vec2_t(screen_center.x - 16 * base_size * left_size - distance, screen_center.y + 6 * base_size * left_size + y_offset)
            }

            local ArrowRight = {
                vec2_t(screen_center.x + 33 * base_size * right_size + distance, screen_center.y + y_offset),
                vec2_t(screen_center.x + 16 * base_size * right_size + distance, screen_center.y - 6 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 17 * base_size * right_size + distance, screen_center.y - 5 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 18 * base_size * right_size + distance, screen_center.y - 4 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 18.7 * base_size * right_size + distance, screen_center.y - 3 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 19.3 * base_size * right_size + distance, screen_center.y - 2 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 19.8 * base_size * right_size + distance, screen_center.y - 1 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 20.2 * base_size * right_size + distance, screen_center.y + y_offset),
                vec2_t(screen_center.x + 19.8 * base_size * right_size + distance, screen_center.y + 1 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 19.3 * base_size * right_size + distance, screen_center.y + 2 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 18.7 * base_size * right_size + distance, screen_center.y + 3 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 18 * base_size * right_size + distance, screen_center.y + 4 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 17 * base_size * right_size + distance, screen_center.y + 5 * base_size * right_size + y_offset),
                vec2_t(screen_center.x + 16 * base_size * right_size + distance, screen_center.y + 6 * base_size * right_size + y_offset)
            }
            
            render.polygon(ArrowLeft, color_t(color.r, color.g, color.b, color.a * left_alpha))
            render.polygon(ArrowRight, color_t(color.r, color.g, color.b, color.a * right_alpha))
        end
    end

    local bomb_indicator = {}; do
        local gear = group.BombIndicator
        local gearX = gear.pos_x
        local gearY = gear.pos_y
        
        local LastSliderX = gearX:Get()
        local LastSliderY = gearY:Get()
        
        local Alpha = 0       
        local DefuseAlpha = 0   
        local TargetAlpha = 0
        local TargetDefuseAlpha = 0

        local BombStart = nil
        local DefuseStart = nil
        local Site = "Unknown"
        local Time1 = 0
        local Time1Text = nil
        local Time2 = 0
        local NextBeep = 0
        local WasDefusing = false
        local BombExists = false 

        local win = gui.create_window("bomb_indicator", vec2_t(0, 0), vec2_t(150, 55)):setting("set", "border_color", color_t(1, 1, 1, 0)):setting("set", "bg_color", color_t(1, 1, 1, 0))
        win:setting("set", "constraints", vec2_t(0, 0), vec2_t(render.screen_size().x, render.screen_size().y)):setting("set", "pos", vec2_t(450, 10))

        function bomb_indicator:paint()
            local CurrentX = gearX:Get()
            local CurrentY = gearY:Get()
            local WinPos = win:setting("get", "pos")
            
            if CurrentX ~= LastSliderX or CurrentY ~= LastSliderY then
                win:setting("set", "pos", vec2_t(CurrentX, CurrentY))
                LastSliderX = CurrentX
                LastSliderY = CurrentY
            elseif WinPos.x ~= LastSliderX or WinPos.y ~= LastSliderY then
                gearX:Set(WinPos.x)
                gearY:Set(WinPos.y)
                LastSliderX = WinPos.x
                LastSliderY = WinPos.y
            end

            BombExists = false
            local IsDefusing = false
            
            local RealSite = "Unknown"
            local RealTime1 = 0
            local RealTime1Text = nil
            local RealTime2 = 0
            local RealNextBeep = 0
            local RealIsDefusing = false
            
            GetEntities("C_PlantedC4", function(ent)
                if not ent or not global_vars or not pawn then 
                    return 
                end
                
                BombExists = true

                local flDefuseLength = ent.m_flDefuseLength
                local flTimerLength = ent.m_flTimerLength
                local nBombSite = ent.m_nBombSite
                local flNextBeep = ent.m_flNextBeep
                local bBombDefused = ent.m_bBombDefused
                local bHasExploded = ent.m_bHasExploded
                local bBeingDefused = ent.m_bBeingDefused

                if nBombSite ~= nil then
                    RealSite = (nBombSite == 0 and "A") or (nBombSite == 1 and "B") or "Unknown"
                end
                
                RealIsDefusing = bBeingDefused and not bBombDefused and not bHasExploded
                
                if bBombDefused then
                    RealTime1Text = "Defused"
                    RealTime1 = 0
                elseif bHasExploded then
                    RealTime1Text = "Exploded"
                    RealTime1 = 0
                else
                    RealTime1Text = nil
                end

                if flNextBeep then
                    RealNextBeep = flNextBeep
                end
                
                if flTimerLength and flTimerLength > 0 and not bBombDefused and not bHasExploded then
                    if BombStart == nil then
                        BombStart = global_vars.m_flCurrentTime
                    end
                    local Elapsed = global_vars.m_flCurrentTime - BombStart
                    RealTime1 = math.max(0, flTimerLength - Elapsed)
                else
                    RealTime1 = 0
                end
                
                if flDefuseLength and flDefuseLength > 0 and not bBombDefused and not bHasExploded then
                    if not bBeingDefused and DefuseStart ~= nil then
                        DefuseStart = nil
                    end
                    
                    if DefuseStart == nil and bBeingDefused then
                        DefuseStart = global_vars.m_flCurrentTime
                    end
                    
                    if DefuseStart and bBeingDefused then
                        local Elapsed = global_vars.m_flCurrentTime - DefuseStart
                        RealTime2 = math.max(0, flDefuseLength - Elapsed)
                    else
                        RealTime2 = 0
                    end
                else
                    RealTime2 = 0
                end
            end)
            
            local IsMenuOpened = ui.is_menu_opened()
            
            if BombExists then
                Site = RealSite
                Time1 = RealTime1
                Time1Text = RealTime1Text
                Time2 = RealTime2
                NextBeep = RealNextBeep
                IsDefusing = RealIsDefusing
            else
                Site = "Unknown"
                Time1 = 0
                Time1Text = nil
                Time2 = 0
                NextBeep = 0
                IsDefusing = false
            end
            
            local shouldBeVisible = gear:Get() and (BombExists or IsMenuOpened)
            
            if shouldBeVisible then
                TargetAlpha = 1
                if not win:GetStatus() then
                    win:open()
                end
            else
                TargetAlpha = 0
                if Alpha <= 0.01 and win:GetStatus() then
                    win:close()
                end
            end
            
            Alpha = lerp(Alpha, TargetAlpha, 0.2)
            
            if IsDefusing then
                TargetDefuseAlpha = 1
            else
                TargetDefuseAlpha = 0
            end
            DefuseAlpha = lerp(DefuseAlpha, TargetDefuseAlpha, 0.2)
            
            if not BombExists then
                BombStart = nil
                DefuseStart = nil
            end
            
            WasDefusing = IsDefusing
        end

        win:render_func(function(win)
            if Alpha <= 0.01 then
                return
            end

            if not global_vars or not pawn then
                if not (ui.is_menu_opened() and gear:Get()) then
                    return
                end
            end

            win.border = false
            win.is_pinned = true
            win.border_radius = gear.BorderRadius:Get()
            win.bg_color = color_t(0.2, 0.2, 0.2, Alpha * 0.55)

            local WinX = win.pos.x
            local WinY = win.pos.y
            local WinW = win.size.x
            local WinH = win.size.y

            local br = gear.BorderRadius:Get()
            local icon_shift = math.min(4, math.max(0, (br - 6) * 0.2))
            local text_shift = math.min(10, math.max(0, (br - 6) * 0.4))

            local TimeToBeep = NextBeep - global_vars.m_flCurrentTime
            local BombColor = (TimeToBeep >= 0 and TimeToBeep <= 0.06) and color_t(1, 0, 0, Alpha) or color_t(1, 1, 1, Alpha)
            local Time1Display = Time1Text or (Time1 > 0 and string.format("%.1f", Time1) or "0.0")
            local Time2Display = (Time2 > 0) and string.format("%.1f", Time2) or "0.0"

            render.rect_filled(vec2_t(WinX + 52, WinY), vec2_t(WinX + WinW, WinY + WinH), color_t(0.135, 0.135, 0.135, Alpha), win.border_radius)
            render.rect(vec2_t(WinX, WinY), vec2_t(WinX + WinW, WinY + WinH), color_t(1, 1, 1, Alpha * 0.1), win.border_radius, 1)

            render.text(ICON_C4, init.BombIndicatorIcons, vec2_t(WinX + 10 + icon_shift, WinY + 9.5), BombColor)
            render.text(sf("Time: %s", Time1Display), init.BombIndicatorFont, vec2_t(WinX + 58 + text_shift, WinY + 6), color_t(1, 1, 1, Alpha))
            render.text(sf("Site: %s", Site), init.BombIndicatorFont, vec2_t(WinX + 58 + text_shift, WinY + 19), color_t(1, 1, 1, Alpha))
            render.text(sf("Defuse: %s", Time2Display), init.BombIndicatorFont, vec2_t(WinX + 58 + text_shift, WinY + 34), color_t(1, 1, 1, DefuseAlpha))
        end)
    end

    local logs = {}; do
        local gear = group.Logs
        local ScreenLogs = {}
        local last_slider_x = gear.pos_x:Get()
        local last_slider_y = gear.pos_y:Get()
        local Alpha = 0

        local win = gui.create_window("logs", vec2_t(10, 10), vec2_t(375, 175))
        win:setting("set", "constraints", vec2_t(0, 0), vec2_t(render.screen_size().x, render.screen_size().y)):setting("set", "border_color", color_t(1, 1, 1, 0)):setting("set", "bg_color", color_t(1, 1, 1, 0))

        local function GetHitgroupName(Hitgroup)
            local hitgroups = {
                [1] = "Head",
                [2] = "Chest",
                [0] = "Generic",
                [4] = "Arms",
                [5] = "Arms",
                [8] = "Neck",
                [6] = "Legs",
                [7] = "Legs",
                [3] = "Stomach"
            }
            return hitgroups[Hitgroup] or "Unknown"
        end

        local function AddHitLog(e)
            if not pawn or not gear:Get() or not gear.Events:Get() == 1 then return end

            local Attacker = e:get_pawn("attacker")
            local UserId = e:get_pawn("userid")
            if not Attacker or not UserId then return end
            if Attacker ~= pawn or UserId == pawn then return end

            local Name = UserId:GetName()
            local Hitgroup = GetHitgroupName(e:get_int("hitgroup"))
            local Damage = e:get_int("dmg_health") 
            local Health = e:get_int("health")

            if gear.Output:Get(1) then
                table.insert(ScreenLogs, {
                    Name = Name,
                    Hitgroup = Hitgroup,
                    Damage = Damage,
                    Health = Health,
                    Alpha = 0,
                    Time = 3,
                    CTime = os.clock()
                })
            end

            if gear.Output:Get(2) then
                log():SetPrefixColor(color_t(100/255, 149/255, 237/255, 255/255)):Send(CONSOLE, PREFIX, "Hit %s in %s for %d Damage (%d HP left)", Name, Hitgroup, Damage, Health)
            end

            if gear.Output:Get(3) then
                log():SetPrefixColor(color_t(100/255, 149/255, 237/255, 255/255)):Send(CHAT, PREFIX, "Hit %s in %s for %d Damage (%d HP left)", Name, Hitgroup, Damage, Health)
            end
        end

        function logs:paint()
            gear.BorderRadius:Visibility(gear.Output:Get(1) and gear.Events:Get(1))

            local current_x = gear.pos_x:Get()
            local current_y = gear.pos_y:Get()
            local win_pos = win:setting("get", "pos")
            
            if current_x ~= last_slider_x or current_y ~= last_slider_y then
                win:setting("set", "pos", vec2_t(current_x, current_y))
                last_slider_x = current_x
                last_slider_y = current_y
            elseif win_pos.x ~= last_slider_x or win_pos.y ~= last_slider_y then
                gear.pos_x:Set(win_pos.x)
                gear.pos_y:Set(win_pos.y)
                last_slider_x = win_pos.x
                last_slider_y = win_pos.y
            end

            if gear:Get() and gear.Events:Get(1) and gear.Output:Get(1) then
                if not win:GetStatus() then
                    win:open()
                end
            else
                if win:GetStatus() and Alpha < 0.01 then
                    win:close()
                end
            end
        end

        win:render_func(function(win)
            win.is_pinned = true
            win.border_radius = 3.5

            local win_x = win.pos.x
            local win_y = win.pos.y
            local current_time = os.clock()
            local next_y = 0
            
            local screen_center_x = render.screen_size().x / 2
            local win_center_x = win.pos.x + win.size.x / 2
            
            local new_align = "left"
            if win_center_x < screen_center_x - 200 then
                new_align = "left"
            elseif win_center_x > screen_center_x + 200 then
                new_align = "right"
            else
                new_align = "center"
            end
            
            if win.last_align ~= new_align then
                win.last_align = new_align
            end

            if ui.is_menu_opened() and gear:Get() and gear.Events:Get(1) and gear.Output:Get(1) then
                Alpha = lerp(Alpha, 1, 0.2)
            else
                Alpha = lerp(Alpha, 0, 0.2)
            end

            win.border_color = color_t(1, 1, 1, Alpha)

            for i = #ScreenLogs, 1, -1 do
                local log = ScreenLogs[i]
                
                if current_time - log.CTime >= log.Time then
                    log.Alpha = lerp(log.Alpha, 0, 0.15)
                    if log.Alpha <= 0.01 then
                        table.remove(ScreenLogs, i)
                    end
                else
                    log.Alpha = lerp(log.Alpha, 1, 0.15)
                end
            end
            
            for _, log in ipairs(ScreenLogs) do
                local text1 = sf("Hit ")
                local text2 = sf("%s", log.Name)
                local text3 = sf(" in %s for %d Damage (%d HP left)", log.Hitgroup, log.Damage, log.Health)
                local text_size1 = render.calc_text_size(text1, init.StandartFont, 16)
                local text_size2 = render.calc_text_size(text2, init.VerdanaStandart, 16)
                local text_size3 = render.calc_text_size(text3, init.StandartFont, 16)
                local text_size_x = text_size1.x + text_size2.x + text_size3.x
                local rect_width = text_size_x + 33.5
                
                local correct_x = nil
                if win.last_align == "left" then
                    correct_x = win_x
                elseif win.last_align == "right" then
                    correct_x = win_x + win.size.x - rect_width - 10
                elseif win.last_align == "center" then
                    correct_x = win_x + (win.size.x / 2) - (rect_width / 2) - 5
                end
                
                log.current_x = correct_x
                
                if not log.next_y then
                    log.next_y = next_y
                end
                if not log.current_y then
                    log.current_y = next_y
                end
                
                log.next_y = next_y
                log.current_y = lerp(log.current_y, log.next_y, 0.25)
                
                render.rect_filled(vec2_t(log.current_x, win_y + log.current_y), vec2_t(log.current_x + rect_width, win_y + 25 + log.current_y), color_t(0.2, 0.2, 0.2, log.Alpha * 0.55), gear.BorderRadius:Get())
                render.rect_filled(vec2_t(log.current_x + 22.5, win_y + log.current_y), vec2_t(log.current_x + rect_width, win_y + 25 + log.current_y), color_t(0.135, 0.135, 0.135, log.Alpha), gear.BorderRadius:Get())
                render.rect(vec2_t(log.current_x, win_y + log.current_y), vec2_t(log.current_x + rect_width, win_y + 25 + log.current_y), color_t(1, 1, 1, log.Alpha * 0.1), gear.BorderRadius:Get(), 1)
                
                local icon_x = log.current_x + 4.5
                local text_x = log.current_x + 27.5
                
                render.text(ICON_LEGIT, init.StandartIcons, vec2_t(icon_x, win_y + 4.5 + log.current_y), color_t(1, 1, 1, log.Alpha))
                render.text(text1, init.StandartFont, vec2_t(text_x, win_y + 5.55 + log.current_y), color_t(1, 1, 1, log.Alpha))
                render.text(text2, init.VerdanaStandart, vec2_t(text_x + text_size1.x + 1, win_y + 3 + log.current_y), color_t(1, 1, 1, log.Alpha))
                render.text(text3, init.StandartFont, vec2_t(text_x + text_size1.x + text_size2.x + 1, win_y + 5.55 + log.current_y), color_t(1, 1, 1, log.Alpha))
                
                next_y = next_y + 27.5
            end
        end)

        function logs:round_start()
            ScreenLogs = {}
        end
        
        function logs:player_hurt(e)
            AddHitLog(e)
        end
    end

    local keybinds_list = {}; do
        local gear = group.KeybindsList
        local win = gui.create_window("keybinds_list", vec2_t(0, 0), vec2_t(300, 25)):setting("set", "border_color", color_t(1, 1, 1, 0)):setting("set", "bg_color", color_t(1, 1, 1, 0))
        win:setting("set", "constraints", vec2_t(0, 0), vec2_t(render.screen_size().x, render.screen_size().y)):setting("set", "pos", vec2_t(610, 10))
        
        local last_slider_x = gear.pos_x:Get()
        local last_slider_y = gear.pos_y:Get()
        
        local alpha = 0
        local bind_states = {}
        local activation_counter = 0

        local function GetBinds()
            return {
                { name = "Duck Peek", active = gear.Binds:Get(1) and uix.rage.general.DuckPeekAssist.Enabled:Get() },
                { name = "DP MinDmg", active = gear.Binds:Get(2) and uix.rage.general.DuckPeekAssist.MinDamageOverrideEnabled:Get() },
                { name = "AI Peek", active = gear.Binds:Get(3) and uix.rage.general.AiPeek.Enabled:Get() },
                { name = "AI MinDmg", active = gear.Binds:Get(4) and uix.rage.general.AiPeek.MinDamageOverrideEnabled:Get() },
                { name = "Edge Jump", active = gear.Binds:Get(7) and uix.misc.movement.EdgeJump:Get() },
                { name = "Freecam", active = gear.Binds:Get(8) and uix.misc.freecam.Freecam:Get() },
            }
        end

        function keybinds_list:paint()
            local current_x = gear.pos_x:Get()
            local current_y = gear.pos_y:Get()
            local win_pos = win:setting("get", "pos")
            
            if current_x ~= last_slider_x or current_y ~= last_slider_y then
                win:setting("set", "pos", vec2_t(current_x, current_y))
                last_slider_x = current_x
                last_slider_y = current_y
            elseif win_pos.x ~= last_slider_x or win_pos.y ~= last_slider_y then
                gear.pos_x:Set(win_pos.x)
                gear.pos_y:Set(win_pos.y)
                last_slider_x = win_pos.x
                last_slider_y = win_pos.y
            end

            local any_bind_active = false
            for _, b in ipairs(GetBinds()) do
                if b.active then
                    any_bind_active = true
                    break
                end
            end

            local should_show = gear:Get() and (ui.is_menu_opened() or any_bind_active)

            if should_show then
                alpha = lerp(alpha, 1, 0.2)
                if not win:GetStatus() then
                    win:open()
                end
            else
                alpha = lerp(alpha, 0, 0.2)
                if alpha <= 0.01 and win:GetStatus() then
                    win:close()
                end
            end
        end

        win:render_func(function(win)
            win.border = false
            win.is_pinned = true
            win.border_radius = gear.BorderRadius:Get()
            win.size = vec2_t(110, 25)
            win.bg_color = color_t(0.135, 0.135, 0.135, alpha)

            local win_x = win.pos.x
            local win_y = win.pos.y

            local binds = GetBinds()

            render.text(ICON_KEYBOARD, init.SmallBigIcons, vec2_t(win_x + 15, win_y + 2.9), color_t(1, 1, 1, alpha))
            render.text("KeyBinds", init.StandartFont, vec2_t(win_x + 40, win_y + 5), color_t(1, 1, 1, alpha))
            render.rect(vec2_t(win_x, win_y), vec2_t(win_x + 110, win_y + 25), color_t(1, 1, 1, alpha * 0.15), gear.BorderRadius:Get(), 1)

            for _, b in ipairs(binds) do
                local st = bind_states[b.name]
                if not st then
                    st = { alpha = 0, y = 28, target_y = 28, order = 0, was_active = false }
                    bind_states[b.name] = st
                end

                if b.active and not st.was_active then
                    activation_counter = activation_counter + 1
                    st.order = activation_counter
                end
                st.was_active = b.active
            end

            local visible = {}
            for name, st in pairs(bind_states) do
                local is_active = false
                for _, b in ipairs(binds) do
                    if b.name == name then is_active = b.active break end
                end
                if st.alpha > 0.01 or is_active then
                    table.insert(visible, { name = name, st = st, active = is_active })
                end
            end

            table.sort(visible, function(a, b)
                if a.active ~= b.active then return a.active end
                return a.st.order < b.st.order
            end)

            local base_y = 28
            local row_h  = 14
            for i, item in ipairs(visible) do
                item.st.target_y = base_y + (i - 1) * row_h
            end

            for _, item in ipairs(visible) do
                local st = item.st
                local target_alpha = item.active and 1 or 0

                st.alpha = lerp(st.alpha, target_alpha, 0.2)
                st.y = lerp(st.y, st.target_y,    0.2)

                if st.alpha <= 0.01 and not item.active then
                    bind_states[item.name] = nil
                else
                    render.text(item.name, init.KeybindsFont, vec2_t(win_x + 5, win_y + st.y), color_t(1, 1, 1, st.alpha * alpha))
                end
            end
        end)
    end

    function settings.paint()
        watermark:paint()
        bomb_indicator:paint()
        logs:paint()
        keybinds_list:paint()
    end

    function settings.under_gui()
        manual_aa_indicators:under_gui()
    end

    function settings.player_hurt(e)
        logs:player_hurt(e)
    end

    function settings.round_start()
        logs:round_start()
    end
end

user_cmd.createmove(function(cmd)
    uix.createmove(cmd)
    rage.createmove(cmd)
end)

user_cmd.frame_stage_notify(function(stage)
    visuals.frame_stage_notify(stage)
end)

user_cmd.level_init(function()
end)

user_cmd.level_shutdown(function()
end)

events.paint:Add(function()
    uix.paint()
    antiaim.paint()
    visuals.paint()
    misc.paint()
    settings.paint()
end)

gui.paint(function()
    visuals.under_gui()
    settings.under_gui()
end)

events.player_death:Add(function(event)
    visuals.player_death(event)
end)

events.player_hurt:Add(function(event)
    visuals.player_hurt(event)
    misc.player_hurt(event)
    settings.player_hurt(event)
end)

events.round_prestart:Add(function()
    misc.round_prestart()
end)

events.round_start:Add(function()
    misc.round_start()
    settings.round_start()

    LoadResources()
end)

events.override_view:Add(function(view)
    visuals.override_view(view)
    misc.override_view(view)
end)

events.bullet_impact:Add(function(ImpactsPos)
    rage.bullet_impact()
    visuals.bullet_impact(ImpactsPos)
end)

events.unload:Add(function()
    rage.unload()
    antiaim.unload()
    visuals.unload()
    misc.unload()
end)

--logs

if init.Loaded then
    log():Send(ALL, PREFIX, "Welcome to Shadow.lua!")
    log():Send(ALL, PREFIX, "We are Glad to See You, %s!", init.NixwareName)
    log():Send(ALL, PREFIX, "Come to the Discord: https://discord.gg/QNnCTgAAFE!")
end