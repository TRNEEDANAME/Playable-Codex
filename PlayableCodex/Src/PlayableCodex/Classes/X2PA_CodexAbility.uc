class X2PA_CodexAbility extends X2Ability config(GameData_PACodexAbility);

// ============================================================ //
// Codex Teleport Ability										//
// ============================================================ //

//* ------------------Define all variables for the abilities.------------------

var config bool PACodex_TP_DontDisplayInSummary;
var config bool PACodex_TP_ConsumeAllAP;
var config bool PACodex_TP_RestrictToSquadsightRange;

var config int PACodex_TP_ActionPointCost;
var config int PACodex_TP_Cooldown;
var config int PACodex_TP_RadiusTP;
var config int PACodex_TP_Range;

// ============================================================ //
// Codex Psi Bomb Stage 1										//
// ============================================================ //

var config bool PACodex_PsiBombStage1_DontDisplayInSummary;
var config bool PACodex_PsiBombStage1_ConsumeAllPoints;
var config bool PACodex_PsiBombStage1_RestrictToSquadsightRange;

var config int PACodex_PsiBombStage1_ActionPointCost;
var config int PACodex_PsiBombStage1_Cooldown;
var config int PACodex_PsiBombStage1_Radius;
var config int PACodex_PsiBombStage1_AbilityRange;

// ============================================================ //
// Codex Psi Bomb Stage 2										//
// ============================================================ //

var config bool PACodex_PsiBombStage2_DontDisplayInSummary;
var config WeaponDamageValue PACodex_PsiBombStage2_Damage;

var config bool PACodex_DoesPsiBombStage2_IgnoreBlockingCover;
var config bool PACodex_DoesPsiBombStage2_ExcludeFriendlyToSource;
var config bool PACodex_DoesPsiBombStage2_ExcludeHostileToSource;

var name Stage1PsiBombEffectName;
var name PsiBombTriggerName;

//! ------------------FX VARIABLE FOR THE PSI BOMB------------------ !//

var config float PSI_BOMB_STAGE1_START_WARNING_FX_SEC;
var config float PSI_BOMB_STAGE2_START_EXPLOSION_FX_SEC;
var config float PSI_BOMB_STAGE2_NOTIFY_TARGETS_SEC;


var config StatCheck PSI_BOMB_SOURCE_CHECK;
var config StatCheck PSI_BOMB_TARGET_CHECK;

//* ------------------End of variables for the abilities.------------------ //


// ========================================================================================================================================
// ========================================================================================================================================


//* ------------------Define all the templates for the abilities.------------------ //
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(PACodex_TP());
	Templates.AddItem(PACodex_PsiBombStage1());
	Templates.AddItem(PACodex_PsiBombStage2());

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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PACodex_TP');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_alwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_leap";
	Template.bDontDisplayInAbilitySummary = default.PACodex_TP_DontDisplayInSummary;

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
	CursorTarget.bRestrictToSquadsightRange = default.PACodex_TP_RestrictToSquadsightRange;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PACodex_TP_RadiusTP;
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


static simulated function PACodex_TP_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateHistory History;
	local PathPoint NextPoint, EmptyPoint;
	local PathingInputData InputData;
	local XComWorldData World;
	local vector NewLocation;
	local TTile NewTileLocation;

	History = `XCOMHISTORY;
	World = `XWORLD;

	AbilityContext = XComGameStateContext_Ability(Context);
	`assert(AbilityContext.InputContext.TargetLocations.Length > 0);
	
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	// Build the MovementData for the path
	// First posiiton is the current location
	InputData.MovementTiles.AddItem(UnitState.TileLocation);

	NextPoint.Position = World.GetPositionFromTileCoordinates(UnitState.TileLocation);
	NextPoint.Traversal = eTraversal_Teleport;
	NextPoint.PathTileIndex = 0;
	InputData.MovementData.AddItem(NextPoint);

	// Second posiiton is the cursor position
	`assert(AbilityContext.InputContext.TargetLocations.Length == 1);

	NewLocation = AbilityContext.InputContext.TargetLocations[0];
	NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
	NewLocation = World.GetPositionFromTileCoordinates(NewTileLocation);

	NextPoint = EmptyPoint;
	NextPoint.Position = NewLocation;
	NextPoint.Traversal = eTraversal_Landing;
	NextPoint.PathTileIndex = 1;
	InputData.MovementData.AddItem(NextPoint);
	InputData.MovementTiles.AddItem(NewTileLocation);

    //Now add the path to the input context
	InputData.MovingUnitRef = UnitState.GetReference();
	AbilityContext.InputContext.MovementPaths.AddItem(InputData);
}

