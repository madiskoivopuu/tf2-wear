#pragma semicolon 1
#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <tf2>
#include <tf2items_2>
#include <tf2attributes>
#include <tf2_stocks>
#include <tf2idb>
#include <steamtools>
#include <client_group_status>

#define PLUGIN_VERSION		"3.0"
#define JTAG "{deeppink}[{pink}HatPaints{deeppink}]{white}"
new g_iHealth[MAXPLAYERS+1];
float fEffects[MAXPLAYERS+1] = 0.0;
Handle hUnusualMenu;
Handle hEquipWearable;
Handle hGiveNamedItem;
Handle g_hClientHats[8];	//0 - Head, 1 - Misc, 2 - Action
Handle h_hatPaint[8];
int g_iClientHatEntities[MAXPLAYERS+1][8];
int g_iHatNum[MAXPLAYERS+1];

new const String:sMenuItems[][] = {

    {"6|Green Confetti"},
    {"7|Purple Confetti"},
    {"8|Haunted Ghosts"},
    {"9|Green Energy"},
    {"10|Purple Energy"},
    {"11|Circling TF Logo"},
    {"12|Massed Flies"},
    {"13|Burning Flames"},
    {"14|Scorching Flames"},
    {"15|Searing Plasma"},
    {"16|Vivid Plasma"},
    {"17|Sunbeams"},
    {"18|Circling Peace Sign"},
    {"19|Circling Heart"},
    {"29|Stormy Storm"},
    {"30|Blizzardy Storm"},
    {"31|Nuts n' Bolts"},
    {"32|Orbiting Planets"},
    {"33|Orbiting Fire"},
    {"34|Bubbling"},
    {"35|Smoking"},
    {"36|Steaming"},
    {"37|Flaming Lantern"},
    {"38|Cloudy Moon"},
    {"39|Cauldron Bubbles"},
    {"40|Eerie Orbiting Fire"},
    {"43|Knifestorm"},
    {"44|Misty Skull"},
    {"45|Harvest Moon"},
    {"46|It's A Secret To Everybody"},
    {"47|Stormy 13th Hour"},
    {"56|Kill-a-Watt"},
    {"57|Terror-Watt"},
    {"58|Cloud 9"},
    {"59|Aces High"},
    {"60|Dead Presidents"},
    {"61|Miami Nights"},
    {"62|Disco Beat Down"},
    {"63|Phosphorous"},
    {"64|Sulphurous"},
    {"65|Memory Leak"},
    {"66|Overclocked"},
    {"67|Electrostatic"},
    {"68|Power Surge"},
    {"69|Anti-Freeze"},
    {"70|Time Warp"},
    {"71|Green Black Hole"},
    {"72|Roboactive"},
    {"73|Arcana"},
    {"74|Spellbound"},
    {"75|Chiroptera Venenata"},
    {"76|Poisoned Shadows"},
    {"77|Something Burning This Way Comes"},
    {"78|Hellfire"},
    {"79|Darkblaze"},
    {"80|Demonflame"},
    {"81|Bonzo The All-Gnawing"},
    {"82|Amaranthine"},
    {"83|Stare From Beyond"},
    {"84|The Ooze"},
    {"85|Ghastly Ghosts Jr"},
    {"86|Haunted Phantasm Jr"},
    {"87|Frostbite"},
    {"88|Motlen Mallard"},
    {"89|Morning Glory"},
    {"90|Death At Dusk"},
    {"91|Abduction"},
    {"92|Atomic"},
    {"93|Subatomic"},
    {"94|Electric Hat Protector"},
    {"95|Magnetic Hat Protector"},
    {"96|Voltaic Hat Protector"},
    {"97|Galactic Codex"},
    {"98|Ancient Codex"},
    {"99|Nebula"},
    {"100|Death By Disco"},
    {"101|It's a mystery to everyone"},
    {"102|It's a puzzle to me"},
    {"103|Ether Trail"},
    {"104|Nether Trail"},
    {"105|Ancient Eldritch"},
    {"106|Eldritch Flame"}

};

public Plugin myinfo =
{
	name = "[TF2] Wearables",
	author = "Sparkly Cat",
	description = "Newest version of !wear",
	version = PLUGIN_VERSION,
	url = "https://www.recursion.tf"
};

