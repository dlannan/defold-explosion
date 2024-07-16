--useful constants
local STANDARD_GRAVITY = 9.80665
local RSpecificAir = 287.058
local heatCapacityRatio = 1.4

--Layer data
--https://en.wikipedia.org/wiki/International_Standard_Atmosphere
local layers = {
    {
        layer= 0,
        name= 'Troposphere',
        baseGeopotential= -610,
        baseGeometric= -611,
        lapse= 6.5,
        baseTemperature= 19.0,
        basePressure= 108900,
        baseDensity= 1.2985,
    },
    {
        layer= 1,
        name= 'Tropopause',
        baseGeopotential= 11000,
        baseGeometric= 11019,
        lapse= 0.0,
        baseTemperature= -56.5,
        basePressure= 22632,
        baseDensity= 0.3639,
    },
    {
        layer= 2,
        name= 'Stratosphere',
        baseGeopotential= 20000,
        baseGeometric= 20063,
        lapse= -1.0,
        baseTemperature= -56.5,
        basePressure= 5474.9,
        baseDensity= 0.088,
    },
    {
        layer= 3,
        name= 'Stratosphere',
        baseGeopotential= 32000,
        baseGeometric= 32162,
        lapse= -2.8,
        baseTemperature= -44.5,
        basePressure= 868.02,
        baseDensity= 0.0132,
    },
    {
        layer= 4,
        name= 'Stratopause',
        baseGeopotential= 47000,
        baseGeometric= 47350,
        lapse= 0.0,
        baseTemperature= -2.5,
        basePressure= 110.91,
        baseDensity= 0.002,
    },
    {
        layer= 5,
        name= 'Mesosphere',
        baseGeopotential= 51000,
        baseGeometric= 51413,
        lapse= 2.8,
        baseTemperature= -2.5,
        basePressure= 66.939,
        baseDensity= 0.00086,
    },
    {
        layer= 6,
        name= 'Mesosphere',
        baseGeopotential= 71000,
        baseGeometric= 71802,
        lapse= 2.0,
        baseTemperature= -58.5,
        basePressure= 3.9564,
        baseDensity= 0.000064,
    },
    {
        layer= 7,
        name= 'Mesopause',
        baseGeopotential= 84852,
        baseGeometric= 86000,
        lapse= 0,
        baseTemperature= -86.28,
        basePressure= 0.3734,
        baseDensity= 0.00000696,
    },
}

-- /**
--  * Convert Celsius to Kelvin
--  * @param {Number} temperature Temperature in celsius
--  */
local function celsiusToKelvin(temperature) 
    return temperature + 273.15
end

-- /**
--  * Calculate temperature given atmospheric layer and altitude
--  * @param {Object} layer Atmospheric layer data
--  * @param {Number} height Altitude
--  */
local function getTemperature(layer, height) 
    local bT = celsiusToKelvin(layer.baseTemperature)
    local a = layer.lapse / 1000
    local deltaHeight = height - layer.baseGeometric

    local temperature = bT - deltaHeight * a
    return temperature
end

-- /**
--  * Calculate pressure of layer with no lapse rate
--  * @param {Object} layer Atmospheric layer data
--  * @param {Number} height Altitude
--  */
local function getPressureNoLapse(layer, height) 
    --https://en.wikipedia.org/wiki/Barometric_formula
    local l = layer
    local bT = celsiusToKelvin(l.baseTemperature)
    local eqExponent = (-STANDARD_GRAVITY * (height - l.baseGeometric)) / (bT * RSpecificAir)
    local pressure = l.basePressure * math.exp(eqExponent)
    return pressure
end

-- /**
--  * Calculate pressure
--  * @param {Object} layer Atmospheric layer data
--  * @param {Number} temperature temperature in celsius
--  */
local function getPressure(layer, temperature) 
    local l = layer
    local lapse = l.lapse / 1000
    local bT = celsiusToKelvin(l.baseTemperature)

    --P = Pl * (T/Tl)^(-g0/a*R)
    local eqExponent = STANDARD_GRAVITY / (lapse * RSpecificAir)

    local pressure = l.basePressure * ((temperature / bT) ^ eqExponent)

    return pressure
end

-- /**
--  * Get atmospheric layer data
--  * @param {Number} height Altitude (m)
--  */
local function getLayer(height) 
    --find atmospheric layer
    for  i = 1, #layers-1 do
        if (height < layers[i+1].baseGeometric) then 
            return layers[i]
        end
    end
    return nil
end

-- /**
--  * Calculate speed of sound in air
--  * @param {Number} temperature Temperature in Kelvin
--  */
local function speedOfSound(temperature) 
    return math.sqrt(heatCapacityRatio * RSpecificAir * temperature)
end

-- /**
--  * Get the atmospheric data for a given altitude using ISA
--  * @param {Number} altitude altitude (m)
--  */
local function ISA(altitude) 
    if (altitude > 86000 or altitude < -611) then
        return {
            temperature= 0,
            pressure= 0,
            density= 0,
            soundSpeed= 0,
        }
    end

    local layer = getLayer(altitude)

    local temperature = getTemperature(layer, altitude)
    local pressure = 0
    if (layer.lapse == 0) then
        pressure = getPressureNoLapse(layer, altitude)
    else 
        pressure = getPressure(layer, temperature)
    end
    local density = pressure / (RSpecificAir * temperature)
    local soundSpeed = speedOfSound(temperature)
    return {
        temperature=temperature,
        pressure=pressure,
        density=density,
        soundSpeed=soundSpeed,
    }
end

return {
    ISA         = ISA,
}

