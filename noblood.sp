//includes
#include <cstrike>
#include <sourcemod>
#include <sdkhooks>
#include <smlib>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

ConVar g_cEnableNoBlood;
ConVar g_cEnableNoBloodSplatter;
ConVar g_cEnableNoBloodSplash;

public Plugin myinfo =
{
	name = "DisableBlood",
	author = "shanapu,bara",
	description = "Disable Blood on your server - all credits to bara",
	version = "1.0",
	url = "shanapu.de"
};

public void OnPluginStart()
{
	g_cEnableNoBlood = CreateConVar("sm_blood_disable", "0", "Enable / Disable No Blood", _, true, 0.0, true, 1.0);
	g_cEnableNoBloodSplatter = CreateConVar("sm_blood_disable_splatter", "0", "Enable / Disable No Blood Splatter", _, true, 0.0, true, 1.0);
	g_cEnableNoBloodSplash = CreateConVar("sm_blood_disable_splash", "0", "Enable / Disable No Blood Splash", _, true, 0.0, true, 1.0);

	AddTempEntHook("EffectDispatch", TE_OnEffectDispatch);
	AddTempEntHook("World Decal", TE_OnWorldDecal);
}

public Action TE_OnEffectDispatch(const char[] te_name, const Players[], int numClients, float delay)
{
	int iEffectIndex = TE_ReadNum("m_iEffectName");
	int nHitBox = TE_ReadNum("m_nHitBox");
	char sEffectName[64];
	
	GetEffectName(iEffectIndex, sEffectName, sizeof(sEffectName));
	
	if(g_cEnableNoBlood.BoolValue)
	{
		if(StrEqual(sEffectName, "csblood"))
		{
			if(g_cEnableNoBloodSplatter.BoolValue)
				return Plugin_Handled;
		}
		if(StrEqual(sEffectName, "ParticleEffect"))
		{
			if(g_cEnableNoBloodSplash.BoolValue)
			{
				char sParticleEffectName[64];
				GetParticleEffectName(nHitBox, sParticleEffectName, sizeof(sParticleEffectName));
				
				if(StrEqual(sParticleEffectName, "impact_helmet_headshot") || StrEqual(sParticleEffectName, "impact_physics_dust"))
					return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action TE_OnWorldDecal(const char[] te_name, const Players[], int numClients, float delay)
{
	float vecOrigin[3];
	int nIndex = TE_ReadNum("m_nIndex");
	char sDecalName[64];
	
	TE_ReadVector("m_vecOrigin", vecOrigin);
	GetDecalName(nIndex, sDecalName, sizeof(sDecalName));
	
	if(g_cEnableNoBlood.BoolValue)
	{
		if(StrContains(sDecalName, "decals/blood") == 0 && StrContains(sDecalName, "_subrect") != -1)
			if(g_cEnableNoBloodSplash.BoolValue)
				return Plugin_Handled;
	}
	return Plugin_Continue;
}

stock int GetParticleEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetDecalName(int index, char[] sDecalName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("decalprecache");
	
	return ReadStringTable(table, index, sDecalName, maxlen);
}