public OnPluginStart()
{
	/*StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetSignature(SDKLibrary_Server, "\x0F\xB7\x41\x04\x50\xE8\x2A\x2A\x2A\x2A\x8B\xC8\xE8\x2A\x2A\x2A\x2A\x6A\x00\x68\x2A\x2A\x2A\x2A\x68\x2A\x2A\x2A\x2A\x6A\x00\x50\xE8\x2A\x2A\x2A\x2A\x83\xC4\x14\xC3", 41);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hGetStaticDataFunc = EndPrepSDKCall();
	if(hGetStaticDataFunc == INVALID_HANDLE)
	{
		SetFailState("Unable to create SDKCall for CTFItemDefinition *CEconItemView::GetStaticData");
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetSignature(SDKLibrary_Server, "\x55\x8B\xEC\x56\x8B\xF1\xE8\x2A\x2A\x2A\x2A\x8B\x55\x08\x0F\xB7\x40\x28\x3B\xD0\x74\x2A", 22);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hGetLoadoutSlotFunc = EndPrepSDKCall();
	if(hGetLoadoutSlotFunc == INVALID_HANDLE)
	{
		SetFailState("Unable to create SDKCall for CTFItemDefinition::GetLoadoutSlot");
	}*/

  Handle hGameConf = LoadGameConfigFile("tf2.wearables");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
  PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
  hEquipWearable = EndPrepSDKCall();

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "GiveNamedItem");
  PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Plain);
  hGiveNamedItem = EndPrepSDKCall();

  CloseHandle(hGameConf);

	LoadTranslations("common.phrases");

	g_hClientHats[0] = RegClientCookie("wearables_index_1", "", CookieAccess_Private);
	g_hClientHats[1] = RegClientCookie("wearables_index_2", "", CookieAccess_Private);
	g_hClientHats[2] = RegClientCookie("wearables_index_3", "", CookieAccess_Private);
  g_hClientHats[3] = RegClientCookie("wearables_index_4", "", CookieAccess_Private);
  g_hClientHats[4] = RegClientCookie("wearables_index_5", "", CookieAccess_Private);
  g_hClientHats[5] = RegClientCookie("wearables_index_6", "", CookieAccess_Private);
  g_hClientHats[6] = RegClientCookie("wearables_index_7", "", CookieAccess_Private);
  g_hClientHats[7] = RegClientCookie("wearables_index_8", "", CookieAccess_Private);
	h_hatPaint[0] = RegClientCookie("hatpaint_slot1", "", CookieAccess_Private);
	h_hatPaint[1] = RegClientCookie("hatpaint_slot2", "", CookieAccess_Private);
	h_hatPaint[2] = RegClientCookie("hatpaint_slot3", "", CookieAccess_Private);
  h_hatPaint[3] = RegClientCookie("hatpaint_slot4", "", CookieAccess_Private);
  h_hatPaint[4] = RegClientCookie("hatpaint_slot5", "", CookieAccess_Private);
  h_hatPaint[5] = RegClientCookie("hatpaint_slot6", "", CookieAccess_Private);
  h_hatPaint[6] = RegClientCookie("hatpaint_slot7", "", CookieAccess_Private);
  h_hatPaint[7] = RegClientCookie("hatpaint_slot8", "", CookieAccess_Private);

//	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEvent("post_inventory_application", Event_Inventory, EventHookMode_Post);


	RegConsoleCmd("sm_wear", Command_GiveHat);
	RegConsoleCmd("sm_wear1", Command_GiveHat);
	RegConsoleCmd("sm_wear2", Command_GiveHat2);
	RegConsoleCmd("sm_wear3", Command_GiveHat3);
  RegAdminCmd("sm_wear4", Command_GiveHat4, ADMFLAG_RESERVATION);
  RegAdminCmd("sm_wear5", Command_GiveHat5, ADMFLAG_RESERVATION);
  RegAdminCmd("sm_wear6", Command_GiveHat6, ADMFLAG_RESERVATION);
	RegConsoleCmd("sm_removehat", Command_RemoveHats);
	RegConsoleCmd("sm_removehats", Command_RemoveHats);
	RegConsoleCmd("sm_wear_r", Command_RemoveHats);
	RegConsoleCmd("sm_wear_u", Command_Unusual);
	RegConsoleCmd("sm_wear_unusual", Command_Unusual);
	RegConsoleCmd("sm_wear_unusuals", Command_Unusual);
	RegConsoleCmd("sm_unusual", Command_Unusual);
	RegConsoleCmd("sm_unusuals", Command_Unusual);
	RegConsoleCmd("sm_hatpaint", Command_HatPaints);
	RegConsoleCmd("sm_hatpaints", Command_HatPaints);

	RegAdminCmd("sm_wearclientcookie", Command_WearClientCookie, ADMFLAG_BAN);

	hUnusualMenu = Menu_BuildMain();
}

