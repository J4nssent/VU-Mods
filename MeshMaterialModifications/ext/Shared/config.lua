require('__shared/mergeTables')

-- CUSTOM SHADER PARAMETERS
local NO_WEAR_SHADER_PARAMETERS = {
	ScatchAmount = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	SmoothnessMasked = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	SmoothnessRegular = { VALUE = Vec4(1, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	SmoothnessWear = { VALUE = Vec4(1, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	SpecularBrightness = { VALUE = Vec4(2, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	WearAmount = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
	WearPower = { VALUE = Vec4(1, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
}

-- CUSTOM TEXTURE CONFIGS
local BLACK_CAMO_TEXTURE = {
	TYPE = ParameterModificationType.ModifyParameters,
	PARAMETERS = {
		Camo = "Weapons/Textures/Blacktape_D",
	}
}

-- CUSTOM MATERIAL CONFIGS
local SMOOTH_BLACK_CAMO_LAND_MATERIAL = {
	SHADER = {
		TYPE = ParameterModificationType.ModifyOrAddParameters,
		PARAMETERS = mergeTables(
			NO_WEAR_SHADER_PARAMETERS, {
			CamoBrightness = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Color },
			CamoTiling = { VALUE = Vec4(2, 2, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Vec2 },
			}
		)
	},
	TEXTURES = {
		TYPE = ParameterModificationType.ModifyParameters,
		PARAMETERS = {
			Camo = "Characters/shared/ColorSwatches/white",
		}
	}
}

local SMOOTH_PINK_CAMO_AIR_MATERIAL = {
	SHADER = {
		TYPE = ParameterModificationType.ModifyOrAddParameters,
		PARAMETERS = mergeTables(
			NO_WEAR_SHADER_PARAMETERS, {
			CamoBrightness = { VALUE = Vec4(1, 0, 0.8, 0), TYPE = ShaderParameterType.ShaderParameterType_Color },
			CamoTiling = { VALUE = Vec4(2, 2, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Vec2 },
			}
		)
	},
	TEXTURES = {
		TYPE = ParameterModificationType.ModifyParameters,
		PARAMETERS = {
			CamoA = "Characters/shared/ColorSwatches/white",
			CamoB = "Characters/shared/ColorSwatches/white",
		}
	}
}

-- FULL MESH CONFIGS
local GOLD_MAGUM_CONFIG = {
	MATERIALS = {
		[1] = {
			SHADER = {
				TYPE = ParameterModificationType.ModifyOrAddParameters,
				PARAMETERS = mergeTables({ 
					DiffuseDarkening = { VALUE = Vec4(1, 0.9, 0, -100), TYPE = ShaderParameterType.ShaderParameterType_Color } 
					}, NO_WEAR_SHADER_PARAMETERS
				)
			}
		}
	}
}

local BLACK_M16_CONFIG = {
	MATERIALS = {
		[1] = { SHADER = { NAME = "SomeNoneExistentShader" } },
		[2] = { TEXTURES = BLACK_CAMO_TEXTURE },
		[3] = { SHADER = { NAME = "SomeNoneExistentShader" } },
		[4] = { TEXTURES = BLACK_CAMO_TEXTURE },
	}
}

local BLACK_M16_SIGHT_CONFIG = {
	MATERIALS = {
		[1] = {	TEXTURES = BLACK_CAMO_TEXTURE },
		[2] = {	TEXTURES = BLACK_CAMO_TEXTURE },
	}
}


local config = {

	-- JUNGLE LAV ---------------------------------------------------------------------------------------------
	-- vehicles/lav25/lav25_Mesh
	['651E110D-9DD1-F900-658E-18504BD8ABF1'] = {
		MATERIALS = {
			[3] = {
				TEXTURES = {
					TYPE = ParameterModificationType.ModifyParameters,
					PARAMETERS = {
						Camo = "Characters/Shared/ClothCamo/RU_Partizan_01",
					}
				}
			},
		}
	},

	-- BLUE KOBRA  --------------------------------------------------------------------------------------------
	-- weapons/accessories/kobra/kobra_reticule_1p_Mesh
	['E8823571-723C-3EF2-87F7-12A177136C55'] = {
		MATERIALS = {
			[1] = {
				SHADER = {
					TYPE = ParameterModificationType.ModifyOrAddParameters,
					PARAMETERS = {
						Color = { VALUE = Vec4(0.0, 0.0, 0.7, 1.0), TYPE = ShaderParameterType.ShaderParameterType_Color },
					}
				}
			},
		}
	},

	-- PURPLE CIVILIAN CAR ------------------------------------------------------------------------------------
	-- props/vehicles/civiliancar_03/civiliancar_03_Mesh
	['0522EAB2-AAE1-C82A-2EC6-28C2A238FEB7'] = {
		MATERIALS = {
			[1] = {
				SHADER = {
					TYPE = ParameterModificationType.ModifyParameters,
					PARAMETERS = {
						CoatColor = { VALUE = Vec4(0.1, 0.058, 0.2, 1), TYPE = ShaderParameterType.ShaderParameterType_Color },
					}
				}
			},
			[6] = {
				SHADER = {
					TYPE = ParameterModificationType.ModifyParameters,
					PARAMETERS = {
						CoatColor = { VALUE = Vec4(0.1, 0.058, 0.2, 1), TYPE = ShaderParameterType.ShaderParameterType_Color },
					}
				}
			}
		}
	},

	-- SILVER/GLASS MEDKIT ------------------------------------------------------------------------------------
	-- weapons/gadgets/medicbag/mediccrate_projectile_Mesh
	['BC6154A0-CDFC-D402-ECCA-444811062765'] = {
		MATERIALS = {
			[1] = {
				SHADER = {
					NAME = "Weapons/Shaders/Solid_Glass",
					TYPE = ParameterModificationType.ReplaceParameters,
				},
			},
		}
	},

	-- BLACK SHINY HUMVEE -------------------------------------------------------------------------------------
	-- vehicles/humveearmored/humveearmored_Mesh
	['1EF65CDB-ABED-FD37-6E17-BE3D2C497B05'] = {
		MATERIALS = {
			[1] = SMOOTH_BLACK_CAMO_LAND_MATERIAL,
			[8] = SMOOTH_BLACK_CAMO_LAND_MATERIAL
		}
	},

	-- PINK SHINY Z11 -----------------------------------------------------------------------------------------
	-- vehicles/z11w/z-11w_Mesh
	['D780B071-38B7-11DE-BF1C-984D9AEE762C'] = {
		MATERIALS = {
			[3] = SMOOTH_PINK_CAMO_AIR_MATERIAL,
			[7] = SMOOTH_PINK_CAMO_AIR_MATERIAL,
			[8] = SMOOTH_PINK_CAMO_AIR_MATERIAL
		}
	},

	-- GOLD MAGNUM --------------------------------------------------------------------------------------------
	-- weapons/taurus44/taurus44_1p_Mesh
	['8EE94AD0-0E0B-DE6C-F68A-B602B9A7E0EB'] = GOLD_MAGUM_CONFIG,
	-- weapons/taurus44/taurus44_3p_Mesh
	['D47D9E4A-E1F0-76A0-9ECD-2C24FAE78714'] = GOLD_MAGUM_CONFIG,

	-- BLACK M16A4 (WITHOUT STOCK CLOTH) ----------------------------------------------------------------------
	-- weapons/m16a4/m16a4_1p_Mesh
	['BA1C98ED-C0FA-0B1A-B371-8AFCE1505B01'] = BLACK_M16_CONFIG,
	-- weapons/m16a4/m16a4_3p_Mesh
	['1EF3B639-6E13-0BC7-B909-9D3408C5D537'] = BLACK_M16_CONFIG,

	-- BLACK IRONSIGHT/SIGHT
	-- weapons/accessories/m16_ironsight/m16_sight_1p_Mesh
	['DE3E1B98-AABE-ADB3-918B-33A003785A76'] = BLACK_M16_SIGHT_CONFIG,
	-- weapons/accessories/m16_ironsight/m16_sight_3p_Mesh
	['29DE7061-1216-DB69-84E7-02211ACE0345'] = BLACK_M16_SIGHT_CONFIG,

	-- BLACK IRONSIGHT/IRONSIGHT
	-- weapons/accessories/m16_ironsight/m16_ironsight_1p_Mesh
	['14EA621F-DDFD-A5C7-852B-6D351DFB318B'] = BLACK_M16_SIGHT_CONFIG,
	-- weapons/accessories/m16_ironsight/m16_ironsight_3p_Mesh
	['2B01B83B-3E70-9318-F6B4-07D54478A901'] = BLACK_M16_SIGHT_CONFIG,
}

return config

--[[
	[<MeshAsset_Guid>] = {
		VARIATION_HASH = <ObjectVariationHash> (defaults to 0 if not specified)
		MATERIALS = 
			[<MeshMaterial_Index>] = {
				SHADER = {
					TYPE = <ParameterModificationType>,
					NAME = <ShaderGraph_Name>,
					PARAMETERS = {
						<VectorShaderParameter_parameterName> = { TYPE = <ShaderParameterType>, VALUE = <Vec4> }
					}
				},
				TEXTURES = {
					TYPE = <ParameterModificationType>,
					PARAMETERS = {
						<TextureShaderParameter_parameterName> = <TextureAsset_Name>,
					}
				}
			}
		}
	},

ModifyParameters		-- Modifies parameters if they exist.
ModifyOrAddParameters		-- Modifies parameters if they exist, adds them if they don't.
ReplaceParameters		-- Clears existing parameters and adds the specified parameters.

Look at vanilla meshes and materials to find out what vector and texture parameters can be used for a shader.
A dump of the VectorShaderParameters and the shaders they're used with can be found in the mod folder.

Textures in Weapon_ShaderStateAssets can only be replaced with other textures from Weapon_ShaderStateAssets (no ClothCamo textures f.e.)

ParameterModificationType.ReplaceParameters will clear the MeshVariationDatabaseMaterial.textureParameters array.
Just clearing this array causes a crash, instead, the MeshVariationDatabaseMaterial is replaced with a new MeshVariationDatabaseMaterial, and the original MeshMaterial is assigned to it.
--]]
