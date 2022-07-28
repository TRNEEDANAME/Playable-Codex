class PA_CodexAbility extends X2Ability config(GameData_PACodexAbility);

var config bool PACodex_TP_DisplayInSummary;
var config bool PACodex_TP_ConsumeAllAP;
var config int PACodex_TP_ActionPointCost;
var config int PACodex_TP_Cooldown;
var config int PACodex_TP_Radius;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(PACodex_TP());
	return Templates;
}

static function X2AbilityTemplate PACodex_TP()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2Condition_UnitProperty UnitProperty;
	local X2Condition_UnitProperty UnitProperty2;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PACodexTP');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_alwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_leap";
	Template.bDontDisplayInAbilitySummary = default.PACodex_TP_DisplayInSummary;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.PACodex_TP_ActionPointCost;
	ActionPointCost.bConsumeAllPoints = default.PACodex_TP_ConsumeAllAP;

	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PACodex_TP_Cooldown;
	Template.AbilityCooldown = Cooldown;

	UnitProperty2 = new class'X2Condition_UnitProperty';
	UnitProperty2.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitProperty2);

	UnitProperty = new class'X2Condition_UnitProperty';
	UnitProperty.ExcludeDead = true;
	UnitProperty.ExcludeCosmetic = true;
	UnitProperty.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitProperty);

	Template.TargetingMethod = class'X2TargetingMethod_Teleport';
	Template.bCrossClassEligible = false;
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_PlayerInput');

	Template.AbilityToHitCalc = default.DeadEye;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToSquadsightRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PACodex_TP_Radius;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.ConcealmentRule = eConceal_Always;
	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.bShowActivation = false;
	Template.ModifyNewContextFn = class'X2Ability_Cyberus'.static.Teleport_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = class 'X2Ability_Cyberus'.static.Teleport_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_Cyberus'.static.Teleport_BuildVisualization;
	Template.CinescriptCameraType = "Cyberus_Teleport";

	return Template;
}