public OnClientDisconnect(int client)
{
	fEffects[client] = 0.0;
}

public OnClientPostAdminCheck(client)
{
  for(int i = 0; i < sizeof(g_hClientHats); ++i)
  {
    SetClientCookie(client, g_hClientHats[i], "0");
  }
  for(int i = 0; i < sizeof(g_hClientHats); ++i)
  {
    SetClientCookie(client, h_hatPaint[i], "0");
  }
}

// Debug admin functions
public Action Command_WearClientCookie(int client, int args)
{
	if(args != 1)
	{
		CPrintToChat(client, "{darkgreen}[DEBUG]{white} Usage: sm_wearclientcookie <target>");
		return Plugin_Handled;
	}

	new String:arg1[48];

	GetCmdArg(1, arg1, sizeof(arg1));

	int target = FindTarget(client, arg1);
	if(target == -1)
	{
		return Plugin_Handled;
	}

	char cookie1[32], cookie2[32], cookie3[32];
	GetClientCookie(target, g_hClientHats[0], cookie1, 32);
	GetClientCookie(target, g_hClientHats[1], cookie2, 32);
	GetClientCookie(target, g_hClientHats[2], cookie3, 32);

	CPrintToChat(client, "{darkgreen}[DEBUG]{white} Cookie values - wear1: %s, wear2: %s, wear3: %s.", cookie1, cookie2, cookie3);
	return Plugin_Handled;

}
//Hat Paints function

public Action Command_HatPaints(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("This command cannot be used from the console");
		return Plugin_Handled;
	}
	if(Steam_InGroup(client) == 0)
	{
		PrintToChat(client, "[SM] You must be in our steam group to use this command. Type !group to join our group.");
		return Plugin_Handled;
	}

	Handle hMenu = CreateMenu(HatMenuCallBack);
	SetMenuTitle(hMenu, "Recursion.TF >> Hat Paints");
	AddMenuItem(hMenu, "0", "---------------------", ITEMDRAW_DISABLED);
	AddMenuItem(hMenu, "1", "Slot 1");
	AddMenuItem(hMenu, "2", "Slot 2");
	AddMenuItem(hMenu, "3", "Slot 3");
  AddMenuItem(hMenu, "4", "---------------------", ITEMDRAW_DISABLED);
  AddMenuItem(hMenu, "5", "Remove All Hat Paints");
	DisplayMenu(hMenu, client, 60);

	return Plugin_Handled;
}

