////////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////

#ifndef __ENUMS__
#define __ENUMS__

#include <string>
#include <list>
#include "definitions.h"

enum CreatureType_t
{
	CREATURETYPE_PLAYER = 0,
	CREATURETYPE_MONSTER = 1,
	CREATURETYPE_NPC = 2
};

enum DatabaseEngine_t
{
	DATABASE_ENGINE_NONE = 0,
	DATABASE_ENGINE_MYSQL,
	DATABASE_ENGINE_SQLITE,
	DATABASE_ENGINE_POSTGRESQL
};

enum Encryption_t
{
	ENCRYPTION_PLAIN = 0,
	ENCRYPTION_MD5,
	ENCRYPTION_SHA1,
	ENCRYPTION_SHA256,
	ENCRYPTION_SHA512,
	ENCRYPTION_VAHASH
};

enum GuildLevel_t
{
	GUILDLEVEL_NONE = 0,
	GUILDLEVEL_MEMBER,
	GUILDLEVEL_VICE,
	GUILDLEVEL_LEADER
};

enum OperatingSystem_t
{
	CLIENTOS_LINUX				= 0x01,
	CLIENTOS_WINDOWS			= 0x02,
	CLIENTOS_FLASH				= 0x03,

	CLIENTOS_OTCLIENT_LINUX		= 0x0A,
	CLIENTOS_OTCLIENT_WINDOWS	= 0x0B,
	CLIENTOS_OTCLIENT_MAC		= 0x0C
};

enum Channels_t
{
	CHANNEL_GUILD = 0x00,
	CHANNEL_PARTY = 0x01,
	CHANNEL_RVR = 0x03,
	CHANNEL_HELP = 0x09,
	CHANNEL_DEFAULT = 0xFFFE, //internal usage only, there is no such channel
	CHANNEL_PRIVATE = 0xFFFF
};

enum ViolationAction_t
{
	ACTION_NOTATION = 0,
	ACTION_NAMEREPORT,
	ACTION_BANISHMENT,
	ACTION_BANREPORT,
	ACTION_BANFINAL,
	ACTION_BANREPORTFINAL,
	ACTION_STATEMENT,
	//internal use
	ACTION_DELETION,
	ACTION_NAMELOCK,
	ACTION_BANLOCK,
	ACTION_BANLOCKFINAL,
	ACTION_PLACEHOLDER
};

enum RaceType_t
{
	RACE_NONE = 0,
	RACE_VENOM,
	RACE_BLOOD,
	RACE_UNDEAD,
	RACE_FIRE,
	RACE_ENERGY
};

enum CombatType_t
{
	COMBAT_FIRST		= 0,
	COMBAT_NONE		= COMBAT_FIRST,
	COMBAT_PHYSICALDAMAGE	= 1 << 0,
	COMBAT_ENERGYDAMAGE	= 1 << 1,
	COMBAT_EARTHDAMAGE	= 1 << 2,
	COMBAT_FIREDAMAGE	= 1 << 3,
	COMBAT_UNDEFINEDDAMAGE	= 1 << 4,
	COMBAT_LIFEDRAIN	= 1 << 5,
	COMBAT_MANADRAIN	= 1 << 6,
	COMBAT_HEALING		= 1 << 7,
	COMBAT_DROWNDAMAGE	= 1 << 8,
	COMBAT_ICEDAMAGE	= 1 << 9,
	COMBAT_HOLYDAMAGE	= 1 << 10,
	COMBAT_DEATHDAMAGE	= 1 << 11,
	COMBAT_LAST		= COMBAT_DEATHDAMAGE
};

enum CombatParam_t
{
	COMBATPARAM_NONE = 0,
	COMBATPARAM_COMBATTYPE,
	COMBATPARAM_EFFECT,
	COMBATPARAM_DISTANCEEFFECT,
	COMBATPARAM_BLOCKEDBYSHIELD,
	COMBATPARAM_BLOCKEDBYARMOR,
	COMBATPARAM_TARGETCASTERORTOPMOST,
	COMBATPARAM_CREATEITEM,
	COMBATPARAM_AGGRESSIVE,
	COMBATPARAM_DISPEL,
	COMBATPARAM_USECHARGES,
	COMBATPARAM_TARGETPLAYERSORSUMMONS,
	COMBATPARAM_DIFFERENTAREADAMAGE,
	COMBATPARAM_HITEFFECT,
	COMBATPARAM_HITCOLOR
};

