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
local SMOOTH_PINK_CAMO_LAND_MATERIAL = {
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
			}, 
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
		[2] = { TEXTURES = BLACK_CAMO_TEXTURE },
		[4] = { TEXTURES = BLACK_CAMO_TEXTURE }
		}
	}
}


local config = {
	
	-- JUNGLE LAV -------------------------------------------------------------------------------------
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


	-- SILVER/GLASS MEDKIT
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

	-- PINK SHINY HUMVEE -------------------------------------------------------------------------------------
	-- vehicles/humveearmored/humveearmored_Mesh
	['1EF65CDB-ABED-FD37-6E17-BE3D2C497B05'] = {
		MATERIALS = {
			[1] = SMOOTH_BLACK_CAMO_LAND_MATERIAL,
			[8] = SMOOTH_BLACK_CAMO_LAND_MATERIAL
		}
	},

	-- PINK SHINY Z11 -------------------------------------------------------------------------------------
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

	-- BLACK M16A4 --------------------------------------------------------------------------------------------
	-- weapons/m16a4/m16a4_1p_Mesh
	['BA1C98ED-C0FA-0B1A-B371-8AFCE1505B01'] = BLACK_M16_CONFIG,
	-- weapons/m16a4/m16a4_3p_Mesh
	['1EF3B639-6E13-0BC7-B909-9D3408C5D537'] = BLACK_M16_CONFIG,
}

return config

--[[
Changes to a MeshMaterial's shader name or parameters don't appear to have an effect. 
If SHADER.REPLACE is set, the MeshVariationDatabaseMaterial's MeshMaterial will be replaced with a new MeshMaterial instance.

If a shader name is specified, shader will be replaced regardless of what SHADER.REPLACE is set to. 
If SHADER.REPLACE is set, the existing VectorParameters will be lost (so you have to include all parameters, not just those that should be modified)

Look at vanilla meshes and materials to find out what shader parameters can be used for a shader or what texture parameters work for a material

Textures in Weapon_ShaderStateAssets can only be replaced with other textures from Weapon_ShaderStateAssets (no ClothCamo textures)

If TEXTURES.REPLACE is set, MeshVariationDatabaseMaterial.textureParameters gets cleared.
If defined, new TextureShaderParameters are created and added to the textureParameters array, this causes a crash.
Workaround is to replace the MeshVariationDatabaseMaterial with a new MeshVariationDatabaseMaterial struct (and copy over material).



	[<MeshAsset_Guid>] = {
		[<MeshMaterial_Index>] = {
			SHADER = {
				REPLACE = <CreateNewMeshMaterial_bool>
				NAME = <ShaderAsset_Name>,
				PARAMETERS = {
					<VectorShaderParameterName> = { TYPE = <ParameterType>, VALUE = <Value_Vec4> }
				}
			},
			TEXTURES = {
				REPLACE = <ClearExistingParameters_bool>
				PARAMETERS = {
					<TextureShaderParameterName> = <TextureAsset_Name>,
				}
			}
		}
	},

						ScratchTiling = Vec4(0.0, 0.0, 0.0, 0.0),
						CamoBrightness = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Color },
						CamoBrightness = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Color },
						ScatchAmount = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						SmoothnessMasked = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						SmoothnessRegular = { VALUE = Vec4(1, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						SmoothnessWear = { VALUE = Vec4(1, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						SpecularBrightness = { VALUE = Vec4(2, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						WearAmount = { VALUE = Vec4(0, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },
						WearPower = { VALUE = Vec4(10, 0, 0, 0), TYPE = ShaderParameterType.ShaderParameterType_Scalar },

--]]

--[[
MeshVariationDatabaseEntry 3C489F07-9F95-F721-33D9-20B96090AD21
    $::DataContainer
    Mesh weapons/m240/m240_bipods_3p_Mesh/7FA64A64-F204-8A4B-0956-5F8027D32CB3
    VariationAssetNameHash 0
    Materials::array
        member(0)::MeshVariationDatabaseMaterial
            Material weapons/m240/m240_bipods_3p_Mesh/65B8181A-543E-F3DD-280A-D20154831933
            MaterialVariation *nullGuid*
            TextureParameters::array
                member(0)::TextureShaderParameter
                    ParameterName Camo
                    Value Weapons/Textures/Dust_D/D0E10743-790A-1CF4-A129-DB1D42710F31
                member(1)::TextureShaderParameter
                    ParameterName Diffuse
                    Value Weapons/M240/M240_D/2E25B6D5-34AB-3464-98E3-E0F42E5400EF
                member(2)::TextureShaderParameter
                    ParameterName Specular
                    Value Weapons/M240/M240_S/A1C44010-2245-8460-2D4A-107B9645C3E5

A MeshMaterial is basically a SurfaceShader Struct with Shader instance and parameters

MeshMaterial 65B8181A-543E-F3DD-280A-D20154831933
    $::DataContainer
    ShaderInstance *nullGuid*
    Shader::SurfaceShaderInstanceDataStruct
        Shader Weapons/Shaders/WeaponPreset3P/8D89EDAD-D2B1-4BB9-B36C-1498F76C8C8B
        BoolParameters *nullArray*
        VectorParameters::array
            member(0)::VectorShaderParameter
                ParameterName Emissive
                ParameterType ShaderParameterType_Color
                Value::Vec4
                    x 0.00700000021607
                    y 0.00700000021607
                    z 0.00700000021607
                    w 0.00700000021607
            member(1)::VectorShaderParameter
                ParameterName WearAmount
                ParameterType ShaderParameterType_Scalar
                Value::Vec4
                    x 25.0
                    y 0.0
                    z 0.0
                    w 0.0
            member(2)::VectorShaderParameter
                ParameterName WearPower
                ParameterType ShaderParameterType_Scalar
                Value::Vec4
                    x 0.0
                    y 0.0
                    z 0.0
                    w 0.0
        VectorArrayParameters *nullArray*
        TextureParameters *nullArray*


ShaderGraph 8D89EDAD-D2B1-4BB9-B36C-1498F76C8C8B #primary instance
    $::SurfaceShaderBaseAsset
        $::Asset
            $::DataContainer
            Name Weapons/Shaders/WeaponPreset3P
    MaxSubMaterialCount 8
    GammaCorrectionEnable True
--]]