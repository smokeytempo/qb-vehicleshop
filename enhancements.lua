-- qb-vehicleshop enhancements.lua
-- This file contains enhanced features for the qb-vehicleshop script

local QBCore = exports['qb-core']:GetCoreObject()

-- Vehicle Stats Cache
local VehicleStatCache = {}

-- Get vehicle performance stats
local function GetVehicleStats(model)
    if VehicleStatCache[model] then return VehicleStatCache[model] end
    
    -- Default values
    local stats = {
        topSpeed = 0,
        acceleration = 0,
        braking = 0,
        handling = 0
    }
    
    -- Calculate vehicle stats
    local vehicleHash = GetHashKey(model)
    if not IsModelInCdimage(vehicleHash) then return stats end
    
    stats.topSpeed = GetVehicleModelMaxSpeed(vehicleHash) * 3.6 -- Convert to km/h
    stats.acceleration = GetVehicleModelAcceleration(vehicleHash) * 10
    stats.braking = GetVehicleModelMaxBraking(vehicleHash) * 10
    stats.handling = GetVehicleModelMaxTraction(vehicleHash)
    
    -- Normalize values to be between 0-100
    stats.topSpeed = math.floor(stats.topSpeed / 2.5)
    if stats.topSpeed > 100 then stats.topSpeed = 100 end
    
    stats.acceleration = math.floor(stats.acceleration * 10)
    if stats.acceleration > 100 then stats.acceleration = 100 end
    
    stats.braking = math.floor(stats.braking * 10)
    if stats.braking > 100 then stats.braking = 100 end
    
    stats.handling = math.floor(stats.handling * 10)
    if stats.handling > 100 then stats.handling = 100 end
    
    -- Cache the stats
    VehicleStatCache[model] = stats
    
    return stats
end

-- Format vehicle stats for display
function FormatVehicleStats(model)
    local stats = GetVehicleStats(model)
    local display = ""
    
    display = display .. "━━━━━━━━ VEHICLE STATS ━━━━━━━━\\n"
    display = display .. "Top Speed: " .. GenerateStatBar(stats.topSpeed) .. " " .. stats.topSpeed .. "\\n"
    display = display .. "Acceleration: " .. GenerateStatBar(stats.acceleration) .. " " .. stats.acceleration .. "\\n"
    display = display .. "Braking: " .. GenerateStatBar(stats.braking) .. " " .. stats.braking .. "\\n"
    display = display .. "Handling: " .. GenerateStatBar(stats.handling) .. " " .. stats.handling .. "\\n"
    display = display .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    return display
end

-- Generate a visual bar for stat display
function GenerateStatBar(value)
    local barLength = 10
    local filledBars = math.floor(value / (100 / barLength))
    
    local bar = ""
    for i = 1, barLength do
        if i <= filledBars then
            bar = bar .. "█"
        else
            bar = bar .. "▒"
        end
    end
    
    return bar
end

-- Apply test drive discount
function ApplyTestDriveDiscount(vehiclePrice)
    if not Config.AllowTestDriveDiscount then return vehiclePrice end
    
    local discount = math.floor(vehiclePrice * Config.TestDriveDiscount)
    local finalPrice = vehiclePrice - discount
    
    return finalPrice, discount
end

-- Apply vehicle tax
function ApplyVehicleTax(vehiclePrice)
    if not Config.EnableVehicleTax then return vehiclePrice, 0 end
    
    local taxAmount = math.floor(vehiclePrice * Config.VehicleTaxPercentage)
    local finalPrice = vehiclePrice + taxAmount
    
    return finalPrice, taxAmount
end