static simulated function XComGameState PACodex_TP_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local vector NewLocation;
	local TTile NewTileLocation;
	local XComWorldData World;
	local X2EventManager EventManager;
	local int LastElementIndex;

	World = `XWORLD;
	EventManager = `XEVENTMGR;

	//Build the new game state frame
	NewGameState = TypicalAbility_BuildGameState(Context);

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());	
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));

	LastElementIndex = AbilityContext.InputContext.MovementPaths[0].MovementData.Length - 1;

	// Set the unit's new location
	// The last position in MovementData will be the end location
	`assert(LastElementIndex > 0);
	NewLocation = AbilityContext.InputContext.MovementPaths[0].MovementData[LastElementIndex].Position;
	NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
	UnitState.SetVisibilityLocation(NewTileLocation);

	AbilityContext.ResultContext.bPathCausesDestruction = MoveAbility_StepCausesDestruction(UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);
	MoveAbility_AddTileStateObjects(NewGameState, UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);

	EventManager.TriggerEvent('ObjectMoved', UnitState, UnitState, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', UnitState, UnitState, NewGameState);

	//Return the game state we have created
	return NewGameState;
}

simulated function PACodex_TP_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  AbilityContext;
	local StateObjectReference InteractingUnitRef;
	local X2AbilityTemplate AbilityTemplate;
	local VisualizationActionMetadata EmptyTrack, ActionMetadata;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local int i, j;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local X2Action_MoveTurn MoveTurnAction;
	local X2VisualizerInterface TargetVisualizerInterface;
	
	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = AbilityContext.InputContext.SourceObject;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);

	//****************************************************************************************
	//Configure the visualization track for the source
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Bad);

	// Turn to face the target action. The target location is the center of the ability's radius, stored in the 0 index of the TargetLocations
	MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	MoveTurnAction.m_vFacePoint = AbilityContext.InputContext.TargetLocations[0];

	// move action
	class'X2VisualizerHelpers'.static.ParsePath(AbilityContext, ActionMetadata);

		
	//****************************************************************************************

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.VisualizeActor = none;
		ActionMetadata.StateObject_NewState = WorldDataUpdate;
		ActionMetadata.StateObject_OldState = WorldDataUpdate;

		for (i = 0; i < AbilityTemplate.AbilityTargetEffects.Length; ++i)
		{
			AbilityTemplate.AbilityTargetEffects[i].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, AbilityContext.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[i]));
		}

			}

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	for( i = 0; i < AbilityContext.InputContext.MultiTargets.Length; ++i )
	{
		InteractingUnitRef = AbilityContext.InputContext.MultiTargets[i];
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
		for( j = 0; j < AbilityContext.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			AbilityContext.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, AbilityContext.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}
	}
}

static function X2AbilityTemplate PACodex_PsiBombStage1()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2Effect_MarkValidActivationTiles MarkTilesEffect;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2Effect_DelayedAbilityActivation DelayedDimensionalRiftEffect;
	local X2Effect_DisableWeapon DisableWeapon;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PACodex_PsiBombStage1');

	Template.AdditionalAbilities.AddItem('PACodex_PsiBombStage2');
	Template.TwoTurnAttackAbility = 'PACodex_PsiBombStage2';
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_psibomb";
	Template.bDontDisplayInAbilitySummary = default.PACodex_PsiBombStage1_DontDisplayInSummary;

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.bShowActivation = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.PACodex_PsiBombStage1_ActionPointCost;
	ActionPointCost.bConsumeAllPoints = default.PACodex_PsiBombStage1_ConsumeAllPoints;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = default.PACodex_PsiBombStage1_Cooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PACodex_PsiBombStage1_Radius;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	MarkTilesEffect = new class'X2Effect_MarkValidActivationTiles';
	MarkTilesEffect.AbilityToMark = 'PsiBombStage2';
	MarkTilesEffect.OnlyUseTargetLocation = true;
	Template.AddShooterEffect(MarkTilesEffect);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToSquadsightRange = default.PACodex_PsiBombStage1_RestrictToSquadsightRange;
	CursorTarget.FixedAbilityRange = default.PACodex_PsiBombStage1_AbilityRange;
	Template.AbilityTargetStyle = CursorTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	//Effect on a successful test is adding the delayed marked effect to the target
	DelayedDimensionalRiftEffect = new class 'X2Effect_DelayedAbilityActivation';
	DelayedDimensionalRiftEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	DelayedDimensionalRiftEffect.EffectName = default.Stage1PsiBombEffectName;
	DelayedDimensionalRiftEffect.TriggerEventName = default.PsiBombTriggerName;
	DelayedDimensionalRiftEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(DelayedDimensionalRiftEffect);

	DisableWeapon = new class'X2Effect_DisableWeapon';
	DisableWeapon.TargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
	Template.AddMultiTargetEffect(DisableWeapon);

	Template.TargetingMethod = class'X2TargetingMethod_VoidRift';

	Template.CustomFireAnim = 'HL_Malfunction';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = PACodex_PsiBombStage1_BuildVisualization;
	Template.BuildAffectedVisualizationSyncFn = PACodex_PsiBombStage1_BuildAffectedVisualization;
	Template.CinescriptCameraType = "Codex_PsiBomb_Stage1";
	Template.DamagePreviewFn = PsiBombDamagePreview;
//BEGIN AUTOGENERATED CODE: Template Overrides 'PACodex_PsiBombStage1'
	Template.bFrameEvenWhenUnitIsHidden = true;
//END AUTOGENERATED CODE: Template Overrides 'PACodex_PsiBombStage1'

	return Template;
}

function bool PsiBombDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference PsiBombStage2Ref;
	local XComGameState_Ability PsiBombStage2Ability;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	PsiBombStage2Ref = AbilityOwner.FindAbility('PsiBombStage2');
	PsiBombStage2Ability = XComGameState_Ability(History.GetGameStateForObjectID(PsiBombStage2Ref.ObjectID));
	if( PsiBombStage2Ability == none )
	{
		`RedScreenOnce("Unit has PACodex_PsiBombStage1 but is missing PACodex_PsiBombStage2. No es Bueno. -dslonneger @gameplay");
	}
	else
	{
		PsiBombStage2Ability.GetDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}
	return true;
}

