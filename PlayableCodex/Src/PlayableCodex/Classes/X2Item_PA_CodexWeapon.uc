class X2Item_PA_CodexWeapon extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue PACodex_Weapon_BaseDamage;

var config array<int> FLAT_BEAM_RANGE;

var config int PACodex_Weapon_ClipSize;
var config int PACodex_Weapon_ISOUNDRANGE;
var config int PACodex_Weapon_EnvironmentalDamage;
var config int PACodex_Weapon_SoundRange;
var config int PACodex_Weapon_BaseDamage;
var config int PACodex_Weapon_IdealRange;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	// Codex Weapon

	Weapons.AddItem(CreateTemplate_Codex_WPN());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_Codex_WPN()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'PACodex_WPN');
	
	Template.WeaponPanelImage = "_ConventionalRifle";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'PA_codexGunCat';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.ViperRifle";
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.RangeAccuracy = default.FLAT_BEAM_RANGE;
	Template.BaseDamage = default.PACodex_Weapon_BaseDamage;
	Template.iClipSize = default.PACodex_Weapon_ClipSize;
	Template.iSoundRange = default.PACodex_Weapon_SoundRange;
	Template.iEnvironmentDamage = default.PACodex_Weapon_EnvironmentalDamage;
	Template.iIdealRange = default.PACodex_Weapon_IdealRange;

	Template.DamageTypeTemplateName = 'Heavy';
	
	Template.InfiniteAmmo = true;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Cyberus_Gun.WP_CyberusRifle";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	return Template;
}