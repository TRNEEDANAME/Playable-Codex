class X2Character_PlayableCodex extends X2Character config(GameData_CharacterStats);

var config bool ALIENS_APPEAR_IN_BASE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateTemplate_Codex());

	return Templates;
}

static function X2CharacterTemplate CreateTemplate_Codex()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'PA_Codex');
	CharTemplate.CharacterGroupName = 'Codex';
	CharTemplate.DefaultLoadout='Codex_Loadout';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_Cyberus.ARC_GameUnit_Cyberus");

	CharTemplate.strMatineePackages.AddItem("CIN_Cyberus");

	CharTemplate.UnitSize = 1;
	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;    
	CharTemplate.bCanTakeCover = true;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = true;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = true;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bCanBeCarried = true;	
	CharTemplate.bCanBeRevived = true;
	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bStaffingAllowed = true;
	CharTemplate.bAppearInBase = true;
	CharTemplate.bWearArmorInBase = true;
	CharTemplate.bAllowSpawnFromATT = false;
	CharTemplate.bUsesWillSystem = false;
	CharTemplate.bIsTooBigForArmory = true;

	CharTemplate.DefaultSoldierClass = 'CodexClass';
	CharTemplate.DefaultLoadout = 'Codex_Loadout';
	CharTemplate.RequiredLoadout = 'Codex_Loadout';

	CharTemplate.Abilities.AddItem('Loot');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('PlaceEvacZone');
	CharTemplate.Abilities.AddItem('LiftOffAvenger');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('Interact_MarkSupplyCrate');
	CharTemplate.Abilities.AddItem('TriggerSuperpositionDamageListener');
	CharTemplate.Abilities.AddItem('CodexImmunities');
	CharTemplate.Abilities.AddItem('Interact_UseElevator');

	CharTemplate.ImmuneTypes.AddItem('Poison');
	CharTemplate.ImmuneTypes.AddItem('Mental');
	CharTemplate.ImmuneTypes.AddItem('Panicked');
	CharTemplate.ImmuneTypes.AddItem('Berserk');
	CharTemplate.ImmuneTypes.AddItem('Obsessed');
	CharTemplate.ImmuneTypes.AddItem('Shattered');

	CharTemplate.bAllowSpawnFromATT = false;

	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Alien;

	return CharTemplate;
}