simulated function PACodex_PsiBombStage1_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local X2VisualizerInterface Visualizer;
	local VisualizationActionMetadata CyberusBuildTrack, ActionMetadata, EmptyTrack;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit CyberusUnit;
	local XComWorldData World;
	local vector TargetLocation;
	local TTile TargetTile;
	local X2Action_TimedWait WaitAction;
	local X2Action_PlaySoundAndFlyOver SoundCueAction;
	local int i, j;
	local X2VisualizerInterface TargetVisualizerInterface;
	local X2Action_Fire_CloseUnfinishedAnim CloseFireAction;
	local XGUnit CodexUnit;
	local XComUnitPawn CodexPawn;
	local X2Action ExitCoverAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//Configure the visualization track for the shooter
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.SourceObject;
	CyberusBuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	CyberusBuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	CyberusBuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	CyberusUnit = XComGameState_Unit(CyberusBuildTrack.StateObject_NewState);

	if( CyberusUnit != none )
	{
		World = `XWORLD;

		// Exit cover
		ExitCoverAction = class'X2Action_ExitCover'.static.AddToVisualizationTree(CyberusBuildTrack, Context);

		//If we were interrupted, insert a marker node for the interrupting visualization code to use. In the move path version above, it is expected for interrupts to be 
		//done during the move.
		if (Context.InterruptionStatus != eInterruptionStatus_None)
		{
			//Insert markers for the subsequent interrupt to insert into
			class'X2Action'.static.AddInterruptMarkerPair(CyberusBuildTrack, Context, ExitCoverAction);
		}

		class'X2Action_Fire_OpenUnfinishedAnim'.static.AddToVisualizationTree(CyberusBuildTrack, Context);

		// Wait to time the start of the warning FX
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		WaitAction.DelayTimeSec = default.PSI_BOMB_STAGE1_START_WARNING_FX_SEC;

		// Display the Warning FX (convert to tile and back to vector because stage 2 is at the GetPositionFromTileCoordinates coord
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		EffectAction.EffectName = "FX_Psi_Bomb.P_Psi_Bomb_Warning";

		TargetLocation = Context.InputContext.TargetLocations[0];
		TargetTile = World.GetTileCoordinatesFromPosition(TargetLocation);

		EffectAction.EffectLocation = World.GetPositionFromTileCoordinates(TargetTile);

		// Play Target Activate Sound
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CyberusFX.Cyberus_Psi_Bomb_Target_Activate';
		SoundAction.iAssociatedGameStateObjectId = CyberusUnit.ObjectID;
		SoundAction.bStartPersistentSound = true;
		SoundAction.bIsPositional = true;
		SoundAction.vWorldPosition = EffectAction.EffectLocation;

		// Play the sound cue
		SoundCueAction = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		SoundCueAction.SetSoundAndFlyOverParameters(SoundCue'SoundX2CyberusFX.Cyberus_Psi_Bomb_Target_Activate_Cue', "", '', eColor_Good);

		CloseFireAction = X2Action_Fire_CloseUnfinishedAnim(class'X2Action_Fire_CloseUnfinishedAnim'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		CloseFireAction.bNotifyTargets = true;

		Visualizer = X2VisualizerInterface(CyberusBuildTrack.VisualizeActor);
		if( Visualizer != none )
		{
			Visualizer.BuildAbilityEffectsVisualization(VisualizeGameState, CyberusBuildTrack);
		}

		class'X2Action_EnterCover'.static.AddToVisualizationTree(CyberusBuildTrack, Context);

		CodexUnit = XGUnit(CyberusBuildTrack.VisualizeActor);
		if( CodexUnit != none )
		{
			CodexPawn = CodexUnit.GetPawn();
			if( CodexPawn != none )
			{
				X2Action_SetWeapon(class'X2Action_SetWeapon'.static.AddToVisualizationTree(CyberusBuildTrack, Context)).WeaponToSet = XComWeapon(CodexPawn.Weapon);
			}
		}
		//****************************************************************************************

		//****************************************************************************************
		//Configure the visualization track for the targets
		//****************************************************************************************
		for( i = 0; i < Context.InputContext.MultiTargets.Length; ++i )
		{
			InteractingUnitRef = Context.InputContext.MultiTargets[i];
			if( InteractingUnitRef == CyberusUnit.GetReference() )
			{
				ActionMetadata = CyberusBuildTrack;
			}
			else
			{
				ActionMetadata = EmptyTrack;
				ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
				ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
				ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
			}

			if( InteractingUnitRef != CyberusUnit.GetReference() )
			{
				class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
			}

			for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
			{
				Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
			}

			TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
			if( TargetVisualizerInterface != none )
			{
				//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
				TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
			}
		}

		TypicalAbility_AddEffectRedirects(VisualizeGameState, CyberusBuildTrack);
	}
}

simulated function PACodex_PsiBombStage1_BuildAffectedVisualization(name EffectName, XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
	local XComGameStateContext_Ability Context;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit CyberusUnit;
	local XComWorldData World;
	local vector TargetLocation;
	local TTile TargetTile;
	
	if( !`XENGINE.IsMultiplayerGame() && EffectName == default.Stage1PsiBombEffectName )
	{
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		CyberusUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

		if( (Context == none) || (CyberusUnit == none) )
		{
			return;
		}

		World = `XWORLD;

		// Display the Warning FX (convert to tile and back to vector because stage 2 is at the GetPositionFromTileCoordinates coord
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		EffectAction.EffectName = "FX_Psi_Bomb.P_Psi_Bomb_Warning";

		TargetLocation = Context.InputContext.TargetLocations[0];
		TargetTile = World.GetTileCoordinatesFromPosition(TargetLocation);

		EffectAction.EffectLocation = World.GetPositionFromTileCoordinates(TargetTile);

		// Play Target Activate Sound
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CyberusFX.Cyberus_Psi_Bomb_Target_Activate';
		SoundAction.iAssociatedGameStateObjectId = CyberusUnit.ObjectID;
		SoundAction.bStartPersistentSound = true;
		SoundAction.bIsPositional = true;
		SoundAction.vWorldPosition = EffectAction.EffectLocation;
	}
}


static function X2AbilityTemplate PACodex_PsiBombStage2()
{
	local X2AbilityTemplate Template;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2Condition_UnitProperty LivingTargetCondition;
	local X2AbilityTrigger_EventListener DelayedEventListener;
	local X2Effect_ApplyWeaponDamage RiftDamageEffect;
	local X2Effect_PerkAttachForFX FXEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PACodex_PsiBombStage2');

	Template.bDontDisplayInAbilitySummary = default.PACodex_PsiBombStage2_DontDisplayInSummary;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.AbilityToHitCalc = default.DeadEye;

	LivingTargetCondition = new class'X2Condition_UnitProperty';
	LivingTargetCondition.ExcludeFriendlyToSource = default.PACodex_DoesPsiBombStage2_ExcludeFriendlyToSource;
	LivingTargetCondition.ExcludeHostileToSource = default.PACodex_DoesPsiBombStage2_ExcludeHostileToSource;
	LivingTargetCondition.ExcludeAlive = false;
	LivingTargetCondition.ExcludeDead = true;
	LivingTargetCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(LivingTargetCondition);

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PACodex_PsiBombStage1_Radius;
	RadiusMultiTarget.bIgnoreBlockingCover = default.PACodex_DoesPsiBombStage2_IgnoreBlockingCover;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.AbilityTargetStyle = default.SelfTarget;

	// This ability fires when the event DelayedExecuteRemoved fires on this unit
	DelayedEventListener = new class'X2AbilityTrigger_EventListener';
	DelayedEventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	DelayedEventListener.ListenerData.EventID = default.PsiBombTriggerName;
	DelayedEventListener.ListenerData.Filter = eFilter_Unit;
	DelayedEventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_ValidAbilityLocation;
	Template.AbilityTriggers.AddItem(DelayedEventListener);

	// This effect is here to attach perk FX to
	FXEffect = new class'X2Effect_PerkAttachForFX';
	Template.AddShooterEffect(FXEffect);

	RiftDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	RiftDamageEffect.EffectDamageValue.DamageType = 'Psi';
	RiftDamageEffect.EffectDamageValue = default.PACodex_PsiBombStage2_Damage;
	RiftDamageEffect.bIgnoreArmor = default.PACodex_DoesPsiBombStage2_IgnoreBlockingCover;
	Template.AddMultiTargetEffect(RiftDamageEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_Cyberus'.static.PsiBombStage2_BuildVisualization;
	Template.CinescriptCameraType = "Codex_PsiBomb_Stage2";
//BEGIN AUTOGENERATED CODE: Template Overrides 'PACodex_PsiBombStage2'
	Template.bFrameEvenWhenUnitIsHidden = true;
//END AUTOGENERATED CODE: Template Overrides 'PACodex_PsiBombStage2'

	return Template;
}

simulated function PACodex_PsiBombStage2_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference InteractingUnitRef;
	local X2AbilityTemplate AbilityTemplate;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata CyberusBuildTrack, ActionMetadata;
	local int i, j;
	local X2VisualizerInterface TargetVisualizerInterface;
	local XComGameState_EnvironmentDamage EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local XComGameState_InteractiveObject InteractiveObject;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit CyberusUnit;
	local X2Action_TimedInterTrackMessageAllMultiTargets MultiTargetMessageAction;
	local X2Action_TimedWait WaitAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

	//****************************************************************************************
	//Configure the visualization track for the source
	//****************************************************************************************

	CyberusBuildTrack = EmptyTrack;
	History.GetCurrentAndPreviousGameStatesForObjectID(InteractingUnitRef.ObjectID,
													   CyberusBuildTrack.StateObject_OldState, CyberusBuildTrack.StateObject_NewState,
													   eReturnType_Reference,
													   VisualizeGameState.HistoryIndex);
	CyberusBuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	CyberusUnit = XComGameState_Unit(CyberusBuildTrack.StateObject_OldState);

	if( CyberusUnit != none )
	{
		// Stop the Loop audio
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CyberusFX.Stop_CodexPsiBombLoop';
		SoundAction.iAssociatedGameStateObjectId = InteractingUnitRef.ObjectID;
		SoundAction.bIsPositional = true;
		SoundAction.bStopPersistentSound = true;

		// Stop the Warning FX
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		EffectAction.EffectName = "FX_Psi_Bomb.P_Psi_Bomb_Warning";
		EffectAction.EffectLocation = Context.InputContext.TargetLocations[0];
		EffectAction.bStopEffect = true;

		// Play the Collapsing audio
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CyberusFX.Cyberus_Ability_Psi_Bomb_Collapse';
		SoundAction.bIsPositional = true;
		SoundAction.vWorldPosition = Context.InputContext.TargetLocations[0];

		// Play the Collapse FX
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		EffectAction.EffectName = "FX_Psi_Bomb.P_Psi_Bomb_Build_Up";
		EffectAction.EffectLocation = Context.InputContext.TargetLocations[0];
		EffectAction.bWaitForCompletion = false;
		EffectAction.bWaitForCameraCompletion = false;

		// Wait to time the start of the explosion FX
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		WaitAction.DelayTimeSec = default.PSI_BOMB_STAGE1_START_WARNING_FX_SEC;

		// Play the Explosion audio
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2AvatarFX.Avatar_Ability_Dimensional_Rift_Explode';
		SoundAction.bIsPositional = true;
		SoundAction.vWorldPosition = Context.InputContext.TargetLocations[0];

		// Play the Explosion FX
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		EffectAction.EffectName = "FX_Psi_Bomb.P_Psi_Bomb_Explosion";
		EffectAction.EffectLocation = Context.InputContext.TargetLocations[0];

		// Notify multi targets of explosion
		MultiTargetMessageAction = X2Action_TimedInterTrackMessageAllMultiTargets(class'X2Action_TimedInterTrackMessageAllMultiTargets'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
		MultiTargetMessageAction.SendMessagesAfterSec = default.PSI_BOMB_STAGE2_NOTIFY_TARGETS_SEC;
	}
	//****************************************************************************************

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	for (i = 0; i < Context.InputContext.MultiTargets.Length; ++i)
	{
		InteractingUnitRef = Context.InputContext.MultiTargets[i];

		if( InteractingUnitRef == CyberusUnit.GetReference() )
		{
			ActionMetadata = CyberusBuildTrack;

			WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(CyberusBuildTrack, Context));
			WaitAction.DelayTimeSec = default.PSI_BOMB_STAGE2_NOTIFY_TARGETS_SEC;
		}
		else
		{
			ActionMetadata = EmptyTrack;
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
			ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
		}

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}
	}

	//****************************************************************************************
	//Configure the visualization tracks for the environment
	//****************************************************************************************
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.VisualizeActor = none;
		ActionMetadata.StateObject_NewState = EnvironmentDamageEvent;
		ActionMetadata.StateObject_OldState = EnvironmentDamageEvent;

		//Wait until signaled by the shooter that the projectiles are hitting
		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

		for( i = 0; i < AbilityTemplate.AbilityMultiTargetEffects.Length; ++i )
		{
			AbilityTemplate.AbilityMultiTargetEffects[i].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');	
		}

			}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.VisualizeActor = none;
		ActionMetadata.StateObject_NewState = WorldDataUpdate;
		ActionMetadata.StateObject_OldState = WorldDataUpdate;

		//Wait until signaled by the shooter that the projectiles are hitting
		class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

		for( i = 0; i < AbilityTemplate.AbilityMultiTargetEffects.Length; ++i )
		{
			AbilityTemplate.AbilityMultiTargetEffects[i].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');	
		}

			}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification
		if( InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim() && InteractiveObject.InteractionCount % 2 != 0 ) //Is this a closed door?
		{
			ActionMetadata = EmptyTrack;
			//Don't necessarily have a previous state, so just use the one we know about
			ActionMetadata.StateObject_OldState = InteractiveObject;
			ActionMetadata.StateObject_NewState = InteractiveObject;
			ActionMetadata.VisualizeActor = History.GetVisualizer(InteractiveObject.ObjectID);
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);
			class'X2Action_BreakInteractActor'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

					}
	}

	TypicalAbility_AddEffectRedirects(VisualizeGameState, CyberusBuildTrack);
}