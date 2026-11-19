-- [[ Nyanko_x4.7 - Módulo de utilidades ]]
-- Repositorio: https://github.com/JeanDev-rgb/x4.7

-- Nota: los cambios en este módulo no actualizan automáticamente conf.lua en instalaciones existentes.
-- Si los cambios no aparecen, ejecuta «Configuración» > «Actualizar datos numéricos».

local menu = require("menu");
local util = {};

-- Administración de la configuración
util.data = {};

util.set_base_address = function()
    if base then
        return 0;
    end
    -- Obtener la zona horaria
    local t = os.time();
    local time_zone = os.difftime(t, os.time(os.date("!*t", t)));
    baset = math.tointeger(time_zone);
    local hex_baset = ("h %02X %02X %02X %02X"):format(
        baset & 0xFF, (baset >> 8) & 0xFF, (baset >> 16) & 0xFF, (baset >> 24) & 0xFF
    );
    -- Buscar la dirección base
    local range = 48;   -- Cb, A
    ::start_i::
    gg.clearResults();
    gg.setRanges(range);
    gg.searchNumber(hex_baset, 1, false, 536870912);
    local res = gg.getResults(gg.getResultsCount());
    if #res == 0 then
        if range == 48 then
            range = -2080896;   -- O
            goto start_i;
        end
        gg.alert(table.concat({
            "No se pudo obtener la dirección base.\nReinicia la aplicación."
        }, "\n\n"));
        return os.exit();
    end
    -- Precisar la dirección base
    base = res[1].address;
    for i = 1, #res-8, 4 do
        local diff = res[i+8].address - res[i+4].address;
        if diff > 0x3000 and diff < 0x4fff and (function()
            gg.clearResults();
            gg.searchNumber(gen_search_group(4), 4, false, 536870912, res[i].address, res[i].address+0x100);
            gg.refineNumber("-256~~256", 4);
            return gg.getResultsCount();
        end)() == 4 then
            base = res[i].address;
            break;
        end
    end
end

util.update_values = function(self)
    for _, u in ipairs(self.data.menu_names) do
        for s, t in pairs(self.data[u.."_datas"]) do

            if menu.datas[t.key] and #menu.datas[t.key] == 0 and t.encrypt ~= false then
                local _, v = xpcall(menu[t.key.."_b"], function()
                    gg.alert("Error de configuración: "..t.key.."\n\nReinicia la aplicación.");
                    return nil;
                end, t.key);
                t.value = v or t.value;
                local save_path = menu.path:gsub("?", menu.version);
                gg.saveVariable(menu.datas, save_path);

            elseif menu.datas[t.key] and t.type == "number" and t.encrypt ~= false then
                -- print("Decrypting: "..t.key);
                t.value = decrypt(menu.datas[t.key]);
            end
            
        end
    end
end

-- Esta función actualiza la configuración durante la ejecución.
util.conf_update = function(self, _spec)
    util:set_base_address();

    -- Ejecutar cada elemento, guardar los datos y extraer sus valores
    self.data = menu:setup();

    -- Guardar los datos de configuración
    gg.toast("Actualización completada");
    return gg.saveVariable(util.data, "/sdcard/catfood/conf.lua");
end

-- util.gen_menu(mnu_name)の返却値はutil[menu_name.."_datas"]に依存します。
util.gen_menu = function(self, menu_name)
    local datas = util.data[menu_name.."_datas"];
    local names, values, types = {}, {}, {};
    for i = 1, #datas do
        table.insert(names, datas[i].name or "noname");
        table.insert(types, datas[i].type or "checkbox");
        table.insert(values, datas[i].value);
    end
    return names, values, types;
end

util.exe = function(self, data, val)
    -- 数値があるかチェック
    if menu.datas[data.key] and #menu.datas[data.key] == 0 and data.encrypt ~= false then
        local _, v = xpcall(menu[data.key.."_b"], function()
            gg.alert("Error de configuración: "..data.key.."\n\nSe omitió la ejecución.");
            return nil;
        end, data.key);
        if not v then
            return gg.toast("Se omitió la ejecución.");
        end
        data.value = v or 0;
        local save_path = menu.path:gsub("?", menu.version);
        gg.saveVariable(menu.datas, save_path);
    end

    local value = menu[data.key](data.key, val);
    if data.type == "number" and data.encrypt ~= false then
        data.value = tostring(val);
    end
    -- gg.saveVariable(util.data, "/sdcard/catfood/conf.lua");
end

util.input_type = function(self)
    local datas = self.data;
    local checked = datas.basic_datas[1].type == "number" and 1 or 2;
    local mp2 = gg.choice({
        "Barra deslizante", 
        "Entrada directa"
    }, checked, "Selecciona el formato de entrada de los datos numéricos.");

    if mp2 == checked then
        return gg.toast("Operación cancelada");
    end

    local type = mp2 == 1 and "number" or "not_seek";
    local data = {};
    for _, s in ipairs(datas.menu_names) do
        for t = 1, #datas[s.."_datas"] do
            data = datas[s.."_datas"][t];
            if data.type == "number" or data.type == "not_seek"then
                data.type = type;
            end
        end
    end
    gg.toast("Completado");
end

util.data_link = function(self)

end

return util;