enum CallBackParam_t
{
	CALLBACKPARAM_NONE = 0,
	CALLBACKPARAM_LEVELMAGICVALUE,
	CALLBACKPARAM_SKILLVALUE,
	CALLBACKPARAM_TARGETTILECALLBACK,
	CALLBACKPARAM_TARGETCREATURECALLBACK
};

enum ConditionParam_t
{
	CONDITIONPARAM_OWNER = 1,
	CONDITIONPARAM_TICKS,
	CONDITIONPARAM_OUTFIT,
	CONDITIONPARAM_HEALTHGAIN,
	CONDITIONPARAM_HEALTHTICKS,
	CONDITIONPARAM_MANAGAIN,
	CONDITIONPARAM_MANATICKS,
	CONDITIONPARAM_DELAYED,
	CONDITIONPARAM_SPEED,
	CONDITIONPARAM_LIGHT_LEVEL,
	CONDITIONPARAM_LIGHT_COLOR,
	CONDITIONPARAM_SOULGAIN,
	CONDITIONPARAM_SOULTICKS,
	CONDITIONPARAM_MINVALUE,
	CONDITIONPARAM_MAXVALUE,
	CONDITIONPARAM_STARTVALUE,
	CONDITIONPARAM_TICKINTERVAL,
	CONDITIONPARAM_FORCEUPDATE,
	CONDITIONPARAM_SKILL_MELEE,
	CONDITIONPARAM_SKILL_FIST,
	CONDITIONPARAM_SKILL_CLUB,
	CONDITIONPARAM_SKILL_SWORD,
	CONDITIONPARAM_SKILL_AXE,
	CONDITIONPARAM_SKILL_DISTANCE,
	CONDITIONPARAM_SKILL_SHIELD,
	CONDITIONPARAM_SKILL_FISHING,
	CONDITIONPARAM_STAT_MAXHEALTH,
	CONDITIONPARAM_STAT_MAXMANA,
	CONDITIONPARAM_STAT_SOUL,
	CONDITIONPARAM_STAT_MAGICLEVEL,
	CONDITIONPARAM_STAT_MAXHEALTHPERCENT,
	CONDITIONPARAM_STAT_MAXMANAPERCENT,
	CONDITIONPARAM_STAT_SOULPERCENT,
	CONDITIONPARAM_STAT_MAGICLEVELPERCENT,
	CONDITIONPARAM_SKILL_MELEEPERCENT,
	CONDITIONPARAM_SKILL_FISTPERCENT,
	CONDITIONPARAM_SKILL_CLUBPERCENT,
	CONDITIONPARAM_SKILL_SWORDPERCENT,
	CONDITIONPARAM_SKILL_AXEPERCENT,
	CONDITIONPARAM_SKILL_DISTANCEPERCENT,
	CONDITIONPARAM_SKILL_SHIELDPERCENT,
	CONDITIONPARAM_SKILL_FISHINGPERCENT,
	CONDITIONPARAM_PERIODICDAMAGE,
	CONDITIONPARAM_BUFF,
	CONDITIONPARAM_SUBID
};

enum BlockType_t
{
	BLOCK_NONE = 0,
	BLOCK_DEFENSE,
	BLOCK_ARMOR,
	BLOCK_IMMUNITY
};

enum Reflect_t
{
	REFLECT_FIRST = 0,
	REFLECT_PERCENT = REFLECT_FIRST,
	REFLECT_CHANCE,
	REFLECT_LAST = REFLECT_CHANCE
};

enum Increment_t
{
	INCREMENT_FIRST = 0,
	HEALING_VALUE = INCREMENT_FIRST,
	HEALING_PERCENT,
	MAGIC_VALUE,
	MAGIC_PERCENT,
	INCREMENT_LAST = MAGIC_PERCENT
};

