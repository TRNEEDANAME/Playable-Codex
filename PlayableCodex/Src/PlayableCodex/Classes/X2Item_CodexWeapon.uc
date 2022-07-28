class X2Item_CodexWeapon extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue CYBERUS_WPN_BASEDAMAGE;

var config array<int> FLAT_CONVENTIONAL_RANGE;

var config int ASSAULTRIFLE_MAGNETIC_ICLIPSIZE;
var config int ASSAULTRIFLE_MAGNETIC_ISOUNDRANGE;
var config int ASSAULTRIFLE_MAGNETIC_IENVIRONMENTDAMAGE;

var config int CYBERUS_IDEALRANGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	// Alien Rulers

	Weapons.AddItem(CreateTemplate_Codex_WPN());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_Codex_WPN()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'Codex_WPN');
	
	Template.WeaponPanelImage = "_ConventionalRifle";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'PA_codexGunCat';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.ViperRifle";
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.RangeAccuracy = default.FLAT_CONVENTIONAL_RANGE;
	Template.BaseDamage = default.CYBERUS_WPN_BASEDAMAGE;
	Template.iClipSize = default.ASSAULTRIFLE_MAGNETIC_ICLIPSIZE;
	Template.iSoundRange = default.ASSAULTRIFLE_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.ASSAULTRIFLE_MAGNETIC_IENVIRONMENTDAMAGE;
	Template.iIdealRange = default.CYBERUS_IDEALRANGE;

	Template.DamageTypeTemplateName = 'Heavy';
	
	Template.InfiniteAmmo = true;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	// This all the resources; sounds, animations, models, physics...
	Template.GameArchetype = "WP_Cyberus_Gun.WP_CyberusRifle";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	return Template;
}