-- Custom color picker for vehicle purchase
function OpenColorPickerMenu(vehicle, callback)
    if not Config.EnableCustomColors then 
        callback(0, 0) -- Default colors
        return 
    end
    
    local colorOptions = {
        {
            header = "Choose Primary Color",
            isMenuHeader = true
        }
    }
    
    local colors = {
        {name = "Black", colorIndex = 0},
        {name = "Carbon Black", colorIndex = 147},
        {name = "Graphite", colorIndex = 1},
        {name = "Anthracite Black", colorIndex = 11},
        {name = "Black Steel", colorIndex = 2},
        {name = "Dark Steel", colorIndex = 3},
        {name = "Silver", colorIndex = 4},
        {name = "Bluish Silver", colorIndex = 5},
        {name = "Rolled Steel", colorIndex = 6},
        {name = "Shadow Silver", colorIndex = 7},
        {name = "Stone Silver", colorIndex = 8},
        {name = "Midnight Silver", colorIndex = 9},
        {name = "Cast Iron Silver", colorIndex = 10},
        {name = "Red", colorIndex = 27},
        {name = "Torino Red", colorIndex = 28},
        {name = "Formula Red", colorIndex = 29},
        {name = "Lava Red", colorIndex = 150},
        {name = "Blaze Red", colorIndex = 30},
        {name = "Grace Red", colorIndex = 31},
        {name = "Garnet Red", colorIndex = 32},
        {name = "Sunset Red", colorIndex = 33},
        {name = "Cabernet Red", colorIndex = 34},
        {name = "Wine Red", colorIndex = 143},
        {name = "Candy Red", colorIndex = 35},
        {name = "Hot Pink", colorIndex = 135},
        {name = "Pfsiter Pink", colorIndex = 137},
        {name = "Salmon Pink", colorIndex = 136},
        {name = "Sunrise Orange", colorIndex = 36},
        {name = "Orange", colorIndex = 38},
        {name = "Bright Orange", colorIndex = 138},
        {name = "Gold", colorIndex = 99},
        {name = "Bronze", colorIndex = 90},
        {name = "Yellow", colorIndex = 88},
        {name = "Race Yellow", colorIndex = 89},
        {name = "Dew Yellow", colorIndex = 91},
        {name = "Green", colorIndex = 139},
        {name = "Dark Green", colorIndex = 49},
        {name = "Racing Green", colorIndex = 50},
        {name = "Sea Green", colorIndex = 51},
        {name = "Olive Green", colorIndex = 52},
        {name = "Bright Green", colorIndex = 53},
        {name = "Gasoline Green", colorIndex = 54},
        {name = "Blue", colorIndex = 64},
        {name = "Midnight Blue", colorIndex = 141},
        {name = "Dark Blue", colorIndex = 62},
        {name = "Saxon Blue", colorIndex = 63},
        {name = "Navy Blue", colorIndex = 65},
        {name = "Harbor Blue", colorIndex = 66},
        {name = "Diamond Blue", colorIndex = 67},
        {name = "Surf Blue", colorIndex = 68},
        {name = "Nautical Blue", colorIndex = 69},
        {name = "Racing Blue", colorIndex = 73},
        {name = "Ultra Blue", colorIndex = 70},
        {name = "Light Blue", colorIndex = 74},
        {name = "Chocolate Brown", colorIndex = 96},
        {name = "Bison Brown", colorIndex = 101},
        {name = "Creek Brown", colorIndex = 95},
        {name = "Feltzer Brown", colorIndex = 94},
        {name = "Maple Brown", colorIndex = 97},
        {name = "Beechwood Brown", colorIndex = 103},
        {name = "Sienna Brown", colorIndex = 104},
        {name = "Saddle Brown", colorIndex = 98},
        {name = "Moss Brown", colorIndex = 100},
        {name = "Woodbeech Brown", colorIndex = 102},
        {name = "Straw Brown", colorIndex = 99},
        {name = "Sandy Brown", colorIndex = 105},
        {name = "Bleached Brown", colorIndex = 106},
        {name = "Schafter Purple", colorIndex = 71},
        {name = "Spinnaker Purple", colorIndex = 72},
        {name = "Midnight Purple", colorIndex = 142},
        {name = "Bright Purple", colorIndex = 145},
        {name = "Cream", colorIndex = 107},
        {name = "Ice White", colorIndex = 111},
        {name = "Frost White", colorIndex = 112}
    }
    
    for _, color in ipairs(colors) do
        table.insert(colorOptions, {
            header = color.name,
            params = {
                event = "qb-vehicleshop:client:setSecondaryColor",
                args = {
                    vehicle = vehicle,
                    colorIndex = color.colorIndex,
                    colorName = color.name,
                    callback = callback
                }
            }
        })
    end
    
    exports['qb-menu']:openMenu(colorOptions)
end

