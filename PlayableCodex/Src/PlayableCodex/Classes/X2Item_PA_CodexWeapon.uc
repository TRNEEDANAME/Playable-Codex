class X2Item_PA_CodexWeapon extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue PA_Codex_Weapon_BaseDamage;

var config array<int> PA_Codex_Weapon_RangeAccuracy;

var config bool PA_Codex_Weapon_InfiniteAmmo;

var config int PA_Codex_Weapon_Aim;
var config int PA_Codex_Weapon_CritChance;
var config int PA_Codex_Weapon_ClipSize;
var config int PA_Codex_Weapon_SoundRange;
var config int PA_Codex_Weapon_EnvironmentalDamage;
var config int PA_Codex_Weapon_IdealRange;
var config int PA_Codex_Weapon_NumUpgradeSlots;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	// Codex Weapon

	Weapons.AddItem(CreateTemplate_PA_Codex_WPN());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_PA_Codex_WPN()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'PA_Codex_WPN');
	
	Template.WeaponPanelImage = "_ConventionalRifle";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'PA_CodexGunCat';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.ViperRifle";
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.RangeAccuracy = default.PA_Codex_Weapon_RangeAccuracy;
	Template.BaseDamage = default.PA_Codex_Weapon_BaseDamage;
	Template.Aim = default.PA_Codex_Weapon_Aim;
	Template.CritChance = default.PA_Codex_Weapon_CritChance;
	Template.iClipSize = default.PA_Codex_Weapon_ClipSize;
	Template.iSoundRange = default.PA_Codex_Weapon_SoundRange;
	Template.iEnvironmentDamage = default.PA_Codex_Weapon_EnvironmentalDamage;
	Template.iIdealRange = default.PA_Codex_Weapon_IdealRange;

	Template.NumUpgradeSlots = default.PA_Codex_Weapon_NumUpgradeSlots;

	Template.DamageTypeTemplateName = 'Heavy';

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Cyberus_Gun.WP_CyberusRifle";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;
	Template.bInfiniteItem = true;
	Template.InfiniteAmmo = default.PA_Codex_Weapon_InfiniteAmmo;

	return Template;
}