enum skills_t
{
	SKILL_FIRST = 0,
	SKILL_FIST = SKILL_FIRST,
	SKILL_CLUB,
	SKILL_SWORD,
	SKILL_AXE,
	SKILL_DIST,
	SKILL_SHIELD,
	SKILL_FISH,
	SKILL__MAGLEVEL,
	SKILL__LEVEL,
	SKILL_LAST = SKILL_FISH,
	SKILL__LAST = SKILL__LEVEL
};

enum stats_t
{
	STAT_FIRST = 0,
	STAT_MAXHEALTH = STAT_FIRST,
	STAT_MAXMANA,
	STAT_SOUL,
	STAT_LEVEL,
	STAT_MAGICLEVEL,
	STAT_LAST = STAT_MAGICLEVEL
};

enum lossTypes_t
{
	LOSS_FIRST = 0,
	LOSS_EXPERIENCE = LOSS_FIRST,
	LOSS_MANA,
	LOSS_SKILLS,
	LOSS_CONTAINERS,
	LOSS_ITEMS,
	LOSS_LAST = LOSS_ITEMS
};

enum formulaType_t
{
	FORMULA_UNDEFINED = 0,
	FORMULA_LEVELMAGIC,
	FORMULA_SKILL,
	FORMULA_VALUE
};

enum ConditionId_t
{
	CONDITIONID_DEFAULT = -1,
	CONDITIONID_COMBAT = 0,
	CONDITIONID_HEAD,
	CONDITIONID_NECKLACE,
	CONDITIONID_BACKPACK,
	CONDITIONID_ARMOR,
	CONDITIONID_RIGHT,
	CONDITIONID_LEFT,
	CONDITIONID_LEGS,
	CONDITIONID_FEET,
	CONDITIONID_RING,
	CONDITIONID_AMMO,
	CONDITIONID_OUTFIT
};

enum PlayerSex_t
{
	PLAYERSEX_FEMALE = 0,
	PLAYERSEX_MALE
	// DO NOT ADD HERE! Every higher sex is only for your
	// own use- each female should be even and male odd.
};
#ifdef __WAR_SYSTEM__

enum WarType_t
{
	WAR_FIRST = 0,
	WAR_GUILD = WAR_FIRST,
	WAR_ENEMY,
	WAR_LAST = WAR_ENEMY
};

struct War_t
{
	War_t()
	{
		war = 0;
		type = WAR_FIRST;

		memset(ids, 0, sizeof(ids));
		memset(frags, 0, sizeof(frags));

		limit = payment = 0;
	}

	uint32_t war;
	WarType_t type;

	uint32_t ids[WAR_LAST + 1];
	std::string names[WAR_LAST + 1];
	uint16_t frags[WAR_LAST + 1];

	uint16_t limit;
	uint64_t payment;
};
#endif

struct Outfit_t
{
	Outfit_t() {lookHead = lookBody = lookLegs = lookFeet = lookType = lookTypeEx = lookAddons = 0;}
	uint16_t lookType, lookTypeEx;
	uint8_t lookHead, lookBody, lookLegs, lookFeet, lookAddons;

	bool operator==(const Outfit_t& o) const
	{
		return (o.lookAddons == lookAddons
			&& o.lookType == lookType && o.lookTypeEx == lookTypeEx
			&& o.lookHead == lookHead && o.lookBody == lookBody
			&& o.lookLegs == lookLegs && o.lookFeet == lookFeet);
	}

	bool operator!=(const Outfit_t& o) const
	{
		return !(*this == o);
	}
};

struct LightInfo
{
	uint32_t level, color;

	LightInfo() {level = color = 0;}
	LightInfo(uint32_t _level, uint32_t _color):
		level(_level), color(_color) {}
};

struct ShopInfo
{
	uint32_t itemId;
	int32_t subType, buyPrice, sellPrice;
	std::string itemName;

	ShopInfo()
	{
		itemId = 0;
		subType = 1;
		buyPrice = sellPrice = -1;
		itemName = "";
	}
	ShopInfo(uint32_t _itemId, int32_t _subType = 1, int32_t _buyPrice = -1, int32_t _sellPrice = -1,
		const std::string& _itemName = ""): itemId(_itemId), subType(_subType), buyPrice(_buyPrice),
		sellPrice(_sellPrice), itemName(_itemName) {}
};

typedef std::list<ShopInfo> ShopInfoList;
#endif