RegisterNetEvent('qb-vehicleshop:client:setSecondaryColor', function(data)
    local colorOptions = {
        {
            header = "Choose Secondary Color",
            isMenuHeader = true
        },
        {
            header = "Same as Primary",
            params = {
                event = "qb-vehicleshop:client:confirmColors",
                args = {
                    primaryColor = data.colorIndex,
                    secondaryColor = data.colorIndex,
                    primaryName = data.colorName,
                    secondaryName = data.colorName,
                    vehicle = data.vehicle,
                    callback = data.callback
                }
            }
        }
    }
    
    local colors = {
        {name = "Black", colorIndex = 0},
        {name = "Carbon Black", colorIndex = 147},
        {name = "Graphite", colorIndex = 1},
        {name = "Anthracite Black", colorIndex = 11},
        {name = "Black Steel", colorIndex = 2},
        {name = "Dark Steel", colorIndex = 3},
        {name = "Silver", colorIndex = 4},
        {name = "Bluish Silver", colorIndex = 5},
        {name = "Rolled Steel", colorIndex = 6},
        {name = "Shadow Silver", colorIndex = 7},
        {name = "Stone Silver", colorIndex = 8},
        {name = "Midnight Silver", colorIndex = 9},
        {name = "Cast Iron Silver", colorIndex = 10},
        {name = "Red", colorIndex = 27},
        {name = "Torino Red", colorIndex = 28},
        {name = "Formula Red", colorIndex = 29},
        {name = "Lava Red", colorIndex = 150},
        {name = "Blaze Red", colorIndex = 30},
        {name = "Grace Red", colorIndex = 31},
        {name = "Garnet Red", colorIndex = 32},
        {name = "Sunset Red", colorIndex = 33},
        {name = "Cabernet Red", colorIndex = 34},
        {name = "Wine Red", colorIndex = 143},
        {name = "Candy Red", colorIndex = 35},
        {name = "Hot Pink", colorIndex = 135},
        {name = "Pfsiter Pink", colorIndex = 137},
        {name = "Salmon Pink", colorIndex = 136},
        {name = "Sunrise Orange", colorIndex = 36},
        {name = "Orange", colorIndex = 38},
        {name = "Bright Orange", colorIndex = 138},
        {name = "Gold", colorIndex = 99},
        {name = "Bronze", colorIndex = 90},
        {name = "Yellow", colorIndex = 88},
        {name = "Race Yellow", colorIndex = 89},
        {name = "Dew Yellow", colorIndex = 91},
        {name = "Green", colorIndex = 139},
        {name = "Dark Green", colorIndex = 49},
        {name = "Racing Green", colorIndex = 50},
        {name = "Sea Green", colorIndex = 51},
        {name = "Olive Green", colorIndex = 52},
        {name = "Bright Green", colorIndex = 53},
        {name = "Gasoline Green", colorIndex = 54},
        {name = "Blue", colorIndex = 64},
        {name = "Midnight Blue", colorIndex = 141},
        {name = "Dark Blue", colorIndex = 62},
        {name = "Saxon Blue", colorIndex = 63},
        {name = "Navy Blue", colorIndex = 65},
        {name = "Harbor Blue", colorIndex = 66},
        {name = "Diamond Blue", colorIndex = 67},
        {name = "Surf Blue", colorIndex = 68},
        {name = "Nautical Blue", colorIndex = 69},
        {name = "Racing Blue", colorIndex = 73},
        {name = "Ultra Blue", colorIndex = 70},
        {name = "Light Blue", colorIndex = 74},
        {name = "Chocolate Brown", colorIndex = 96},
        {name = "Bison Brown", colorIndex = 101},
        {name = "Creek Brown", colorIndex = 95},
        {name = "Feltzer Brown", colorIndex = 94},
        {name = "Maple Brown", colorIndex = 97},
        {name = "Beechwood Brown", colorIndex = 103},
        {name = "Sienna Brown", colorIndex = 104},
        {name = "Saddle Brown", colorIndex = 98},
        {name = "Moss Brown", colorIndex = 100},
        {name = "Woodbeech Brown", colorIndex = 102},
        {name = "Straw Brown", colorIndex = 99},
        {name = "Sandy Brown", colorIndex = 105},
        {name = "Bleached Brown", colorIndex = 106},
        {name = "Schafter Purple", colorIndex = 71},
        {name = "Spinnaker Purple", colorIndex = 72},
        {name = "Midnight Purple", colorIndex = 142},
        {name = "Bright Purple", colorIndex = 145},
        {name = "Cream", colorIndex = 107},
        {name = "Ice White", colorIndex = 111},
        {name = "Frost White", colorIndex = 112}
    }
    
    for _, color in ipairs(colors) do
        table.insert(colorOptions, {
            header = color.name,
            params = {
                event = "qb-vehicleshop:client:confirmColors",
                args = {
                    primaryColor = data.colorIndex,
                    secondaryColor = color.colorIndex,
                    primaryName = data.colorName,
                    secondaryName = color.name,
                    vehicle = data.vehicle,
                    callback = data.callback
                }
            }
        })
    end
    
    exports['qb-menu']:openMenu(colorOptions)
end)

RegisterNetEvent('qb-vehicleshop:client:confirmColors', function(data)
    QBCore.Functions.Notify('Selected Colors: ' .. data.primaryName .. ' (Primary) / ' .. data.secondaryName .. ' (Secondary)', 'success')
    data.callback(data.primaryColor, data.secondaryColor)
end)

-- Check if player has test driven a vehicle
-- Used to apply test drive discount
local TestDrivenVehicles = {}

function HasTestDriven(vehicle)
    return TestDrivenVehicles[vehicle] ~= nil
end

function AddTestDrivenVehicle(vehicle)
    TestDrivenVehicles[vehicle] = true
end

-- Export functions for use in other scripts
exports('FormatVehicleStats', FormatVehicleStats)
exports('ApplyTestDriveDiscount', ApplyTestDriveDiscount)
exports('ApplyVehicleTax', ApplyVehicleTax)
exports('OpenColorPickerMenu', OpenColorPickerMenu)
exports('HasTestDriven', HasTestDriven)
exports('AddTestDrivenVehicle', AddTestDrivenVehicle)
