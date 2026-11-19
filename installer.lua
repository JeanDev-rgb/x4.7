-- [[ Nyanko_x4.7 - Instalador ]]
-- Repositorio: https://github.com/JeanDev-rgb/x4.7
local repo_mods = "https://raw.githubusercontent.com/JeanDev-rgb/x4.7/refs/heads/main/mods/";
local repo_ext = "https://raw.githubusercontent.com/JeanDev-rgb/x4.7/refs/heads/main/ext/";
local repo_idx = "https://raw.githubusercontent.com/JeanDev-rgb/x4.7/refs/heads/main/index.lua";
local path = "/sdcard/catfood/mods/";
local my_name = gg.getFile():match("[^/]+$");

-- Nombres de los módulos
local package = {"menu", "util"};
local ext_list = {"Designate_Char"};

-- Crear los directorios necesarios y eliminar los archivos temporales de direcciones
local addr_path = ("%saddress_pack.txt"):format(path);
gg.saveList(addr_path);
os.remove(addr_path);

-- Preparar el directorio de datos
addr_path = ("%saddress_pack.txt"):format(path.."../datas/");
gg.saveList(addr_path);
os.remove(addr_path);

-- Preparar el directorio de extensiones
addr_path = ("%saddress_pack.txt"):format(path.."../ext/");
gg.saveList(addr_path);
os.remove(addr_path);

-- Descargar los módulos desde el repositorio.
for _, mod_name in ipairs(package)do
    local mod = gg.makeRequest(("%s%s.lua"):format(repo_mods, mod_name));

    -- Si la descarga tiene éxito, guardar en /sdcard/catfood/mods/.
    if mod and mod.code == 200 then
        local fw = io.open(("%s%s.lua"):format(path, mod_name), "w");
        fw:write(mod.content);
        fw:close();
    else
        print(table.concat({
            "No se pudo descargar el módulo.\nComprueba tu conexión a Internet."
        }, "\n\n"));
        return os.exit();
    end
end

-- Descargar el archivo principal.
local idx_pro = gg.makeRequest(repo_idx);

-- Si la descarga tiene éxito, guardar como Nyanko_x4.7.lua.
if idx_pro and idx_pro.code == 200 then
    os.remove(my_name);
    local fw = io.open("./Nyanko_x4.7.lua", "w");
    fw:write(idx_pro.content);
    fw:close();
else
    print(table.concat({
        "No se pudo descargar el archivo principal.\nComprueba tu conexión a Internet."
    }, "\n\n"));
    return os.exit();
end

-- Descargar las extensiones.
for _, ext_name in ipairs(ext_list) do
    local ext = gg.makeRequest(("%s%s.lua"):format(repo_ext, ext_name));

    -- Si la descarga tiene éxito, guardar en /sdcard/catfood/ext/.
    if ext and ext.code == 200 then
        local fw = io.open(("%s%s.lua"):format(path.."../ext/", ext_name), "w");
        fw:write(ext.content);
        fw:close();
    else
        print(table.concat({
            "No se pudo descargar la extensión.\nComprueba tu conexión a Internet."
        }, "\n\n"));
        return os.exit();
    end
end

-- Descarga completada.
print(table.concat({
    "Nyanko_x4.7: descarga completada.", 
    ("[ %s ] se ha renombrado como [ Nyanko_x4.7.lua ]"):format(my_name)
}, "\n\n"));