public HatMenuCallBack(Handle:h_Menu, MenuAction action, int client, int itemNum)
{
	if(!IsValidClient(client))
	{
		return 0;
	}
	if(action == MenuAction_Select)
	{
	switch(itemNum)
	{
		case 1:
		{
			Handle hMenu = CreateMenu(HatMenuSlot1CallBack);
			SetMenuTitle(hMenu, "Recursion.TF >> Hat Paints - 1st slot");
			AddMenuItem(hMenu, "0", "Remove 1st slot Hat Paint");
			AddMenuItem(hMenu, "1", "----Regular Paints----", ITEMDRAW_DISABLED);
			AddMenuItem(hMenu, "3100495", "A Color Similar to Slate");
			AddMenuItem(hMenu, "8208497", "A Deep Commitment to Purple");
			AddMenuItem(hMenu, "1315860", "A Distinctive Lack of Hue");
			AddMenuItem(hMenu, "12377523", "A Mann's Mint");
			AddMenuItem(hMenu, "2960676", "After Eight");
			AddMenuItem(hMenu, "8289918", "Aged Moustache Grey");
			AddMenuItem(hMenu, "15132390", "An Extraordinary Abundance of Tinge");
			AddMenuItem(hMenu, "15185211", "Australium Gold");
			AddMenuItem(hMenu, "14204632", "Color No. 216-190-216");
			AddMenuItem(hMenu, "15308410", "Dark Salmon Injustice");
			AddMenuItem(hMenu, "8421376", "Drably Olive");
			AddMenuItem(hMenu, "7511618", "Indubitably Green");
			AddMenuItem(hMenu, "13595446", "Mann Co. Orange");
			AddMenuItem(hMenu, "10843461", "Muskelmannbraun");
			AddMenuItem(hMenu, "5322826", "Noble Hatter's Violet");
			AddMenuItem(hMenu, "12955537", "Peculiarly Drab Tincture");
			AddMenuItem(hMenu, "16738740", "Pink as Hell");
			AddMenuItem(hMenu, "6901050", "Radigan Conagher Brown");
			AddMenuItem(hMenu, "3329330", "The Bitter Taste of Defeat and Lime");
			AddMenuItem(hMenu, "15787660", "The Color of a Gentlemann's Business Pants");
			AddMenuItem(hMenu, "8154199", "Ye Olde Rustic Colour");
			AddMenuItem(hMenu, "4345659", "Zepheniah's Greed");
			AddMenuItem(hMenu, "2", "----Team Colors----", ITEMDRAW_DISABLED);
			AddMenuItem(hMenu, "6637376,2636109", "An Air of Debonair");
			AddMenuItem(hMenu, "3874595,1581885", "Balaclavas Are Forever");
			AddMenuItem(hMenu, "12807213,12091445", "Cream Spirit");
			AddMenuItem(hMenu, "4732984,3686984", "Operator's Overalls");
			AddMenuItem(hMenu, "12073019,5801378", "Team Spirit");
			AddMenuItem(hMenu, "8400928,2452877", "The Value of Teamwork");
			AddMenuItem(hMenu, "11049612,8626083", "Waterlogged Lab Coat");
			DisplayMenu(hMenu, client, 60);
		}
		case 2:
		{
				Handle hMenu = CreateMenu(HatMenuSlot2CallBack);
				SetMenuTitle(hMenu, "Hat Paints - 2nd slot Paints");
				AddMenuItem(hMenu, "0", "Remove 2nd slot Hat Paint");
				AddMenuItem(hMenu, "1", "----Regular Paints----", ITEMDRAW_DISABLED);
				AddMenuItem(hMenu, "3100495", "A Color Similar to Slate");
				AddMenuItem(hMenu, "8208497", "A Deep Commitment to Purple");
				AddMenuItem(hMenu, "1315860", "A Distinctive Lack of Hue");
				AddMenuItem(hMenu, "12377523", "A Mann's Mint");
				AddMenuItem(hMenu, "2960676", "After Eight");
				AddMenuItem(hMenu, "8289918", "Aged Moustache Grey");
				AddMenuItem(hMenu, "15132390", "An Extraordinary Abundance of Tinge");
				AddMenuItem(hMenu, "15185211", "Australium Gold");
				AddMenuItem(hMenu, "14204632", "Color No. 216-190-216");
				AddMenuItem(hMenu, "15308410", "Dark Salmon Injustice");
				AddMenuItem(hMenu, "8421376", "Drably Olive");
				AddMenuItem(hMenu, "7511618", "Indubitably Green");
				AddMenuItem(hMenu, "13595446", "Mann Co. Orange");
				AddMenuItem(hMenu, "10843461", "Muskelmannbraun");
				AddMenuItem(hMenu, "5322826", "Noble Hatter's Violet");
				AddMenuItem(hMenu, "12955537", "Peculiarly Drab Tincture");
				AddMenuItem(hMenu, "16738740", "Pink as Hell");
				AddMenuItem(hMenu, "6901050", "Radigan Conagher Brown");
				AddMenuItem(hMenu, "3329330", "The Bitter Taste of Defeat and Lime");
				AddMenuItem(hMenu, "15787660", "The Color of a Gentlemann's Business Pants");
				AddMenuItem(hMenu, "8154199", "Ye Olde Rustic Colour");
				AddMenuItem(hMenu, "4345659", "Zepheniah's Greed");
				AddMenuItem(hMenu, "2", "----Team Colors----", ITEMDRAW_DISABLED);
				AddMenuItem(hMenu, "6637376,2636109", "An Air of Debonair");
				AddMenuItem(hMenu, "3874595,1581885", "Balaclavas Are Forever");
				AddMenuItem(hMenu, "12807213,12091445", "Cream Spirit");
				AddMenuItem(hMenu, "4732984,3686984", "Operator's Overalls");
				AddMenuItem(hMenu, "12073019,5801378", "Team Spirit");
				AddMenuItem(hMenu, "8400928,2452877", "The Value of Teamwork");
				AddMenuItem(hMenu, "11049612,8626083", "Waterlogged Lab Coat");
				DisplayMenu(hMenu, client, 60);
			}
			case 3:
			{
				Handle hMenu = CreateMenu(HatMenuSlot3CallBack);
				SetMenuTitle(hMenu, "Hat Paints - 3rd slot Paints");
				AddMenuItem(hMenu, "0", "Remove 3rd slot Hat Paint");
				AddMenuItem(hMenu, "1", "----Regular Paints----", ITEMDRAW_DISABLED);
				AddMenuItem(hMenu, "3100495", "A Color Similar to Slate");
				AddMenuItem(hMenu, "8208497", "A Deep Commitment to Purple");
				AddMenuItem(hMenu, "1315860", "A Distinctive Lack of Hue");
				AddMenuItem(hMenu, "12377523", "A Mann's Mint");
				AddMenuItem(hMenu, "2960676", "After Eight");
				AddMenuItem(hMenu, "8289918", "Aged Moustache Grey");
				AddMenuItem(hMenu, "15132390", "An Extraordinary Abundance of Tinge");
				AddMenuItem(hMenu, "15185211", "Australium Gold");
				AddMenuItem(hMenu, "14204632", "Color No. 216-190-216");
				AddMenuItem(hMenu, "15308410", "Dark Salmon Injustice");
				AddMenuItem(hMenu, "8421376", "Drably Olive");
				AddMenuItem(hMenu, "7511618", "Indubitably Green");
				AddMenuItem(hMenu, "13595446", "Mann Co. Orange");
				AddMenuItem(hMenu, "10843461", "Muskelmannbraun");
				AddMenuItem(hMenu, "5322826", "Noble Hatter's Violet");
				AddMenuItem(hMenu, "12955537", "Peculiarly Drab Tincture");
				AddMenuItem(hMenu, "16738740", "Pink as Hell");
				AddMenuItem(hMenu, "6901050", "Radigan Conagher Brown");
				AddMenuItem(hMenu, "3329330", "The Bitter Taste of Defeat and Lime");
				AddMenuItem(hMenu, "15787660", "The Color of a Gentlemann's Business Pants");
				AddMenuItem(hMenu, "8154199", "Ye Olde Rustic Colour");
				AddMenuItem(hMenu, "4345659", "Zepheniah's Greed");
				AddMenuItem(hMenu, "2", "----Team Colors----", ITEMDRAW_DISABLED);
				AddMenuItem(hMenu, "6637376,2636109", "An Air of Debonair");
				AddMenuItem(hMenu, "3874595,1581885", "Balaclavas Are Forever");
				AddMenuItem(hMenu, "12807213,12091445", "Cream Spirit");
				AddMenuItem(hMenu, "4732984,3686984", "Operator's Overalls");
				AddMenuItem(hMenu, "12073019,5801378", "Team Spirit");
				AddMenuItem(hMenu, "8400928,2452877", "The Value of Teamwork");
				AddMenuItem(hMenu, "11049612,8626083", "Waterlogged Lab Coat");
				DisplayMenu(hMenu, client, 60);
			}
      case 5:
      {
        for(int i = 0; i < sizeof(h_hatPaint); ++i)
        {
          SetClientCookie(client, h_hatPaint[i], "0.0");
        }
        CPrintToChat(client, "%s Removed Hat Paints for all wearables.", JTAG);
      }
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(h_Menu);
	}
	return 1;
}

public HatMenuSlot1CallBack(Handle hMenu, MenuAction action, int client, int itemNum)
{
	if(action == MenuAction_Select)
	{
		if(!IsClientInGame(client))
		{
			return 0;
		}
		char cPaintID[32];
		GetMenuItem(hMenu, itemNum, cPaintID, sizeof(cPaintID));

		if(StrEqual(cPaintID, "0", false))
		{
			SetClientCookie(client, h_hatPaint[0], "0.0");
			CPrintToChat(client, "%s Removed Hat Paint for hats in the 1st slot.", JTAG);
		}
		else{
			SetClientCookie(client, h_hatPaint[0], cPaintID);
			CPrintToChat(client, "%s Touch the resupply locker to paint your cosmetic!", JTAG);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
	}
	return 1;
}

public HatMenuSlot2CallBack(Handle hMenu, MenuAction action, int client, int itemNum)
{
	if(action == MenuAction_Select)
	{
		if(!IsClientInGame(client))
		{
			return 0;
		}
		char cPaintID[32];
		GetMenuItem(hMenu, itemNum, cPaintID, sizeof(cPaintID));

		if(StrEqual(cPaintID, "0", false))
		{
			SetClientCookie(client, h_hatPaint[1], "0.0");
			CPrintToChat(client, "%s Removed Hat Paint for hats in the 2nd slot.", JTAG);
		}
		else{
			SetClientCookie(client, h_hatPaint[1], cPaintID);
			CPrintToChat(client, "%s Touch the resupply locker to paint your cosmetic!", JTAG);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
	}
	return 1;
}

public HatMenuSlot3CallBack(Handle hMenu, MenuAction action, int client, int itemNum)
{
	if(action == MenuAction_Select)
	{
		if(!IsClientInGame(client))
		{
		return 0;
		}
		char cPaintID[32];
		GetMenuItem(hMenu, itemNum, cPaintID, sizeof(cPaintID));

		if(StrEqual(cPaintID, "0", false))
		{
			SetClientCookie(client, h_hatPaint[2], "0.0");
			CPrintToChat(client, "%s Removed Hat Paint for hats in the 3rd slot.", JTAG);
		}
		else{
			SetClientCookie(client, h_hatPaint[2], cPaintID);
			CPrintToChat(client, "%s Touch the resupply locker to paint your cosmetic!", JTAG);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(hMenu);
	}
	return 1;
}

//Main hat add function
public Action Command_GiveHat(int client, int args)
{

	if(Steam_InGroup(client) == 0)
	{
		PrintToChat(client, "[SM] You must be in our steam group to use this command. Type !group to join our group.");
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[0], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 1.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[0], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 1. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action Command_GiveHat2(int client, int args)
{

	if(Steam_InGroup(client) == 0)
	{
		PrintToChat(client, "[SM] You must be in our steam group to use this command. Type !group to join our group.");
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear2 <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[1], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 2.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[1], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 2. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action Command_GiveHat3(int client, int args)
{

	if(Steam_InGroup(client) == 0)
	{
		PrintToChat(client, "[SM] You must be in our steam group to use this command. Type !group to join our group.");
		return Plugin_Handled;
	}

	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear3 <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[2], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 3.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[2], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 3. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action Command_GiveHat4(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear4 <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[3], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 4.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[3], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 4. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action Command_GiveHat5(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear5 <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[4], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 5.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[4], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 5. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action Command_GiveHat6(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_wear6 <index, -1 for no hat>. Use !index to search for cosmetics indexes.");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if(IsCharAlpha(arg1[0]) || IsCharAlpha(arg1[1]) || IsCharAlpha(arg1[2]) || IsCharAlpha(arg1[3]) || IsCharAlpha(arg1[4]) || IsCharAlpha(arg1[5]))
	{
		PrintToChat(client, "[SM] Invalid wearable index, use numbers instead of letters.");
		return Plugin_Handled;
	}

	int id = StringToInt(arg1);

	if(id == -1 || id == 0)
	{
		SetClientCookie(client, g_hClientHats[5], "0");
		ReplyToCommand(client, "[SM] Removed wearable in slot 6.");
		return Plugin_Handled;
	}

	new String:classname[32];
	TF2IDB_GetItemClass(id, classname, sizeof(classname));
	int slot = TF2IDB_GetItemSlot(id);
	if(!StrEqual(classname, "tf_wearable", false) || slot < 4)
	{
		ReplyToCommand(client, "[SM] Your item index (%i) is not a wearable index. Use !index to search for cosmetics indexes.", id);
		return Plugin_Handled;
	}

	new String:itemname[72];
	TF2IDB_GetItemName(id, itemname, sizeof(itemname));
	SetClientCookie(client, g_hClientHats[5], arg1);

	PrintToChat(client, "[SM] Equipped wearable with name '%s' [index %s] in slot 6. Touch the resupply locker to receive your cosmetic item!", itemname, arg1);

	return Plugin_Continue;
}

public Action:Command_Unusual(client, args){

	if(!IsValidClient(client)) return Plugin_Handled;

	if(Steam_InGroup(client) == 0)
	{
		PrintToChat(client, "[SM] You must be in our steam group to use this command. Type !group to join our group.");
		return Plugin_Handled;
	}

	DisplayMenu(hUnusualMenu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;

}

Handle:Menu_BuildMain(){

	new Handle:hMenu = CreateMenu(Menu_Manager);

	SetMenuTitle(hMenu, "Recursion.TF >> Unusual effects");

	AddMenuItem(hMenu, "0", "Remove Effect");
	AddMenuItem(hMenu, "X", "-------------------", 1);

	new String:sItemIDName[2][32];
	for(new i = 0; i < sizeof(sMenuItems); i++){

		ExplodeString(sMenuItems[i], "|", sItemIDName, sizeof(sItemIDName), sizeof(sItemIDName[]));

		AddMenuItem(hMenu, sItemIDName[0], sItemIDName[1]);

	}

	return hMenu;

}

public Menu_Manager(Handle:hMenu, MenuAction:state, client, position){

	if(!IsValidClient(client))	return 0;

	if(state == MenuAction_Select){

		new String:sItem[4]; GetMenuItem(hMenu, position, sItem, sizeof(sItem));
		fEffects[client] = StringToFloat(sItem);

		DisplayMenuAtItem(hMenu, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if(StrEqual(sItem, "0", false))
		{
			PrintToChat(client, "[SM] Touch the resupply locker to remove the unusual effect!");
		}
		else
		{
			PrintToChat(client, "[SM] Touch the resupply locker to receive the unusual effect!");
		}

	}
	if(state == MenuAction_End)
	{
		CloseHandle(hMenu);
	}

	return 1;

}

public Action:Command_RemoveHats(client, args)
{
	PrintToChat(client, "[SM] Touch the resupply locker to receive your original wearables.");
  for(int i = 0; i < sizeof(g_hClientHats); ++i)
  {
    SetClientCookie(client, g_hClientHats[i], "0");
  }

	return Plugin_Handled;
}

/*
*
*	Main functions
*
*/

/*public void TF2Items_OnGiveNamedItem_Post(int client, char[] classname, int itemDefinitionIndex, int itemLevel, int itemQuality, int entityIndex)
{
  if(StrEqual(classname, "tf_wearable", false))
  {
    int flags = GetEntProp(entityIndex, Prop_Data, "m_iEFlags", 0);
	  PrintToChatAll("ONGIVENAMEDITEMPOST: %i, %i", itemDefinitionIndex, flags);
    Address pEntity = GetEntityAddress(entityIndex) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
    int m_iItemIDHigh = GetEntData(entityIndex, FindSendPropInfo("CTFWearable", "m_iItemIDHigh"), 4);
    int m_iItemIDLow = GetEntData(entityIndex, FindSendPropInfo("CTFWearable", "m_iItemIDLow"), 4);
    //TF2Items_SetItemId(pEntity, 0, m_iItemIDHigh, m_iItemIDLow);
    for(int i = 0; i < 8; ++i)
    {
      if(g_iClientHatEntities[client][i] == 0)
      {
        /*PrintToChatAll("%i", i);
        char cookie[32];
        GetClientCookie(client, g_hClientHats[i], cookie, 32);
        int index = StringToInt(cookie);
        if(index > 1) TF2Items_SetItemId(pEntity, 0, m_iItemIDHigh, m_iItemIDLow);*/

        g_iClientHatEntities[client][i] = entityIndex;
        return;
      }
    }
  }
}*/

public void Event_Inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);

	//FindAllWearablesForClient(client);
	EquipWearables(client);
}

void FindAllWearablesForClient(int client)
{
	int entityIndex, i = 0;
	while ((entityIndex = FindEntityByClassname(entityIndex, "tf_wearable")) != -1)
	{
		int owner = GetEntPropEnt(entityIndex, Prop_Send, "m_hOwnerEntity");
    int spawnflags = GetEntProp(entityIndex, Prop_Data, "m_spawnflags");
    PrintToChatAll("%i", spawnflags);
		int slot = TF2IDB_GetItemSlot(GetEntProp(entityIndex, Prop_Send, "m_iItemDefinitionIndex"));

		if(owner == client && slot > 4)
		{
			g_iClientHatEntities[client][i] = entityIndex;
			++i;
		}
	}
}

void EquipWearables(int client)
{
  for(int i = 0; i < 8; ++i)
  {
    EquipWearable(client, g_iClientHatEntities[client][i], i);
	  g_iClientHatEntities[client][i] = 0;
  }
}

void EquipWearable(int client, int entity, int slotNum)
{
  char cookie[32], hatpaintC[32];
  GetClientCookie(client, g_hClientHats[slotNum], cookie, 32);
  GetClientCookie(client, h_hatPaint[slotNum], hatpaintC, 32);

  TFTeam team = TF2_GetClientTeam(client);
  int index = StringToInt(cookie);
  float hatpaint = GetHatpaintFromCookie(hatpaintC, team);

  char classname[86];
  if(IsValidEntity(entity) && entity > 1)
  {
	GetEntityClassname(entity, classname, sizeof(classname));
  }

  if(index > 1)
  {
    if(IsValidEntity(entity) && entity > 1 && StrEqual(classname, "tf_wearable", false))
    {
      AcceptEntityInput(entity, "Kill");
    }

    int wearable = CreateEntityByName("tf_wearable");
    SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", index);
    SetEntProp(wearable, Prop_Send, "m_iEntityLevel", 100);
    SetEntProp(wearable, Prop_Send, "m_iEntityQuality", 6);
    TF2ItemSlot slot = TF2IDB_GetItemSlot(index);
    if(slot == TF2ItemSlot_Head)
    {
      TF2Attrib_SetByDefIndex(wearable, 134, fEffects[client]);
    }
    TF2Attrib_SetByDefIndex(wearable, 142, hatpaint);
    DispatchSpawn(wearable);
    SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
    SetEntProp(wearable, Prop_Send, "m_bInitialized", 1);

    SDKCall(hEquipWearable, client, wearable);
    SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
    SetEntProp(wearable, Prop_Send, "m_bInitialized", 1);
  }
  else
  {
    if(IsValidEntity(entity) && entity > 1)
    {
      if(fEffects[client] != 0.0 || hatpaint != 0.0)
      {
        int newindex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
        int wearable = CreateEntityByName("tf_wearable");
        SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", newindex);

		GetEntityClassname(entity, classname, sizeof(classname));
		if(!StrEqual(classname, "tf_wearable", false))
		{
			AcceptEntityInput(wearable, "Kill");
			return;
		}

		TF2Items_CopyDynamicAttributes("CTFWearable", entity, wearable, 3);
		AcceptEntityInput(entity, "Kill");

        TF2ItemSlot slot = TF2IDB_GetItemSlot(newindex);
        SetEntProp(wearable, Prop_Send, "m_iEntityLevel", 100);
        SetEntProp(wearable, Prop_Send, "m_iEntityQuality", 6);
        if(fEffects[client] != 0.0 && slot == TF2ItemSlot_Head)
        {
          TF2Items_SetAttributeNew("CTFWearable", wearable, 134, fEffects[client]);
        }
        if(hatpaint != 0.0)
        {
          TF2Items_SetAttributeNew("CTFWearable", wearable, 142, hatpaint);
          TF2Items_SetAttributeNew("CTFWearable", wearable, 261, hatpaint);
        }
        DispatchSpawn(wearable);
        SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
        SetEntProp(wearable, Prop_Send, "m_bInitialized", 1);

        SDKCall(hEquipWearable, client, wearable);
        SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
        SetEntProp(wearable, Prop_Send, "m_bInitialized", 1);
      }
    }
  }
}

float GetHatpaintFromCookie(char[] hatpaint1, TFTeam team)
{
  if(StrEqual(hatpaint1, "6637376,2636109", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 6637376.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 2636109.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "3874595,1581885", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 1581885.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 3874595.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "12807213,12091445", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 12091445.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 12807213.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "4732984,3686984", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 3686984.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 4732984.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "12073019,5801378", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 5801378.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 12073019.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "8400928,2452877", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 2452877.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 8400928.0;
    }
    return p1;
  }
  else if(StrEqual(hatpaint1, "11049612,8626083", false))
  {
    float p1;
    if(team == TFTeam_Blue)
    {
      p1 = 8626083.0;
    }
    else if(team == TFTeam_Red)
    {
      p1 = 11049612.0;
    }
    return p1;
  }
  else
  {
    float p1 = StringToFloat(hatpaint1);
    return p1;
  }
}

bool:IsValidClient(client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	return IsClientInGame(client);
}

FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
